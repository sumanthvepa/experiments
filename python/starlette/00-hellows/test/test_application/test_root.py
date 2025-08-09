"""
  test_root.py: Unit tests for the hellows webservice
"""
import unittest
from httpx import Response
from starlette.testclient import TestClient
from hellows.application import app


class TestRoot(unittest.TestCase):
  """
    Unit tests for the / route of the hellows webservice
  """
  def test_get(self) -> None:
    """
      Test that get / returns a 200 OK response with a JSON
      message containing a greeting.
      :return: None
    """
    client = TestClient(app)
    response: Response = client.get('/')
    self.assertEqual(response.status_code, 200)
    self.assertEqual(response.json(), {'greeting': 'hello'})

  def test_post(self) -> None:
    """
      Test that posting to the home route returns a 405 Method Not
      Allowed error.
      :return: None
    """
    client = TestClient(app)
    response: Response = client.post('/')
    self.assertEqual(response.status_code, 405)  # Method Not Allowed
