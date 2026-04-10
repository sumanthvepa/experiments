"""
  test_greeting_relation_endpoint.py: Unit tests for the
  /profiles/cbrws/v1/rels/greeting endpoint of the cbrws webservice.
"""
import unittest

from starlette import status

from test_cbrws.test_helper import TestHelper


class TestGreetingRelationEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the greeting relation documentation route.
  """
  def test_get_html(self) -> None:
    """
      Test that the relation endpoint returns HTML documentation.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws/v1/rels/greeting',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_link(response)
    self.assertIn('cbrws:greeting', response.text)
    self.assertIn('/api/greeting', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the relation endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1/rels/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.check_link(response)
    data = response.json()
    self.assertEqual(data['type'], 'object')
    self.assertIn('message', data['properties'])
    self.assertIn('_links', data['properties'])
