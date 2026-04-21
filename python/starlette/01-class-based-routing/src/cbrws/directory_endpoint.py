"""
  directory_endpoint.py: Base class for profile directory URLs in
  the cbrws web service.
"""
from abc import ABC

from cbrws.http_endpoint import ResponseMediaType
from cbrws.template_endpoint import TemplateEndpoint


class DirectoryEndpoint(TemplateEndpoint, ABC):
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
  def machine_readable_response_media_type(cls) -> ResponseMediaType:
    """
      Return the machine-readable media type for this endpoint:
      appication/hal+json

      :return: The machine-readable media type for this endpoint
    """
    return 'application/hal+json'
