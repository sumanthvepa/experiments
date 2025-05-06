"""
  test_verbosity_option.py: Unit tests for the VerbosityOption class.
"""
import unittest

from parameterized import parameterized

from verbosity_option import VerbosityOption


def make_correct_cases() -> list[tuple[str, str, str | None, int, bool]]:
  """
    Generate test cases for the VerbosityOption class.

    :return: A list of test cases
  """
  return [
    ('short_no_value_no_next_arg', '-v', None, 1, False),
    ('short_no_value_next_arg_option', '-v', '-h', 1, False),
    ('short_no_value_next_arg_parameter', '-v', 'parameter', 1, False),
    ('long_no_value_no_next_arg', '--verbosity', None, 1, False),
    ('long_no_value_next_arg_option', '--verbosity', '-h', 1, False),
    ('long_no_value_next_arg_parameter', '--verbosity', 'parameter', 1, False),
    ('short_value_no_next_arg', '-v2', None, 2, False),
    ('short_value_next_arg_option', '-v2', '-h', 2, False),
    ('short_value_next_arg_parameter', '-v2', 'parameter', 2, False),
    ('short_value_equal_no_next_arg', '-v=2', None, 2, False),
    ('short_value_equal_next_arg_option', '-v=2', '-h', 2, False),
    ('short_value_equal_next_arg_parameter', '-v=2', 'parameter', 2, False),
    ('long_value_equal_no_next_arg', '--verbosity=2', None, 2, False),
    ('long_value_equal_next_arg_option', '--verbosity=2', '-h', 2, False),
    ('long_value_equal_next_arg_parameter', '--verbosity=2', 'parameter', 2, False),
    ('short_no_value_next_arg_bad_value', '-v', 'bad_value', 1, False),
    ('short_no_value_next_arg_bad_value2', '-v', 'True', 1, False),
    ('long_no_value_next_arg_bad_value', '--verbosity', 'bad_value', 1, False),
    ('long_no_value_next_arg_bad_value2', '--verbosity', 'True', 1, False),
    ('short_no_value_next_arg', '-v', '2', 2, True),
    ('long_no_value_next_arg', '--verbosity', '2', 2, True),
    ('long2_no_value_next_arg', '--verbose', '2', 2, True),
    ('short_bad_value_next_arg_true', '-v', 'True', 1, False),
    ('long_bad_value_next_arg_true', '--verbosity', 'True', 1, False)]

def make_bad_cases() -> list[tuple[str, str, str | None]]:
  """
    Generate test cases for the VerbosityOption class with bad values.

    :return: A list of test cases
  """
  return [
    ('short_bad_value_equal', '-v=bad_value', None),
    ('short_bad_value2_equal', '-v=True', None),
    ('short_bad_value3_equal', '-v=-2', None),
    ('long_bad_value_equal', '--verbose=bad_value', None),
    ('long_bad_value2_equal', '--verbose=True', None),
    ('long_bad_value3_equal', '--verbose=-2', None),
    ('long2_bad_value_equal', '--verbosity=bad_value', None),
    ('long2_bad_value2_equal', '--verbosity=True', None),
    ('long2_bad_value3_equal', '--verbosity=-2', None),
    ('short_bad_value_next_arg_negative', '-v', '-2'),
    ('long_bad_value_next_arg', '--verbosity=bad_value', 'parameter')]

class TestVerbosityOption(unittest.TestCase):
  """
    Unit tests for class VerbosityOption
  """

  def test_value(self):
    """
      Test the value of the verbosity option.
    """
    verbosity_option = VerbosityOption(2)
    self.assertEqual(verbosity_option.value, 2)

  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('add_2_to_empty_dict', 2, {}, 2),
    ('add_3_to_dict_1', 3, {'verbosity': 1}, 4),
    ('add_1_to_none_dict', 1, {'verbosity': None}, 1),
    ('and_1_to_dict_0', 1, {'verbosity': 0}, 1)])
  def test_add_to(self, name, verbosity, dictionary, expected_verbosity): # pylint: disable=unused-argument
    """
      Test the add_to method.
    """
    verbosity_option = VerbosityOption(verbosity)
    verbosity_option.add_to(dictionary)
    self.assertEqual(expected_verbosity, dictionary['verbosity'])

  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('short_no_value', '-v', True),
    ('long_no_value', '--verbose', True),
    ('long2_no_value', '--verbosity', True),
    ('short_value', '-v=1', True),
    ('long_value', '--verbose=1', True),
    ('long2_value', '--verbosity=1', True),
    ('short_bad_value', '-v=True', True),  # Yes, this an option, although not a valid one
    ('long_bad_value', '--verbosity=True', True),  # So is this, for the same reason
    ('short_wrong_option', '-h', False),
    ('not_option','parameter', False)])
  def test_is_option(self, name, arg, expected_result):  # pylint: disable=unused-argument
    """
      Test the is_option method.
    """
    self.assertEqual(expected_result, VerbosityOption.is_option(arg))


  # noinspection PyUnusedLocal
  @parameterized.expand(make_correct_cases())
  def test_make(self,  # pylint: disable=too-many-arguments, too-many-positional-arguments
      name, current_arg, next_arg, expected_verbosity, expected_skip_next_arg) -> None:  # pylint: disable=unused-argument
    """
      Test the make method with parameterized inputs.
    """
    verbosity_option, skip_next_arg = VerbosityOption.make(current_arg, next_arg)
    self.assertIsInstance(verbosity_option, VerbosityOption)
    self.assertEqual(expected_verbosity, verbosity_option.value)
    self.assertEqual(expected_skip_next_arg, skip_next_arg)

  # noinspection PyUnusedLocal
  @parameterized.expand(make_bad_cases())
  def test_make_bad_cases(self,  # pylint: disable=too-many-arguments, too-many-positional-arguments
      name: str, current_arg: str, next_arg: str | None) -> None:  # pylint: disable=unused-argument
    """
      Test the make method with a bad value.
    """
    with self.assertRaises(ValueError):
      VerbosityOption.make(current_arg, next_arg)
