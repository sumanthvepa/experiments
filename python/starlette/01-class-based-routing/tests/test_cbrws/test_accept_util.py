"""
  test_accept_util.py: Unit tests for Accept header negotiation.
"""
import unittest

from cbrws.accept_util import select_media_type


class TestAcceptUtil(unittest.TestCase):
  """
    Unit tests for Accept header negotiation.
  """
  def test_exact_media_type_match(self) -> None:
    """
      Test that an exact media type match is selected.
      :return: None
    """
    self.assertEqual(
      'application/hal+json',
      select_media_type(
        'application/hal+json',
        ['application/hal+json']))

  def test_wildcard_uses_server_preference(self) -> None:
    """
      Test that wildcards select the first concrete server media type.
      :return: None
    """
    self.assertEqual(
      'application/hal+json',
      select_media_type(
        '*/*',
        ['application/hal+json', 'text/html']))

  def test_quality_values_are_used(self) -> None:
    """
      Test that media type quality values are honored.
      :return: None
    """
    self.assertEqual(
      'application/hal+json',
      select_media_type(
        'text/html;q=0.5, application/hal+json;q=0.9',
        ['application/hal+json', 'text/html']))

  def test_zero_quality_rejects_media_type(self) -> None:
    """
      Test that q=0 marks a media type as unacceptable.
      :return: None
    """
    self.assertEqual(
      'application/hal+json',
      select_media_type(
        'text/html;q=0, */*;q=0.5',
        ['application/hal+json', 'text/html']))

  def test_partial_media_type_does_not_match(self) -> None:
    """
      Test that media types are not matched by substring.
      :return: None
    """
    self.assertIsNone(
      select_media_type(
        'text/html-fragment',
        ['application/hal+json', 'text/html']))

  def test_missing_accept_header_allows_any_media_type(self) -> None:
    """
      Test that a missing Accept header behaves like */*.
      :return: None
    """
    self.assertEqual(
      'application/hal+json',
      select_media_type(
        None,
        ['application/hal+json', 'text/html']))
