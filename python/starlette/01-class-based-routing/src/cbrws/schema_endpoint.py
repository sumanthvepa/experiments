"""
  schema_endpoint.py: Base class for profile schema URLs in the
  cbrws web service.
"""
from abc import ABC
from typing import TypeAlias


from cbrws.http_endpoint import SupportedMediaTypes
from cbrws.documentation_endpoint import DocumentationEndpoint


LiteralContext: TypeAlias = dict[str, str]


class SchemaEndpoint(DocumentationEndpoint, ABC):
  """
    A base class for profile schema URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or
    'application/schema+json' depending on the Accept header of the
    request.

    The ABC base is not strictly needed because abstract methods are
    inherited from ProfileEndpointBase. It is included to signal that
    this class is an abstract base class and should not be instantiated.
  """
  @classmethod
  def supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by profile schema endpoints.
      :return: A non-empty tuple of concrete responses media types
    """
    return 'application/schema+json', 'text/html'
