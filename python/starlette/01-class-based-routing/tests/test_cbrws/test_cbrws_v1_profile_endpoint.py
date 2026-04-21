"""
  test_cbrws_v1_profile_endpoint.py: Unit tests for the
  /profiles/cbrws/v1 endpoint of the cbrws webservice.
"""
import unittest
from pathlib import Path

from starlette import status

from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
from test_cbrws.test_helper import HTMLTitleParser, TestHelper


class TestCBRWSV1ProfileEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the profile documentation route.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The CBRWS v1 profile endpoint URL
    """
    return '/profiles/cbrws/v1'

  @property
  def cbrws_directory_url(self) -> str:
    """
      Expected URL for the parent CBRWS directory.
      :return: The CBRWS directory URL
    """
    return f'{self.base_url}/profiles/cbrws'

  @property
  def api_url(self) -> str:
    """
      Expected URL for the API discovery endpoint.
      :return: The API endpoint URL
    """
    return f'{self.base_url}/api'

  @property
  def greeting_url(self) -> str:
    """
      Expected URL for the greeting endpoint.
      :return: The greeting endpoint URL
    """
    return f'{self.base_url}/api/greeting'

  @property
  def greeting_relation_url(self) -> str:
    """
      Expected URL for the greeting relation profile.
      :return: The greeting relation profile URL
    """
    return f'{self.base_url}/profiles/cbrws/v1/rels/greeting'

  @property
  def relations_directory_url(self) -> str:
    """
      Expected URL for the relations directory.
      :return: The relations directory URL
    """
    return f'{self.base_url}/profiles/cbrws/v1/rels/'

  def check_endpoint_link(self, response: object) -> None:
    """
      Template endpoints do not emit Link headers.
      :param response: The response object
      :return: None
    """
    return None

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
    self.assertNotIn('Link', response.headers)

    parser = HTMLTitleParser()
    parser.feed(response.text)
    self.assertEqual('CBRWS API v1 Schema', parser.title)
    self.assertIn('<h1>CBRWS API v1 Schema</h1>', response.text)
    self.assertIn(self.profile_url, response.text)
    self.assertIn(self.cbrws_directory_url, response.text)
    self.assertIn(self.api_url, response.text)
    self.assertIn(self.greeting_url, response.text)
    self.assertIn(self.greeting_relation_url, response.text)
    self.assertIn(self.relations_directory_url, response.text)
    self.assertIn('application/schema+json', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the profile endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.assertNotIn('Link', response.headers)

    expected_data = self.load_json(
      APIV1SchemaEndpoint,
      str(Path(APIV1SchemaEndpoint.schema_dir()) / 'api-v1-schema.json'),
      {
        'title': 'CBRWS API v1 Schema',
        'schema_url': self.profile_url,
        'cbrws_directory_url': self.cbrws_directory_url,
        'api_url': self.api_url,
        'api_media_type': self.response_media_type,
        'greeting_url': self.greeting_url,
        'greeting_relation_url': self.greeting_relation_url,
        'relations_directory_url': self.relations_directory_url,
        'curie_href_template': self.relations_directory_url.rstrip('/') + '/{rel}'
      })
    self.assertDictEqual(response.json(), expected_data)

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
    self.assertNotIn('Link', response.headers)
