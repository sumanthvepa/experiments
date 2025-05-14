"""
  test_option.py: Unit tests for the option module.
"""
from __future__ import annotations

import unittest
from typing import override

from parameterized import parameterized

from option import Option
from option_terminator import OptionTerminator
from help_option import HelpOption
from verbosity_option import VerbosityOption
from environment_option import EnvironmentOption
from multi_option import MultiOption


def make_correct_cases() -> list[
      tuple[
        str,
        str,
        str | None,
        type[Option],
        bool | int | str | set[str],
        bool]]:
  """
    Generate test cases for the Option class.

    Note that not all cases are obviously correct.

    Indeed, some cases would be incorrect if the argument pair were
    part of a larger set of arguments, but are considered correct for
    the specific option being created. For example: -v -2 would be
    invalid as part of a command line since -2 is not a valid command
    option. But the purpose of this test is to test only the first
    argument and the next argument is only processed if it is needed
    to create the option. So -v -2 is a valid test case. It results
    in a VerbosityOption with a value of 1 and a skip_next_arg
    value of False.

    :return: A list of test cases
  """
  # pylint: disable=line-too-long
  return [
    ('option-terminator', '--', None, OptionTerminator, None, False),
    ('short-help', '-h', None, HelpOption, True, False),
    ('short-help-next-arg', '-h', 'True', HelpOption, True, False),
    ('short-help-next-arg2', '-h', '2', HelpOption, True, False),
    ('short-help-next-arg3', '-h', '-2', HelpOption, True, False),
    ('long-help', '--help', None, HelpOption, True, False),
    ('long-help-next-arg', '--help', 'True', HelpOption, True, False),
    ('long-help-next-arg2', '--help', '2', HelpOption, True, False),
    ('long-help-next-arg3', '--help', '-2', HelpOption, True, False),
    ('short-verbosity', '-v', None, VerbosityOption, 1, False),
    ('short-verbosity-value', '-v=2', None, VerbosityOption, 2, False),
    ('short-verbosity-next-arg', '-v', '2', VerbosityOption, 2, True),
    ('short-verbosity-next-arg-value', '-v', '2', VerbosityOption, 2, True),
    ('short-verbosity-next-arg-bad-value', '-v', 'bad_value', VerbosityOption, 1, False),
    ('short-verbosity-next-arg-bad-value2', '-v', 'True', VerbosityOption, 1, False),
    ('short-verbosity-next-arg-option', '-v', '-h', VerbosityOption, 1, False),
    ('short-verbosity-next-arg-verbosity', '-v', '-v', VerbosityOption, 1, False),
    ('short-verbosity-next-arg-parameter', '-v', 'parameter', VerbosityOption, 1, False),
    ('long-verbosity', '--verbosity', None, VerbosityOption, 1, False),
    ('long-verbosity-value', '--verbosity=2', None, VerbosityOption, 2, False),
    ('long-verbosity-next-arg', '--verbosity', '2', VerbosityOption, 2, True),
    ('long-verbosity-next-arg-option', '--verbosity', '-h', VerbosityOption, 1, False),
    ('long-verbosity-next-arg-verbosity', '--verbosity', '-v', VerbosityOption, 1, False),
    ('long-verbosity-next-arg-parameter', '--verbosity', 'parameter', VerbosityOption, 1, False),
    ('long2-verbosity', '--verbose', None, VerbosityOption, 1, False),
    ('long2-verbosity-value', '--verbose=2', None, VerbosityOption, 2, False),
    ('long2-verbosity-next-arg', '--verbose', '2', VerbosityOption, 2, True),
    ('long2-verbosity-next-arg-option', '--verbose', '-h', VerbosityOption, 1, False),
    ('long2-verbosity-next-arg-verbosity', '--verbose', '-v', VerbosityOption, 1, False),
    ('long2-verbosity-next-arg-parameter', '--verbose', 'parameter', VerbosityOption, 1, False),
    ('short-env', '-e=local', None, EnvironmentOption, {'local'}, False),
    ('short-env-multi-value', '-e=local,test', None, EnvironmentOption, {'local', 'test'}, False),
    ('short-env-next-arg', '-e', 'local', EnvironmentOption, {'local'}, True),
    ('short-env-next-arg-multi-value', '-e', 'local,test', EnvironmentOption, {'local', 'test'}, True),
    ('short-env-next-arg-option', '-e=local', '-h', EnvironmentOption, {'local'}, False),
    ('short-env-next-arg-parameter', '-e=local', 'parameter', EnvironmentOption, {'local'}, False),
    ('short-env-multi-value-next-arg-option', '-e=local,test', '-h', EnvironmentOption, {'local', 'test'}, False),
    ('short-env-multi-value-next-arg-parameter', '-e=local,test', 'parameter', EnvironmentOption, {'local', 'test'}, False),
    ('long-env', '--env=local', None, EnvironmentOption, {'local'}, False),
    ('long-env-multi-value', '--env=local,test', None, EnvironmentOption, {'local', 'test'}, False),
    ('long-env-next-arg', '--env', 'local', EnvironmentOption, {'local'}, True),
    ('long-env-next-arg-multi-value', '--env', 'local,test', EnvironmentOption, {'local', 'test'}, True),
    ('long-env-next-arg-option', '--env=local', '-h', EnvironmentOption, {'local'}, False),
    ('long-env-next-arg-parameter', '--env=local', 'parameter', EnvironmentOption, {'local'}, False),
    ('long-env-multi-value-next-arg-option', '--env=local,test', '-h', EnvironmentOption, {'local', 'test'}, False),
    ('long-env-multi-value-next-arg-parameter', '--env=local,test', 'parameter', EnvironmentOption, {'local', 'test'}, False),
    ('long2-env', '--environment=local', None, EnvironmentOption, {'local'}, False),
    ('long2-env-multi-value', '--environment=local,test', None, EnvironmentOption, {'local', 'test'}, False),
    ('long2-env-next-arg', '--environment', 'local', EnvironmentOption, {'local'}, True),
    ('long2-env-next-arg-multi-value', '--environment', 'local,test', EnvironmentOption, {'local', 'test'}, True),
    ('long2-env-next-arg-option', '--environment=local', '-h', EnvironmentOption, {'local'}, False),
    ('long2-env-next-arg-parameter', '--environment=local', 'parameter', EnvironmentOption, {'local'}, False),
    ('long2-env-multi-value-next-arg-option', '--environment=local,test', '-h', EnvironmentOption, {'local', 'test'}, False),
    ('long2-env-multi-value-next-arg-parameter', '--environment=local,test', 'parameter', EnvironmentOption, {'local', 'test'}, False)]


def make_multi_option_correct_cases() \
    -> list[tuple[str, str, str | None, type[Option], list[Option], bool]]:
  """
    Generate test cases for the MultiOption class.
    :return: A list of test cases
  """
  return [
    ('multi-option1', '-hv', None, MultiOption, [HelpOption('h'), VerbosityOption('v', 1)], False),
    ('multi-option2', '-vh', None, MultiOption, [VerbosityOption('v', 1), HelpOption('h')], False),
  ]

def make_incorrect_cases() -> \
    list[tuple[str, str, str | None, type[Exception]]]:
  """
    Generate test cases that cause an exception for the Option.make() method
    :return: A list of test cases
  """
  return [
    ('short-help-value', '-h=True', None, ValueError),
    ('short-help-value2', '-h=2', None, ValueError),
    ('short-help-value3', '-h=-2', None, ValueError),
    ('long-help-value', '--help=True', None, ValueError),
    ('long-help-value2', '--help=2', None, ValueError),
    ('long-help-value3', '--help=-2', None, ValueError),
    ('short-verbosity-bad-value', '-v=bad_value', None, ValueError),
    ('short-verbosity-bad-value2', '-v=True', None, ValueError),
    ('short-verbosity-bad-value3', '-v=-2', None, ValueError),
    ('short-verbosity-next-arg', '-v', '-2', ValueError),
    ('long-verbosity-bad-value', '--verbosity=bad_value', None, ValueError),
    ('long-verbosity-bad-value2', '--verbosity=True', None, ValueError),
    ('long-verbosity-bad-value3', '--verbosity=-2', None, ValueError),
    ('long-verbosity-next-arg', '--verbosity', '-2', ValueError),
    ('long2-verbosity-bad-value', '--verbose=bad_value', None, ValueError),
    ('long2-verbosity-bad-value2', '--verbose=True', None, ValueError),
    ('long2-verbosity-bad-value3', '--verbose=-2', None, ValueError),
    ('long2-verbosity-next-arg', '--verbose', '-2', ValueError),
    ('short-env-bad_value', '-e=bad_value', None, ValueError),
    ('short-env-bad_value2', '-e=True', None, ValueError),
    ('short-env-bad_value3', '-e=-2', None, ValueError),
    ('short-env-next-arg', '-e', 'bad_value', ValueError),
    ('short-env-next-arg2', '-e', 'True', ValueError),
    ('short-env-next-arg3', '-e', '-2', ValueError),
    ('long-env-bad_value', '--env=bad_value', None, ValueError),
    ('long-env-bad_value2', '--env=True', None, ValueError),
    ('long-env-bad_value3', '--env=-2', None, ValueError),
    ('long-env-next-arg', '--env', 'bad_value', ValueError),
    ('long-env-next-arg2', '--env', 'True', ValueError),
    ('long-env-next-arg3', '--env', '-2', ValueError),
    ('long2-env-bad_value', '--environment=bad_value', None, ValueError),
    ('long2-env-bad_value2', '--environment=True', None, ValueError),
    ('long2-env-bad_value3', '--environment=-2', None, ValueError),
    ('long2-env-next-arg', '--environment', 'bad_value', ValueError),
    ('long2-env-next-arg2', '--environment', 'True', ValueError),
    ('long2-env-next-arg3', '--environment', '-2', ValueError),
    ('long2-env-multi-value-next-arg-option', '--environment', 'local,bad_value', ValueError),
    ('bad-multi-option', '-vhe', None, ValueError),
    ('bad-multi-option2', '-vhe=local', None, ValueError),
    ('bad-multi-option3', '-vhe=local,test', None, ValueError),
    ('bad-multi-option-next-arg', '-vhe', 'parameter', ValueError),
    ('bad-multi-option-next-arg2', '-vhe', 'local', ValueError),
    ('bad-multi-option-next-arg3', '-vhe=local', 'parameter', ValueError)
  ]

class TestOption(unittest.TestCase):
  """
    Unit tests for class Option
  """
  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('option-terminator', '--', None, True),
    ('short-help', '-h', None, True),
    ('long-help', '--help', None, True),
    ('short-verbosity', '-v', None, True),
    ('short-verbosity-value', '-v=2', None, True),
    ('short-verbosity-bad-value', '-v=bad-value', None, True),
    ('long-verbosity', '--verbosity', None, True),
    ('long-verbosity-value', '--verbosity=2', None, True),
    ('long-verbosity-bad-value', '--verbosity=bad-value', None, True),
    ('long2-verbosity', '--verbose', None, True),
    ('long2-verbosity-value', '--verbose=2', None, True),
    ('long2-verbosity-bad-value', '--verbose=bad-value', None, True),
    ('short-env', '-e', None, True),
    ('short-env-value', '-e=local', None, True),
    ('short-env-multi-value', '-e=local,test', None, True),
    ('short-env-bad_value', '-e=bad-value', None, True),
    ('short-env-bad_multi-value', '-e=bad-value,local', None, True),
    ('long-env', '--env', None, True),
    ('long-env-value', '--env=local', None, True),
    ('long-env-multi-value', '--env=local,test', None, True),
    ('long-env-bad_value', '--env=bad-value', None, True),
    ('long-env-bad_multi-value', '--env=bad-value,local', None, True),
    ('long2-env', '--environment', None, True),
    ('long2-env-value', '--environment=local', None, True),
    ('long2-env-multi-value', '--environment=local,test', None, True),
    ('long2-env-bad_value', '--environment=bad-value', None, True),
    ('long2-env-bad_multi-value', '--environment=bad-value,local', None, True),
    ('unknown-short-option', '-x', None, True),
    ('unknown-short-option-value', '-x=2', None, True),
    ('unknown-long-option', '--xtra', None, True),
    ('unknown-long-option-value', '--xtra=2', None, True),
    ('non-option1', 'n', None, False),
    ('non-option2', 'non-option', None, False),
    ('non-option3', '---', None, False),
    ('multi-option1', '-hv', None, True),
    ('multi-option2', '-vh', None, True),
    ('multi-option3', '-vhe', None, True),
    ('multi-option4', '-vvv', None, True),
    ('bad-multi-option1', '-vh=1', None, False),
    ('bad-multi-option2', '-vhe=local', None, False),
    ('bad-short-option', '-2', None, False),
    ('bad-long-option', '--2', None, False),
    ('bad-long-option2', '--4sight', None, False),
    ('bad-long-option3', '--4sight=2', None, False)])
  def test_is_option_correct(self,
    name: str,  # pylint: disable=unused-argument
    arg: str, next_arg: str | None,
    expected_value: bool) -> None:
    """
      Test the is_option method of the Option class.

      :return: None
    """
    actual_value = Option.is_option(arg, next_arg)
    self.assertEqual(expected_value, actual_value)

  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('option-terminator', '--', None, OptionTerminator),
    ('short-help', '-h', None, HelpOption),
    ('long-help', '--help', None, HelpOption),
    ('short-verbosity', '-v', None, VerbosityOption),
    ('long-verbosity', '--verbosity', None, VerbosityOption),
    ('long-verbosity-value', '--verbosity=2', None, VerbosityOption),
    ('long2-verbosity', '--verbose', None, VerbosityOption),
    ('long2-verbosity-value', '--verbose=2', None, VerbosityOption),
    ('short-verbosity-bad-value', '-v=bad_value', None, None),
    ('short-verbosity-bad-value2', '-v=True', None, None),
    ('short-verbosity-bad-value3', '-v=-2', None, None),
    ('long-verbosity-bad-value', '--verbosity=bad_value', None, None),
    ('long-verbosity-bad-value2', '--verbosity=True', None, None),
    ('long-verbosity-bad-value3', '--verbosity=-2', None, None),
    ('short-env', '-e', None, None),
    ('short-env-value', '-e=local', None, EnvironmentOption),
    ('short-env-multi-value', '-e=local,test', None, EnvironmentOption),
    ('short-env-bad_value', '-e=bad_value', None, None),
    ('short-env-bad_multi-value', '-e=bad_value,local', None, None),
    ('short-env-bad-multi-value2', '-e=local,bad_value', None, None),
    ('long-env', '--env', None, None),
    ('long-env-value', '--env=local', None, EnvironmentOption),
    ('long-env-multi-value', '--env=local,test', None, EnvironmentOption),
    ('long-env-bad_value', '--env=bad_value', None, None),
    ('long-env-bad_multi-value', '--env=bad_value,local', None, None),
    ('long-env-bad-multi-value2', '--env=local,bad_value', None, None),
    ('long2-env', '--environment', None, None),
    ('long2-env-value', '--environment=local', None, EnvironmentOption),
    ('long2-env-multi-value', '--environment=local,test', None, EnvironmentOption),
    ('long2-env-bad_value', '--environment=bad_value', None, None),
    ('long2-env-bad_multi-value', '--environment=bad_value,local', None, None),
    ('long2-env-bad-multi-value2', '--environment=local,bad_value', None, None)])
  def test_type_of(self,
    name: str,  # pylint: disable=unused-argument
    arg: str, next_arg: str | None,
    expected_cls: type[Option] | None) -> None:
    """
      Test the type_of method
    """
    actual_cls = Option.type_of(arg, next_arg)
    self.assertEqual(expected_cls, actual_cls)

  # noinspection PyUnusedLocal
  @parameterized.expand(make_correct_cases())
  def test_make(self,  # pylint: disable=too-many-arguments, too-many-positional-arguments
      name: str, # pylint: disable=unused-argument
      current_arg: str,
      next_arg: str | None,
      expected_option_type: type[Option],
      expected_option_value: bool | int | str | set[str],
      expected_skip_next_arg: bool) -> None:
    """
      Test the make method of the Option class.
      :return: None
    """
    option, skip_next_arg = Option.make(current_arg, next_arg)
    self.assertIsInstance(option, expected_option_type)
    self.assertEqual(expected_option_value, option.value)
    self.assertEqual(expected_skip_next_arg, skip_next_arg)

  # noinspection PyUnusedLocal
  @parameterized.expand(make_incorrect_cases())
  def test_make_incorrect_cases(self,
      name: str,  # pylint: disable=unused-argument
      current_arg: str,
      next_arg: str| None,
      exception_type: type[Exception]) -> None:
    """
      Test the make method with incorrect cases.
      :return: None
    """
    with self.assertRaises(exception_type):
      Option.make(current_arg, next_arg)

  # noinspection PyUnusedLocal
  @parameterized.expand(make_multi_option_correct_cases())
  def test_make_multi_option(self, # pylint: disable=too-many-arguments, too-many-positional-arguments
    name: str,  # pylint: disable=unused-argument
    current_arg: str,
    next_arg: str | None,
    expected_option_type: type[Option],
    expected_option_subclasses: list[Option],
    expected_skip_next_arg: bool) -> None:
    """
      Test the make method of the MultiOption class.
      :return: None
    """
    option, skip_next_arg = Option.make(current_arg, next_arg)
    self.assertIsInstance(option, expected_option_type)
    assert isinstance(option, MultiOption)
    multi_option: MultiOption = option
    self.assertListEqual(expected_option_subclasses, multi_option.options)
    self.assertEqual(expected_skip_next_arg, skip_next_arg)

  def test_subclassing(self) -> None:
    """
      Test that Option is an abstract class can be subclassed.
    """
    class DummyOption(Option):
      """
        A dummy subclass of Option for testing purposes.
      """
      def __init__(self, flag: str, value: int):
        """ Initialize the object with a value. """
        self._flag = flag
        self._value = value

      @classmethod
      def supported_short_flags(cls) -> list[str]:
        """
          Supported short flags for this option.

          :return: A list of short flag strings
        """
        return ['d']

      @classmethod
      def supported_long_flags(cls) -> list[str]:
        """
          Supported long flags for this option.

          :return: A list of long flag strings
        """
        return ['dummy']

      @override
      @property
      def flag(self) -> str:
        """
          Get the flag of the option.

          :return: The flag of the option
        """
        return self._flag

      @override
      @property
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
      def is_option(cls, arg: str, next_arg: str | None) -> bool:
        """
          Check if the argument is a dummy option.

          :param arg: The argument string
          :param next_arg: The next argument string (unused)
          :return: True if the argument is a dummy option
        """
        return arg in ['-d', '-dummy']

      @classmethod
      def is_valid_value_type(cls, str_value: str) -> bool:
        """
          Check if the value is valid for this option.

          :param str_value: The value to check
          :return: Always False. The dummy option does not take a value
        """
        return False

      @classmethod
      def make(cls, current_arg: str, next_arg: str | None) -> tuple[DummyOption, bool]:
        # noinspection GrazieInspection
        """
          Create a DummyOption object from command line arguments.

          :param current_arg: The current argument string
          :param next_arg: The next argument string
          :return:  A tuple containing the DummyOption object and a boolean
            indicating whether to skip the next argument.
        """
        flag, _, __ = cls._extract_value(current_arg, next_arg)
        return DummyOption(flag, 42), False

    # Create an instance of the dummy subclass
    expected_flag1 = 'd'
    expected_value1 = 52
    dummy1 = DummyOption(expected_flag1, expected_value1)
    # Check that the value property returns the correct value
    self.assertEqual(expected_flag1, dummy1.flag)
    self.assertEqual(expected_value1, dummy1.value)

    # Create another instance of the dummy subclass
    expected_flag2 = 'dummy'
    expected_value2 = 84
    dummy2 = DummyOption(expected_flag2, expected_value2)
    # Check that the value property returns the correct value
    self.assertEqual(expected_flag2, dummy2.flag)
    self.assertEqual(expected_value2, dummy2.value)
