"""
  api_endpoint.py: URL handler for the /api URL of the cbrws
  web service.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, override

from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.service_endpoint import ServiceEndpoint
from cbrws.url_util import public_url_for
if TYPE_CHECKING:
  from cbrws.schema_endpoint import SchemaEndpoint


class APIEndpoint(ServiceEndpoint):
  """
    A URL handler for the /api URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.
  """

  @override
  @classmethod
  def schema_class(cls) -> type[SchemaEndpoint]:
    # pylint: disable=import-outside-toplevel
    from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
    return APIV1SchemaEndpoint

  # noinspection PyMethodMayBeStatic
  async def get(self, request: Request) -> JSONResponse:
    """
      Handle GET requests to the /api endpoint.
      :param request: The HTTP request
      :return: A JSON response with API information
    """
    # pylint: disable=import-outside-toplevel
    from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
    from cbrws.greeting_endpoint import GreetingEndpoint

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
          'href': public_url_for(request, self.route_name()),
          'type': self.default_response_media_type(),
          'profile': public_url_for(request, self.schema_class().route_name())
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': public_url_for(
              request, RelationsDirectoryEndpoint.route_name()).strip('/') + '/{rel}',
            'templated': True
          }
        ],
        'cbrws:greeting': {
          'href': public_url_for(request, GreetingEndpoint.route_name()),
          'type': GreetingEndpoint.default_response_media_type(),
          'profile': public_url_for(request, GreetingEndpoint.schema_class().route_name())
        }
      }
    }
    return JSONResponse(
      content=message,
      status_code=status.HTTP_200_OK,
      media_type=cls.default_response_media_type(),
      headers=cls.headers(request))
