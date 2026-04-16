"""
  test_helper.py: Mixin for testing HTTP endpoints.
  Provides methods to make requests and check responses.
"""
import asyncio
from html.parser import HTMLParser
from typing import Any, Container, Iterable, Protocol

from httpx import Response
from starlette import status
from starlette.testclient import TestClient

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
  def assertIn(self, member: Any, container: Iterable[Any] | Container[Any], msg: Any | None = None) -> None: ...
  def assertEqual(self, first: Any, second: Any, msg: Any | None = None) -> None: ...


class TestHelper(RequireAsserts):
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
  def schema_media_type(self) -> str:
    """ Expected media type for the cbrws web service schema. """
    return 'application/schema+json'

  @property
  def problem_media_type(self) -> str:
    """ Expected media type for problem responses. """
    return 'application/problem+json'

  def make_request(self, method: str, url: str, headers: dict[str, str] | None = None) -> Response:
    """
      Helper function to make a request to the root endpoint.
      :param method: The HTTP method to use (e.g., 'get', 'head')
      :param url: The URL to request
      :param headers: Optional request headers
      :return: The response object
    """
    client = TestClient(app, self.base_url)
    return client.request(method, url=url, headers=headers, follow_redirects=False)

  def load_file(
        self,
        endpoint_class: Any,
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
        endpoint_class: Any,
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
        title='API version identifier(URI) for the cbrws web service'),
      'describedBy': Link(
        url=self.schema_url,
        rel='describedBy',
        media_type='application/schema+json',
        title='JSON schema of the response'),
      'documentation': Link(
        url=self.schema_url,
        rel='documentation',
        media_type='text/html',
        title='Documentation for the cbrws web service API')
    }
    for rel, link in expected_links.items():
      self.assertIn(rel, actual_links)
      self.assertEqual(expected_links[rel], actual_links[rel])

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
