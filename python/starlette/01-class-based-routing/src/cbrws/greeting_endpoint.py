"""
  greeting_endpoint.py: URL handler for the /api/greeting URL of the
  cbrws web service.
"""
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.service_endpoint import ServiceEndpoint
from cbrws.url_util import public_url_for


class GreetingEndpoint(ServiceEndpoint):
  """
    A URL handler for the /api/greeting URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.
  """

  # noinspection PyMethodMayBeStatic
  async def get(self, request: Request) -> JSONResponse:
    """
      Handle GET requests to the /api/greeting endpoint.
      :param request: The HTTP request
      :return: A JSON response with the greeting resource
    """
    cls = type(self)
    media_type = select_media_type(
      request.headers.get('accept'),
      cls.supported_media_types())
    if media_type is None:
      return cls.not_acceptable(request)

    message = {
      'message': 'Hello, world!',
      '_links': {
        'self': {
          'href': public_url_for(request, 'greeting_endpoint'),
          'type': cls.response_media_type(),
          'profile': public_url_for(request, 'greeting_relation_endpoint')
        },
        'up': {
          'href': public_url_for(request, 'api_endpoint'),
          'type': cls.response_media_type(),
          'profile': ServiceEndpoint.schema_url(request)
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=cls.response_media_type(),
      headers=cls.headers(request))
