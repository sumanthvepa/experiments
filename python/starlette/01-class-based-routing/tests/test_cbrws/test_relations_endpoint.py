"""
  test_relations_endpoint.py: Unit tests for the
  /profiles/cbrws/v1/rels/ endpoint of the cbrws webservice.
"""
# Pylint 4.0.x misclassifies test_cbrws imports as third-party.
# Revisit this once Pylint 4.1 known-first-party support is available.
# pylint: disable=wrong-import-order
import unittest

from starlette import status
from starlette.testclient import TestClient

from cbrws.application import app
from cbrws.http_endpoint import ResponseMediaType, SupportedMediaTypes
from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
from test_cbrws.test_helper import TestHelper


class TestRelationsEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the relations index route.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The relations index endpoint URL
    """
    return '/profiles/cbrws/v1/rels/'

  @property
  def relations_directory_url(self) -> str:
    """
      Expected URL for the relations directory.
      :return: The relations directory URL
    """
    return f'{self.base_url}/profiles/cbrws/v1/rels/'

  @property
  def greeting_relation_url(self) -> str:
    """
      Expected URL for the greeting relation documentation.
      :return: The greeting relation URL
    """
    return f'{self.base_url}/profiles/cbrws/v1/rels/greeting'

  @property
  def curie_href_template(self) -> str:
    """
      Expected CURIE href template for cbrws relations.
      :return: The CURIE href template
    """
    return self.relations_directory_url.rstrip('/') + '/{rel}'

  def check_endpoint_link(self, response: object) -> None:
    """
      Template endpoints do not emit Link headers.
      :param response: The response object
      :return: None
    """
    return None

  def test_get_returns_hal_by_default(self) -> None:
    """
      Test that GET /profiles/cbrws/v1/rels/ returns a HAL directory.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1/rels/')
    self.check_success_without_link(response, 'application/hal+json')

    data = response.json()
    self.assertEqual('CBRWS v1 Link Relations', data['title'])
    self.assertIn('custom link relations defined by the v1 CBRWS API', data['description'])
    self.assertEqual(self.relations_directory_url, data['_links']['self']['href'])
    self.assertEqual('application/hal+json', data['_links']['self']['type'])
    self.assertEqual(self.greeting_relation_url, data['_links']['item'][0]['href'])
    self.assertEqual(
      'cbrws:greeting link relation',
      data['_links']['item'][0]['title'])
    self.assertEqual(
      'application/schema+json',
      data['_links']['item'][0]['type'])

  def test_get_html_returns_current_documentation_page(self) -> None:
    """
      Test that GET /profiles/cbrws/v1/rels/ returns HTML when requested.
      :return: None
    """
    self.assert_html_response_without_link(
      '/profiles/cbrws/v1/rels/',
      'CBRWS v1 Link Relations',
      [
        '<h1>CBRWS v1 Link Relations</h1>',
        self.relations_directory_url,
        self.greeting_relation_url,
        self.curie_href_template,
        '<code>application/hal+json</code>',
        '<code>text/html</code>'
      ])

  def test_head_returns_default_media_type_headers(self) -> None:
    """
      Test that HEAD /profiles/cbrws/v1/rels/ returns HAL headers by default.
      :return: None
    """
    self.assert_head_without_link(
      '/profiles/cbrws/v1/rels/',
      'application/hal+json')

  def test_head_returns_html_headers_when_requested(self) -> None:
    """
      Test that HEAD /profiles/cbrws/v1/rels/ returns HTML headers when requested.
      :return: None
    """
    self.assert_head_without_link('/profiles/cbrws/v1/rels/', 'text/html')

  def test_options_returns_allow_without_link_header(self) -> None:
    """
      Test that OPTIONS /profiles/cbrws/v1/rels/ returns no Link header.
      :return: None
    """
    self.assert_options_without_link('/profiles/cbrws/v1/rels/')

  def test_get_uses_current_request_origin_in_directory_links(self) -> None:
    """
      Test that the HAL directory uses the current request origin.
      :return: None
    """
    first_client = TestClient(app, 'http://localhost:5101')
    second_client = TestClient(app, 'http://127.0.0.1:5101')

    first_response = first_client.get('/profiles/cbrws/v1/rels/')
    second_response = second_client.get('/profiles/cbrws/v1/rels/')

    self.assertEqual(status.HTTP_200_OK, first_response.status_code)
    self.assertEqual(status.HTTP_200_OK, second_response.status_code)
    self.assertEqual(
      'http://localhost:5101/profiles/cbrws/v1/rels/',
      first_response.json()['_links']['self']['href'])
    self.assertEqual(
      'http://localhost:5101/profiles/cbrws/v1/rels/greeting',
      first_response.json()['_links']['item'][0]['href'])
    self.assertEqual(
      'http://127.0.0.1:5101/profiles/cbrws/v1/rels/',
      second_response.json()['_links']['self']['href'])
    self.assertEqual(
      'http://127.0.0.1:5101/profiles/cbrws/v1/rels/greeting',
      second_response.json()['_links']['item'][0]['href'])

  def test_get_html_uses_current_request_origin_in_documentation_links(self) -> None:
    """
      Test that the HTML response uses the current request origin.
      :return: None
    """
    first_client = TestClient(app, 'http://localhost:5101')
    second_client = TestClient(app, 'http://127.0.0.1:5101')

    first_response = first_client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})
    second_response = second_client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})

    self.assertEqual(status.HTTP_200_OK, first_response.status_code)
    self.assertEqual(status.HTTP_200_OK, second_response.status_code)
    self.assertIn(
      'http://localhost:5101/profiles/cbrws/v1/rels/',
      first_response.text)
    self.assertIn(
      'http://localhost:5101/profiles/cbrws/v1/rels/greeting',
      first_response.text)
    self.assertIn(
      'http://127.0.0.1:5101/profiles/cbrws/v1/rels/',
      second_response.text)
    self.assertIn(
      'http://127.0.0.1:5101/profiles/cbrws/v1/rels/greeting',
      second_response.text)

  def test_get_returns_problem_details_for_unsupported_accept(self) -> None:
    """
      Test that unsupported Accept values return 406.
      :return: None
    """
    self.assert_not_acceptable_without_link(
      '/profiles/cbrws/v1/rels/',
      ['application/hal+json', 'text/html'])

  def test_get_negotiates_with_supported_media_types(self) -> None:
    """
      Test that response negotiation uses declared media types.
      :return: None
    """
    class CustomRelationsEndpoint(RelationsDirectoryEndpoint):
      """
        A relations endpoint with a deliberately restricted media type list.
      """

      @classmethod
      def default_response_media_type(cls) -> ResponseMediaType:
        """
          Return the primary response media type for the endpoint.
          :return: A concrete response media type
        """
        return 'text/html'

      @classmethod
      def supported_media_types(cls) -> SupportedMediaTypes:
        """
          Return the response media types supported by the endpoint.
          :return: A non-empty tuple of concrete response media types
        """
        return ('text/html',)

    client = self.make_relations_test_client(
      relations_endpoint_class=CustomRelationsEndpoint)

    response = client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'application/hal+json'})

    self.check_not_acceptable_without_link(
      response,
      ['text/html'],
      check_allow=False)
