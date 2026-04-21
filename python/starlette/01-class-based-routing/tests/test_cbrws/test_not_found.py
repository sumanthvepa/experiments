"""
  test_not_found.py: Unit tests for the unknown URLs passed to
  the cbrws webservice.
"""
# Pylint 4.0.x misclassifies test_cbrws imports as third-party.
# Revisit this once Pylint 4.1 known-first-party support is available.
# pylint: disable=wrong-import-order
import unittest

from httpx import Response
from starlette.testclient import TestClient

from cbrws.application import app
from test_cbrws.test_helper import CommonTestHelper


class TestNotFound(unittest.TestCase, CommonTestHelper):
  """
    Unit tests for the unknown URLs passed to the colophonws
    webservice
  """
  def test_not_found(self) -> None:
    """
      Test that a request to an unknown URL returns a 404 Not Found
      response.
      :return: None
    """
    client = TestClient(app, 'http://localhost:5101')
    response: Response = client.get('/unknown')
    self.check_problem_response(
      response,
      404,
      {
        'type': (
          'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/404'),
        'title': 'Not Found',
        'status': 404,
        'detail': (
          'The requested resource was not found on this server. '
          + 'Please check the URL and try again.')
      })
