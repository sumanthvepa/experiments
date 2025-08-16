"""
  test_not_found.py: Unit tests for the unknown URLs passed to
  the cbrws webservice.
"""
import unittest

from httpx import Response
from starlette import status
from starlette.testclient import TestClient

from cbrws.application import app


class TestNotFound(unittest.TestCase):
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
    client = TestClient(app)
    response: Response = client.get('/unknown')
    self.assertEqual(status.HTTP_404_NOT_FOUND, response.status_code)
    self.assertIn('Content-Type', response.headers)
    self.assertEqual('application/json', response.headers['Content-Type'])
    data = response.json()
    self.assertIn('type', data)
    self.assertIn('title', data)
    self.assertIn('status', data)
    self.assertIn('detail', data)
    self.assertEqual(
      data['type'],
      'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/404')
    self.assertEqual(data['title'], 'Not Found')
    self.assertEqual(data['status'], status.HTTP_404_NOT_FOUND)
    self.assertEqual(
      data['detail'],
      'The requested resource was not found on this server. '
      + 'Please check the URL and try again.')
