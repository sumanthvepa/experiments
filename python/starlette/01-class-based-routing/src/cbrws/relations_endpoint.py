"""
  relations_endpoint.py: URL handler for the /profiles/cbrws/v1/rels/
  URL of the cbrws web service.
"""
from cbrws.profile_schema_endpoint import ProfileSchemaEndpoint


class RelationsEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/ URL of the cbrws
    web service.

    For the GET request it returns either text/html or
    application/schema+json depending on the Accept header.
  """
  RELATIONS_PATH = '/profiles/cbrws/v1/rels/'
  HTML_FILENAME = 'relations-v1.jinja2'
  JSON_FILENAME = 'relations-v1.json'
  URL_CONTEXT = {
    'profile_url': 'profile_endpoint',
    'relations_url': 'relations_endpoint',
    'greeting_relation_url': 'greeting_relation_endpoint'
  }
  LITERAL_CONTEXT = {
    'title': 'CBRWS v1 Relations'
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
