"""
  profile_endpoint.py: URL handler for the /profiles/cbrws/v1 URL of the cbrws
  web service.
"""
from typing import Any
import json

import aiofiles
from jinja2 import Template
from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response
from starlette import status

from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint


class ProfileEndpoint(CBRWSBaseEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1 URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests. The latter two are handled
    by the base class.

    For the GET request it returns either an text/html or application/schema+json
    response depending on the Accept header of the request.
  """
  schema: dict[str, str] | None = None
  html: str | None = None

  @staticmethod
  async def load_file(filename: str, context: dict[str, str]) -> str:
    """
      Load a file from the filesystem.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: The content of the file as a string
    """
    async with aiofiles.open(filename, mode='r', encoding='utf-8') as file:
      template = await file.read()
      content = Template(template).render(context)
      return content

  @staticmethod
  async def load_schema(filename: str, context: dict[str, str]) -> dict[str, Any]:
    """
      Load a JSON schema from a file.
      :param filename: The name of the file to load the schema from
      :param context: The context to render the template with
      :return: A dictionary representing the JSON schema
    """
    content = await ProfileEndpoint.load_file(filename, context)
    data = json.loads(content)
    assert isinstance(data, dict)
    assert all(isinstance(k, str) for k in data.keys())
    return data

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the profile endpoint.
      :param request: The HTTP request
      :return: A Response with HTML content
    """
    if self.html is None:
      context = {
        'profile_url': CBRWSBaseEndpoint.profile_url(request),
        'schema_url': CBRWSBaseEndpoint.schema_url(request),
        'version': '1.0',
        'title': 'CBRWS API Profile'
      }
      self.html = await ProfileEndpoint.load_file('schemas/api-profile-v1.jinja2', context)

    return HTMLResponse(
      self.html,
      status_code=status.HTTP_200_OK,
      media_type='text/html',
      headers=CBRWSBaseEndpoint.headers(request))

  async def json_response(self, request: Request) -> JSONResponse:
    """
      Generate a JSON Schema response for the profile endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with JSON Schema content
    """
    if self.schema is None:
      context = {
        'profile_url': CBRWSBaseEndpoint.profile_url(request),
        'schema_url': CBRWSBaseEndpoint.schema_url(request),
        'version': '1.0',
        'title': 'CBRWS API Profile'
      }
    self.schema = await ProfileEndpoint.load_schema('schemas/api-profile-v1.json', context)

    return JSONResponse(
      self.schema,
      status_code=status.HTTP_200_OK,
      media_type=CBRWSBaseEndpoint.schema_media_type(),
      headers=CBRWSBaseEndpoint.headers(request))

  async def get(self, request: Request) -> Response:
    """
      Handle GET requests to the /profiles/cbrws/v1 endpoint.
      :param request: The HTTP request
      :return: A Response with profile information in either HTML or JSON Schema format
    """
    # Content negotiation
    # Check if the request's Accept header includes a supported media type
    # If not, return a 406 Not Acceptable response
    accept = request.headers.get('accept', '*/*')
    if 'text/html' in accept:
      return await self.html_response(request)
    if 'application/schema+json' in accept or '*/*' in accept:
      return await self.json_response(request)
    return CBRWSBaseEndpoint.not_acceptable(request, self.SUPPORTED_MEDIA_TYPES)
