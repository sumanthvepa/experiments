"""
  test_option_terminator.py: Unit tests for the OptionTerminator class.
"""
import unittest

from option_terminator import OptionTerminator


class TestOptionTerminator(unittest.TestCase):
  """
    Unit tests for class OptionTerminator
  """

  def test_value(self):
    """
      Test the value of the option terminator.
    """
    terminator = OptionTerminator()
    self.assertEqual(terminator.value, '--')


  def test_is_option(self):
    """
      Test the is_option method.
    """
    self.assertTrue(OptionTerminator.is_option('--'))
    self.assertFalse(OptionTerminator.is_option('-h'))


  def test_make(self):
    """
      Test the make method.
    """
    terminator, skip_next = OptionTerminator.make('--', None)
    self.assertIsInstance(terminator, OptionTerminator)
    self.assertEqual(terminator.value, '--')
    self.assertFalse(skip_next)
