"""
  test_relations_endpoint.py: Unit tests for the
  /profiles/cbrws/v1/rels/ endpoint of the cbrws webservice.
"""
import unittest

from starlette import status
from starlette.applications import Starlette
from starlette.routing import Route
from starlette.testclient import TestClient

from cbrws.application import app
from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
from cbrws.config import Settings
from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
from cbrws.http_endpoint import ResponseMediaType, SupportedMediaTypes
from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
from test_cbrws.test_helper import HTMLTitleParser, TestHelper


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
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

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
    response = self.make_request(
      'GET',
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)

    parser = HTMLTitleParser()
    parser.feed(response.text)
    self.assertEqual('CBRWS v1 Link Relations', parser.title)
    self.assertIn('<h1>CBRWS v1 Link Relations</h1>', response.text)
    self.assertIn(self.relations_directory_url, response.text)
    self.assertIn(self.greeting_relation_url, response.text)
    self.assertIn(self.curie_href_template, response.text)
    self.assertIn('<code>application/hal+json</code>', response.text)
    self.assertIn('<code>text/html</code>', response.text)

  def test_head_returns_default_media_type_headers(self) -> None:
    """
      Test that HEAD /profiles/cbrws/v1/rels/ returns HAL headers by default.
      :return: None
    """
    response = self.make_request('HEAD', '/profiles/cbrws/v1/rels/')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)

  def test_head_returns_html_headers_when_requested(self) -> None:
    """
      Test that HEAD /profiles/cbrws/v1/rels/ returns HTML headers when requested.
      :return: None
    """
    response = self.make_request(
      'HEAD',
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)

  def test_options_returns_allow_without_link_header(self) -> None:
    """
      Test that OPTIONS /profiles/cbrws/v1/rels/ returns no Link header.
      :return: None
    """
    response = self.make_request('OPTIONS', '/profiles/cbrws/v1/rels/')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)

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
    response = self.make_request(
      'GET',
      '/profiles/cbrws/v1/rels/',
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

    test_app = Starlette(routes=[
      Route('/profiles/cbrws/v1/rels/',
            CustomRelationsEndpoint,
            name=CustomRelationsEndpoint.route_name()),
      Route('/profiles/cbrws/v1',
            APIV1SchemaEndpoint,
            name=APIV1SchemaEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingSchemaEndpoint,
            name=GreetingSchemaEndpoint.route_name())
    ])
    test_app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=('localhost',))
    client = TestClient(test_app, self.base_url)

    response = client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'application/hal+json'})

    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
    self.assertDictEqual(
      response.json(),
      {
        'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
        'title': 'Not Acceptable',
        'status': status.HTTP_406_NOT_ACCEPTABLE,
        'detail': 'The requested media type is not supported by this endpoint. '
                  + 'Supported media types are: text/html',
        'supportedMediaTypes': ['text/html']
      })
