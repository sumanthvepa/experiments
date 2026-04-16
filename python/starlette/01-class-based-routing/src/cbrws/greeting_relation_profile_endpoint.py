"""
  greeting_relation_profile_endpoint.py: URL handler for the
  /profiles/cbrws/v1/rels/greeting URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.profile_schema_endpoint import ProfileSchemaEndpoint


class GreetingRelationProfileEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/greeting URL of the
    cbrws web service.

    This endpoint describes the cbrws:greeting relation.
  """
  HTML_FILENAME = 'greeting-rel-v1.jinja2'
  JSON_FILENAME = 'greeting-rel-v1.json'
  URL_CONTEXT = {
    'profile_url': 'profile_endpoint',
    'relations_url': 'relations_endpoint',
    'relation_url': 'greeting_relation_endpoint',
    'resource_url': 'greeting_endpoint'
  }
  LITERAL_CONTEXT = {
    'title': 'CBRWS V1 Greeting Relation'
  }
  LINK_HEADER_ITEMS = (
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
