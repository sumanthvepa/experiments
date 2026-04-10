"""
  test_cbrws_v1_profile_endpoint.py: Unit tests for the
  /profiles/cbrws/v1 endpoint of the cbrws webservice.
"""
import unittest

from starlette import status

from test_cbrws.test_helper import TestHelper


class TestCBRWSV1ProfileEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the profile documentation route.
  """
  def test_get_html(self) -> None:
    """
      Test that the profile endpoint returns HTML documentation.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws/v1',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_link(response)
    self.assertIn('CBRWS API Profile', response.text)
    self.assertIn('/api', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the profile endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.check_link(response)
    data = response.json()
    self.assertEqual(data['type'], 'object')
    self.assertIn('title', data['properties'])
    self.assertIn('_links', data['properties'])

  def test_get_unsupported_media_type(self) -> None:
    """
      Test that unsupported Accept values return 406.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws/v1',
      headers={'Accept': 'application/xml'})
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
