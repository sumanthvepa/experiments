"""
  service_endpoint.py: Base class for API endpoints in the cbrws
  web service.
"""
from __future__ import annotations
from typing import TYPE_CHECKING, Any
from abc import ABC, abstractmethod

from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.http_endpoint import (
  HTTPEndpoint,
  LinkHeaderItem,
  LinkHeaderItems,
  SupportedMediaTypes
)

if TYPE_CHECKING:
  from cbrws.schema_endpoint import SchemaEndpoint


class ServiceEndpoint(HTTPEndpoint, ABC):
  """
  A base class for endpoints that are actual functional endpoints
  of the web service. They only return HAL+JSON responses.

  This class provides common functionality for API endpoints
  /, /api, and /greeting such as generating profile URLs and
  handling common response structures. It is not intended to be used
  directly, but rather as a base class for RootEndpoint and
  APIEndpoint classes.
  """

  async def get(self, request: Request) -> JSONResponse:
    """
      Handle GET requests for HAL service endpoints.
      :param request: The HTTP request
      :return: A JSON response with the endpoint document
    """
    cls = type(self)
    media_type = select_media_type(
      request.headers.get('accept'),
      cls.supported_media_types())
    if media_type is None:
      return cls.not_acceptable(request)

    return JSONResponse(
      content=self.response_document(request),
      status_code=status.HTTP_200_OK,
      media_type=cls.default_response_media_type(),
      headers=cls.headers(request))

  @classmethod
  def supported_media_types(cls) -> SupportedMediaTypes:
    """
      Return the response media types supported by CBRWS API endpoints.
      :return: A non-empty tuple of concrete response media types
    """
    return ('application/hal+json',)

  @classmethod
  @abstractmethod
  def schema_class(cls) -> type[SchemaEndpoint]:
    """
    Returns the schema endpoint class for this service endpoint
    :return:
    """

  @abstractmethod
  def response_document(self, request: Request) -> dict[str, Any]:
    """
      Build the HAL document returned by this service endpoint.
      :param request: The HTTP request
      :return: The endpoint response document
    """

  @classmethod
  def link_header_items(cls, request: Request) -> LinkHeaderItems:
    """
      Generate Link header item definitions for API responses.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      LinkHeaderItem(
        route_name=cls.schema_class().route_name(),
        rel='profile',
        title=cls.schema_class().schema_title()),
      LinkHeaderItem(
        route_name=cls.schema_class().route_name(),
        rel='describedBy',
        type=cls.schema_class().machine_readable_response_media_type(),
        title=cls.schema_class().schema_title()),
      LinkHeaderItem(
        route_name=cls.schema_class().route_name(),
        rel='documentation',
        type=cls.schema_class().human_readable_response_media_type(),
        title=cls.schema_class().schema_title())
    )
