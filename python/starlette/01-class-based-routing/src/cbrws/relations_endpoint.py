"""
  relations_endpoint.py: URL handler for the /profiles/cbrws/v1/rels/
  URL of the cbrws web service.
"""
from pathlib import Path

from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response
from starlette import status

from cbrws.accept_util import select_media_type
from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint
from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint


class RelationsEndpoint(CBRWSBaseEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/ URL of the cbrws
    web service.

    For the GET request it returns either text/html or
    application/schema+json depending on the Accept header.
  """
  RELATIONS_PATH = '/profiles/cbrws/v1/rels/'
  SUPPORTED_MEDIA_TYPES = ['text/html', 'application/schema+json', '*/*']
  SCHEMA_DIR = Path(__file__).resolve().parent / 'schemas'

  @staticmethod
  def relations_url(request: Request) -> str:
    """
      Generate the URL for the relations index.
      :param request: The HTTP request
      :return: The absolute relations index URL
    """
    return str(request.url_for('relations_endpoint'))

  @staticmethod
  def greeting_relation_url(request: Request) -> str:
    """
      Generate the URL for the greeting relation documentation.
      :param request: The HTTP request
      :return: The absolute greeting relation URL
    """
    return str(request.url_for('greeting_relation_endpoint'))

  @staticmethod
  def context(request: Request) -> dict[str, str]:
    """
      Generate the template context for the relations index.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    return {
      'profile_url': CBRWSBaseEndpoint.profile_url(request),
      'relations_url': RelationsEndpoint.relations_url(request),
      'greeting_relation_url': RelationsEndpoint.greeting_relation_url(request),
      'title': 'CBRWS v1 Relations'
    }

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the relations endpoint.
      :param request: The HTTP request
      :return: A Response with HTML content
    """
    html = await CBRWSV1ProfileEndpoint.load_file(
      str(self.SCHEMA_DIR / 'relations-v1.jinja2'),
      RelationsEndpoint.context(request))

    return HTMLResponse(
      html,
      status_code=status.HTTP_200_OK,
      media_type='text/html',
      headers=type(self).headers(request))

  async def json_response(self, request: Request) -> JSONResponse:
    """
      Generate a JSON Schema response for the relations endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with JSON Schema content
    """
    schema = await CBRWSV1ProfileEndpoint.load_schema(
      str(self.SCHEMA_DIR / 'relations-v1.json'),
      RelationsEndpoint.context(request))

    return JSONResponse(
      schema,
      status_code=status.HTTP_200_OK,
      media_type=CBRWSBaseEndpoint.schema_media_type(),
      headers=type(self).headers(request))

  async def get(self, request: Request) -> Response:
    """
      Handle GET requests to the /profiles/cbrws/v1/rels/ endpoint.
      :param request: The HTTP request
      :return: A Response with relations information in either HTML or
      JSON Schema format
    """
    media_type = select_media_type(
      request.headers.get('accept'),
      [CBRWSBaseEndpoint.schema_media_type(), 'text/html'])
    if media_type == 'text/html':
      return await self.html_response(request)
    if media_type == CBRWSBaseEndpoint.schema_media_type():
      return await self.json_response(request)
    return type(self).not_acceptable(request)
