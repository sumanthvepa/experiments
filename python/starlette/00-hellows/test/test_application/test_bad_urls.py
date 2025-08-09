"""
  test_bad_urls.py: Unit tests for bad URLs passed to the hellows
  webservice
"""
import unittest

from httpx import Response
from starlette.testclient import TestClient

from hellows.application import app


class TestBadURLs(unittest.TestCase):
  """
    Unit tests for bad URLs passed to the hellows webservice
  """
  def test_bad_url(self) -> None:
    client = TestClient(app)
    response: Response = client.get('/unknown')
    self.assertEqual(response.status_code, 404)
