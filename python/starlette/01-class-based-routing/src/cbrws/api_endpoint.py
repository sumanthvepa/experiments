"""
  api_endpoint.py: URL handler for the /api URL of the cbrws
  web service.
"""
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint


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
      return type(self).not_acceptable(request)
    cls = type(self)

    message = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': str(request.url_for('api_endpoint')),
          'type': cls.response_media_type(),
          'profile': CBRWSBaseEndpoint.profile_url(request)
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': str(request.url_for('relations_endpoint')) + '{rel}',
            'templated': True,
            'media_type': CBRWSBaseEndpoint.schema_media_type(),
            'profile': CBRWSBaseEndpoint.profile_url(request)
          }
        ],
        'cbrws:greeting': {
          'href': str(request.url_for('greeting_endpoint')),
          'rel': 'greeting',
          'media_type': cls.response_media_type(),
          'profile': str(request.url_for('greeting_relation_endpoint'))
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=cls.response_media_type(),
      headers=cls.headers(request))
