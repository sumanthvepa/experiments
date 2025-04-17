import unittest
from typing import TypedDict

from parse_command_line import parse_command_line

class TestCaseData(TypedDict):
  """
    A TypedDict to define the structure of a test case
  """
  args: list[str]
  expected_options: dict[str, bool | int | str | list[str]]
  expected_parameters: list[str]


class TestParseCommandLine(unittest.TestCase):
  def execute_test(self, case: TestCaseData) -> None:
    """
      Execute the test with the provided case data and check that
      the actual output matches the expected output.

      :param case: A test case
      :return: None
    """
    expected = (case['expected_options'], case['expected_parameters'])
    actual = parse_command_line(case['args'])
    self.assertEqual(expected, actual)

  def execute_test_old(
    self,
    args: list[str],
    expected_options: dict[str, bool | int | str | list[str]],
    expected_parameters: list[str]) -> None:
    """
      Execute the test with the provided arguments and check the expected
      :param args: The command line arguments to test.
      :param expected_options: The expected options dictionary.
      :param expected_parameters: The expected parameters list.
      :return: None
    """
    expected = (expected_options, expected_parameters)
    actual = parse_command_line(args)
    self.assertEqual(expected, actual)

  def test_no_arguments(self) -> None:
    """
      Test the case when no arguments are provided.

      :return: None
    """
    self.execute_test_old(
      args=[],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_verbosity(self) -> None:
    """
      Test the case when a single short option for verbosity is
      provided.

      :return: None
    """
    self.execute_test_old(
      args=['-v'],
      expected_options={'verbosity': 1, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_verbosity_with_value(self) -> None:
    """
      Test the case when a single short option with a value is provided.

      :return: None
    """
    self.execute_test_old(
      args=['-v2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_verbosity_with_value_equal(self) -> None:
    """
      Test the case when a single short option with a value is provided using an equal sign.

      :return: None
    """
    self.execute_test_old(
      args=['-v=2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_sing_le_short_option_verbosity_with_value_space(self) -> None:
    """
      Test the case when a single short option for verbosity is
      provided with a value using a space.

      :return: None
    """
    self.execute_test_old(
      args=['-v', '2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_verbosity_with_wrong_value(self) -> None:
    """
      Test the case when a single short option for verbosity is provided
      with a wrong value.

      :return: None
    """
    self.execute_test_old(
      args=['-v=wrong'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_help(self) -> None:
    """
      Test the case when a single short option for help is provided.

      :return: None
    """
    self.execute_test_old(
      args=['-h'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_help_with_wrong_value(self) -> None:
    """
      Test the case when a single short option for help is provided with
      an unnecessary value.

      :return: None
    """
    self.execute_test_old(
      args=['-h=true'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_environment(self) -> None:
    """
      Test the case when a single short option for environment is provided.

      :return: None
    """
    self.execute_test_old(
      args=['-e'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_short_option_environment_with_value(self) -> None:
    """
      Test the case when a single short option for environment is provided
      with a value.

      :return: None
    """
    self.execute_test_old(
      args=['-e=test'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['test']},
      expected_parameters=[])

  def test_single_short_option_environment_with_multi_value(self) -> None:
    """
      Test the case when a single short option for environment is provided
      with multiple values.

      :return: None
    """
    self.execute_test_old(
      args=['-e=test,local'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['test', 'local']},
      expected_parameters=[])

  def test_single_short_option_environment_with_wrong_value(self) -> None:
    """
      Test the case when a single short option for environment is provided with an
      incorrect value.

      :return: None
    """
    self.execute_test_old(
      args=['-e=wrong'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_verbose(self) -> None:
    """
      Test the case when a single long option for verbosity is provided.

      :return: None
    """
    self.execute_test_old(
      args=['--verbose'],
      expected_options={'verbosity': 1, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_verbose_with_value(self) -> None:
    """
      Test the case when a single long option for verbosity is provided
      with a value.

      :return: None
    """
    self.execute_test_old(
      args=['--verbose=2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_verbose_with_value_space(self) -> None:
    """
      Test the case when a single long option for verbosity is provided
      with a value using a space.

      :return: None
    """
    self.execute_test_old(
      args=['--verbose', '2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_verbosity_with_value(self) -> None:
    """
      Test the case when a single long option for verbosity is provided
      with a value.

      :return: None
    """
    self.execute_test_old(
      args=['--verbosity=2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_verbosity_with_value_space(self) -> None:
    """
      Test the case when a single long option for verbosity is provided
      with a value using a space.

      :return: None
    """
    self.execute_test_old(
      args=['--verbosity', '2'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_help(self) -> None:
    """
      Test the case when a single long option for help is provided.

      :return: None
    """
    self.execute_test_old(
      args=['--help'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_environment(self) -> None:
    """
      Test the case when a single long option for environment is provided.

      :return: None
    """
    self.execute_test_old(
      args=['--environment'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_env(self) -> None:
    """
    Test the case when a single long option --env is used for environment

    :return: None
    """
    self.execute_test_old(
      args=['--env'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_single_long_option_environment_with_value(self) -> None:
    """
    Test the case when a single long option for environment is provided
    with a value.

    :return: None
    """
    self.execute_test_old(
      args=['--environment=local'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local']},
      expected_parameters=[])

  def test_single_long_option_environment_with_value_space(self) -> None:
    """
      Test the case when a single long option for environment is provided
      with a value using a space.

      :return: None
    """
    self.execute_test_old(
      args=['--environment', 'local'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local']},
      expected_parameters=[])

  def test_single_long_option_env_with_value(self) -> None:
    """
    Test the case when a single long option for environment is provided
    with a value.

    :return: None
    """
    self.execute_test_old(
      args=['--env=local'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local']},
      expected_parameters=[])

  def test_single_long_option_env_with_value_space(self) -> None:
    """
      Test the case when a single long option --env is used for
      environment with a value using a space.

      :return: None
    """
    self.execute_test_old(
      args=['--env', 'local'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local']},
      expected_parameters=[])

  def test_single_long_option_environment_with_multi_value(self) -> None:
    """
    Test the case when a single long option for environment is provided with multiple values.

    :return: None
    """
    self.execute_test_old(
      args=['--environment=local,test'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
      expected_parameters=[])

  def test_single_long_option_environment_with_multi_value_space(self) -> None:
    """
      Test the case when a single long option for environment is provided
      with multiple values using a space.

      :return: None
    """
    self.execute_test_old(
      args=['--environment', 'local,test'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
      expected_parameters=[])

  def test_single_long_option_env_with_multi_value(self) -> None:
    """
    Test the case when a single long option for env is provided with
    multiple values.

    :return: None
    """
    self.execute_test_old(
      args=['--env=local,test'],
      expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
      expected_parameters=[])

  def test_multi_option_verbose(self) -> None:
    """
      Test the case when multiple short options for verbosity are provided in one
      multi-option argument.

      :return: None
    """
    self.execute_test_old(
      args=['-vvv'],
      expected_options={'verbosity': 3, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_multi_option_verbose_help(self) -> None:
    """
      Test the case when short options for verbosity and help are
      provided in one multi-option argument.

      :return: None
    """
    self.execute_test_old(
      args=['-vvvh'],
      expected_options={'verbosity': 3, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_multi_option_help_help(self) -> None:
    """
      Test the case when short the short option for help is duplicated
      in a multi-option argument.

      :return: None
    """
    self.execute_test_old(
      args=['-hh'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_multi_option_verbose_help_help(self) -> None:
    """
      Test the case when short the short option for help is duplicated
      in a multi-option argument.

      :return: None
    """
    self.execute_test_old(
      args=['-hvh'],
      expected_options={'verbosity': 1, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_multi_option_environment_wrong(self) -> None:
    """
      Test the case when multiple short options for verbosity and
      environment are provided in one multi-option argument.

      :return: None
    """
    self.execute_test_old(
      args=['-vve=local'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_multiple_short_options_verbosity(self) -> None:
    """
      Test the case when multiple short options for verbosity are
      provided.

      :return: None
    """
    self.execute_test_old(
      args=['-v', '-v'],
      expected_options={'verbosity': 2, 'help': True, 'environment': []},
      expected_parameters=[])

  def test_multiple_short_options_help(self) -> None:
    """
      Test the case when multiple short options for help are provided.

      :return: None
    """
    self.execute_test_old(
      args=['-h', '-h'],
      expected_options={'verbosity': 0, 'help': True, 'environment': []},
      expected_parameters=[])

  #
  # def test_positional_arguments(self) -> None:
  #     args: list[str] = ['application1', 'application2']
  #     expected_options: dict[str, int | bool] = {'v': 0, 'h': False}
  #     expected_positional: list[str] = ['application1', 'application2']
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))
  #
  # def test_mixed_arguments(self) -> None:
  #     args: list[str] = ['-v', '--env', 'test', 'application1']
  #     expected_options: dict[str, int | bool | str] = {'v': 1, 'h': False, 'env': 'test'}
  #     expected_positional: list[str] = ['application1']
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))
  #
  # def test_help_option(self) -> None:
  #     args: list[str] = ['-h']
  #     expected_options: dict[str, int | bool] = {'v': 0, 'h': True}
  #     expected_positional: list[str] = []
  #     self.assertEqual(parse_command_line(args), (expected_options, expected_positional))


if __name__ == '__main__':
  unittest.main()
