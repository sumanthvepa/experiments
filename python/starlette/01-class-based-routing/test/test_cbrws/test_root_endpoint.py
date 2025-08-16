"""
  test_root_endpoint.py: Unit tests for the root endpoint(/) of the
  colophon webservice.
"""
import unittest

from httpx import Response
from starlette import status
from starlette.testclient import TestClient

from cbrws.application import app
from cbrws.root_endpoint import RootEndpoint
from test_cbrws.link_header import Link, parse


class TestRootEndpoint(unittest.TestCase):
  """
    Unit tests for the / route of the cbrws webservice
  """
  def test_get(self) -> None:
    """
      Test that get / returns a 308 Permanent Redirect response to the
      /api endpoint.
      :return: None
    """
    client = TestClient(app)
    # If follow_redirects is not set to False, the test client will
    # automatically follow the redirect, and the response will not be a
    # 308 Permanent Redirect. This will cause the test to fail.
    # Setting follow_redirects to False ensures that we get the 308
    response: Response = client.get('/', follow_redirects=False)
    self.assertEqual(status.HTTP_308_PERMANENT_REDIRECT, response.status_code)

  def test_head(self) -> None:
    """
      Test that head / returns a 308 Permanent Redirect response to the
      /api endpoint.
      :return: None
    """
    client = TestClient(app)
    response: Response = client.head('/', follow_redirects=False)
    self.assertEqual(status.HTTP_308_PERMANENT_REDIRECT, response.status_code)

  def test_options(self) -> None:
    """
      Test that options / returns a 200 OK response with the correct headers
      :param self:
      :return: None
    """
    # We specify a base URL to ensure that the Link header contains
    # URLs that we can test for This is important for the test to
    # correctly parse the Link header and verify the links.
    # Otherwise, TestClient will use the default base URL of
    # 'http://testserver'. We could also use this, but it is better to
    # be explicit about the base URL. The URL also matches the URL
    # used when accessing the webservice from the local host on which
    # the webservice is running. Although this is not strictly
    # necessary. It's just for consistency.
    base_url = 'http://localhost:5101'
    client = TestClient(app, base_url=base_url)
    response: Response = client.options('/')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.assertIn('Allow', response.headers)
    self.assertIn('GET', response.headers['Allow'])
    self.assertIn('HEAD', response.headers['Allow'])
    self.assertIn('OPTIONS', response.headers['Allow'])

    self.assertIn('Link', response.headers)
    link_header = response.headers['Link']
    actual_links: dict[str, Link] = parse(link_header)
    expected_links: dict[str, Link] = {
      'default': Link(
        url=RootEndpoint.default_media_type,
        rel='default',
        media_type=RootEndpoint.default_media_type_format),
      'schema': Link(
        url=base_url + '/' + RootEndpoint.schema_path,
        rel='schema',
        media_type=RootEndpoint.schema_format),
      'documentation': Link(
        url=base_url + '/' + RootEndpoint.documentation_path,
        rel='documentation',
        media_type=RootEndpoint.documentation_format)
    }
    for rel, link in expected_links.items():
      self.assertIn(rel, actual_links)
      self.assertEqual(expected_links[rel], actual_links[rel])

  def test_disallowed_methods(self) -> None:
    """
      Test that methods other than GET, HEAD, and OPTIONS return a 405
      Method Not Allowed response.
      :return: None
    """
    def make_assertions(r: Response) -> None:
      """ Make assertions on the response for disallowed methods."""
      self.assertEqual(status.HTTP_405_METHOD_NOT_ALLOWED, r.status_code)
      self.assertIn('Allow', r.headers)
      self.assertIn('GET', r.headers['Allow'])
      self.assertIn('HEAD', r.headers['Allow'])
      self.assertIn('OPTIONS', r.headers['Allow'])
      self.assertIn('Content-Type', r.headers)
      self.assertEqual('application/json', r.headers['Content-Type'])
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

    client = TestClient(app)
    response: Response = client.post('/')
    make_assertions(response)

    response = client.put('/')
    make_assertions(response)

    response = client.delete('/')
    make_assertions(response)

    response = client.patch('/')
    self.assertEqual(status.HTTP_405_METHOD_NOT_ALLOWED, response.status_code)
