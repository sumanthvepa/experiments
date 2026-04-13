"""
  cbrws_v1_profile_endpoint.py: URL handler for the /profiles/cbrws/v1
  URL of the cbrws web service.
"""
from cbrws.profile_schema_endpoint import ProfileSchemaEndpoint


class CBRWSV1ProfileEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1 URL of the cbrws web service.

    This endpoint describes the concrete v1 CBRWS API profile.
  """
  HTML_FILENAME = 'api-profile-v1.jinja2'
  SCHEMA_FILENAME = 'api-profile-v1.json'
  URL_CONTEXT = {
    'profile_url': 'profiles/cbrws/v1',
    'schema_url': 'profiles/cbrws/v1/api.schema'
  }
  LITERAL_CONTEXT = {
    'version': '1.0',
    'title': 'CBRWS V1 API Profile'
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
