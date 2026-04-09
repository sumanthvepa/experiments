"""
  test_url_util.py: Unit tests for URL utility helpers.
"""
import unittest

from starlette.requests import Request

from cbrws.url_util import make_url


class TestUrlUtil(unittest.TestCase):
  """
    Unit tests for URL helper functions.
  """
  @staticmethod
  def make_request() -> Request:
    """
      Build a minimal Starlette request for URL generation tests.
      :return: Request
    """
    return Request({
      'type': 'http',
      'scheme': 'http',
      'server': ('localhost', 5101),
      'headers': [],
      'path': '/api',
    })

  def test_make_url_with_relative_path(self) -> None:
    """
      Relative paths should be appended once.
      :return: None
    """
    request = self.make_request()
    self.assertEqual('http://localhost:5101/api', make_url(request, 'api'))

  def test_make_url_with_absolute_path(self) -> None:
    """
      Leading slashes in the path should not produce a double slash.
      :return: None
    """
    request = self.make_request()
    self.assertEqual(
      'http://localhost:5101/profiles/cbrws/v1',
      make_url(request, '/profiles/cbrws/v1'))
