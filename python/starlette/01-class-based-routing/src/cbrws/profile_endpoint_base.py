"""
  profile_endpoint_base.py: Base class for profile URLs in the cbrws
  web service.
"""
from pathlib import Path
from typing import Any
import json

import aiofiles
from jinja2 import Template
from starlette import status
from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response

from cbrws.accept_util import select_media_type
from cbrws.http_endpoint_base import HTTPEndpointBase
from cbrws.url_util import make_url


class ProfileEndpointBase(HTTPEndpointBase):
  """
    A base class for profile URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or the configured
    JSON media type depending on the Accept header of the request.
  """
  HTML_FILENAME = ''
  JSON_FILENAME = ''
  RESPONSE_MEDIA_TYPE = ''
  SUPPORTED_MEDIA_TYPES = ['text/html', '*/*']
  SCHEMA_DIR = Path(__file__).resolve().parent / 'schemas'
  URL_CONTEXT: dict[str, str] = {}
  LINK_HEADER_ITEMS: tuple[dict[str, str], ...] = ()

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

  @classmethod
  async def load_json(cls, filename: str, context: dict[str, str]) -> dict[str, Any]:
    """
      Load a JSON document from a file.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: A dictionary representing the JSON document
    """
    content = await cls.load_file(filename, context)
    data = json.loads(content)
    if not isinstance(data, dict):
      raise ValueError(f'JSON document must be an object: {filename}')
    return data

  @classmethod
  def json_filename(cls) -> str:
    """
      Generate the filename for the JSON response.
      :return: The JSON filename
    """
    return cls.JSON_FILENAME

  @classmethod
  def response_media_type(cls) -> str:
    """
      Generate the media type for the profile response.
      :return: A string representing the media type
    """
    return cls.RESPONSE_MEDIA_TYPE

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the profile response.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    return {
      key: make_url(request, path)
      for key, path in cls.URL_CONTEXT.items()
    }

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the profile endpoint.
      :param request: The HTTP request
      :return: A Response with HTML content
    """
    cls = type(self)
    content = await cls.load_file(
      str(cls.SCHEMA_DIR / cls.HTML_FILENAME),
      cls.context(request))
    return HTMLResponse(
      content,
      status_code=status.HTTP_200_OK,
      media_type='text/html',
      headers=cls.headers(request))

  async def json_response(self, request: Request) -> JSONResponse:
    """
      Generate a JSON response for the profile endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with JSON content
    """
    cls = type(self)
    content = await cls.load_json(
      str(cls.SCHEMA_DIR / cls.json_filename()),
      cls.context(request))
    return JSONResponse(
      content,
      status_code=status.HTTP_200_OK,
      media_type=cls.response_media_type(),
      headers=cls.headers(request))

  async def get(self, request: Request) -> Response:
    """
      Handle GET requests to the profile endpoint.
      :param request: The HTTP request
      :return: A Response with either HTML or JSON content
    """
    cls = type(self)
    media_type = select_media_type(
      request.headers.get('accept'),
      [cls.response_media_type(), 'text/html'])
    if media_type == 'text/html':
      return await self.html_response(request)
    if media_type == cls.response_media_type():
      return await self.json_response(request)
    return cls.not_acceptable(request)

  async def head(self, request: Request) -> Response:
    """
      Handle HEAD requests to the profile endpoint.
      :param request: The HTTP request
      :return: A Response with headers only
    """
    cls = type(self)
    media_type = select_media_type(
      request.headers.get('accept'),
      [cls.response_media_type(), 'text/html'])
    if media_type == 'text/html':
      return Response(
        status_code=status.HTTP_200_OK,
        media_type='text/html',
        headers=cls.headers(request))
    if media_type == cls.response_media_type():
      return Response(
        status_code=status.HTTP_200_OK,
        media_type=cls.response_media_type(),
        headers=cls.headers(request))
    return cls.not_acceptable(request)
