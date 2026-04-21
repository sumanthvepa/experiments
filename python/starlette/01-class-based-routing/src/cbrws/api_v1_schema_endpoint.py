"""
  api_v1_schema_endpoint.py: URL handler for the /profiles/cbrws/v1
  URL of the cbrws web service.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, override

from starlette.requests import Request

from cbrws.template_endpoint import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.schema_endpoint import SchemaEndpoint
from cbrws.url_util import public_url_for
if TYPE_CHECKING:
  from cbrws.service_endpoint import ServiceEndpoint


class APIV1SchemaEndpoint(SchemaEndpoint):
  """
    Endpoint for the /profiles/cbrws/v1 URL of the cbrws web service.
     This endpoint describes the concrete v1 CBRWS API profile.
     It is the schema class for the service class APIEndpoint
  """
  @override
  @classmethod
  def service_class(cls) -> type[ServiceEndpoint]:
    # pylint: disable=import-outside-toplevel
    from cbrws.api_endpoint import APIEndpoint
    return APIEndpoint

  @override
  @classmethod
  def schema_title(cls) -> str:
    return 'CBRWS API v1 Schema'

  @override
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    # pylint: disable=import-outside-toplevel
    from cbrws.api_endpoint import APIEndpoint
    from cbrws.cbrws_directory_endpoint import CBRWSDirectoryEndpoint
    from cbrws.greeting_endpoint import GreetingEndpoint
    from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
    from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
    relations_directory_url = public_url_for(
      request, RelationsDirectoryEndpoint.route_name())
    return {
      'title': cls.schema_title(),
      'schema_url': public_url_for(request, cls.route_name()),
      'cbrws_directory_url': public_url_for(
        request, CBRWSDirectoryEndpoint.route_name()),
      'api_url': public_url_for(request, APIEndpoint.route_name()),
      'api_media_type': APIEndpoint.default_response_media_type(),
      'greeting_url': public_url_for(request, GreetingEndpoint.route_name()),
      'greeting_relation_url': public_url_for(
        request, GreetingSchemaEndpoint.route_name()),
      'relations_directory_url': relations_directory_url,
      'curie_href_template': (
        relations_directory_url.rstrip('/') + '/{rel}')
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('api-v1-schema.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('api-v1-schema.json')
