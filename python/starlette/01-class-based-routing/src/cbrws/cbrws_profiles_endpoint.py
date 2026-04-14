"""
  cbrws_profiles_endpoint.py: URL handler for the /profiles/cbrws URL of
  the cbrws web service.
"""
from cbrws.profile_directory_endpoint import ProfileDirectoryEndpoint


class CBRWSProfilesEndpoint(ProfileDirectoryEndpoint):
  """
    A URL handler for the /profiles/cbrws URL of the cbrws web service.

    This endpoint lists the versions of the CBRWS profile supported by
    the service.
  """
  HTML_FILENAME = 'cbrws-profiles.jinja2'
  JSON_FILENAME = 'cbrws-profiles.json'
  URL_CONTEXT = {
    'cbrws_profile_url': 'cbrws_profiles_endpoint',
    'cbrws_v1_profile_url': 'profile_endpoint'
  }
  LINK_HEADER_ITEMS = (
    {
      'route_name': 'cbrws_profiles_endpoint',
      'rel': 'self',
      'type': ProfileDirectoryEndpoint.response_media_type()
    },
    {
      'route_name': 'profile_endpoint',
      'rel': 'item',
      'type': 'application/schema+json',
      'title': 'CBRWS v1 API profile'
    }
  )
