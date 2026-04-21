"""
  greeting_endpoint.py: URL handler for the /api/greeting URL of the
  cbrws web service.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, Any, override

from starlette.requests import Request

from cbrws.api_endpoint import APIEndpoint
from cbrws.service_endpoint import ServiceEndpoint
from cbrws.url_util import public_url_for
if TYPE_CHECKING:
  from cbrws.schema_endpoint import SchemaEndpoint


class GreetingEndpoint(ServiceEndpoint):
  """
    A URL handler for the /api/greeting URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.
  """
  @classmethod
  def schema_class(cls) -> type[SchemaEndpoint]:
    """
    The schema class of the greeting endpoint is the
    GreetingSchemaEndpoint class
    :return: The schema class of the greeting endpoint.
    """
    # pylint: disable=import-outside-toplevel
    from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
    return GreetingSchemaEndpoint

  @override
  def response_document(self, request: Request) -> dict[str, Any]:
    """
      Build the HAL document for the /api/greeting endpoint.
      :param request: The HTTP request
      :return: The greeting resource document
    """
    cls = type(self)
    return {
      'message': 'Hello, world!',
      '_links': {
        'self': {
          'href': public_url_for(request, self.route_name()),
          'type': cls.default_response_media_type(),
          'profile': public_url_for(request, self.schema_class().route_name())
        },
        'up': {
          'href': public_url_for(request, APIEndpoint.route_name()),
          'type': cls.default_response_media_type(),
          'profile': public_url_for(request, APIEndpoint.schema_class().route_name())
        }
      }
    }
