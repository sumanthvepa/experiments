"""
  profile_endpoint_base.py: Base class for profile URLs in the cbrws
  web service.
"""
from pathlib import Path
from typing import Any, override
import json

import aiofiles
from jinja2 import Template
from starlette import status
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response

from cbrws.url_util import make_url


class ProfileEndpointBase(HTTPEndpoint):
  """
    A base class for profile URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or the configured
    JSON media type depending on the Accept header of the request.
  """
  HTML_FILENAME = ''
  JSON_FILENAME = ''
  RESPONSE_MEDIA_TYPE = ''
  SUPPORTED_MEDIA_TYPES = ['text/html', '*/*']
  SCHEMA_DIR = Path(__file__).resolve().parent / 'schemas'
  URL_CONTEXT: dict[str, str] = {}
  LINK_HEADER_ITEMS: tuple[dict[str, str], ...] = ()

  @staticmethod
  async def load_file(filename: str, context: dict[str, str]) -> str:
    """
      Load a file from the filesystem.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: The content of the file as a string
    """
    async with aiofiles.open(filename, mode='r', encoding='utf-8') as file:
      template = await file.read()
      content = Template(template).render(context)
      return content

  @classmethod
  async def load_json(cls, filename: str, context: dict[str, str]) -> dict[str, Any]:
    """
      Load a JSON document from a file.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: A dictionary representing the JSON document
    """
    content = await cls.load_file(filename, context)
    data = json.loads(content)
    assert isinstance(data, dict)
    assert all(isinstance(k, str) for k in data.keys())
    return data

  @classmethod
  def json_filename(cls) -> str:
    """
      Generate the filename for the JSON response.
      :return: The JSON filename
    """
    return cls.JSON_FILENAME

  @classmethod
  def response_media_type(cls) -> str:
    """
      Generate the media type for the profile response.
      :return: A string representing the media type
    """
    return cls.RESPONSE_MEDIA_TYPE

  @staticmethod
  def problem_media_type() -> str:
    """
      Generate the media type for problem details.
      :return: A string representing the problem media type
    """
    return 'application/problem+json'

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the profile response.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    return {
      key: make_url(request, path)
      for key, path in cls.URL_CONTEXT.items()
    }

  @classmethod
  def link_header(cls, request: Request) -> str:
    """
      Generate the Link header value for profile responses.
      :param request: The HTTP request
      :return: The Link header value
    """
    links: list[str] = []
    for item in cls.LINK_HEADER_ITEMS:
      link = f'<{make_url(request, item["path"])}>; rel="{item["rel"]}"'
      if 'type' in item:
        link += f'; type="{item["type"]}"'
      if 'title' in item:
        link += f'; title="{item["title"]}"'
      links.append(link)
    return ', '.join(links)

  @classmethod
  def headers(cls, request: Request) -> dict[str, str]:
    """
      Generate common headers for profile responses.
      :param request: The HTTP request
      :return: A dictionary of headers
    """
    headers = {'Allow': 'GET, HEAD, OPTIONS'}
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

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the profile endpoint.
      :param request: The HTTP request
      :return: A Response with HTML content
    """
    cls = type(self)
    content = await cls.load_file(
      str(cls.SCHEMA_DIR / cls.HTML_FILENAME),
      cls.context(request))
    return HTMLResponse(
      content,
      status_code=status.HTTP_200_OK,
      media_type='text/html',
      headers=cls.headers(request))

  async def json_response(self, request: Request) -> JSONResponse:
    """
      Generate a JSON response for the profile endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with JSON content
    """
    cls = type(self)
    content = await cls.load_json(
      str(cls.SCHEMA_DIR / cls.json_filename()),
      cls.context(request))
    return JSONResponse(
      content,
      status_code=status.HTTP_200_OK,
      media_type=cls.response_media_type(),
      headers=cls.headers(request))

  async def get(self, request: Request) -> Response:
    """
      Handle GET requests to the profile endpoint.
      :param request: The HTTP request
      :return: A Response with either HTML or JSON content
    """
    cls = type(self)
    accept = request.headers.get('accept', '*/*')
    if 'text/html' in accept:
      return await self.html_response(request)
    if cls.response_media_type() in accept or '*/*' in accept:
      return await self.json_response(request)
    return cls.not_acceptable(request)

  async def head(self, request: Request) -> Response:
    """
      Handle HEAD requests to the profile endpoint.
      :param request: The HTTP request
      :return: A Response with headers only
    """
    cls = type(self)
    accept = request.headers.get('accept', '*/*')
    if 'text/html' in accept:
      return Response(
        status_code=status.HTTP_200_OK,
        media_type='text/html',
        headers=cls.headers(request))
    if cls.response_media_type() in accept or '*/*' in accept:
      return Response(
        status_code=status.HTTP_200_OK,
        media_type=cls.response_media_type(),
        headers=cls.headers(request))
    return cls.not_acceptable(request)

  async def options(self, request: Request) -> Response:
    """
      Handle OPTIONS requests for the profile endpoint.
      :param request: The HTTP request
      :return: A 204 No Content response with appropriate headers
    """
    return Response(
      status_code=status.HTTP_204_NO_CONTENT,
      headers=type(self).headers(request))

  @override
  async def method_not_allowed(self, request: Request) -> JSONResponse:
    """
      Handle methods that are not allowed for the profile endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with problem details
    """
    cls = type(self)
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405',
      'title': 'Method Not Allowed',
      'status': status.HTTP_405_METHOD_NOT_ALLOWED,
      'detail': 'The requested method is not allowed for this resource. ' +
                'See the Allow header for allowed methods.',
      'allowedMethods': ['GET', 'HEAD', 'OPTIONS']
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
      media_type=cls.problem_media_type(),
      headers=cls.headers(request))
