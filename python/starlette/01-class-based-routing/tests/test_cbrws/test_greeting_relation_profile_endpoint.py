"""
  test_greeting_relation_profile_endpoint.py: Unit tests for the
  /profiles/cbrws/v1/rels/greeting endpoint of the cbrws webservice.
"""
# Pylint 4.0.x misclassifies test_cbrws imports as third-party.
# Revisit this once Pylint 4.1 known-first-party support is available.
# pylint: disable=wrong-import-order
import unittest
from pathlib import Path

from starlette import status

from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
from test_cbrws.test_helper import HTMLTitleParser, TestHelper


class TestGreetingRelationProfileEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the greeting relation documentation route.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The greeting relation endpoint URL
    """
    return '/profiles/cbrws/v1/rels/greeting'

  @property
  def relation_url(self) -> str:
    """
      Expected URL for the greeting relation documentation.
      :return: The greeting relation URL
    """
    return f'{self.base_url}/profiles/cbrws/v1/rels/greeting'

  @property
  def relations_directory_url(self) -> str:
    """
      Expected URL for the parent relations directory.
      :return: The relations directory URL
    """
    return f'{self.base_url}/profiles/cbrws/v1/rels/'

  @property
  def api_url(self) -> str:
    """
      Expected URL for the API discovery endpoint.
      :return: The API endpoint URL
    """
    return f'{self.base_url}/api'

  @property
  def api_schema_url(self) -> str:
    """
      Expected URL for the API schema document.
      :return: The API schema URL
    """
    return f'{self.base_url}/profiles/cbrws/v1'

  @property
  def service_url(self) -> str:
    """
      Expected URL for the greeting service endpoint.
      :return: The greeting endpoint URL
    """
    return f'{self.base_url}/api/greeting'

  def check_endpoint_link(self, response: object) -> None:
    """
      Template endpoints do not emit Link headers.
      :param response: The response object
      :return: None
    """
    return None

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
    self.assertNotIn('Link', response.headers)

    parser = HTMLTitleParser()
    parser.feed(response.text)
    expected_title = 'CBRWS V1 Greeting Schema'
    self.assertEqual(expected_title, parser.title)
    self.assertIn(f'<h1>{expected_title}</h1>', response.text)
    self.assertIn(self.relation_url, response.text)
    self.assertIn(self.relations_directory_url, response.text)
    self.assertIn(self.service_url, response.text)
    self.assertIn(self.api_url, response.text)
    self.assertIn(self.api_schema_url, response.text)
    self.assertIn(self.response_media_type, response.text)
    self.assertIn('application/schema+json', response.text)
    self.assertIn('cbrws:greeting', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the relation endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1/rels/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.assertNotIn('Link', response.headers)

    expected_data = self.load_json(
      GreetingSchemaEndpoint,
      str(Path(GreetingSchemaEndpoint.schema_dir()) / 'greeting-rel-v1.json'),
      {
        'title': 'CBRWS V1 Greeting Schema',
        'description': 'Schema for the /api/greeting response',
        'parent_url': self.relations_directory_url,
        'schema_url': self.relation_url,
        'service_url': self.service_url,
        'service_media_type': self.response_media_type,
        'api_url': self.api_url,
        'api_schema_url': self.api_schema_url
      })
    self.assertDictEqual(response.json(), expected_data)
