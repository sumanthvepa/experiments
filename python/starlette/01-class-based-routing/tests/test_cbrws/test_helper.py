"""
  test_helper.py: Mixin for testing HTTP endpoints.
  Provides methods to make requests and check responses.
"""
# Pylint 4.0.x misclassifies test_cbrws imports as third-party.
# Revisit this once Pylint 4.1 known-first-party support is available.
# pylint: disable=wrong-import-order
import asyncio
from html.parser import HTMLParser
from typing import Any, Container, Iterable, Protocol

from httpx import Response
from starlette import status
from starlette.applications import Starlette
from starlette.routing import Route
from starlette.testclient import TestClient

from cbrws.api_endpoint import APIEndpoint
from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
from cbrws.config import Settings
from cbrws.greeting_endpoint import GreetingEndpoint
from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
from cbrws.application import app
from test_cbrws.link_header import Link, parse


class HTMLTitleParser(HTMLParser):
  """
    Minimal HTML parser that extracts the document title.
  """
  def __init__(self) -> None:
    super().__init__()
    self.in_title = False
    self.title_parts: list[str] = []

  def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
    if tag == 'title':
      self.in_title = True

  def handle_endtag(self, tag: str) -> None:
    if tag == 'title':
      self.in_title = False

  def handle_data(self, data: str) -> None:
    if self.in_title:
      self.title_parts.append(data)

  @property
  def title(self) -> str:
    """ The parsed document title. """
    return ''.join(self.title_parts).strip()


# noinspection PyPep8Naming
class RequireAsserts(Protocol):
  """
    Protocol to require assert methods for testing.
    This is used to ensure that the test mixin has the necessary
    assert methods available.
  """
  def assertIn(  # pylint: disable=invalid-name
        self,
        member: Any,
        container: Iterable[Any] | Container[Any],
        msg: Any | None = None) -> None:
    """ Assert that member is present in the given container. """

  def assertNotIn(  # pylint: disable=invalid-name
        self,
        member: Any,
        container: Iterable[Any] | Container[Any],
        msg: Any | None = None) -> None:
    """ Assert that member is not present in the given container. """

  def assertEqual(  # pylint: disable=invalid-name
        self,
        first: Any,
        second: Any,
        msg: Any | None = None) -> None:
    """ Assert that first and second compare as equal. """


class SupportsFileLoading(Protocol):
  """
    Protocol for endpoint classes that expose async file loading helpers.
  """
  @classmethod
  async def load_file(
        cls,
        filename: str,
        context: dict[str, str]) -> str:
    """ Load a rendered file as a string. """

  @classmethod
  async def load_json(
        cls,
        filename: str,
        context: dict[str, str]) -> dict[str, Any]:
    """ Load a rendered JSON document as a dictionary. """


# This mixin intentionally exposes many small reusable test helper methods.
# pylint: disable=too-many-public-methods
class CommonTestHelper(RequireAsserts):
  """
    Mixin for testing HTTP endpoints.
    Provides methods to make requests and check responses.
  """
  @property
  def base_url(self) -> str:
    """ The base url for testing endpoints. """
    return 'http://localhost:5101'

  @property
  def endpoint_url(self) -> str:
    """ The URL used by shared endpoint behavior tests. """
    return '/'

  @property
  def profile_url(self) -> str:
    """ Expected profile URL for the cbrws web service API. """
    return f'{self.base_url}/profiles/cbrws/v1'

  @property
  def schema_url(self) -> str:
    """ Expected schema URL for the cbrws web service API. """
    return self.profile_url

  @property
  def response_media_type(self) -> str:
    """ Expected media type for the cbrws web service API response. """
    return 'application/hal+json'

  @property
  def profile_media_type(self) -> str:
    """ Expected media type for the cbrws web service profile. """
    return 'application/ld+json'

  @property
  def profile_link_title(self) -> str:
    """ Expected title for the profile Link header item. """
    return 'API version identifier(URI) for the cbrws web service'

  @property
  def documentation_link_title(self) -> str:
    """ Expected title for the documentation Link header item. """
    return 'Documentation for the cbrws web service API'

  @property
  def schema_media_type(self) -> str:
    """ Expected media type for the cbrws web service schema. """
    return 'application/schema+json'

  @property
  def problem_media_type(self) -> str:
    """ Expected media type for problem responses. """
    return 'application/problem+json'

  def make_request(
        self,
        method: str,
        url: str,
        headers: dict[str, str] | None = None) -> Response:
    """
      Helper function to make a request to the root endpoint.
      :param method: The HTTP method to use (e.g., 'get', 'head')
      :param url: The URL to request
      :param headers: Optional request headers
      :return: The response object
    """
    client = TestClient(app, self.base_url)
    return client.request(method, url=url, headers=headers, follow_redirects=False)

  def make_custom_test_client(
        self,
        api_endpoint_class: Any = APIEndpoint,
        greeting_endpoint_class: Any = GreetingEndpoint,
        base_url: str | None = None,
        allowed_hosts: tuple[str, ...] = ('localhost',)) -> TestClient:
    """
      Build a TestClient around a custom app route table for endpoint tests.
      :param api_endpoint_class: The endpoint class to route at /api
      :param greeting_endpoint_class: The endpoint class to route at /api/greeting
      :param base_url: Optional base URL override for the test client
      :param allowed_hosts: Allowed hosts to place in application settings
      :return: A configured test client
    """
    test_app = Starlette(routes=[
      Route('/api', api_endpoint_class, name=api_endpoint_class.route_name()),
      Route(
        '/api/greeting',
        greeting_endpoint_class,
        name=greeting_endpoint_class.route_name()),
      Route(
        '/profiles/cbrws/v1',
        APIV1SchemaEndpoint,
        name=APIV1SchemaEndpoint.route_name()),
      Route(
        '/profiles/cbrws/v1/rels/',
        RelationsDirectoryEndpoint,
        name=RelationsDirectoryEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingSchemaEndpoint,
            name=GreetingSchemaEndpoint.route_name())
    ])
    test_app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=allowed_hosts)
    return TestClient(test_app, base_url or self.base_url)

  def make_relations_test_client(
        self,
        relations_endpoint_class: Any = RelationsDirectoryEndpoint,
        base_url: str | None = None,
        allowed_hosts: tuple[str, ...] = ('localhost',)) -> TestClient:
    """
      Build a TestClient around the relations route table for endpoint tests.
      :param relations_endpoint_class: The endpoint class to route at the
        relations directory URL
      :param base_url: Optional base URL override for the test client
      :param allowed_hosts: Allowed hosts to place in application settings
      :return: A configured test client
    """
    test_app = Starlette(routes=[
      Route('/profiles/cbrws/v1/rels/',
            relations_endpoint_class,
            name=relations_endpoint_class.route_name()),
      Route('/profiles/cbrws/v1',
            APIV1SchemaEndpoint,
            name=APIV1SchemaEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingSchemaEndpoint,
            name=GreetingSchemaEndpoint.route_name())
    ])
    test_app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=allowed_hosts)
    return TestClient(test_app, base_url or self.base_url)

  def load_file(
        self,
        endpoint_class: type[SupportsFileLoading],
        filename: str,
        context: dict[str, str]) -> str:
    """
      Synchronously load a rendered file through an endpoint helper.
      :param endpoint_class: The endpoint class that provides load_file
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: The rendered file contents
    """
    return asyncio.run(endpoint_class.load_file(filename, context))

  def load_json(
        self,
        endpoint_class: type[SupportsFileLoading],
        filename: str,
        context: dict[str, str]) -> dict[str, Any]:
    """
      Synchronously load JSON through an endpoint helper.
      :param endpoint_class: The endpoint class that provides load_json
      :param filename: The name of the file to load
      :param context: The context to render the template with
      :return: A dictionary representing the JSON document
    """
    return asyncio.run(endpoint_class.load_json(filename, context))

  def check_allow(self, response: Response) -> None:
    """
      Check that the response has the correct Allow header.
      :param response: The response object
      :return: None
    """
    self.assertIn('Allow', response.headers)
    self.assertIn('GET', response.headers['Allow'])
    self.assertIn('HEAD', response.headers['Allow'])
    self.assertIn('OPTIONS', response.headers['Allow'])

  def check_link(self, response: Response) -> None:
    """
      Check that the response has the correct Link header.
      :param response: The response object
      :return: None
    """
    self.assertIn('Link', response.headers)
    link_header = response.headers['Link']
    self.assertIn(f'<{self.schema_url}>; rel="describedBy"', link_header)
    actual_links: dict[str, Link] = parse(link_header)
    expected_links: dict[str, Link] = {
      'profile': Link(
        url=self.profile_url,
        rel='profile',
        media_type='application/ld+json',
        title=self.profile_link_title),
      'describedBy': Link(
        url=self.schema_url,
        rel='describedBy',
        media_type='application/schema+json',
        title='JSON schema of the response'),
      'documentation': Link(
        url=self.schema_url,
        rel='documentation',
        media_type='text/html',
        title=self.documentation_link_title)
    }
    for rel, link in expected_links.items():
      self.assertIn(rel, actual_links)
      self.assertEqual(link, actual_links[rel])

  def check_content_type(self, response: Response, media_type: str) -> None:
    """
      Check that the response has the correct Content-Type header.
      :param response: The response object
      :param media_type: The expected media type (e.g., 'application/hal+json')
      :return: None
    """
    self.assertIn('Content-Type', response.headers)
    self.assertEqual(media_type, response.headers['Content-Type'])

  def check_endpoint_link(self, response: Response) -> None:
    """
      Check that the response has the correct endpoint Link header.
      :param response: The response object
      :return: None
    """
    self.check_link(response)

  def check_hal_success_response(self, response: Response) -> None:
    """
      Check the common headers for a successful HAL response.
      :param response: The response object
      :return: None
    """
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.check_endpoint_link(response)

  def check_head_response(self, response: Response) -> None:
    """
      Check the common headers and empty body for a HEAD response.
      :param response: The response object
      :return: None
    """
    self.check_hal_success_response(response)
    self.assertEqual(b'', response.content)

  def check_options_response(self, response: Response) -> None:
    """
      Check the common headers and empty body for an OPTIONS response.
      :param response: The response object
      :return: None
    """
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertEqual(b'', response.content)

  def check_not_acceptable_response(
        self,
        response: Response,
        supported_media_types: list[str]) -> None:
    """
      Check the common 406 response shape for unsupported Accept values.
      :param response: The response object
      :param supported_media_types: Supported media types for the endpoint
      :return: None
    """
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertEqual(
      {
        'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
        'title': 'Not Acceptable',
        'status': status.HTTP_406_NOT_ACCEPTABLE,
        'detail': (
          'The requested media type is not supported by this endpoint. '
          + 'Supported media types are: '
          + ', '.join(supported_media_types)),
        'supportedMediaTypes': supported_media_types
      },
      response.json())

  def check_success_without_link(
        self,
        response: Response,
        media_type: str) -> None:
    """
      Check a successful template response that does not emit Link headers.
      :param response: The response object
      :param media_type: The expected response media type
      :return: None
    """
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, media_type)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

  def check_html_response_without_link(
        self,
        response: Response,
        title: str,
        expected_fragments: list[str]) -> None:
    """
      Check an HTML template response that does not emit Link headers.
      :param response: The response object
      :param title: The expected HTML title
      :param expected_fragments: Fragments expected in the response body
      :return: None
    """
    self.check_success_without_link(response, 'text/html; charset=utf-8')
    parser = HTMLTitleParser()
    parser.feed(response.text)
    self.assertEqual(title, parser.title)
    for fragment in expected_fragments:
      self.assertIn(fragment, response.text)

  def assert_html_page_without_link(
        self,
        url: str,
        title: str,
        expected_fragments: list[str]) -> None:
    """
      Request a URL as HTML and check the rendered page.
      :param url: The URL to request
      :param title: The expected HTML title
      :param expected_fragments: Fragments expected in the response body
      :return: None
    """
    response = self.make_request(
      'GET',
      url,
      headers={'Accept': 'text/html'})
    self.check_html_response_without_link(response, title, expected_fragments)

  def check_head_without_link(
        self,
        response: Response,
        media_type: str) -> None:
    """
      Check a HEAD response that does not emit Link headers.
      :param response: The response object
      :param media_type: The expected response media type
      :return: None
    """
    expected_media_type = media_type
    if media_type == 'text/html':
      expected_media_type = 'text/html; charset=utf-8'
    self.check_success_without_link(response, expected_media_type)
    self.assertEqual('', response.text)

  def check_options_without_link(self, response: Response) -> None:
    """
      Check an OPTIONS response that does not emit Link headers.
      :param response: The response object
      :return: None
    """
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)

  def check_not_acceptable_without_link(
        self,
        response: Response,
        supported_media_types: list[str],
        check_allow: bool = True) -> None:
    """
      Check a 406 response that does not emit Link headers.
      :param response: The response object
      :param supported_media_types: Supported media types for the endpoint
      :param check_allow: Whether to assert the Allow header is present
      :return: None
    """
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
    if check_allow:
      self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(
      {
        'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
        'title': 'Not Acceptable',
        'status': status.HTTP_406_NOT_ACCEPTABLE,
        'detail': (
          'The requested media type is not supported by this endpoint. '
          + 'Supported media types are: '
          + ', '.join(supported_media_types)),
        'supportedMediaTypes': supported_media_types
      },
      response.json())

  def assert_html_response_without_link(
        self,
        url: str,
        title: str,
        expected_fragments: list[str]) -> None:
    """
      Request a URL as HTML and check the response without Link headers.
      :param url: The URL to request
      :param title: The expected HTML title
      :param expected_fragments: Fragments expected in the response body
      :return: None
    """
    response = self.make_request(
      'GET',
      url,
      headers={'Accept': 'text/html'})
    self.check_html_response_without_link(response, title, expected_fragments)

  def assert_not_acceptable_without_link(
        self,
        url: str,
        supported_media_types: list[str],
        accept_header: str = 'application/xml',
        check_allow: bool = True) -> None:
    """
      Request a URL with an unsupported Accept value and check the 406 response.
      :param url: The URL to request
      :param supported_media_types: Supported media types for the endpoint
      :param accept_header: The Accept header value to send
      :param check_allow: Whether to assert the Allow header is present
      :return: None
    """
    response = self.make_request(
      'GET',
      url,
      headers={'Accept': accept_header})
    self.check_not_acceptable_without_link(
      response,
      supported_media_types,
      check_allow=check_allow)

  def assert_head_without_link(self, url: str, media_type: str) -> None:
    """
      Request a URL with HEAD and check the response without Link headers.
      :param url: The URL to request
      :param media_type: The expected response media type
      :return: None
    """
    response = self.make_request(
      'HEAD',
      url,
      headers={'Accept': media_type})
    self.check_head_without_link(response, media_type)

  def assert_options_without_link(self, url: str) -> None:
    """
      Request a URL with OPTIONS and check the response without Link headers.
      :param url: The URL to request
      :return: None
    """
    response = self.make_request('OPTIONS', url)
    self.check_options_without_link(response)

  def check_problem_response(
        self,
        response: Response,
        expected_status: int,
        expected_problem: dict[str, str | int],
        expected_media_type: str | None = None) -> None:
    """
      Check a problem+json style response body and content type.
      :param response: The response object
      :param expected_status: The expected status code
      :param expected_problem: Expected type, title, status, and detail values
      :param expected_media_type: Optional override for the content type
      :return: None
    """
    self.assertEqual(expected_status, response.status_code)
    self.check_content_type(
      response,
      expected_media_type or self.problem_media_type)
    data = response.json()
    self.assertIn('type', data)
    self.assertIn('title', data)
    self.assertIn('status', data)
    self.assertIn('detail', data)
    self.assertEqual(expected_problem, data)

class TestHelper(CommonTestHelper):
  """
    Shared endpoint behavior tests for concrete endpoint test cases.
  """

  def test_options(self) -> None:
    """
      Test that OPTIONS returns allowed methods and links.
      :param self:
      :return: None
    """
    # We specify a base URL to ensure that the Link header contains
    # URLs that we can test for. This is important for the test to
    # correctly parse the Link header and verify the links.
    # Otherwise, TestClient will use the default base URL of
    # 'http://testserver'. We could also use this, but it is better to
    # be explicit about the base URL. The URL also matches the URL
    # used when accessing the webservice from the local host on which
    # the webservice is running. Although this is not strictly
    # necessary. It's just for consistency.
    response = self.make_request('OPTIONS', self.endpoint_url)
    self.check_allow(response)
    self.check_endpoint_link(response)

  def test_disallowed_methods(self) -> None:
    """
      Test that methods other than GET, HEAD, and OPTIONS return a 405
      Method Not Allowed response.
      :return: None
    """
    def make_assertions(r: Response) -> None:
      """ Make assertions on the response for disallowed methods."""
      self.assertEqual(status.HTTP_405_METHOD_NOT_ALLOWED, r.status_code)
      self.check_allow(r)
      self.check_content_type(r, self.problem_media_type)
      data = r.json()
      self.assertIn('type', data)
      self.assertIn('title', data)
      self.assertIn('status', data)
      self.assertIn('detail', data)
      self.assertEqual(
        data['type'],
        'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405')
      self.assertEqual(data['title'], 'Method Not Allowed')
      self.assertEqual(data['status'], status.HTTP_405_METHOD_NOT_ALLOWED)
      self.assertEqual(
        data['detail'],
        'The requested method is not allowed for this resource.'
        + ' See the Allow header for allowed methods.')

    for method in ['POST', 'PUT', 'DELETE', 'PATCH']:
      # Use the make_request helper to send the request
      # to the endpoint under test with the specified method.
      response = self.make_request(method, self.endpoint_url)
      make_assertions(response)
