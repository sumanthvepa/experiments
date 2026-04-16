"""
  cbrws_base_endpoint.py: Base class for API endpoints in the cbrws
  web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint_base import HTTPEndpointBase
from cbrws.url_util import public_url_for


class CBRWSBaseEndpoint(HTTPEndpointBase):
  """
  A base class for the API endpoints (/ and /api) in the cbrws
  web service.

  This class provides common functionality for API endpoints
  / and /api, such as generating profile URLs and handling
  common response structures. It is not intended to be used
  directly, but rather as a base class for RootEndpoint and
  APIEndpoint classes.
  """

  RESPONSE_MEDIA_TYPE = 'application/hal+json'
  SUPPORTED_MEDIA_TYPES = ['application/hal+json']

  @staticmethod
  def profile_url(request: Request) -> str:
    """
      Generate the profile URL for the cbrws web service.
      :param request: The HTTP request
      :return: A string representing the profile URL
    """
    return public_url_for(request, 'profile_endpoint')

  @staticmethod
  def schema_url(request: Request) -> str:
    """
      Generate the schema URL for the cbrws web service.
      :param request: The HTTP request
      :return: A string representing the schema URL
    """
    return CBRWSBaseEndpoint.profile_url(request)

  @classmethod
  def response_media_type(cls) -> str:
    """
      Return the media type for cbrws API responses.
      :return: A string representing the response media type
    """
    return cls.RESPONSE_MEDIA_TYPE

  @staticmethod
  def schema_media_type() -> str:
    """
      Generate the media type for the schema of the cbrws web service.
      :return: A string representing the schema media type
    """
    return 'application/schema+json'

  @classmethod
  def link_header_items(cls, request: Request) -> tuple[dict[str, str], ...]:
    """
      Generate Link header item definitions for API responses.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      {
        'route_name': 'profile_endpoint',
        'rel': 'profile',
        'type': 'application/ld+json',
        'title': 'API version identifier(URI) for the cbrws web service'
      },
      {
        'route_name': 'profile_endpoint',
        'rel': 'describedBy',
        'type': cls.schema_media_type(),
        'title': 'JSON schema of the response'
      },
      {
        'route_name': 'profile_endpoint',
        'rel': 'documentation',
        'type': 'text/html',
        'title': 'Documentation for the cbrws web service API'
      }
    )
