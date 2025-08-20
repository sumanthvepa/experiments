"""
  test_api_endpoint.py: Unit tests for the /api endpoint of the
  cbrws webservice.
"""
import unittest

from httpx import Response
from starlette import status
from starlette.testclient import TestClient

from cbrws.application import app
from test_cbrws.link_header import Link, parse


class TestAPIEndpoint(unittest.TestCase):
  """
    Unit tests for the / route of the cbrws webservice
  """
  def test_get(self) -> None:
    """
      Test that get /api returns a hal+json response with the
      correct headers and links.
      :return: None
    """
    base_url = 'http://localhost:5101'
    client = TestClient(app, base_url=base_url)
    response: Response = client.get('/api', follow_redirects=False)
    self.assertEqual(status.HTTP_200_OK, response.status_code)

    profile_url = f'{base_url}/profiles/cbrws/v1'
    schema_url = f'{profile_url}/api.schema'

    self.assertIn('Content-Type', response.headers)
    self.assertEqual(f'application/hal+json; profile="{profile_url}"', response.headers['Content-Type'])

    self.assertIn('Link', response.headers)
    link_header = response.headers['Link']
    actual_links: dict[str, Link] = parse(link_header)
    expected_links: dict[str, Link] = {
      'profile': Link(
        url=profile_url,
        rel='profile',
        media_type='application/ld+json',
        title='API version identifier(URI) for the cbrws web service'),
      'describedBy': Link(
        url=schema_url,
        rel='describedBy',
        media_type='application/schema+json',
        title='JSON schema of the response'),
      'documentation': Link(
        url=schema_url,
        rel='documentation',
        media_type='text/html',
        title='Documentation for the cbrws web service API')
    }
    for rel, link in expected_links.items():
      self.assertIn(rel, actual_links)
      self.assertEqual(expected_links[rel], actual_links[rel])

    actual_data = response.json()
    expected_data = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': base_url + '/api',
          'type': 'application/hal+json',
          'profile': profile_url
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': base_url + '/profiles/cbrws/v1/rels/{rel}',
            'templated': True,
            'media_type': 'application/schema+json',
            'profile': profile_url
          }
        ],
        'cbrws:greeting': {
          'href': base_url + '/api/greeting',
          'rel': 'greeting',
          'media_type': 'application/hal+json',
          'profile': profile_url
        }
      }
    }
    self.assertDictEqual(actual_data, expected_data)

  def test_head(self) -> None:
    """
      Test that head /api returns a
      :return: None
    """
    base_url = 'http://localhost:5101'
    client = TestClient(app, base_url=base_url)
    response: Response = client.head('/api', follow_redirects=False)
    self.assertEqual(status.HTTP_200_OK, response.status_code)

    profile_url = f'{base_url}/profiles/cbrws/v1'
    schema_url = f'{profile_url}/api.schema'

    headers = response.headers
    content_type = response.headers['Content-Type']
    self.assertEqual(f'application/hal+json; profile="{profile_url}"', content_type)

    self.assertIn('Link', response.headers)
    link_header = response.headers['Link']
    actual_links: dict[str, Link] = parse(link_header)
    expected_links: dict[str, Link] = {
      'profile': Link(
        url=profile_url,
        rel='profile',
        media_type='application/ld+json',
        title='API version identifier(URI) for the cbrws web service'),
      'describedBy': Link(
        url=schema_url,
        rel='describedBy',
        media_type='application/schema+json',
        title='JSON schema of the response'),
      'documentation': Link(
        url=schema_url,
        rel='documentation',
        media_type='text/html',
        title='Documentation for the cbrws web service API')
    }
    for rel, link in expected_links.items():
      self.assertIn(rel, actual_links)
      self.assertEqual(expected_links[rel], actual_links[rel])

  def test_options(self) -> None:
    """
      Test that options / returns a 200 OK response with the correct headers
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
    profile_url = f'{base_url}/profiles/cbrws/v1'
    schema_url = f'{profile_url}/api.schema'
    expected_links: dict[str, Link] = {
      'profile': Link(
        url=profile_url,
        rel='profile',
        media_type='application/ld+json',
        title='API version identifier(URI) for the cbrws web service'),
      'describedBy': Link(
        url=schema_url,
        rel='describedBy',
        media_type='application/schema+json',
        title='JSON schema of the response'),
      'documentation': Link(
        url=schema_url,
        rel='documentation',
        media_type='text/html',
        title='Documentation for the cbrws web service API')
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
      self.assertEqual('application/problem+json', r.headers['Content-Type'])
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
