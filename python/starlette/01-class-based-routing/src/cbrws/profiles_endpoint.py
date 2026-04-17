"""
  profiles_endpoint.py: URL handler for the /profiles/ URL of the cbrws
  web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint_base import LinkHeaderItems
from cbrws.profile_directory_endpoint import ProfileDirectoryEndpoint


class ProfilesEndpoint(ProfileDirectoryEndpoint):
  """
    A URL handler for the /profiles/ URL of the cbrws web service.

    This endpoint lists the profile families supported by the service.
  """
  HTML_FILENAME = 'profiles.jinja2'
  JSON_FILENAME = 'profiles.json'
  URL_CONTEXT = {
    'profiles_url': 'profiles_endpoint',
    'cbrws_profile_url': 'cbrws_profiles_endpoint'
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
        'route_name': 'profiles_endpoint',
        'rel': 'self',
        'type': ProfileDirectoryEndpoint.response_media_type()
      },
      {
        'route_name': 'cbrws_profiles_endpoint',
        'rel': 'item',
        'type': ProfileDirectoryEndpoint.response_media_type(),
        'title': 'CBRWS profile family'
      }
    )
