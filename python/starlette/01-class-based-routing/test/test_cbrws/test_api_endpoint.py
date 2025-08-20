"""
  test_api_endpoint.py: Unit tests for the /api endpoint of the
  cbrws webservice.
"""
import unittest

from starlette import status

from test_cbrws.http_endpoint_test_helper import HTTPEndpointTestHelper


class TestAPIEndpoint(unittest.TestCase, HTTPEndpointTestHelper):
  """
    Unit tests for the / route of the cbrws webservice
  """
  def test_get(self) -> None:
    """
      Test that get /api returns a hal+json response with the
      correct headers and links.
      :return: None
    """
    self.maxDiff = 2048
    response = self.make_request('GET', '/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, TestAPIEndpoint.response_media_type())
    self.check_link(response)
    actual_data = response.json()
    expected_data = {
      'title': 'CBRWS API',
      'version': '1.0',
      'description': 'This is the API endpoint for the cbrws web service.',
      '_links': {
        'self': {
          'href': TestAPIEndpoint.base_url() + '/api',
          'type': TestAPIEndpoint.response_media_type(),
          'profile': TestAPIEndpoint.profile_url()
        },
        'curies': [
          {
            'name': 'cbrws',
            'href': TestAPIEndpoint.base_url() + '/profiles/cbrws/v1/rels/{rel}',
            'templated': True,
            'media_type': TestAPIEndpoint.schema_media_type(),
            'profile': TestAPIEndpoint.profile_url()
          }
        ],
        'cbrws:greeting': {
          'href': TestAPIEndpoint.base_url() + '/api/greeting',
          'rel': 'greeting',
          'media_type': TestAPIEndpoint.response_media_type(),
          'profile': TestAPIEndpoint.profile_url(),
        }
      }
    }
    self.assertDictEqual(actual_data, expected_data)

  def test_head(self) -> None:
    """
      Test that head /api returns a
      :return: None
    """
    response = self.make_request('GET', '/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, TestAPIEndpoint.response_media_type())
    self.check_link(response)
