"""
  schema_endpoint.py: Base class for profile schema URLs in the
  cbrws web service.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, TypeAlias
from abc import ABC, abstractmethod

from cbrws.http_endpoint import ResponseMediaType
from cbrws.template_endpoint import TemplateEndpoint
if TYPE_CHECKING:
  from cbrws.service_endpoint import ServiceEndpoint


LiteralContext: TypeAlias = dict[str, str]


class SchemaEndpoint(TemplateEndpoint, ABC):
  """
    A base class for profile schema URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or
    'application/schema+json' depending on the Accept header of the
    request.

    The ABC base is not strictly needed because abstract methods are
    inherited from TemplateEndpoint. It is included to signal that
    this class is an abstract base class and should not be instantiated.
  """
  @classmethod
  @abstractmethod
  def service_class(cls) -> type[ServiceEndpoint]:
    """
      Return the service endpoint class that this schema endpoint describes.
      :return: The service endpoint class that this schema endpoint describes.
    """

  @classmethod
  def machine_readable_response_media_type(cls) -> ResponseMediaType:
    """
      Return the machine-readable media type for the endpoint:
      "application/schema+json".
      :return: The machine-readable media type for the endpoint:
    """
    return 'application/schema+json'

  @classmethod
  @abstractmethod
  def schema_title(cls) -> str:
    """
      Return the title of the schema for this endpoint.
      :return: The schema title
    """
