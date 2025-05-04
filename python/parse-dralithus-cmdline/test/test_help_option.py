"""
  test_help_option.py: Unit tests for the HelpOption class.
"""
import unittest

from help_option import HelpOption

class TestHelpOption(unittest.TestCase):
  """
    Unit tests for class HelpOption
  """

  def test_value(self):
    """
      Test the value of the help option.
    """
    help_option = HelpOption()
    self.assertTrue(help_option.value)

  def test_is_option(self):
    """
      Test the is_option method.
    """
    self.assertTrue(HelpOption.is_option('-h'))
    self.assertTrue(HelpOption.is_option('--help'))
    self.assertFalse(HelpOption.is_option('-h=True'))
    self.assertFalse(HelpOption.is_option('--help=True'))
    self.assertFalse(HelpOption.is_option('-v'))
    self.assertFalse(HelpOption.is_option('parameter'))

  def test_make(self):
    """
      Test the make method.
    """
    help_option, skip_next = HelpOption.make('--help', None)
    self.assertIsInstance(help_option, HelpOption)
    self.assertTrue(help_option.value)
    self.assertFalse(skip_next)
