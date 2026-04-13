"""
  test_api_endpoint.py: Unit tests for the /api endpoint of the
  cbrws webservice.
"""
import unittest

from starlette import status

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
            'media_type': self.schema_media_type,
            'profile': self.profile_url
          }
        ],
        'cbrws:greeting': {
          'href': self.base_url + '/api/greeting',
          'rel': 'greeting',
          'media_type': self.response_media_type,
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
