"""
  test_api_endpoint.py: Unit tests for the /api endpoint of the
  cbrws webservice.
"""
import unittest

from starlette.applications import Starlette
from starlette.routing import Route
from starlette import status
from starlette.testclient import TestClient

from cbrws.api_endpoint import APIEndpoint
from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint
from cbrws.config import Settings
from cbrws.greeting_endpoint import GreetingEndpoint
from cbrws.greeting_relation_profile_endpoint import GreetingRelationProfileEndpoint
from cbrws.relations_endpoint import RelationsEndpoint
from test_cbrws.test_helper import TestHelper


class TestAPIEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the / route of the cbrws webservice
  """
  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The API endpoint URL
    """
    return '/api'

  def test_get(self) -> None:
    """
      Test that get /api returns a hal+json response with the
      correct headers and links.
      :return: None
    """
    self.maxDiff = 2048
    response = self.make_request('GET', '/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.response_media_type)
    self.check_link(response)
    actual_data = response.json()
    expected_data = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': self.base_url + '/api',
          'type': self.response_media_type,
          'profile': self.profile_url
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': self.base_url + '/profiles/cbrws/v1/rels/{rel}',
            'templated': True,
            'type': self.schema_media_type,
            'profile': self.profile_url
          }
        ],
        'cbrws:greeting': {
          'href': self.base_url + '/api/greeting',
          'type': self.response_media_type,
          'profile': self.profile_url + '/rels/greeting',
        }
      }
    }
    self.assertDictEqual(actual_data, expected_data)

  def test_head(self) -> None:
    """
      Test that HEAD /api returns response headers without a body.
      :return: None
    """
    response = self.make_request('HEAD', '/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.response_media_type)
    self.check_link(response)
    self.assertEqual(b'', response.content)

  def test_get_uses_proxy_adjusted_request_origin_for_links(self) -> None:
    """
      Test that generated links use the request scheme and host.
      :return: None
    """
    app = Starlette(routes=[
      Route('/api', APIEndpoint, name='api_endpoint'),
      Route('/api/greeting', GreetingEndpoint, name='greeting_endpoint'),
      Route('/profiles/cbrws/v1', CBRWSV1ProfileEndpoint, name='profile_endpoint'),
      Route('/profiles/cbrws/v1/rels/', RelationsEndpoint, name='relations_endpoint'),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingRelationProfileEndpoint,
            name='greeting_relation_endpoint')
    ])
    app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=('api.example.com',))
    client = TestClient(app, 'https://api.example.com')
    response = client.get('/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    data = response.json()
    self.assertEqual(
      'https://api.example.com/api',
      data['_links']['self']['href'])
    self.assertEqual(
      'https://api.example.com/profiles/cbrws/v1',
      data['_links']['self']['profile'])
    self.assertEqual(
      'https://api.example.com/profiles/cbrws/v1/rels/{rel}',
      data['_links']['curies'][0]['href'])
    self.assertEqual(
      'https://api.example.com/api/greeting',
      data['_links']['cbrws:greeting']['href'])
    self.assertEqual(
      'https://api.example.com/profiles/cbrws/v1/rels/greeting',
      data['_links']['cbrws:greeting']['profile'])

  def test_get_uses_subclass_response_media_type(self) -> None:
    """
      Test that GET /api uses a subclass response media type.
      :return: None
    """
    class CustomAPIEndpoint(APIEndpoint):
      """ API endpoint with a custom response media type. """
      RESPONSE_MEDIA_TYPE = 'application/vnd.example.api+json'
      SUPPORTED_MEDIA_TYPES = ['application/vnd.example.api+json']

    app = Starlette(routes=[
      Route('/api', CustomAPIEndpoint, name='api_endpoint'),
      Route('/api/greeting', GreetingEndpoint, name='greeting_endpoint'),
      Route('/profiles/cbrws/v1', CBRWSV1ProfileEndpoint, name='profile_endpoint'),
      Route('/profiles/cbrws/v1/rels/', RelationsEndpoint, name='relations_endpoint'),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingRelationProfileEndpoint,
            name='greeting_relation_endpoint')
    ])
    app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=('localhost',))
    client = TestClient(app, self.base_url)
    response = client.get('/api')
    data = response.json()
    self.check_content_type(response, CustomAPIEndpoint.RESPONSE_MEDIA_TYPE)
    self.assertEqual(
      CustomAPIEndpoint.RESPONSE_MEDIA_TYPE,
      data['_links']['self']['type'])
    self.assertEqual(
      CustomAPIEndpoint.RESPONSE_MEDIA_TYPE,
      data['_links']['cbrws:greeting']['type'])
