"""
  greeting_relation_profile_endpoint.py: URL handler for the
  /profiles/cbrws/v1/rels/greeting URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.profile_schema_endpoint import ProfileSchemaEndpoint
from cbrws.url_util import make_url


class GreetingRelationProfileEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/greeting URL of the
    cbrws web service.

    This endpoint describes the cbrws:greeting relation.
  """
  HTML_FILENAME = 'greeting-rel-v1.jinja2'
  SCHEMA_FILENAME = 'greeting-rel-v1.json'
  URL_CONTEXT = {
    'profile_url': 'profiles/cbrws/v1',
    'relations_url': 'profiles/cbrws/v1/rels/',
    'relation_url': 'profiles/cbrws/v1/rels/greeting',
    'resource_url': 'api/greeting'
  }
  LITERAL_CONTEXT = {
    'title': 'CBRWS V1 Greeting Relation'
  }
  LINK_HEADER_ITEMS = (
    {
      'path': 'profiles/cbrws/v1',
      'rel': 'profile',
      'type': 'application/ld+json',
      'title': 'API version identifier(URI) for the cbrws web service'
    },
    {
      'path': 'profiles/cbrws/v1/api.schema',
      'rel': 'describedBy',
      'type': ProfileSchemaEndpoint.response_media_type(),
      'title': 'JSON schema of the response'
    },
    {
      'path': 'profiles/cbrws/v1/api.schema',
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
    profile_url = make_url(request, 'profiles/cbrws/v1')
    context['resource_media_type'] = f'application/hal+json; profile="{profile_url}"'
    return context
