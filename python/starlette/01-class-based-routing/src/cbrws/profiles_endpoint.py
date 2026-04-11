"""
  profiles_endpoint.py: URL handler for the /profiles/ URL of the cbrws
  web service.
"""
from pathlib import Path
from typing import Any, override
import json

import aiofiles
from jinja2 import Template
from starlette import status
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse, Response

from cbrws.url_util import make_url


class ProfilesEndpoint(HTTPEndpoint):
  """
    A URL handler for the /profiles/ URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    For the GET request it returns either text/html or
    'application/hal+json' depending on the Accept header of the
    request.
  """
  SUPPORTED_MEDIA_TYPES = ['text/html', 'application/hal+json', '*/*']
  SCHEMA_DIR = Path(__file__).resolve().parent / 'schemas'

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
  async def load_json(filename: str, context: dict[str, str]) -> dict[str, Any]:
    """
      Load a JSON document from a file.
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: A dictionary representing the JSON document
    """
    content = await ProfilesEndpoint.load_file(filename, context)
    data = json.loads(content)
    assert isinstance(data, dict)
    assert all(isinstance(k, str) for k in data.keys())
    return data

  @staticmethod
  def profiles_url(request: Request) -> str:
    """
      Generate the profiles directory URL.
      :param request: The HTTP request
      :return: A string representing the profiles directory URL
    """
    return make_url(request, 'profiles/')

  @staticmethod
  def cbrws_profile_url(request: Request) -> str:
    """
      Generate the cbrws profile family URL.
      :param request: The HTTP request
      :return: A string representing the cbrws profile family URL
    """
    return make_url(request, 'profiles/cbrws')

  @staticmethod
  def response_media_type() -> str:
    """
      Generate the media type for the profiles directory response.
      :return: A string representing the media type
    """
    return 'application/hal+json'

  @staticmethod
  def problem_media_type() -> str:
    """
      Generate the media type for problem details.
      :return: A string representing the problem media type
    """
    return 'application/problem+json'

  @staticmethod
  def context(request: Request) -> dict[str, str]:
    """
      Generate the template context for the 'profiles' directory.
      :param request: The HTTP request
      :return: A dictionary of template variables
    """
    return {
      'profiles_url': ProfilesEndpoint.profiles_url(request),
      'cbrws_profile_url': ProfilesEndpoint.cbrws_profile_url(request)
    }

  @staticmethod
  def headers(request: Request) -> dict[str, str]:
    """
      Generate common headers for profiles directory responses.
      :param request: The HTTP request
      :return: A dictionary of headers
    """
    return {
      'Allow': 'GET, HEAD, OPTIONS',
      'Link': f'<{ProfilesEndpoint.profiles_url(request)}>; rel="self"; ' +
              f'type="{ProfilesEndpoint.response_media_type()}", ' +
              f'<{ProfilesEndpoint.cbrws_profile_url(request)}>; rel="item"; ' +
              f'type="{ProfilesEndpoint.response_media_type()}"; ' +
              'title="CBRWS profile family"'
    }

  @staticmethod
  def not_acceptable(request: Request) -> JSONResponse:
    """
      Generate a 406 Not Acceptable response.
      :param request: The HTTP request
      :return: A JSONResponse with problem details
    """
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
      'title': 'Not Acceptable',
      'status': status.HTTP_406_NOT_ACCEPTABLE,
      'detail': 'The requested media type is not supported by this endpoint. ' +
                'Supported media types are: ' + ', '.join(ProfilesEndpoint.SUPPORTED_MEDIA_TYPES),
      'supportedMediaTypes': ProfilesEndpoint.SUPPORTED_MEDIA_TYPES
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_406_NOT_ACCEPTABLE,
      media_type=ProfilesEndpoint.problem_media_type(),
      headers=ProfilesEndpoint.headers(request))

  async def html_response(self, request: Request) -> HTMLResponse:
    """
      Generate an HTML response for the profiles directory endpoint.
      :param request: The HTTP request
      :return: A Response with HTML content
    """
    content = await ProfilesEndpoint.load_file(
      str(self.SCHEMA_DIR / 'profiles.jinja2'),
      ProfilesEndpoint.context(request))
    return HTMLResponse(
      content,
      status_code=status.HTTP_200_OK,
      media_type='text/html',
      headers=ProfilesEndpoint.headers(request))

  async def json_response(self, request: Request) -> JSONResponse:
    """
      Generate a HAL JSON response for the profiles directory endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with HAL JSON content
    """
    content = await ProfilesEndpoint.load_json(
      str(self.SCHEMA_DIR / 'profiles.json'),
      ProfilesEndpoint.context(request))
    return JSONResponse(
      content,
      status_code=status.HTTP_200_OK,
      media_type=ProfilesEndpoint.response_media_type(),
      headers=ProfilesEndpoint.headers(request))

  async def get(self, request: Request) -> Response:
    """
      Handle GET requests to the /profiles/ endpoint.
      :param request: The HTTP request
      :return: A Response with profiles information in either HTML or HAL JSON format
    """
    accept = request.headers.get('accept', '*/*')
    if 'text/html' in accept:
      return await self.html_response(request)
    if 'application/hal+json' in accept or '*/*' in accept:
      return await self.json_response(request)
    return ProfilesEndpoint.not_acceptable(request)

  # By convention HTTP verb methods in starlette should be non-static,
  # hence the suppression of the IntelliJ IDEA warning about the method
  # potentially being static.
  # noinspection PyMethodMayBeStatic
  async def head(self, request: Request) -> Response:
    """
      Handle HEAD requests to the /profiles/ endpoint.
      :param request: The HTTP request
      :return: A Response with headers only
    """
    accept = request.headers.get('accept', '*/*')
    if 'text/html' in accept:
      return Response(
        status_code=status.HTTP_200_OK,
        media_type='text/html',
        headers=ProfilesEndpoint.headers(request))
    if 'application/hal+json' in accept or '*/*' in accept:
      return Response(
        status_code=status.HTTP_200_OK,
        media_type=ProfilesEndpoint.response_media_type(),
        headers=ProfilesEndpoint.headers(request))
    return ProfilesEndpoint.not_acceptable(request)

  # By convention HTTP verb methods in starlette should be non-static,
  # hence the suppression of the IntelliJ IDEA warning about the method
  # potentially being static.
  # noinspection PyMethodMayBeStatic
  async def options(self, request: Request) -> Response:
    """
      Handle OPTIONS requests for the /profiles/ endpoint.
      :param request: The HTTP request
      :return: A 204 No Content response with appropriate headers
    """
    return Response(
      status_code=status.HTTP_204_NO_CONTENT,
      headers=ProfilesEndpoint.headers(request))

  @override
  async def method_not_allowed(self, request: Request) -> JSONResponse:
    """
      Handle methods that are not allowed for the /profiles/ endpoint.
      :param request: The HTTP request
      :return: A JSONResponse with problem details
    """
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405',
      'title': 'Method Not Allowed',
      'status': status.HTTP_405_METHOD_NOT_ALLOWED,
      'detail': 'The requested method is not allowed for this resource. ' +
                'See the Allow header for allowed methods.',
      'allowedMethods': ['GET', 'HEAD', 'OPTIONS']
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
      media_type=ProfilesEndpoint.problem_media_type(),
      headers=ProfilesEndpoint.headers(request))
