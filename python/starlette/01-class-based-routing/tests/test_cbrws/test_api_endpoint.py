"""
  test_api_endpoint.py: Unit tests for the /api endpoint of the
  cbrws webservice.
"""
import unittest

from httpx import Response
from starlette import status
from starlette.applications import Starlette
from starlette.routing import Route
from starlette.testclient import TestClient

from cbrws.api_endpoint import APIEndpoint
from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
from cbrws.config import Settings
from cbrws.greeting_endpoint import GreetingEndpoint
from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
from cbrws.http_endpoint import ResponseMediaType, SupportedMediaTypes
from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
from test_cbrws.link_header import Link, parse
from test_cbrws.test_helper import TestHelper


class TestAPIEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the /api route of the cbrws webservice.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared endpoint behavior tests.
      :return: The API endpoint URL
    """
    return '/api'

  def check_endpoint_link(self, response: Response) -> None:
    """
      Check that the response has the current API endpoint Link header.
      :param response: The response object
      :return: None
    """
    self.assertIn('Link', response.headers)
    actual_links = parse(response.headers['Link'])
    expected_links = {
      'profile': Link(
        url=self.base_url + '/profiles/cbrws/v1',
        rel='profile',
        title='CBRWS API v1 Schema'),
      'describedBy': Link(
        url=self.base_url + '/profiles/cbrws/v1',
        rel='describedBy',
        media_type='application/schema+json',
        title='CBRWS API v1 Schema'),
      'documentation': Link(
        url=self.base_url + '/profiles/cbrws/v1',
        rel='documentation',
        media_type='text/html',
        title='CBRWS API v1 Schema')
    }
    self.assertDictEqual(expected_links, actual_links)

  def test_get_returns_current_hal_document(self) -> None:
    """
      Test that GET /api returns the current HAL document.
      :return: None
    """
    response = self.make_request('GET', '/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertDictEqual(
      response.json(),
      {
        'title': 'CBRWS API',
        'version': '1.0',
        'description': 'This is the API endpoint for the cbrws web service.',
        '_links': {
          'self': {
            'href': self.base_url + '/api',
            'type': 'application/hal+json',
            'profile': self.base_url + '/profiles/cbrws/v1'
          },
          'curies': [
            {
              'name': 'cbrws',
              'href': self.base_url + '/profiles/cbrws/v1/rels/{rel}',
              'templated': True
            }
          ],
          'cbrws:greeting': {
            'href': self.base_url + '/api/greeting',
            'type': 'application/hal+json',
            'profile': self.base_url + '/profiles/cbrws/v1/rels/greeting'
          }
        }
      })

  def test_head_returns_current_headers_without_body(self) -> None:
    """
      Test that HEAD /api returns the current headers without a body.
      :return: None
    """
    response = self.make_request('HEAD', '/api')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/hal+json')
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertEqual(b'', response.content)

  def test_options_returns_allow_and_link_headers(self) -> None:
    """
      Test that OPTIONS /api returns Allow and Link headers.
      :return: None
    """
    response = self.make_request('OPTIONS', '/api')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.check_allow(response)
    self.check_endpoint_link(response)
    self.assertEqual(b'', response.content)

  def test_get_returns_problem_details_for_unsupported_accept(self) -> None:
    """
      Test that GET /api returns 406 for unsupported Accept values.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/api',
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

  def test_get_uses_proxy_adjusted_request_origin_for_links(self) -> None:
    """
      Test that generated links use the request scheme and host.
      :return: None
    """
    app = Starlette(routes=[
      Route('/api', APIEndpoint, name=APIEndpoint.route_name()),
      Route('/api/greeting', GreetingEndpoint, name=GreetingEndpoint.route_name()),
      Route('/profiles/cbrws/v1', APIV1SchemaEndpoint, name=APIV1SchemaEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/', RelationsDirectoryEndpoint, name=RelationsDirectoryEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingSchemaEndpoint,
            name=GreetingSchemaEndpoint.route_name())
    ])
    app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=('api.example.com',))
    client = TestClient(app, 'https://api.example.com')

    response = client.get('/api')

    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.assertDictEqual(
      response.json(),
      {
        'title': 'CBRWS API',
        'version': '1.0',
        'description': 'This is the API endpoint for the cbrws web service.',
        '_links': {
          'self': {
            'href': 'https://api.example.com/api',
            'type': 'application/hal+json',
            'profile': 'https://api.example.com/profiles/cbrws/v1'
          },
          'curies': [
            {
              'name': 'cbrws',
              'href': 'https://api.example.com/profiles/cbrws/v1/rels/{rel}',
              'templated': True
            }
          ],
          'cbrws:greeting': {
            'href': 'https://api.example.com/api/greeting',
            'type': 'application/hal+json',
            'profile': 'https://api.example.com/profiles/cbrws/v1/rels/greeting'
          }
        }
      })

  def test_get_uses_subclass_response_media_type_for_api_document_only(self) -> None:
    """
      Test that a subclass controls the API document media type, while
      linked resource types keep their own defaults.
      :return: None
    """
    class CustomAPIEndpoint(APIEndpoint):
      """ API endpoint with a custom response media type. """

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

    app = Starlette(routes=[
      Route('/api', CustomAPIEndpoint, name=CustomAPIEndpoint.route_name()),
      Route('/api/greeting', GreetingEndpoint, name=GreetingEndpoint.route_name()),
      Route('/profiles/cbrws/v1', APIV1SchemaEndpoint, name=APIV1SchemaEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/', RelationsDirectoryEndpoint, name=RelationsDirectoryEndpoint.route_name()),
      Route('/profiles/cbrws/v1/rels/greeting',
            GreetingSchemaEndpoint,
            name=GreetingSchemaEndpoint.route_name())
    ])
    app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=('localhost',))
    client = TestClient(app, self.base_url)

    response = client.get('/api')

    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'application/schema+json')
    data = response.json()
    self.assertEqual('application/schema+json', data['_links']['self']['type'])
    self.assertEqual('application/hal+json', data['_links']['cbrws:greeting']['type'])
