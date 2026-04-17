"""
  relations_endpoint.py: URL handler for the /profiles/cbrws/v1/rels/
  URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint_base import LinkHeaderItem, LinkHeaderItems
from cbrws.profile_endpoint_base import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.profile_schema_endpoint import LiteralContext, ProfileSchemaEndpoint


class RelationsEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/ URL of the cbrws
    web service.

    For the GET request it returns either text/html or
    application/schema+json depending on the Accept header.
  """
  RELATIONS_PATH = '/profiles/cbrws/v1/rels/'
  URL_CONTEXT = {
    'profile_url': 'profile_endpoint',
    'relations_url': 'relations_endpoint',
    'greeting_relation_url': 'greeting_relation_endpoint'
  }

  @classmethod
  def literal_context(cls) -> LiteralContext:
    """
      Return literal template context values for the endpoint.
      :return: A dictionary of template variables
    """
    return {
      'title': 'CBRWS v1 Relations'
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('relations-v1.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('relations-v1.json')

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
        type=ProfileSchemaEndpoint.response_media_type(),
        title='JSON schema of the response'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='documentation',
        type='text/html',
        title='Documentation for the cbrws web service API')
    )
