"""
  test_option.py: Unit tests for the option module.
"""
from __future__ import annotations

import unittest
from typing import override

from option import Option


class TestOption(unittest.TestCase):
  """
    Unit tests for class Option
  """
  def test_subclassing(self):
    """
      Test that Option is an abstract class can be subclassed.
    """
    class DummyOption(Option):
      """
        A dummy subclass of Option for testing purposes.
      """
      def __init__(self, value: int):
        """ Initialize the object with a value. """
        self._value = value

      @property
      @override
      def value(self) -> int:
        """
          Get the value of the option.

          :return: The value of the option
        """
        return self._value

      def add_to(self, dictionary: dict[str, None | bool | int | str | set[str]]) -> None:
        """
          Add the option to a dictionary.

          :param dictionary: The dictionary to add the option to
        """
        dictionary["dummy"] = self._value

      @classmethod
      def make(cls, _: str, __: str | None) -> tuple[DummyOption, bool]:
        # noinspection GrazieInspection
        """
          Create a DummyOption object from command line arguments.

          :param _:  Not used
          :param __:  Not used
          :return:  A tuple containing the DummyOption object and a boolean
            indicating whether to skip the next argument.
        """
        return DummyOption(42), False

    # Create an instance of the dummy subclass
    expected_value1 = 52
    dummy1 = DummyOption(expected_value1)
    # Check that the value property returns the correct value
    self.assertEqual(expected_value1, dummy1.value)

    # Create another instance of the dummy subclass
    expected_value2 = 84
    dummy2 = DummyOption(expected_value2)
    # Check that the value property returns the correct value
    self.assertEqual(expected_value2, dummy2.value)
