"""
  root_endpoint.py: URL handler for the root URL of the cbrws
  web service.
"""
from starlette.endpoints import HTTPEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, RedirectResponse, Response
from starlette import status


def make_url(request: Request, path: str) -> str:
  """
    Create a URL for the given path based on the request's scheme and netloc.
    This is used to construct URLs for schema and media type links.
    :param request: The HTTP request
    :return: A URL for th
  """
  return f'{request.url.scheme}://{request.url.netloc}/{path}'


class RootEndpoint(HTTPEndpoint):
  """
    A URL handler for the root URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    This is a class based routing endpoint. The class
    handles all requests to the root URL ('/') of the web service.

    As a matter of convention, all web services should provide
    actual service at the /api endpoint. The root URL should
    always redirect to the /api endpoint.
  """
  default_media_type = 'application/vnd.milestone42.cbrws.v1+json'
  default_media_type_format = 'application/json'
  schema_path = 'schema/v1/cbrws.schema.json'
  schema_format = 'application/schema+json'
  documentation_path = 'doc/cbrws.html'
  documentation_format = 'text/html'

  # noinspection PyMethodMayBeStatic,PyUnusedLocal
  async def get(
        self, request: Request) -> RedirectResponse:  # pylint: disable=unused-argument
    """
      Redirect GET requests to the API endpoint.
      :param request: The HTTP request
      :return: A 308 Permanent Redirect response
    """
    return RedirectResponse(
      url='/api', status_code=status.HTTP_308_PERMANENT_REDIRECT)

  # noinspection PyMethodMayBeStatic, PyUnusedLocal
  async def head(
        self, request: Request) -> RedirectResponse:  # pylint: disable=unused-argument
    """
      Redirect HEAD requests to the API endpoint.
      :param request: The HTTP request
      :return: A 308 Permanent Redirect response
    """
    return RedirectResponse(
      url='/api', status_code=status.HTTP_308_PERMANENT_REDIRECT)

  # noinspection PyMethodMayBeStatic, PyUnusedLocal
  async def options(
        self, request: Request) -> Response:  # pylint: disable=unused-argument
    """
      Handle OPTIONS requests for the root URL.
      :param request:
      :return: A 204 No Content response with appropriate headers
    """
    # This response indicates that the server supports
    # GET, HEAD, and OPTIONS methods for the root URL.
    # The Allow header lists the allowed methods.

    # The Link header provides 3 links:
    # 1. The default media type for the API
    # 2. The schema that defines the default media type
    # 3. Human-readable documentation for the API

    # 1. Default media type
    # The default media type is the media type of the response if
    # the client does not specify an Accept header.
    # The default media type is application/vnd.milestone42.cbrws.v1+json.
    # This is a custom media type that indicates the version of the API
    # and the format of the response. The 'v1' indicates that this is
    # version 1 of the API, and 'json' indicates that the response
    # will be in JSON format.
    # Normally a link would be URL but RFC 8288 allows the use of
    # media types in the Link header.
    # https://datatracker.ietf.org/doc/html/rfc8288#section-5.3

    # 2. Schema
    # The schema is a JSON Schema that defines the structure of the
    # default media type. It is used to validate the response and
    # to provide documentation for the API. The schema is located at
    # /schema/v1/cbrws.schema.json. The schema format is
    # application/schema+json. This is actually just a static file
    # and is normally served by the proxy server (e.g. nginx)
    # or the web server (e.g. Apache) that is a reverse proxy
    # for the cbrws web service.
    # However, during development, it is useful to have the
    # web service serve the schema directly so that it can be
    # tested and validated without needing to set up a web server
    # or a proxy server.
    schema_url = make_url(request, RootEndpoint.schema_path)

    # 3. Documentation
    # The documentation is a human-readable HTML document that
    # describes the API and how to use it. It is located at
    # /doc/cbrws.html. The documentation format is text/html.
    # This is also a static file that is normally served by the
    # proxy server or the web server that is a reverse proxy
    # for the cbrws web service. However, during development,
    # it is useful to have the web service serve the documentation
    # directly so that it can be tested and validated without
    # needing to set up a web server or a proxy server.
    # The documentation is not required for the API to function,
    # but it is highly recommended to provide a good user experience/
    doc_url = make_url(request, RootEndpoint.documentation_path)

    headers = {
      "Allow": "GET, HEAD, OPTIONS",
      "Accept": RootEndpoint.default_media_type,
      # pylint: disable=line-too-long
      "Link": f'<{RootEndpoint.default_media_type}>; rel="default"; type="{RootEndpoint.default_media_type_format}", '
      + f'<{schema_url}>; rel="schema"; type="{RootEndpoint.schema_format}", '
      + f'<{doc_url}>; rel="documentation"; type="{RootEndpoint.documentation_format}"',
    }
    return Response(status_code=204, headers=headers)

  async def method_not_allowed(self, request: Request) -> JSONResponse:
    """
      Handle methods that are not allowed for the root URL.
      :param request:
      :return:
    """
    # The error response conforms to RFC 7807 (Problem Details for HTTP APIs)
    # https://datatracker.ietf.org/doc/html/rfc7807
    # The type URI is a unique identifier for the error type,
    # I used the MDN documentation link for Method Not Allowed
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405
    # as the unique identifier.
    # The list of allowed methods is provided in the Allow header.
    # This is a common practice to inform the client about the allowed methods
    # for the resource.
    error = {
      'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405',
      'title': 'Method Not Allowed',
      'status': status.HTTP_405_METHOD_NOT_ALLOWED,
      # pylint: disable=line-too-long
      'detail': 'The requested method is not allowed for this resource. See the Allow header for allowed methods.',
    }
    return JSONResponse(
      error,
      status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
      headers={'Allow': 'GET, HEAD, OPTIONS'})
