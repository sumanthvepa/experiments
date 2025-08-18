"""
  api_endpoint.py: URL handler for the /api URL of the cbrws
  web service.
"""
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, Response
from starlette import status

from cbrws.url_util import make_url


class APIEndpoint(HTTPEndpoint):
  """
    A URL handler for the /api URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.
  """
  SUPPORTED_MEDIA_TYPES = ['application/hal+json', '*/*']

  # noinspection PyMethodMayBeStatic
  async def get(self, request: Request) -> JSONResponse:
    """
      Handle GET requests to the /api endpoint.
      :param request: The HTTP request
      :return: A JSON response with API information
    """
    profile_url = make_url(request, 'profiles/cbrws/v1')
    schema_url = profile_url + '/api.schema'
    media_type = f'application/hal+json; profile="{profile_url}"'

    headers = {
      'Allow': 'GET, HEAD, OPTIONS',
      # pylint: disable=line-too-long
      # noinspection PyLineTooLong
      'Link': f'<{profile_url}>; rel="profile"; type="application/ld+json"; title="API version identifier(URI) for the cbrws web service", ' +
              f'{schema_url}>; rel="describedBy"; type="application/schema+json"; title="JSON schema of the response", ' +
              f'<{schema_url}>; rel="documentation"; type="text/html"; title="Documentation for the cbrws web service API"'
    }

    # Content negotiation
    # Check if the request's Accept header includes a supported media type
    # If not, return a 406 Not Acceptable response
    accept = request.headers.get('accept', '*/*')
    if not any(media_type in accept for media_type in self.SUPPORTED_MEDIA_TYPES):
      error = {
        'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
        'title': 'Not Acceptable',
        'status': status.HTTP_406_NOT_ACCEPTABLE,
        # pylint: disable=line-too-long
        'detail': 'The requested media type is not supported by this endpoint. ' +
                  'Supported media types are: ' + ', '.join(self.SUPPORTED_MEDIA_TYPES),
        'supportedMediaTypes': self.SUPPORTED_MEDIA_TYPES
      }
      return JSONResponse(
        error,
        status_code=status.HTTP_406_NOT_ACCEPTABLE,
        media_type='application/problem+json',
        headers=headers)

    message = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': make_url(request, 'api'),
          'type': 'application/hal+json',
          'profile': profile_url
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': make_url(request, 'profiles/cbrws/v1/rels/{rel}'),
            'templated': True,
            'media_type': 'application/schema+json',
            'profile': profile_url
          }
        ],
        'cbrws:greeting': {
          'href': make_url(request, 'api/greeting'),
          'rel': 'greeting',
          'media_type': 'application/hal+json',
          'profile': profile_url
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=media_type,
      headers=headers)

  # noinspection PyMethodMayBeStatic
  async def options(self, request: Request) -> Response:
    """
    Handle OPTIONS requests to the /api endpoint.
    :param request:
    :return:
    """
    profile_url = make_url(request, 'profiles/cbrws/v1')
    schema_url = profile_url + '/api.schema'

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
