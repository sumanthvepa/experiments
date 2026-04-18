"""
  schema_endpoint.py: Base class for profile schema URLs in the
  cbrws web service.
"""
from abc import ABC
from typing import TypeAlias

from starlette.requests import Request

from cbrws.http_endpoint import ResponseMediaType, SupportedMediaTypes
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
  def _supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by profile schema endpoints.
      :return: A non-empty tuple of concrete responses media types
    """
    return 'application/schema+json', 'text/html'

  @classmethod
  def response_media_type(cls) -> ResponseMediaType:
    """
      Return the primary response media type for profile schema endpoints.
      :return: A concrete response media type
    """
    return 'application/schema+json'

  @classmethod
  def literal_context(cls) -> LiteralContext:
    """
      Return literal template context values for the profile schema.
      :return: A dictionary of template variables
    """
    return {}

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the profile schema.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    context = super().context(request)
    context.update(cls.literal_context())
    return context
