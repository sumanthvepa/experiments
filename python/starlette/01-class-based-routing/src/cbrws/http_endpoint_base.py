"""
  http_endpoint_base.py: Common base class for cbrws HTTP endpoints.
"""
import logging
from typing import override

from starlette import status
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from cbrws.url_util import public_url_for


logger = logging.getLogger('cbrws.http')


class HTTPEndpointBase(HTTPEndpoint):
  """
    A base class for common HTTP endpoint behavior in the cbrws web service.
  """
  ALLOWED_METHODS = ['GET', 'HEAD', 'OPTIONS']
  SUPPORTED_MEDIA_TYPES: list[str] = []
  LINK_HEADER_ITEMS: tuple[dict[str, str], ...] = ()

  @staticmethod
  def problem_media_type() -> str:
    """
      Generate the media type for problem details.
      :return: A string representing the problem media type
    """
    return 'application/problem+json'

  @classmethod
  def allow_header(cls) -> str:
    """
      Generate the Allow header value.
      :return: A comma-separated list of allowed HTTP methods
    """
    return ', '.join(cls.ALLOWED_METHODS)

  @classmethod
  def link_header_items(cls, request: Request) -> tuple[dict[str, str], ...]:
    """
      Generate Link header item definitions.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return cls.LINK_HEADER_ITEMS

  @classmethod
  def link_header(cls, request: Request) -> str:
    """
      Generate the Link header value for endpoint responses.
      :param request: The HTTP request
      :return: The Link header value
    """
    links: list[str] = []
    for item in cls.link_header_items(request):
      url = public_url_for(request, item['route_name'])
      link = f'<{url}>; rel="{item["rel"]}"'
      if 'type' in item:
        link += f'; type="{item["type"]}"'
      if 'title' in item:
        link += f'; title="{item["title"]}"'
      links.append(link)
    return ', '.join(links)

  @classmethod
  def headers(cls, request: Request) -> dict[str, str]:
    """
      Generate common headers for endpoint responses.
      :param request: The HTTP request
      :return: A dictionary of headers
    """
    headers = {'Allow': cls.allow_header()}
    link_header = cls.link_header(request)
    if link_header:
      headers['Link'] = link_header
    return headers

  @classmethod
  def not_acceptable(cls, request: Request) -> JSONResponse:
    """
      Generate a 406 Not Acceptable response.
      :param request: The HTTP request
      :return: A JSONResponse with problem details
    """
    logger.info(
      'not acceptable method=%s path=%s accept=%s supported=%s',
      request.method,
      request.url.path,
      request.headers.get('accept', ''),
      ','.join(cls.SUPPORTED_MEDIA_TYPES))
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
      'title': 'Not Acceptable',
      'status': status.HTTP_406_NOT_ACCEPTABLE,
      'detail': 'The requested media type is not supported by this endpoint. ' +
                'Supported media types are: ' + ', '.join(cls.SUPPORTED_MEDIA_TYPES),
      'supportedMediaTypes': cls.SUPPORTED_MEDIA_TYPES
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_406_NOT_ACCEPTABLE,
      media_type=cls.problem_media_type(),
      headers=cls.headers(request))

  async def options(self, request: Request) -> Response:
    """
      Handle OPTIONS requests for the endpoint.
      :param request: The HTTP request
      :return: A 204 No Content response with appropriate headers
    """
    return Response(
      status_code=status.HTTP_204_NO_CONTENT,
      headers=type(self).headers(request))

  @override
  async def method_not_allowed(self, request: Request) -> JSONResponse:
    """
      Handle methods that are not allowed for the endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with problem details
    """
    cls = type(self)
    logger.warning(
      'method not allowed method=%s path=%s allowed=%s',
      request.method,
      request.url.path,
      cls.allow_header())
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405',
      'title': 'Method Not Allowed',
      'status': status.HTTP_405_METHOD_NOT_ALLOWED,
      'detail': 'The requested method is not allowed for this resource. ' +
                'See the Allow header for allowed methods.',
      'allowedMethods': cls.ALLOWED_METHODS
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
      media_type=cls.problem_media_type(),
      headers=cls.headers(request))
