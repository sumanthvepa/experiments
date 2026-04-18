"""
  greeting_documentation_endpoint.py: URL handler for the
  /profiles/cbrws/v1/rels/greeting URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint import LinkHeaderItem, LinkHeaderItems
from cbrws.documentation_endpoint import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.schema_endpoint import LiteralContext, SchemaEndpoint

from cbrws.greeting_endpoint import GreetingEndpoint


class GreetingDocumentationEndpoint(SchemaEndpoint):
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

  @classmethod
  def literal_context(cls) -> LiteralContext:
    """
      Return literal template context values for the endpoint.
      :return: A dictionary of template variables
    """
    return {
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
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='profile',
        type='application/ld+json',
        title='API version identifier(URI) for the cbrws web service'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='describedBy',
        type=cls.response_media_type(),
        title='JSON schema of the response'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='documentation',
        type='text/html',
        title='Documentation for the cbrws web service API')
    )

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the greeting relation profile.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    context = super().context(request)
    context['resource_media_type'] = GreetingEndpoint.response_media_type()
    return context
