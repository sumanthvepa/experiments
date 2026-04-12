"""
  test_greeting_endpoint.py: Unit tests for the /api/greeting endpoint
  of the cbrws webservice.
"""
import unittest

from starlette import status

from test_cbrws.test_helper import TestHelper


class TestGreetingEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the /api/greeting route of the cbrws webservice
  """
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
