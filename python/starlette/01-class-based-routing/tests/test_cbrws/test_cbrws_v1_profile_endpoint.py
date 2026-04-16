"""
  test_cbrws_v1_profile_endpoint.py: Unit tests for the
  /profiles/cbrws/v1 endpoint of the cbrws webservice.
"""
import unittest

from starlette import status

from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint
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
    parser = HTMLTitleParser()
    parser.feed(response.text)
    self.assertEqual('CBRWS V1 API Profile', parser.title)
    self.assertIn('<h1>CBRWS V1 API Profile</h1>', response.text)
    self.assertIn(self.profile_url, response.text)
    self.assertIn(self.schema_url, response.text)
    self.assertIn('/api', response.text)
    self.assertIn('application/schema+json', response.text)
    self.assertIn('/profiles/cbrws/v1/rels/{rel}', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the profile endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.check_link(response)
    expected_data = self.load_json(
      CBRWSV1ProfileEndpoint,
      str(CBRWSV1ProfileEndpoint.SCHEMA_DIR / 'api-profile-v1.json'),
      {
        'profile_url': self.profile_url,
        'schema_url': self.schema_url,
        'version': '1.0',
        'title': 'CBRWS V1 API Profile'
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
