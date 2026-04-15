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
from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint
from cbrws.relations_endpoint import RelationsEndpoint
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

  def test_get_html(self) -> None:
    """
      Test that the relations endpoint returns HTML documentation.
      :return: None
    """
    response = self.make_request(
      'GET',
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, 'text/html; charset=utf-8')
    self.check_link(response)
    parser = HTMLTitleParser()
    parser.feed(response.text)
    expected_title = 'CBRWS v1 Relations'
    self.assertEqual(expected_title, parser.title)
    self.assertIn(f'<h1>{expected_title}</h1>', response.text)
    self.assertIn(self.profile_url, response.text)
    self.assertIn(f'href="{self.profile_url}"', response.text)
    self.assertIn(self.profile_url + '/rels/', response.text)
    self.assertIn(self.profile_url + '/rels/greeting', response.text)
    self.assertIn('application/schema+json', response.text)

  def test_get_schema(self) -> None:
    """
      Test that the relations endpoint returns JSON Schema by default.
      :return: None
    """
    response = self.make_request('GET', '/profiles/cbrws/v1/rels/')
    self.assertEqual(status.HTTP_200_OK, response.status_code)
    self.check_content_type(response, self.schema_media_type)
    self.check_link(response)
    expected_data = self.load_schema(
      CBRWSV1ProfileEndpoint,
      str(CBRWSV1ProfileEndpoint.SCHEMA_DIR / 'relations-v1.json'),
      {
        'profile_url': self.profile_url,
        'relations_url': self.profile_url + '/rels/',
        'greeting_relation_url': self.profile_url + '/rels/greeting',
        'title': 'CBRWS v1 Relations'
      })
    self.assertDictEqual(response.json(), expected_data)

  def test_get_schema_uses_current_request_urls(self) -> None:
    """
      Test that the JSON response uses URLs from the current request.
      :return: None
    """
    first_client = TestClient(app, 'http://first.example')
    second_client = TestClient(app, 'http://second.example')

    first_response = first_client.get('/profiles/cbrws/v1/rels/')
    second_response = second_client.get('/profiles/cbrws/v1/rels/')

    self.assertEqual(status.HTTP_200_OK, first_response.status_code)
    self.assertEqual(status.HTTP_200_OK, second_response.status_code)
    self.assertIn('http://first.example/profiles/cbrws/v1/rels/greeting',
                  first_response.text)
    self.assertIn('http://second.example/profiles/cbrws/v1/rels/greeting',
                  second_response.text)
    self.assertNotIn('http://first.example', second_response.text)

  def test_get_html_uses_current_request_urls(self) -> None:
    """
      Test that the HTML response uses URLs from the current request.
      :return: None
    """
    first_client = TestClient(app, 'http://first.example')
    second_client = TestClient(app, 'http://second.example')

    first_response = first_client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})
    second_response = second_client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': 'text/html'})

    self.assertEqual(status.HTTP_200_OK, first_response.status_code)
    self.assertEqual(status.HTTP_200_OK, second_response.status_code)
    self.assertIn('http://first.example/profiles/cbrws/v1/rels/greeting',
                  first_response.text)
    self.assertIn('http://second.example/profiles/cbrws/v1/rels/greeting',
                  second_response.text)
    self.assertNotIn('http://first.example', second_response.text)

  def test_get_unsupported_media_type(self) -> None:
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

  def test_get_negotiates_with_supported_media_types(self) -> None:
    """
      Test that response negotiation uses SUPPORTED_MEDIA_TYPES.
      :return: None
    """
    class CustomRelationsEndpoint(RelationsEndpoint):
      """
        A relations endpoint with a deliberately restricted media type list.
      """
      SUPPORTED_MEDIA_TYPES = ['text/html', '*/*']

    test_app = Starlette(routes=[
      Route('/profiles/cbrws/v1/rels/',
            CustomRelationsEndpoint,
            name='relations_endpoint'),
      Route('/profiles/cbrws/v1',
            CBRWSV1ProfileEndpoint,
            name='profile_endpoint')
    ])
    client = TestClient(test_app, self.base_url)

    response = client.get(
      '/profiles/cbrws/v1/rels/',
      headers={'Accept': self.schema_media_type})

    self.assertEqual(status.HTTP_406_NOT_ACCEPTABLE, response.status_code)
    self.check_content_type(response, self.problem_media_type)
