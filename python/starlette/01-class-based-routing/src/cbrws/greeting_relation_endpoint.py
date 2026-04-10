"""
  greeting_relation_endpoint.py: URL handler for the
  /profiles/cbrws/v1/rels/greeting URL of the cbrws web service.
"""
from pathlib import Path

from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response
from starlette import status

from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint
from cbrws.profile_endpoint import ProfileEndpoint
from cbrws.url_util import make_url


class GreetingRelationEndpoint(CBRWSBaseEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/greeting URL of the
    cbrws web service.

    For the GET request it returns either text/html or
    application/schema+json depending on the Accept header.
  """
  RELATION_PATH = '/profiles/cbrws/v1/rels/greeting'
  TARGET_PATH = 'api/greeting'
  SUPPORTED_MEDIA_TYPES = ['text/html', 'application/schema+json', '*/*']
  SCHEMA_DIR = Path(__file__).resolve().parent / 'schemas'

  @staticmethod
  def relation_url(request: Request) -> str:
    """
      Generate the URL for the greeting relation documentation.
      :param request: The HTTP request
      :return: The absolute relation documentation URL
    """
    return make_url(request, GreetingRelationEndpoint.RELATION_PATH)

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the greeting relation endpoint.
      :param request: The HTTP request
      :return: A response with HTML content
    """
    context = {
      'profile_url': CBRWSBaseEndpoint.profile_url(request),
      'relation_url': GreetingRelationEndpoint.relation_url(request),
      'resource_url': make_url(request, GreetingRelationEndpoint.TARGET_PATH),
      'resource_media_type': CBRWSBaseEndpoint.response_media_type(request)
    }
    html = await ProfileEndpoint.load_file(str(self.SCHEMA_DIR / 'greeting-rel-v1.jinja2'), context)
    return HTMLResponse(
      html,
      status_code=status.HTTP_200_OK,
      media_type='text/html',
      headers=CBRWSBaseEndpoint.headers(request))

  async def json_response(self, request: Request) -> JSONResponse:
    """
      Generate a JSON Schema response for the greeting relation endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with JSON Schema content
    """
    context = {
      'profile_url': CBRWSBaseEndpoint.profile_url(request),
      'relation_url': GreetingRelationEndpoint.relation_url(request),
      'resource_url': make_url(request, GreetingRelationEndpoint.TARGET_PATH),
      'resource_media_type': CBRWSBaseEndpoint.response_media_type(request)
    }
    schema = await ProfileEndpoint.load_schema(str(self.SCHEMA_DIR / 'greeting-rel-v1.json'), context)
    return JSONResponse(
      schema,
      status_code=status.HTTP_200_OK,
      media_type=CBRWSBaseEndpoint.schema_media_type(),
      headers=CBRWSBaseEndpoint.headers(request))

  async def get(self, request: Request) -> Response:
    """
      Handle GET requests to the /profiles/cbrws/v1/rels/greeting endpoint.
      :param request: The HTTP request
      :return: A Response with either HTML or JSON Schema content
    """
    accept = request.headers.get('accept', '*/*')
    if 'text/html' in accept:
      return await self.html_response(request)
    if 'application/schema+json' in accept or '*/*' in accept:
      return await self.json_response(request)
    return CBRWSBaseEndpoint.not_acceptable(request, self.SUPPORTED_MEDIA_TYPES)
