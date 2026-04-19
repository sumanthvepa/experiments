"""
  api_endpoint.py: URL handler for the /api URL of the cbrws
  web service.
"""
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.service_endpoint import ServiceEndpoint
from cbrws.url_util import public_url_for


class APIEndpoint(ServiceEndpoint):
  """
    A URL handler for the /api URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.
  """

  # noinspection PyMethodMayBeStatic
  async def get(self, request: Request) -> JSONResponse:
    """
      Handle GET requests to the /api endpoint.
      :param request: The HTTP request
      :return: A JSON response with API information
    """
    cls = type(self)
    media_type = select_media_type(
      request.headers.get('accept'),
      cls.supported_media_types())
    if media_type is None:
      return cls.not_acceptable(request)

    message = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': public_url_for(request, 'api_endpoint'),
          'type': cls.response_media_type(),
          'profile': ServiceEndpoint.schema_url(request)
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': public_url_for(request, 'relations_endpoint') + '{rel}',
            'templated': True,
            'type': ServiceEndpoint.schema_media_type(),
            'profile': ServiceEndpoint.schema_url(request)
          }
        ],
        'cbrws:greeting': {
          'href': public_url_for(request, 'greeting_endpoint'),
          'type': cls.response_media_type(),
          'profile': public_url_for(request, 'greeting_relation_endpoint')
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=cls.response_media_type(),
      headers=cls.headers(request))
