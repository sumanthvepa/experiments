"""
  test_root_endpoint.py: Unit tests for the root endpoint(/) of the
  colophon webservice.
"""
import unittest

from starlette import status

from test_cbrws.test_helper import TestHelper


class TestRootEndpoint(unittest.TestCase, TestHelper):
  """
    Unit tests for the / route of the cbrws webservice
  """
  def test_get(self) -> None:
    """
      Test that get / returns a 308 Permanent Redirect response to the
      /api endpoint.
      :return: None
    """
    response = self.make_request('GET', '/')
    self.assertEqual(status.HTTP_308_PERMANENT_REDIRECT, response.status_code)

  def test_head(self) -> None:
    """
      Test that head / returns a 308 Permanent Redirect response to the
      /api endpoint.
      :return: None
    """
    response = self.make_request('HEAD', '/')
    self.assertEqual(status.HTTP_308_PERMANENT_REDIRECT, response.status_code)
