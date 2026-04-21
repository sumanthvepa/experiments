"""
  test_profiles_endpoint.py: Unit tests for the /profiles/ endpoint of
  the cbrws webservice.
"""
import unittest

from test_cbrws.test_helper import TestHelper


class TestProfilesEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the profiles directory route.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The profiles directory URL
    """
    return '/profiles/'

  @property
  def profiles_directory_url(self) -> str:
    """
      Expected URL for the profiles directory.
      :return: The profiles directory URL
    """
    return f'{self.base_url}/profiles/'

  @property
  def cbrws_directory_url(self) -> str:
    """
      Expected URL for the CBRWS directory.
      :return: The CBRWS directory URL
    """
    return f'{self.base_url}/profiles/cbrws'

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
      Test that GET /profiles/ returns the current HAL directory.
      :return: None
    """
    response = self.make_request('GET', '/profiles/')
    self.check_success_without_link(response, self.hal_media_type)

    data = response.json()
    self.assertEqual('Profiles Directory', data['title'])
    self.assertIn('top-level directory', data['description'])
    self.assertEqual(self.profiles_directory_url, data['_links']['self']['href'])
    self.assertEqual(self.hal_media_type, data['_links']['self']['type'])
    self.assertEqual(self.cbrws_directory_url, data['_links']['item'][0]['href'])
    self.assertEqual('CBRWS profile family', data['_links']['item'][0]['title'])
    self.assertEqual(self.hal_media_type, data['_links']['item'][0]['type'])

  def test_get_hal_json_with_accept_header(self) -> None:
    """
      Test that GET /profiles/ returns HAL JSON when requested.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/',
      headers={'Accept': self.hal_media_type})
    self.check_success_without_link(response, self.hal_media_type)

    data = response.json()
    self.assertEqual(self.profiles_directory_url, data['_links']['self']['href'])
    self.assertEqual(self.cbrws_directory_url, data['_links']['item'][0]['href'])

  def test_get_html(self) -> None:
    """
      Test that GET /profiles/ returns HTML when requested.
      :return: None
    """
    self.assert_html_response_without_link(
      '/profiles/',
      'Profiles Directory',
      [
        '<h1>Profiles Directory</h1>',
        self.profiles_directory_url,
        self.cbrws_directory_url,
        '<code>application/hal+json</code>',
        '<code>text/html</code>'
      ])

  def test_get_unsupported_media_type(self) -> None:
    """
      Test that unsupported Accept values return 406.
      :return: None
    """
    self.assert_not_acceptable_without_link(
      '/profiles/',
      ['application/hal+json', 'text/html'])

  def test_get_partial_html_media_type_is_unsupported(self) -> None:
    """
      Test that media types are not matched by substring.
      :return: None
    """
    self.assert_not_acceptable_without_link(
      '/profiles/',
      ['application/hal+json', 'text/html'],
      accept_header='text/html-fragment',
      check_allow=False)

  def test_head_hal_json(self) -> None:
    """
      Test that HEAD /profiles/ returns HAL JSON headers.
      :return: None
    """
    self.assert_head_without_link('/profiles/', self.hal_media_type)

  def test_head_html(self) -> None:
    """
      Test that HEAD /profiles/ returns HTML headers when requested.
      :return: None
    """
    self.assert_head_without_link('/profiles/', 'text/html')

  def test_options_profiles(self) -> None:
    """
      Test that OPTIONS /profiles/ returns no Link header.
      :return: None
    """
    self.assert_options_without_link('/profiles/')
