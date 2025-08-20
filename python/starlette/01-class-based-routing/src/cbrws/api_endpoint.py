"""
  api_endpoint.py: URL handler for the /api URL of the cbrws
  web service.
"""
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, Response
from starlette import status

from cbrws.api_base_endpoint import APIBaseEndpoint
from cbrws.url_util import make_url


class APIEndpoint(APIBaseEndpoint):
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
        headers=APIBaseEndpoint.headers(request))

    message = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': make_url(request, 'api'),
          'type': APIBaseEndpoint.response_media_type(request),
          'profile': APIBaseEndpoint.profile_url(request)
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': make_url(request, 'profiles/cbrws/v1/rels/{rel}'),
            'templated': True,
            'media_type': APIBaseEndpoint.schema_media_type(),
            'profile': APIBaseEndpoint.profile_url(request)
          }
        ],
        'cbrws:greeting': {
          'href': make_url(request, 'api/greeting'),
          'rel': 'greeting',
          'media_type': APIBaseEndpoint.response_media_type(request),
          'profile': APIBaseEndpoint.profile_url(request)
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=APIBaseEndpoint.response_media_type(request),
      headers=APIBaseEndpoint.headers(request))
