"""
  profiles_endpoint.py: URL handler for the /profiles/ URL of the cbrws
  web service.
"""
from cbrws.profile_directory_endpoint import ProfileDirectoryEndpoint


class ProfilesEndpoint(ProfileDirectoryEndpoint):
  """
    A URL handler for the /profiles/ URL of the cbrws web service.

    This endpoint lists the profile families supported by the service.
  """
  HTML_FILENAME = 'profiles.jinja2'
  JSON_FILENAME = 'profiles.json'
  URL_CONTEXT = {
    'profiles_url': 'profiles/',
    'cbrws_profile_url': 'profiles/cbrws'
  }
  LINK_HEADER_ITEMS = (
    {
      'path': 'profiles/',
      'rel': 'self',
      'type': ProfileDirectoryEndpoint.response_media_type()
    },
    {
      'path': 'profiles/cbrws',
      'rel': 'item',
      'type': ProfileDirectoryEndpoint.response_media_type(),
      'title': 'CBRWS profile family'
    }
  )
