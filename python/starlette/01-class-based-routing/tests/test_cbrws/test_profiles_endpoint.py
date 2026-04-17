"""
  test_profiles_endpoint.py: Unit tests for the /profiles/ endpoint of
  the cbrws webservice.
"""
import unittest
from pathlib import Path

from httpx import Response
from starlette import status

from cbrws.profiles_endpoint import ProfilesEndpoint
from test_cbrws.link_header import Link, parse
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
  def profiles_url(self) -> str:
    """
      Expected URL for the 'profiles' directory.
      :return: The profiles directory URL
    """
    return f'{self.base_url}/profiles/'

  @property
  def cbrws_profile_url(self) -> str:
    """
      Expected URL for the CBRWS profile family.
      :return: The CBRWS profile family URL
    """
    return f'{self.base_url}/profiles/cbrws'

  @property
  def hal_media_type(self) -> str:
    """
      Expected media type for HAL responses.
      :return: The HAL media type
    """
    return 'application/hal+json'

  @property
  def template_context(self) -> dict[str, str]:
    """
      Expected template context for the 'profiles' directory.
      :return: The template context
    """
    return {
      'profiles_url': self.profiles_url,
      'cbrws_profile_url': self.cbrws_profile_url
    }

  def check_profiles_link(self, response: Response) -> None:
    """
      Check that the response has the profiles directory Link header.
      :param response: The response object
      :return: None
    """
    self.assertIn('Link', response.headers)
    actual_links: dict[str, Link] = parse(response.headers['Link'])
    expected_links: dict[str, Link] = {
      'self': Link(
        url=self.profiles_url,
        rel='self',
        media_type=self.hal_media_type),
      'item': Link(
        url=self.cbrws_profile_url,
        rel='item',
        media_type=self.hal_media_type,
        title='CBRWS profile family')
    }
    for rel, link in expected_links.items():
      self.assertIn(rel, actual_links)
      self.assertEqual(link, actual_links[rel])

  def check_endpoint_link(self, response: Response) -> None:
    """
      Check that the response has the profiles directory Link header.
      :param response: The response object
      :return: None
    """
    self.check_profiles_link(response)

  def test_get_hal_json_by_default(self) -> None:
    """
      Test that GET /profiles/ returns HAL JSON by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.hal_media_type)
    self.check_allow(response)
    self.check_profiles_link(response)
    expected_data = self.load_json(
      ProfilesEndpoint,
      str(Path(ProfilesEndpoint.schema_dir()) / 'profiles.json'),
      self.template_context)
    self.assertDictEqual(response.json(), expected_data)

  def test_get_hal_json_with_accept_header(self) -> None:
    """
      Test that GET /profiles/ returns HAL JSON when requested.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/',
      headers={'Accept': self.hal_media_type})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.hal_media_type)
    self.check_allow(response)
    self.check_profiles_link(response)
    expected_data = self.load_json(
      ProfilesEndpoint,
      str(Path(ProfilesEndpoint.schema_dir()) / 'profiles.json'),
      self.template_context)
    self.assertDictEqual(response.json(), expected_data)

  def test_get_html(self) -> None:
    """
      Test that GET /profiles/ returns HTML when requested.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_allow(response)
    self.check_profiles_link(response)
    expected_html = self.load_file(
      ProfilesEndpoint,
      str(Path(ProfilesEndpoint.schema_dir()) / 'profiles.jinja2'),
      self.template_context)
    self.assertEqual(expected_html, response.text)

  def test_get_unsupported_media_type(self) -> None:
    """
      Test that unsupported Accept values return 406.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/',
      headers={'Accept': 'application/xml'})
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
    self.check_allow(response)
    self.check_profiles_link(response)
    data = response.json()
    self.assertEqual('Not Acceptable', data['title'])
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, data['status'])
    self.assertEqual(
      ['application/hal+json', 'text/html'],
      data['supportedMediaTypes'])
    self.assertNotIn('*/*', data['detail'])

  def test_get_partial_html_media_type_is_unsupported(self) -> None:
    """
      Test that media types are not matched by substring.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/',
      headers={'Accept': 'text/html-fragment'})
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)

  def test_head_hal_json(self) -> None:
    """
      Test that HEAD /profiles/ returns HAL JSON headers.
      :return: None
    """
    response = self.make_request(
      'HEAD',
      '/profiles/',
      headers={'Accept': self.hal_media_type})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.hal_media_type)
    self.check_allow(response)
    self.check_profiles_link(response)
    self.assertEqual('', response.text)

  def test_head_html(self) -> None:
    """
      Test that HEAD /profiles/ returns HTML headers when requested.
      :return: None
    """
    response = self.make_request(
      'HEAD',
      '/profiles/',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_allow(response)
    self.check_profiles_link(response)
    self.assertEqual('', response.text)

  def test_options_profiles(self) -> None:
    """
      Test that OPTIONS /profiles/ returns allowed methods and links.
      :return: None
    """
    response = self.make_request('OPTIONS', '/profiles/')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.check_profiles_link(response)
