"""
  greeting_endpoint.py: URL handler for the /api/greeting URL of the
  cbrws web service.
"""
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint
from cbrws.url_util import make_url


class GreetingEndpoint(CBRWSBaseEndpoint):
  """
    A URL handler for the /api/greeting URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.
  """
  SUPPORTED_MEDIA_TYPES = ['application/hal+json', '*/*']

  # noinspection PyMethodMayBeStatic
  async def get(self, request: Request) -> JSONResponse:
    """
      Handle GET requests to the /api/greeting endpoint.
      :param request: The HTTP request
      :return: A JSON response with the greeting resource
    """
    accept = request.headers.get('accept', '*/*')
    if not any(media_type in accept for media_type in self.SUPPORTED_MEDIA_TYPES):
      return CBRWSBaseEndpoint.not_acceptable(request, self.SUPPORTED_MEDIA_TYPES)

    message = {
      'message': 'Hello, world!',
      '_links': {
        'self': {
          'href': make_url(request, 'api/greeting'),
          'type': CBRWSBaseEndpoint.response_media_type(request),
          'profile': make_url(request, 'profiles/cbrws/v1/rels/greeting')
        },
        'up': {
          'href': make_url(request, 'api'),
          'type': CBRWSBaseEndpoint.response_media_type(request),
          'profile': CBRWSBaseEndpoint.profile_url(request)
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=CBRWSBaseEndpoint.response_media_type(request),
      headers=CBRWSBaseEndpoint.headers(request))
