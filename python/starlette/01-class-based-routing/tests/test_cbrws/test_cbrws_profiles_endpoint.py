"""
  test_cbrws_profiles_endpoint.py: Unit tests for the /profiles/cbrws
  endpoint of the cbrws webservice.
"""
import unittest

from test_cbrws.test_helper import TestHelper


class TestCBRWSProfilesEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the CBRWS profile versions directory route.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The CBRWS profile family URL
    """
    return '/profiles/cbrws'

  @property
  def cbrws_directory_url(self) -> str:
    """
      Expected URL for the CBRWS directory.
      :return: The CBRWS directory URL
    """
    return f'{self.base_url}/profiles/cbrws'

  @property
  def api_v1_schema_url(self) -> str:
    """
      Expected URL for the CBRWS v1 schema.
      :return: The v1 schema URL
    """
    return f'{self.base_url}/profiles/cbrws/v1'

  @property
  def hal_media_type(self) -> str:
    """
      Expected media type for HAL responses.
      :return: The HAL media type
    """
    return 'application/hal+json'

  def check_endpoint_link(self, response: object) -> None:
    """
      Template endpoints do not emit Link headers.
      :param response: The response object
      :return: None
    """
    return None

  def test_get_hal_json_by_default(self) -> None:
    """
      Test that GET /profiles/cbrws returns the current HAL directory.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws')
    self.check_success_without_link(response, self.hal_media_type)

    data = response.json()
    self.assertEqual('CBRWS Profile Versions', data['title'])
    self.assertIn('lists the versions of the CBRWS schema', data['description'])
    self.assertEqual(self.cbrws_directory_url, data['_links']['self']['href'])
    self.assertEqual(self.hal_media_type, data['_links']['self']['type'])
    self.assertEqual(self.api_v1_schema_url, data['_links']['item'][0]['href'])
    self.assertEqual('CBRWS v1 API profile', data['_links']['item'][0]['title'])
    self.assertEqual('application/schema+json', data['_links']['item'][0]['type'])

  def test_get_hal_json_with_accept_header(self) -> None:
    """
      Test that GET /profiles/cbrws returns HAL JSON when requested.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws',
      headers={'Accept': self.hal_media_type})
    self.check_success_without_link(response, self.hal_media_type)

    data = response.json()
    self.assertEqual(self.cbrws_directory_url, data['_links']['self']['href'])
    self.assertEqual(self.api_v1_schema_url, data['_links']['item'][0]['href'])

  def test_get_html(self) -> None:
    """
      Test that GET /profiles/cbrws returns HTML when requested.
      :return: None
    """
    self.assert_html_response_without_link(
      '/profiles/cbrws',
      'CBRWS Schema Versions',
      [
        '<h1>CBRWS Schema Versions</h1>',
        self.cbrws_directory_url,
        self.api_v1_schema_url,
        '<code>application/hal+json</code>',
        '<code>text/html</code>'
      ])

  def test_get_unsupported_media_type(self) -> None:
    """
      Test that unsupported Accept values return 406.
      :return: None
    """
    self.assert_not_acceptable_without_link(
      '/profiles/cbrws',
      ['application/hal+json', 'text/html'])

  def test_head_hal_json(self) -> None:
    """
      Test that HEAD /profiles/cbrws returns HAL JSON headers.
      :return: None
    """
    self.assert_head_without_link('/profiles/cbrws', self.hal_media_type)

  def test_head_html(self) -> None:
    """
      Test that HEAD /profiles/cbrws returns HTML headers when requested.
      :return: None
    """
    self.assert_head_without_link('/profiles/cbrws', 'text/html')

  def test_options_cbrws_profiles(self) -> None:
    """
      Test that OPTIONS /profiles/cbrws returns no Link header.
      :return: None
    """
    self.assert_options_without_link('/profiles/cbrws')
