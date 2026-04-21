"""
  test_root_endpoint.py: Unit tests for the root endpoint (/)
  of the cbrws webservice.
"""
import unittest

from starlette import status

from cbrws.root_endpoint import RootEndpoint
from test_cbrws.test_helper import TestHelper


class TestRootEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the redirecting root endpoint of the cbrws webservice.
  """

  @property
  def endpoint_url(self) -> str:
    """
      The URL used by shared request helpers.
      :return: The root endpoint URL
    """
    return '/'

  def check_endpoint_link(self, response: object) -> None:
    """
      Root endpoint responses do not emit Link headers.
      :param response: The response object
      :return: None
    """
    return None

  def test_get_redirects_to_api(self) -> None:
    """
      Test that GET / redirects permanently to /api.
      :return: None
    """
    response = self.make_request('GET', '/')
    self.assertEqual(status.HTTP_308_PERMANENT_REDIRECT, response.status_code)
    self.assertEqual('/api', response.headers['location'])
    self.assertNotIn('Allow', response.headers)
    self.assertNotIn('Link', response.headers)

  def test_head_redirects_to_api(self) -> None:
    """
      Test that HEAD / redirects permanently to /api.
      :return: None
    """
    response = self.make_request('HEAD', '/')
    self.assertEqual(status.HTTP_308_PERMANENT_REDIRECT, response.status_code)
    self.assertEqual('/api', response.headers['location'])
    self.assertNotIn('Allow', response.headers)
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)

  def test_options_returns_allow_header_without_link_header(self) -> None:
    """
      Test that OPTIONS / exposes allowed methods without Link headers.
      :return: None
    """
    response = self.make_request('OPTIONS', '/')
    self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
    self.assertEqual(RootEndpoint.allow_header(), response.headers['allow'])
    self.assertNotIn('Link', response.headers)
    self.assertEqual(b'', response.content)

  def test_disallowed_methods_return_problem_details_without_link_header(self) -> None:
    """
      Test that unsupported methods return 405 problem details.
      :return: None
    """
    for method in ('POST', 'PUT', 'DELETE', 'PATCH'):
      with self.subTest(method=method):
        response = self.make_request(method, '/')
        self.assertEqual(status.HTTP_405_METHOD_NOT_ALLOWED, response.status_code)
        self.check_content_type(response, self.problem_media_type)
        self.assertEqual(RootEndpoint.allow_header(), response.headers['allow'])
        self.assertNotIn('Link', response.headers)
        self.assertDictEqual(
          response.json(),
          {
            'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405',
            'title': 'Method Not Allowed',
            'status': status.HTTP_405_METHOD_NOT_ALLOWED,
            'detail': 'The requested method is not allowed for this resource. '
                      + 'See the Allow header for allowed methods.',
            'allowedMethods': list(RootEndpoint.allowed_methods())
          })
