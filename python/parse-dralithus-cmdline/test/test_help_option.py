"""
  test_help_option.py: Unit tests for the HelpOption class.
"""
import unittest

from help_option import HelpOption

class TestHelpOption(unittest.TestCase):
  """
    Unit tests for class HelpOption
  """

  def test_value(self) -> None:
    """
      Test the value of the help option.
    """
    help_option = HelpOption()
    self.assertTrue(help_option.value)

  def test_add_to(self) -> None:
    """
      Test the add_to method.
    """
    help_option = HelpOption()
    dictionary: dict[str, None | bool | int | str | set[str]] = {}
    help_option.add_to(dictionary)
    self.assertTrue(dictionary['requires_help'])

    dictionary = {'requires_help': False}
    help_option.add_to(dictionary)
    self.assertTrue(dictionary['requires_help'])

  def test_is_option(self) -> None:
    """
      Test the is_option method.
    """
    self.assertTrue(HelpOption.is_option('-h'))
    self.assertTrue(HelpOption.is_option('--help'))
    self.assertTrue(HelpOption.is_option('-h=True'))
    self.assertTrue(HelpOption.is_option('--help=True'))
    self.assertFalse(HelpOption.is_option('-v'))
    self.assertFalse(HelpOption.is_option('parameter'))

  def test_make(self) -> None:
    """
      Test the make method.
    """
    help_option, skip_next = HelpOption.make('--help', None)
    self.assertIsInstance(help_option, HelpOption)
    self.assertTrue(help_option.value)
    self.assertFalse(skip_next)
