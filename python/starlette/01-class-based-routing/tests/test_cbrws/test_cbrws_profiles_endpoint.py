"""
  test_cbrws_profiles_endpoint.py: Unit tests for the /profiles/cbrws
  endpoint of the cbrws webservice.
"""
import unittest

from starlette import status

from test_cbrws.test_helper import HTMLTitleParser, TestHelper


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
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.hal_media_type)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

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
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.hal_media_type)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

    data = response.json()
    self.assertEqual(self.cbrws_directory_url, data['_links']['self']['href'])
    self.assertEqual(self.api_v1_schema_url, data['_links']['item'][0]['href'])

  def test_get_html(self) -> None:
    """
      Test that GET /profiles/cbrws returns HTML when requested.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

    parser = HTMLTitleParser()
    parser.feed(response.text)
    self.assertEqual('CBRWS Schema Versions', parser.title)
    self.assertIn('<h1>CBRWS Schema Versions</h1>', response.text)
    self.assertIn(self.cbrws_directory_url, response.text)
    self.assertIn(self.api_v1_schema_url, response.text)
    self.assertIn('<code>application/hal+json</code>', response.text)
    self.assertIn('<code>text/html</code>', response.text)

  def test_get_unsupported_media_type(self) -> None:
    """
      Test that unsupported Accept values return 406.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws',
      headers={'Accept': 'application/xml'})
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

    self.assertDictEqual(
      response.json(),
      {
        'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
        'title': 'Not Acceptable',
        'status': status.HTTP_406_NOT_ACCEPTABLE,
        'detail': 'The requested media type is not supported by this endpoint. '
                  + 'Supported media types are: application/hal+json, text/html',
        'supportedMediaTypes': ['application/hal+json', 'text/html']
      })

  def test_head_hal_json(self) -> None:
    """
      Test that HEAD /profiles/cbrws returns HAL JSON headers.
      :return: None
    """
    response = self.make_request(
      'HEAD',
      '/profiles/cbrws',
      headers={'Accept': self.hal_media_type})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.hal_media_type)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual('', response.text)

  def test_head_html(self) -> None:
    """
      Test that HEAD /profiles/cbrws returns HTML headers when requested.
      :return: None
    """
    response = self.make_request(
      'HEAD',
      '/profiles/cbrws',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual('', response.text)

  def test_options_cbrws_profiles(self) -> None:
    """
      Test that OPTIONS /profiles/cbrws returns no Link header.
      :return: None
    """
    response = self.make_request('OPTIONS', '/profiles/cbrws')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)
