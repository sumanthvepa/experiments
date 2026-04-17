"""
  cbrws_v1_profile_endpoint.py: URL handler for the /profiles/cbrws/v1
  URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint_base import LinkHeaderItems
from cbrws.profile_schema_endpoint import ProfileSchemaEndpoint


class CBRWSV1ProfileEndpoint(ProfileSchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1 URL of the cbrws web service.

    This endpoint describes the concrete v1 CBRWS API profile.
  """
  HTML_FILENAME = 'api-profile-v1.jinja2'
  JSON_FILENAME = 'api-profile-v1.json'
  URL_CONTEXT = {
    'profile_url': 'profile_endpoint',
    'schema_url': 'profile_endpoint'
  }
  LITERAL_CONTEXT = {
    'version': '1.0',
    'title': 'CBRWS V1 API Profile'
  }

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
