"""
  root_endpoint.py: URL handler for the root URL of the cbrws
  web service.
"""
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, RedirectResponse, Response
from starlette import status

from cbrws.url_util import make_url


class RootEndpoint(HTTPEndpoint):
  """
    A URL handler for the root URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    This is a class based routing endpoint. The class
    handles all requests to the root URL ('/') of the web service.

    As a matter of convention, all web services should provide
    actual service at the /api endpoint. The root URL should
    always redirect to the /api endpoint.
  """
  # noinspection PyMethodMayBeStatic,PyUnusedLocal
  async def get(
        self, request: Request) -> RedirectResponse:  # pylint: disable=unused-argument
    """
      Redirect GET requests to the API endpoint.
      :param request: The HTTP request
      :return: A 308 Permanent Redirect response
    """
    return RedirectResponse(
      url='/api', status_code=status.HTTP_308_PERMANENT_REDIRECT)

  # noinspection PyMethodMayBeStatic, PyUnusedLocal
  async def options(
        self, request: Request) -> Response:  # pylint: disable=unused-argument
    """
      Handle OPTIONS requests for the root URL.
      :param request:
      :return: A 204 No Content response with appropriate headers
    """
    profile_url = make_url(request, 'profiles/cbrws/v1')
    schema_url = profile_url + '/api.schema'
    media_type = f'application/hal+json; profile="{profile_url}"'

    headers = {
      'Allow': 'GET, HEAD, OPTIONS',
      'Link': f'<{profile_url}>; rel="profile"; ' +
              'type="application/ld+json"; ' +
              'title="API version identifier(URI) for the cbrws web service", ' +
              f'{schema_url}>; rel="describedBy"; ' +
              'type="application/schema+json"; ' +
              'title="JSON schema of the response", ' +
              f'<{schema_url}>; rel="documentation"; ' +
              'type="text/html"; ' +
              'title="Documentation for the cbrws web service API"'
    }
    return Response(
      status_code=status.HTTP_204_NO_CONTENT,
      headers=headers)

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
      headers={'Allow': 'GET, HEAD, OPTIONS'})
