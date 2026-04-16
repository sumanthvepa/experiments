"""
  profile_schema_endpoint.py: Base class for profile schema URLs in the
  cbrws web service.
"""
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
  JSON_FILENAME = ''
  RESPONSE_MEDIA_TYPE = 'application/schema+json'
  SUPPORTED_MEDIA_TYPES = ['application/schema+json', 'text/html']
  LITERAL_CONTEXT: dict[str, str] = {}

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
