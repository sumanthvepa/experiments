"""
  documentation_directory_endpoint.py: Base class for profile directory URLs in
  the cbrws web service.
"""
from abc import ABC

from cbrws.http_endpoint import ResponseMediaType, SupportedMediaTypes
from cbrws.documentation_endpoint import DocumentationEndpoint


class DocumentationDirectoryEndpoint(DocumentationEndpoint, ABC):
  """
    A base class for profile directory URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or
    'application/hal+json' depending on the Accept header of the
    request.

    The ABC base is not strictly needed because abstract methods are
    inherited from ProfileEndpointBase. It is included to signal that
    this class is an abstract base class and should not be instantiated.
  """
  @classmethod
  def supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by profile directories.
      :return: A non-empty tuple of concrete response media types
    """
    return 'application/hal+json', 'text/html'

  @classmethod
  def default_response_media_type(cls) -> ResponseMediaType:
    """
      Return the primary response media type for profile directories.
      :return: A concrete response media type
    """
    return 'application/hal+json'
