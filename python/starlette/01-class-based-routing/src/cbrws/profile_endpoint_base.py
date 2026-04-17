"""
  profile_endpoint_base.py: Base class for profile URLs in the cbrws
  web service.
"""
from abc import abstractmethod
from pathlib import Path
from typing import Any, ClassVar, NewType
import json

from jinja2 import Environment, Template, select_autoescape
from starlette import status
from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response

from cbrws.accept_util import select_media_type
from cbrws.http_endpoint_base import HTTPEndpointBase
from cbrws.url_util import public_url_for


HTMLFilename = NewType('HTMLFilename', str)
JSONFilename = NewType('JSONFilename', str)


def make_html_filename(value: str) -> HTMLFilename:
  """
    Build a validated HTML template filename.
    :param value: The filename value
    :return: An HTML filename
  """
  if not value.endswith('.jinja2'):
    raise ValueError('HTML template filenames must end with .jinja2')
  return HTMLFilename(value)


def make_json_filename(value: str) -> JSONFilename:
  """
    Build a validated JSON template filename.
    :param value: The filename value
    :return: A JSON filename
  """
  if not value.endswith('.json'):
    raise ValueError('JSON filenames must end with .json')
  return JSONFilename(value)


class ProfileEndpointBase(HTTPEndpointBase):
  """
    A base class for profile URLs in the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or the configured
    JSON media type depending on the Accept header of the request.
  """
  SCHEMA_DIR = Path(__file__).resolve().parent / 'schemas'
  URL_CONTEXT: dict[str, str] = {}
  HTML_ENVIRONMENT = Environment(
    autoescape=select_autoescape(['html', 'jinja2']))
  JSON_ENVIRONMENT = Environment(autoescape=False)
  HTML_TEMPLATE_CACHE: ClassVar[dict[Path, Template]] = {}
  JSON_TEMPLATE_CACHE: ClassVar[dict[Path, Template]] = {}

  @classmethod
  def load_html_template(cls, filename: str) -> Template:
    """
      Load and cache an HTML template.
      :param filename: The name of the template file to load
      :return: The compiled template
    """
    path = Path(filename).resolve()
    if path not in cls.HTML_TEMPLATE_CACHE:
      template = path.read_text(encoding='utf-8')
      cls.HTML_TEMPLATE_CACHE[path] = cls.HTML_ENVIRONMENT.from_string(template)
    return cls.HTML_TEMPLATE_CACHE[path]

  @classmethod
  def load_json_template(cls, filename: str) -> Template:
    """
      Load and cache a JSON template.
      :param filename: The name of the template file to load
      :return: The compiled template
    """
    path = Path(filename).resolve()
    if path not in cls.JSON_TEMPLATE_CACHE:
      template = path.read_text(encoding='utf-8')
      cls.JSON_TEMPLATE_CACHE[path] = cls.JSON_ENVIRONMENT.from_string(template)
    return cls.JSON_TEMPLATE_CACHE[path]

  @classmethod
  async def load_file(cls, filename: str, context: dict[str, str]) -> str:
    """
      Load and render a cached file template without HTML escaping.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: The content of the file as a string
    """
    return cls.load_json_template(filename).render(context)

  @classmethod
  async def load_html(cls, filename: str, context: dict[str, str]) -> str:
    """
      Load and render a cached HTML template.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: The HTML content of the file as a string
    """
    return cls.load_html_template(filename).render(context)

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
  @abstractmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """

  @classmethod
  @abstractmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """

  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    """
      Generate the template context for the profile response.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    return {
      key: public_url_for(request, route_name)
      for key, route_name in cls.URL_CONTEXT.items()
    }

  @classmethod
  def negotiate_media_type(cls, request: Request) -> str | None:
    """
      Select the response media type for the request.
      :param request: The HTTP request
      :return: The selected media type, or None if no supported media
      type matches
    """
    return select_media_type(
      request.headers.get('accept'),
      cls.supported_media_types())

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the profile endpoint.
      :param request: The HTTP request
      :return: A Response with HTML content
    """
    cls = type(self)
    content = await cls.load_html(
      str(cls.SCHEMA_DIR / str(cls.html_filename())),
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
      str(cls.SCHEMA_DIR / str(cls.json_filename())),
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
    media_type = cls.negotiate_media_type(request)
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
    media_type = cls.negotiate_media_type(request)
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
