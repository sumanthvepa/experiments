"""
  service_endpoint.py: Base class for API endpoints in the cbrws
  web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint import (
  HTTPEndpoint,
  LinkHeaderItem,
  LinkHeaderItems,
  SupportedMediaTypes
)
from cbrws.url_util import public_url_for


class ServiceEndpoint(HTTPEndpoint):
  """
  A base class for endpoints that are actual functional endpoints
  of the web service. They only return HAL+JSON responses.

  This class provides common functionality for API endpoints
  /, /api, and /greeting such as generating profile URLs and
  handling common response structures. It is not intended to be used
  directly, but rather as a base class for RootEndpoint and
  APIEndpoint classes.
  """

  @classmethod
  def supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by CBRWS API endpoints.
      :return: A non-empty tuple of concrete response media types
    """
    return ('application/hal+json',)

  @staticmethod
  def schema_url(request: Request) -> str:
    """
      Generate the schema URL for the cbrws web service.
      :param request: The HTTP request
      :return: A string representing the schema URL
    """
    return public_url_for(request, 'profile_endpoint')


  @staticmethod
  def schema_media_type() -> str:
    """
      Generate the media type for the schema of the cbrws web service.
      :return: A string representing the schema media type
    """
    return 'application/schema+json'

  @classmethod
  def link_header_items(cls, request: Request) -> LinkHeaderItems:
    """
      Generate Link header item definitions for API responses.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='profile',
        type='application/ld+json',
        title='API version identifier(URI) for the cbrws web service'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='describedBy',
        type=cls.schema_media_type(),
        title='JSON schema of the response'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='documentation',
        type='text/html',
        title='Documentation for the cbrws web service API')
    )
