"""
  greeting_relation_profile_endpoint.py: URL handler for the
  /profiles/cbrws/v1/rels/greeting URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint_base import LinkHeaderItems
from cbrws.profile_endpoint_base import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.profile_schema_endpoint import ProfileSchemaEndpoint


class GreetingRelationProfileEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/greeting URL of the
    cbrws web service.

    This endpoint describes the cbrws:greeting relation.
  """
  URL_CONTEXT = {
    'profile_url': 'profile_endpoint',
    'relations_url': 'relations_endpoint',
    'relation_url': 'greeting_relation_endpoint',
    'resource_url': 'greeting_endpoint'
  }
  LITERAL_CONTEXT = {
    'title': 'CBRWS V1 Greeting Relation'
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

  @classmethod
  def link_header_items(cls, request: Request) -> LinkHeaderItems:
    """
      Generate Link header item definitions.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      {
        'route_name': 'profile_endpoint',
        'rel': 'profile',
        'type': 'application/ld+json',
        'title': 'API version identifier(URI) for the cbrws web service'
      },
      {
        'route_name': 'profile_endpoint',
        'rel': 'describedBy',
        'type': ProfileSchemaEndpoint.response_media_type(),
        'title': 'JSON schema of the response'
      },
      {
        'route_name': 'profile_endpoint',
        'rel': 'documentation',
        'type': 'text/html',
        'title': 'Documentation for the cbrws web service API'
      }
    )

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the greeting relation profile.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    context = super().context(request)
    context['resource_media_type'] = 'application/hal+json'
    return context
