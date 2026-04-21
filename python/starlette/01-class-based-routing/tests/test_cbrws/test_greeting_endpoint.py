"""
  test_greeting_endpoint.py: Unit tests for the /api/greeting endpoint
  of the cbrws webservice.
"""
# Pylint 4.0.x misclassifies test_cbrws imports as third-party.
# Revisit this once Pylint 4.1 known-first-party support is available.
# pylint: disable=wrong-import-order
import unittest

from httpx import Response
from starlette import status

from cbrws.api_endpoint import APIEndpoint
from cbrws.greeting_endpoint import GreetingEndpoint
from cbrws.http_endpoint import ResponseMediaType, SupportedMediaTypes
from test_cbrws.link_header import Link, parse
from test_cbrws.test_helper import TestHelper


class TestGreetingEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the /api/greeting route of the cbrws webservice.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The greeting endpoint URL
    """
    return '/api/greeting'

  def check_endpoint_link(self, response: Response) -> None:
    """
      Check that the response has the current greeting Link header.
      :param response: The response object
      :return: None
    """
    self.assertIn('Link', response.headers)
    actual_links = parse(response.headers['Link'])
    expected_links = {
      'profile': Link(
        url=self.base_url + '/profiles/cbrws/v1/rels/greeting',
        rel='profile',
        title='CBRWS V1 Greeting Schema'),
      'describedBy': Link(
        url=self.base_url + '/profiles/cbrws/v1/rels/greeting',
        rel='describedBy',
        media_type='application/schema+json',
        title='CBRWS V1 Greeting Schema'),
      'documentation': Link(
        url=self.base_url + '/profiles/cbrws/v1/rels/greeting',
        rel='documentation',
        media_type='text/html',
        title='CBRWS V1 Greeting Schema')
    }
    self.assertDictEqual(expected_links, actual_links)

  def test_get_returns_current_hal_document(self) -> None:
    """
      Test that GET /api/greeting returns the current HAL document.
      :return: None
    """
    response = self.make_request('GET', '/api/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertDictEqual(
      response.json(),
      {
        'message': 'Hello, world!',
        '_links': {
          'self': {
            'href': self.base_url + '/api/greeting',
            'type': 'application/hal+json',
            'profile': self.base_url + '/profiles/cbrws/v1/rels/greeting'
          },
          'up': {
            'href': self.base_url + '/api',
            'type': 'application/hal+json',
            'profile': self.base_url + '/profiles/cbrws/v1'
          }
        }
      })

  def test_head_returns_current_headers_without_body(self) -> None:
    """
      Test that HEAD /api/greeting returns the current headers without a body.
      :return: None
    """
    response = self.make_request('HEAD', '/api/greeting')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertEqual(b'', response.content)

  def test_options_returns_allow_and_link_headers(self) -> None:
    """
      Test that OPTIONS /api/greeting returns Allow and Link headers.
      :return: None
    """
    response = self.make_request('OPTIONS', '/api/greeting')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertEqual(b'', response.content)

  def test_get_returns_problem_details_for_unsupported_accept(self) -> None:
    """
      Test that GET /api/greeting returns 406 for unsupported Accept values.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/api/greeting',
      headers={'Accept': 'application/xml'})
    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertDictEqual(
      response.json(),
      {
        'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406',
        'title': 'Not Acceptable',
        'status': status.HTTP_406_NOT_ACCEPTABLE,
        'detail': 'The requested media type is not supported by this endpoint. '
                  + 'Supported media types are: application/hal+json',
        'supportedMediaTypes': ['application/hal+json']
      })

  def test_get_uses_subclass_response_media_type(self) -> None:
    """
      Test that GET /api/greeting uses a subclass response media type.
      :return: None
    """
    class CustomGreetingEndpoint(GreetingEndpoint):
      """ Greeting endpoint with a custom response media type. """

      @classmethod
      def default_response_media_type(cls) -> ResponseMediaType:
        """
          Return the primary response media type for the endpoint.
          :return: A concrete response media type
        """
        return 'application/schema+json'

      @classmethod
      def supported_media_types(cls) -> SupportedMediaTypes:
        """
          Return the response media types supported by the endpoint.
          :return: A non-empty tuple of concrete response media types
        """
        return ('application/schema+json',)

    client = self.make_custom_test_client(
      api_endpoint_class=APIEndpoint,
      greeting_endpoint_class=CustomGreetingEndpoint)

    response = client.get('/api/greeting')

    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/schema+json')
    data = response.json()
    self.assertEqual('application/schema+json', data['_links']['self']['type'])
    self.assertEqual('application/schema+json', data['_links']['up']['type'])
