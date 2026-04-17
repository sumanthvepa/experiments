"""
  profile_directory_endpoint.py: Base class for profile directory URLs in
  the cbrws web service.
"""
from cbrws.http_endpoint_base import SupportedMediaTypes
from cbrws.profile_endpoint_base import ProfileEndpointBase


class ProfileDirectoryEndpoint(ProfileEndpointBase):
  """
    A base class for profile directory URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or
    'application/hal+json' depending on the Accept header of the
    request.
  """
  HTML_FILENAME = ''
  JSON_FILENAME = ''
  RESPONSE_MEDIA_TYPE = 'application/hal+json'

  @classmethod
  def _supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by profile directories.
      :return: A non-empty tuple of concrete response media types
    """
    return 'application/hal+json', 'text/html'
