"""
  api_endpoint.py: URL handler for the /api URL of the cbrws
  web service.
"""
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint
from cbrws.url_util import make_url


class APIEndpoint(CBRWSBaseEndpoint):
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
    media_type = select_media_type(
      request.headers.get('accept'),
      self.SUPPORTED_MEDIA_TYPES)
    if media_type is None:
      return CBRWSBaseEndpoint.not_acceptable(request, self.SUPPORTED_MEDIA_TYPES)

    message = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': make_url(request, 'api'),
          'type': CBRWSBaseEndpoint.response_media_type(request),
          'profile': CBRWSBaseEndpoint.profile_url(request)
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': make_url(request, 'profiles/cbrws/v1/rels/{rel}'),
            'templated': True,
            'media_type': CBRWSBaseEndpoint.schema_media_type(),
            'profile': CBRWSBaseEndpoint.profile_url(request)
          }
        ],
        'cbrws:greeting': {
          'href': make_url(request, 'api/greeting'),
          'rel': 'greeting',
          'media_type': CBRWSBaseEndpoint.response_media_type(request),
          'profile': make_url(request, 'profiles/cbrws/v1/rels/greeting')
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=CBRWSBaseEndpoint.response_media_type(request),
      headers=CBRWSBaseEndpoint.headers(request))
