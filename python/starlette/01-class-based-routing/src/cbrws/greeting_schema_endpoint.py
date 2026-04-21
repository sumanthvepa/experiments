"""
  greeting_schema_endpoint.py: URL handler for the
  /profiles/cbrws/v1/rels/greeting URL of the cbrws web service.
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


class GreetingSchemaEndpoint(SchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/greeting URL of the
    cbrws web service.

    This endpoint describes the cbrws:greeting relation.
  """

  @override
  @classmethod
  def service_class(cls) -> type[ServiceEndpoint]:
    # pylint: disable=import-outside-toplevel
    from cbrws.greeting_endpoint import GreetingEndpoint
    return GreetingEndpoint

  @override
  @classmethod
  def schema_title(cls) -> str:
    return "CBRWS V1 Greeting Schema"

  @override
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
    Return the template context for the endpoint.
    :param request:
    :return:
    """
    # Imports are placed here to avoid circular import issues
    # pylint still detects a circular import, but it does not
    # occur in practice, because the imports happen at runtime,
    # not at the module level.
    # pylint: disable=cyclic-import, import-outside-toplevel
    from cbrws.api_endpoint import APIEndpoint
    from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
    return {
      'title': cls.schema_title(),
      'description': 'Schema for the /api/greeting response',
      'parent_url': public_url_for(request, RelationsDirectoryEndpoint.route_name()),
      'schema_url': public_url_for(request, cls.route_name()),
      'service_url': public_url_for(request, cls.service_class().route_name()),
      'service_media_type': cls.service_class().default_response_media_type(),
      'api_url': public_url_for(request, APIEndpoint.route_name()),
      'api_schema_url': public_url_for(request, APIEndpoint.schema_class().route_name())
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('greeting-rel-v1.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('greeting-rel-v1.json')
