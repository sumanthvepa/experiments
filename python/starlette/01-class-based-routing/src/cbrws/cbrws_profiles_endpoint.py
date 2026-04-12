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
  HTML_FILENAME = 'cbrws_profile.jinja2'
  JSON_FILENAME = 'cbrws_profile.json'
  URL_CONTEXT = {
    'cbrws_profile_url': 'profiles/cbrws',
    'cbrws_v1_profile_url': 'profiles/cbrws/v1'
  }
  LINK_HEADER_ITEMS = (
    {
      'path': 'profiles/cbrws',
      'rel': 'self',
      'type': ProfileDirectoryEndpoint.response_media_type()
    },
    {
      'path': 'profiles/cbrws/v1',
      'rel': 'item',
      'type': 'application/schema+json',
      'title': 'CBRWS v1 API profile'
    }
  )
