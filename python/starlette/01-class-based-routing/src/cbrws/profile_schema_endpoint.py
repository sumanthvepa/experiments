"""
  profile_schema_endpoint.py: Base class for profile schema URLs in the
  cbrws web service.
"""
from typing import Any

from starlette.requests import Request

from cbrws.profile_endpoint_base import ProfileEndpointBase


class ProfileSchemaEndpoint(ProfileEndpointBase):
  """
    A base class for profile schema URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or
    'application/schema+json' depending on the Accept header of the
    request.
  """
  HTML_FILENAME = ''
  SCHEMA_FILENAME = ''
  RESPONSE_MEDIA_TYPE = 'application/schema+json'
  SUPPORTED_MEDIA_TYPES = ['application/schema+json', 'text/html', '*/*']
  LITERAL_CONTEXT: dict[str, str] = {}

  @classmethod
  async def load_schema(cls, filename: str, context: dict[str, str]) -> dict[str, Any]:
    """
      Load a JSON schema from a file.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: A dictionary representing the JSON schema
    """
    return await cls.load_json(filename, context)

  @classmethod
  def json_filename(cls) -> str:
    """
      Generate the filename for the JSON schema response.
      :return: The JSON schema filename
    """
    return cls.SCHEMA_FILENAME

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the profile schema.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    context = super().context(request)
    context.update(cls.LITERAL_CONTEXT)
    return context
