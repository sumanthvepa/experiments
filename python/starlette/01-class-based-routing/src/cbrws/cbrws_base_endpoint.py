"""
  cbrws_base_endpoint.py: Base class for API endpoints in the cbrws
  web service.
"""
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, Response
from starlette import status

from cbrws.url_util import make_url


class CBRWSBaseEndpoint(HTTPEndpoint):
  """
  A base class for the API endpoints (/ and /api) in the cbrws
  web service.

  This class provides common functionality for API endpoints
  / and /api, such as generating profile URLs and handling
  common response structures. It is not intended to be used
  directly, but rather as a base class for RootEndpoint and
  APIEndpoint classes.
  """

  PROFILE_PATH = '/profiles/cbrws/v1'

  @staticmethod
  def profile_url(request: Request) -> str:
    """
      Generate the profile URL for the cbrws web service.
      :param request: The HTTP request
      :return: A string representing the profile URL
    """
    return make_url(request, CBRWSBaseEndpoint.PROFILE_PATH)

  @staticmethod
  def schema_url(request: Request) -> str:
    """
      Generate the schema URL for the cbrws web service.
      :param request: The HTTP request
      :return: A string representing the schema URL
    """
    return CBRWSBaseEndpoint.profile_url(request) + '/api.schema'

  @staticmethod
  def response_media_type(request: Request) -> str:
    """
      Generate the media type for the cbrws web service.
      :param request: The HTTP request
      :return: A string representing the media type
    """
    return f'application/hal+json; profile="{CBRWSBaseEndpoint.profile_url(request)}"'

  @staticmethod
  def schema_media_type() -> str:
    """
      Generate the media type for the schema of the cbrws web service.
      :return: A string representing the schema media type
    """
    return f'application/schema+json'

  @staticmethod
  def problem_media_type() -> str:
    """
      Generate the media type for problem details in the cbrws web service.
      :return: A string representing the problem media type
    """
    return 'application/problem+json'

  @staticmethod
  def headers(request: Request) -> dict[str, str]:
    """
      Generate common headers for API responses.
      :param request: The HTTP request
      :return: A dictionary of headers
    """
    return {
      'Allow': 'GET, HEAD, OPTIONS',
      'Link': f'<{CBRWSBaseEndpoint.profile_url(request)}>; rel="profile"; ' +
              'type="application/ld+json"; ' +
              'title="API version identifier(URI) for the cbrws web service", ' +
              f'{CBRWSBaseEndpoint.schema_url(request)}>; rel="describedBy"; ' +
              'type="application/schema+json"; ' +
              'title="JSON schema of the response", ' +
              f'<{CBRWSBaseEndpoint.schema_url(request)}>; rel="documentation"; ' +
              'type="text/html"; ' +
              'title="Documentation for the cbrws web service API"'
    }

  @staticmethod
  def not_acceptable(request: Request, supported_media_types: list[str]) -> JSONResponse:
    """
      Generate a 415 Unsupported Media Type response.
      :param request: The HTTP request
      :param supported_media_types: A list of supported media types
      :return: A JSONResponse with problem details
    """
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
      'title': 'Not Acceptable',
      'status': status.HTTP_406_NOT_ACCEPTABLE,
      'detail': 'The requested media type is not supported by this endpoint. ' +
                'Supported media types are: ' + ', '.join(supported_media_types),
      'supportedMediaTypes': supported_media_types
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_406_NOT_ACCEPTABLE,
      media_type=CBRWSBaseEndpoint.problem_media_type(),
      headers=CBRWSBaseEndpoint.headers(request))

  # noinspection PyMethodMayBeStatic, PyUnusedLocal
  async def options(self, request: Request) -> Response:
    """
      Handle OPTIONS requests for the root URL.
      :param request:
      :return: A 204 No Content response with appropriate headers
    """
    return Response(
      status_code=status.HTTP_204_NO_CONTENT,
      headers=CBRWSBaseEndpoint.headers(request))

  async def method_not_allowed(self, request: Request) -> JSONResponse:
    """
      Handle methods that are not allowed for the root URL.
      :param request:
      :return:
    """
    # The error response conforms to RFC 7807 (Problem Details for HTTP APIs)
    # https://datatracker.ietf.org/doc/html/rfc7807
    # The type URI is a unique identifier for the error type,
    # I used the MDN documentation link for Method Not Allowed
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405
    # as the unique identifier.
    # The list of allowed methods is provided in the Allow header.
    # This is a common practice to inform the client about the allowed methods
    # for the resource.
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405',
      'title': 'Method Not Allowed',
      'status': status.HTTP_405_METHOD_NOT_ALLOWED,
      # pylint: disable=line-too-long
      'detail': 'The requested method is not allowed for this resource. See the Allow header for allowed methods.',
      'allowedMethods': ['GET', 'HEAD', 'OPTIONS']
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
      media_type='application/problem+json',
      headers=CBRWSBaseEndpoint.headers(request))
