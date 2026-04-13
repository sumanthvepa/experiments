"""
  test_greeting_relation_profile_endpoint.py: Unit tests for the
  /profiles/cbrws/v1/rels/greeting endpoint of the cbrws webservice.
"""
import asyncio
import unittest

from starlette import status

from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint
from test_cbrws.test_helper import HTMLTitleParser, TestHelper


class TestGreetingRelationProfileEndpoint(unittest.TestCase, TestHelper):
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
    parser = HTMLTitleParser()
    parser.feed(response.text)
    expected_title = 'CBRWS V1 Greeting Relation'
    self.assertEqual(expected_title, parser.title)
    self.assertIn(
      f'<h1>{expected_title}: <code>cbrws:greeting</code></h1>',
      response.text)
    self.assertIn(self.profile_url, response.text)
    self.assertIn(self.profile_url + '/rels/', response.text)
    self.assertIn(self.profile_url + '/rels/greeting', response.text)
    self.assertIn(self.base_url + '/api/greeting', response.text)
    self.assertIn(self.response_media_type, response.text)
    self.assertIn('application/schema+json', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the relation endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1/rels/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.check_link(response)
    expected_data = asyncio.run(CBRWSV1ProfileEndpoint.load_schema(
      str(CBRWSV1ProfileEndpoint.SCHEMA_DIR / 'greeting-rel-v1.json'),
      {
        'profile_url': self.profile_url,
        'relations_url': self.profile_url + '/rels/',
        'relation_url': self.profile_url + '/rels/greeting',
        'resource_url': self.base_url + '/api/greeting',
        'resource_media_type': self.response_media_type
      }))
    self.assertDictEqual(response.json(), expected_data)
