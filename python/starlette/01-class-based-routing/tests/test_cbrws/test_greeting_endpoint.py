"""
  test_greeting_endpoint.py: Unit tests for the /api/greeting endpoint
  of the cbrws webservice.
"""
import unittest

from starlette.applications import Starlette
from starlette.routing import Route
from starlette import status
from starlette.testclient import TestClient

from cbrws.api_endpoint import APIEndpoint
from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint
from cbrws.greeting_endpoint import GreetingEndpoint
from cbrws.greeting_relation_profile_endpoint import GreetingRelationProfileEndpoint
from test_cbrws.test_helper import TestHelper


class TestGreetingEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the /api/greeting route of the cbrws webservice
  """
  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The greeting endpoint URL
    """
    return '/api/greeting'

  def test_get(self) -> None:
    """
      Test that get /api/greeting returns a hal+json response with the
      greeting resource.
      :return: None
    """
    self.maxDiff = 2048
    response = self.make_request('GET', '/api/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.response_media_type)
    self.check_link(response)
    actual_data = response.json()
    expected_data = {
      'message': 'Hello, world!',
      '_links': {
        'self': {
          'href': self.base_url + '/api/greeting',
          'type': self.response_media_type,
          'profile': self.profile_url + '/rels/greeting'
        },
        'up': {
          'href': self.base_url + '/api',
          'type': self.response_media_type,
          'profile': self.profile_url
        }
      }
    }
    self.assertDictEqual(actual_data, expected_data)

  def test_head(self) -> None:
    """
      Test that head /api/greeting returns the resource headers.
      :return: None
    """
    response = self.make_request('HEAD', '/api/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.response_media_type)
    self.check_link(response)

  def test_get_uses_subclass_response_media_type(self) -> None:
    """
      Test that GET /api/greeting uses a subclass response media type.
      :return: None
    """
    class CustomGreetingEndpoint(GreetingEndpoint):
      """ Greeting endpoint with a custom response media type. """
      RESPONSE_MEDIA_TYPE = 'application/vnd.example.greeting+json'
      SUPPORTED_MEDIA_TYPES = [
        'application/vnd.example.greeting+json',
        '*/*']

    app = Starlette(routes=[
      Route('/api', APIEndpoint, name='api_endpoint'),
      Route('/api/greeting', CustomGreetingEndpoint, name='greeting_endpoint'),
      Route('/profiles/cbrws/v1', CBRWSV1ProfileEndpoint, name='profile_endpoint'),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingRelationProfileEndpoint,
            name='greeting_relation_endpoint')
    ])
    client = TestClient(app, self.base_url)
    response = client.get('/api/greeting')
    data = response.json()
    self.check_content_type(
      response,
      CustomGreetingEndpoint.RESPONSE_MEDIA_TYPE)
    self.assertEqual(
      CustomGreetingEndpoint.RESPONSE_MEDIA_TYPE,
      data['_links']['self']['type'])
    self.assertEqual(
      CustomGreetingEndpoint.RESPONSE_MEDIA_TYPE,
      data['_links']['up']['type'])
