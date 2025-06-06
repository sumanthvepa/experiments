"""
  test_environment_option.py: Unit tests for class EnvironmentOption
"""
import unittest

from parameterized import parameterized

from dralithus.environment_option import EnvironmentOption

# pylint: disable=line-too-long
def make_correct_cases() -> list[tuple[str, str, str | None, set[str], bool]]:
  """
    Generate test cases for the EnvironmentOption class.

    :return: A list of test cases
  """
  return [
    ('short_equal_value_no_next_arg', '-e=local', None, {'local'}, False),
    ('short_equal_multi_value_no_next_arg', '-e=local,test', None, {'local', 'test'}, False),
    ('long_equal_value_no_next_arg', '--env=local', None, {'local'}, False),
    ('long_equal_multi_value_no_next_arg', '--env=local,test', None, {'local', 'test'}, False),
    ('long2_equal_value_no_next_arg', '--environment=local', None, {'local'}, False),
    ('long2_equal_multi_value_no_next_arg', '--environment=local,test', None, {'local', 'test'}, False),
    ('short_equal_value_next_arg', '-e=local', 'parameter', {'local'}, False),
    ('short_equal_multi_value_next_arg', '-e=local,test', 'parameter', {'local', 'test'}, False),
    ('long_equal_value_next_arg', '--env=local', 'parameter', {'local'}, False),
    ('long_equal_multi_value_next_arg', '--env=local,test', 'parameter', {'local', 'test'}, False),
    ('long2_equal_value_next_arg', '--environment=local', 'parameter', {'local'}, False),
    ('long2_equal_multi_value_next_arg', '--environment=local,test', 'parameter', {'local', 'test'}, False),
    ('short_next_arg_value', '-e', 'local', {'local'}, True),
    ('short_next_arg_multi_value', '-e', 'local,test', {'local', 'test'}, True),
    ('long_next_arg_value', '--env', 'local', {'local'}, True),
    ('long_next_arg_multi_value', '--env', 'local,test', {'local', 'test'}, True),
    ('long2_next_arg_value', '--environment', 'local', {'local'}, True),
    ('long2_next_arg_multi_value', '--environment', 'local,test', {'local', 'test'}, True)]


def make_incorrect_cases() -> list[tuple[str, str, str | None, type[Exception]]]:
  """
    Generate test cases for the EnvironmentOption class with bad values.

    :return: A list of test cases
  """
  return [
    ('short_bad_value_equal', '-e=bad_value', None, AssertionError),
    ('short_bad_value2_equal', '-e=True', None, AssertionError),
    ('short_bad_value3_equal', '-e=-2', None, AssertionError),
    ('long_bad_value_equal', '--env=bad_value', None, AssertionError),
    ('long_bad_value2_equal', '--env=True', None, AssertionError),
    ('long_bad_value3_equal', '--env=-2', None, AssertionError),
    ('long2_bad_value_equal', '--environment=bad_value', None, AssertionError),
    ('long2_bad_value2_equal', '--environment=True', None, AssertionError),
    ('long2_bad_value3_equal', '--environment=-2', None, AssertionError),
    ('short_next_arg_bad_value', '-e', 'bad_value', AssertionError),
    ('short_next_arg_bad_value2', '-e', 'True', AssertionError),
    ('short_next_arg_bad_value3', '-e', '-2', AssertionError),
    ('long_next_arg_bad_value', '--env', 'bad_value', AssertionError),
    ('long_next_arg_bad_value2', '--env', 'True', AssertionError),
    ('long_next_arg_bad_value3', '--env', '-2', AssertionError),
    ('long2_next_arg_bad_value', '--environment', 'bad_value', AssertionError),
    ('long2_next_arg_bad_value2', '--environment', 'True', AssertionError),
    ('long2_next_arg_bad_value3', '--environment', '-2', AssertionError),
    ('wrong_short_option_no_value', '-h', None, AssertionError),
    ('wrong_short_option_value', '-h=True', None, AssertionError),
    ('wrong_long_option_no_value', '--verbosity', None, AssertionError),
    ('wrong_long_option_value', '--verbosity=True', None, AssertionError),
    ('wrong_short_option_next_arg', '-v', '1', AssertionError),
    ('wrong_long_option_next_arg', '--verbosity', '1', AssertionError),
    ('wrong_no_option', 'parameter', None, AssertionError),
    ('short_invalid_environment_equal', '-e=invalid', None, AssertionError),
    ('long_invalid_environment_equal', '--env=invalid', None, AssertionError),
    ('long2_invalid_environment_equal', '--environment=invalid', None, AssertionError),
    ('short_one_invalid_multi_environment_equal', '-e=local,invalid', None, AssertionError),
    ('short_one_invalid_multi_environment_equal_reversed', '-e=invalid,local', None, AssertionError),
    ('long_one_invalid_multi_environment_equal', '--env=local,invalid', None, AssertionError),
    ('long_one_invalid_multi_environment_equal_reversed', '--env=invalid,local', None, AssertionError)]


class TestEnvironmentOption(unittest.TestCase):
  """
    Unit tests for class EnvironmentOption
  """
  def test_value(self) -> None:
    """
      Test the value of the environment option.
    """
    expected_environment = {'local'}
    option = EnvironmentOption('environment', expected_environment)
    self.assertSetEqual(expected_environment, option.value)

  #noinspection PyUnusedLocal
  @parameterized.expand([
    ('add_local_to_empty_dict', {'local'}, {}, {'local'}),
    ('add_local_to_non_empty_dict', {'local'}, {'environments': {'test'}}, {'local', 'test'}),
    ('add_duplicate_to_non_empty_dict', {'local'}, {'environments': {'local', 'test'}}, {'local', 'test'})])
  def test_add_to(
      self,
      name: str,  # pylint: disable=unused-argument
      environments: set[str],
      dictionary: dict[str, None | bool | int | str | set[str]],
      expected_environments: set[str])-> None:
    """
      Test the add_to method.
    """
    option = EnvironmentOption('e', environments)
    option.add_to(dictionary)
    self.assertSetEqual(expected_environments, dictionary['environments'])

  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('short_no_value', '-e', None, False),
    ('long_no_value', '--env', None, False),
    ('long2_no_value', '--environment', None, False),
    ('short_value_equal', '-e=local', None, True),
    ('long_value_equal', '--env=local', None, True),
    ('long2_value_equal', '--environment=local', None, True),
    ('short_multi_value', '-e=local,test', None, True),
    ('long_multi_value', '--env=local,test', None, True),
    ('long2_multi_value', '--environment=local,test', None, True),
    ('short_invalid_value', '-e=invalid', None, False),
    ('long_invalid_value', '--env=invalid', None, False),
    ('long2_invalid_value', '--environment=invalid', None, False),
    ('short_one_invalid_multi_value', '-e=local,invalid', None, False),
    ('short_one_invalid_multi_value_reversed', '-e=invalid,local', None, False),
    ('long_one_invalid_multi_value', '--env=local,invalid', None, False),
    ('long_one_invalid_multi_value_reversed', '--env=invalid,local', None, False),
    ('long2_one_invalid_multi_value', '--environment=local,invalid', None, False),
    ('long2_one_invalid_multi_value_reversed', '--environment=invalid,local', None, False),
    ('wrong_short_option_no_value', '-h', None, False),
    ('wrong_short_option_value', '-h=True', None, False),
    ('wrong_long_option_no_value', '--verbosity', None, False),
    ('wrong_long_option_value', '--verbosity=True', None, False),
    ('not_option','parameter', None, False)])
  def test_is_option(self,
    name: str,  # pylint: disable=unused-argument
    arg: str,
    next_arg: str | None,
    expected: bool) -> None:
    """
      Test the is_option method.
    """
    self.assertEqual(expected, EnvironmentOption.is_option(arg, next_arg))

  # noinspection PyUnusedLocal
  @parameterized.expand(make_correct_cases())
  def test_make(self,  # pylint: disable=too-many-arguments, too-many-positional-arguments
    name: str,  # pylint: disable=unused-argument
    current_arg: str,
    next_arg: str | None,
    expected_environments: set[str],
    expected_skip_next_arg: bool) -> None:
    """
      Test the make method with parameterized inputs
    """
    environment_option, skip_next_arg = EnvironmentOption.make(current_arg, next_arg)
    self.assertIsInstance(environment_option, EnvironmentOption)
    self.assertSetEqual(expected_environments, environment_option.value)
    self.assertEqual(expected_skip_next_arg, skip_next_arg)


  # noinspection PyUnusedLocal
  @parameterized.expand(make_incorrect_cases())
  def test_make_incorrect_cases(self,
      name: str,  # pylint: disable=unused-argument
      current_arg: str,
      next_arg: str | None,
      exception_type: type[Exception]) -> None:
    """
      Test the make method with a bad value.
    """
    with self.assertRaises(exception_type):
      EnvironmentOption.make(current_arg, next_arg)
