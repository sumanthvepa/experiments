"""
  profile_directory_endpoint.py: Base class for profile directory URLs in
  the cbrws web service.
"""
from cbrws.http_endpoint_base import ResponseMediaType, SupportedMediaTypes
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

  @classmethod
  def _supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by profile directories.
      :return: A non-empty tuple of concrete response media types
    """
    return 'application/hal+json', 'text/html'

  @classmethod
  def response_media_type(cls) -> ResponseMediaType:
    """
      Return the primary response media type for profile directories.
      :return: A concrete response media type
    """
    return 'application/hal+json'
