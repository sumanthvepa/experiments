import unittest
from typing import TypedDict

from parameterized import parameterized

from parse_command_line import parse_command_line


class TestCaseData(TypedDict):
  """
    A TypedDict to define the structure of a test case
  """
  args: list[str]
  expected_options: dict[str, bool | int | str | list[str]]
  expected_parameters: list[str]




class TestParseCommandLine(unittest.TestCase):
  @staticmethod
  def all_cases() -> list[tuple[str, TestCaseData]]:
    """
      Return a list of all test cases with their names

      :return: A list of tuples, where each tuple consists of two
        elements, the name of the test case and a TestCaseData object
    """

    return [
      ('no_arguments', {
        'args': [],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_verbosity', {
        'args': ['-v'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_verbosity_with_value', {
        'args': ['-v2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_verbosity_with_value_equal', {
        'args': ['-v=2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_verbosity_with_value_space', {
        'args': ['-v', '2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_verbosity_with_wrong_value', {
        'args': ['-v=wrong'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_help', {
        'args': ['-h'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_help_with_wrong_value', {
        'args': ['-h=true'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_environment', {
        'args': ['-e'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_short_option_environment_with_value', {
        'args': ['-e=test'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['test']},
        'expected_parameters': []
      }),
      ('single_short_option_environment_with_multi_value', {
        'args': ['-e=test,local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['test', 'local']},
        'expected_parameters': []
      }),
      ('single_short_option_environment_with_wrong_value', {
        'args': ['-e=wrong'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_verbose', {
        'args': ['--verbose'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_verbose_with_value', {
        'args': ['--verbose=2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_verbose_with_value_space', {
        'args': ['--verbose', '2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_verbosity_with_value', {
        'args': ['--verbosity=2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_verbosity_with_value_space', {
        'args': ['--verbosity', '2'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_help', {
        'args': ['--help'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_environment', {
        'args': ['--environment'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_env', {
        'args': ['--env'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('single_long_option_environment_with_value', {
        'args': ['--environment=local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('single_long_option_environment_with_value_space', {
        'args': ['--environment', 'local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('single_long_option_env_with_value', {
        'args': ['--env=local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('single_long_option_env_with_value_space', {
        'args': ['--env', 'local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('single_long_option_environment_with_multi_value', {
        'args': ['--environment=local,test'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
        'expected_parameters': []
      }),
      ('single_long_option_environment_with_multi_value_space', {
        'args': ['--environment', 'local,test'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
        'expected_parameters': []
      }),
      ('single_long_option_env_with_multi_value', {
        'args': ['--env=local,test'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
        'expected_parameters': []
      }),
      ('multi_option_verbose', {
        'args': ['-vvv'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multi_option_verbose_help', {
        'args': ['-vvvh'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multi_option_help_help', {
        'args': ['-hh'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multi_option_verbose_help_help', {
        'args': ['-hvh'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multi_option_environment_wrong', {
        'args': ['-vve=local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_short_options_verbosity', {
        'args': ['-v', '-v'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_short_options_help', {
        'args': ['-h', '-h'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_short_options_help_verbosity', {
        'args': ['-h', '-v'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_short_options_verbosity_environment_equal', {
        'args': ['-v', '-e=local'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('multiple_short_options_verbosity_environment_space', {
       'args': ['-v', '-e', 'local'],
       'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local']},
       'expected_parameters': []
      }),
      ('multiple_short_options_verbosity_environment_multi_space', {
       'args': ['-v', '-e', 'local,test'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local', 'test']},
        'expected_parameters': []
      }),
      ('multiple_short_options_verbosity_environment_multi_equal', {
       'args': ['-v', '-e=local,test'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local', 'test']},
        'expected_parameters': []
      }),
      ('multiple_short_options_environment_equal_verbosity_equal', {
        'args': ['-e=local', '-v=1'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('multiple_short_options_environment_space_verbosity_space', {
        'args': ['-e', 'local', '-v', '1'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('multiple_long_options_verbosity_verbosity', {
        'args': ['--verbosity', '--verbosity'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_long_options_verbose_verbose', {
        'args': ['--verbose', '--verbose'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_long_options_help_help', {
        'args': ['--help', '--help'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_long_options_help_verbosity_equal', {
        'args': ['--help', '--verbosity=3'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_long_options_help_verbosity_space', {
        'args': ['--help', '--verbosity', '3'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_long_options_verbose_environment_equal', {
        'args': ['--verbose', '--environment=local'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('multiple_long_options_verbose_environment_space', {
        'args': ['--verbose', '--environment', 'local'],
        'expected_options': {'verbosity': 1, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('multiple_long_options_environment_environment', {
        'args': ['--environment', '--environment'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_long_options_environment_environment_equal', {
        'args': ['--environment=local', '--environment=test'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local', 'test']},
        'expected_parameters': []
      }),
      ('multiple_long_options_environment_space_environment_space', {
        'args': ['--environment', 'test', '--environment', 'local'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['test', 'local']},
        'expected_parameters': []
      }),
      ('multiple_long_options_environment_equal_environment_multi_equal', {
        'args': ['--environment=local', '--environment=test,staging'],
        'expected_options': {'verbosity': 0, 'help': True, 'environment': ['local', 'test', 'staging']},
        'expected_parameters': []
      }),
      ('multiple_multi_options_help_verbosity_long_verbose', {
        'args': ['-hv', '--verbose'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': []},
        'expected_parameters': []
      }),
      ('multiple_multi_options_verbosity_verbosity_long_environment', {
        'args': ['-vv', '--environment=local'],
        'expected_options': {'verbosity': 2, 'help': True, 'environment': ['local']},
        'expected_parameters': []
      }),
      ('multiple_options_verbosity_help_e_equal_environment_multi_equal', {
        'args': ['-e=local', '-hvvv', '--environment=test,staging'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']},
        'expected_parameters': []
      }),
      ('multiple_options_verbosity_help_e_space_environment_multi_space', {
        'args': ['-e', 'local', '-vhvv', '--environment', 'test,staging'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']},
        'expected_parameters': []
      }),
      ('multiple_options_verbosity_help_e_space_environment_multi_equal', {
        'args': ['-e', 'local', '-vvhv', '--environment=test,staging'],
        'expected_options': {'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']},
        'expected_parameters': []
      })
    ]

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


  @parameterized.expand(all_cases())
  def test_cases(self, name: str, case: TestCaseData) -> None:
    """
      Execute the test with the provided case data.

      Note that despite the arrow next to the test in the
      IntelliJ IDEA IDE, you cannot run this this test
      by clicking on the arrow. You need to run the whole
      class, the whole file, or all the tests in the project.

      :param name: The name of the test-case
      :param case: Test-case data with input and expected
        output
      :return: None
    """
    self.execute_test(case)

  def test_debug(self) -> None:
    """
      Debug a failing test case

      :return: None
    """
    case = TestParseCommandLine.all_cases()[55][1]
    self.execute_test(case)

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
