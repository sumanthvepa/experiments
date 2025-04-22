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


def is_asking_for_help(args: list[str]) -> bool:
  """
    Check if the help option is present in the args list.

    The help option is considered present if '--help' is in the args list,
    '-h' is in the args list, or 'h' is part of a multi-option (e.g., '-vhv').

    :param args: A list of command-line arguments
    :return: True if the help option is present, False otherwise
  """
  for arg in args:
    if arg == '--help' or arg == '-h':
      return True
    if arg.startswith('-') and 'h' in arg[1:]:
      return True
  return False


def parameter_missing_cases() -> list[tuple[str, TestCaseData]]:
  """
    Return a list of no parameter test cases.

    A no parameter test case does not contain any positional parameters.

    :return: A list of tuples, where each tuple consists of two
      elements, the name of the test case and a TestCaseData object
  """
  # noinspection SpellCheckingInspection
  return [
    ('no_arguments', TestCaseData(args=[], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_verbosity', TestCaseData(args=['-v'], expected_options={'verbosity': 1, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_verbosity_with_value', TestCaseData(args=['-v2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_verbosity_with_value_equal', TestCaseData(args=['-v=2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_verbosity_with_value_space', TestCaseData(args=['-v', '2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_help', TestCaseData(args=['-h'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_help_with_wrong_value', TestCaseData(args=['-h=true'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_environment', TestCaseData(args=['-e'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_short_option_environment_with_value', TestCaseData(args=['-e=test'], expected_options={'verbosity': 0, 'help': True, 'environment': ['test']}, expected_parameters=[])),
    ('single_short_option_environment_with_multi_value', TestCaseData(args=['-e=test,local'], expected_options={'verbosity': 0, 'help': True, 'environment': ['test', 'local']}, expected_parameters=[])),
    ('single_short_option_environment_with_wrong_value', TestCaseData(args=['-e=wrong'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_verbose', TestCaseData(args=['--verbose'], expected_options={'verbosity': 1, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_verbose_with_value', TestCaseData(args=['--verbose=2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_verbose_with_value_space', TestCaseData(args=['--verbose', '2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_verbosity_with_value', TestCaseData(args=['--verbosity=2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_verbosity_with_value_space', TestCaseData(args=['--verbosity', '2'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_help', TestCaseData(args=['--help'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_environment', TestCaseData(args=['--environment'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_env', TestCaseData(args=['--env'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('single_long_option_environment_with_value', TestCaseData(args=['--environment=local'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('single_long_option_environment_with_value_space', TestCaseData(args=['--environment', 'local'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('single_long_option_env_with_value', TestCaseData(args=['--env=local'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('single_long_option_env_with_value_space', TestCaseData(args=['--env', 'local'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('single_long_option_environment_with_multi_value', TestCaseData(args=['--environment=local,test'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']}, expected_parameters=[])),
    ('single_long_option_environment_with_multi_value_space', TestCaseData(args=['--environment', 'local,test'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']}, expected_parameters=[])),
    ('single_long_option_env_with_multi_value', TestCaseData(args=['--env=local,test'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']}, expected_parameters=[])),
    ('multi_option_verbose', TestCaseData(args=['-vvv'], expected_options={'verbosity': 3, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multi_option_verbose_help', TestCaseData(args=['-vvvh'], expected_options={'verbosity': 3, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multi_option_help_help', TestCaseData(args=['-hh'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multi_option_verbose_help_help', TestCaseData(args=['-hvh'], expected_options={'verbosity': 1, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multi_option_environment_wrong', TestCaseData(args=['-vve=local'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_short_options_verbosity', TestCaseData(args=['-v', '-v'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_short_options_help', TestCaseData(args=['-h', '-h'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_short_options_help_verbosity', TestCaseData(args=['-h', '-v'], expected_options={'verbosity': 1, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_short_options_verbosity_environment_equal', TestCaseData(args=['-v', '-e=local'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_short_options_verbosity_environment_space', TestCaseData(args=['-v', '-e', 'local'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_short_options_verbosity_environment_multi_space', TestCaseData(args=['-v', '-e', 'local,test'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local', 'test']}, expected_parameters=[])),
    ('multiple_short_options_verbosity_environment_multi_equal', TestCaseData(args=['-v', '-e=local,test'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local', 'test']}, expected_parameters=[])),
    ('multiple_short_options_environment_equal_verbosity_equal', TestCaseData(args=['-e=local', '-v=1'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_short_options_environment_space_verbosity_space', TestCaseData(args=['-e', 'local', '-v', '1'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_long_options_verbosity_verbosity', TestCaseData(args=['--verbosity', '--verbosity'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_long_options_verbose_verbose', TestCaseData(args=['--verbose', '--verbose'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_long_options_help_help', TestCaseData(args=['--help', '--help'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_long_options_help_verbosity_equal', TestCaseData(args=['--help', '--verbosity=3'], expected_options={'verbosity': 3, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_long_options_help_verbosity_space', TestCaseData(args=['--help', '--verbosity', '3'], expected_options={'verbosity': 3, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_long_options_verbose_environment_equal', TestCaseData(args=['--verbose', '--environment=local'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_long_options_verbose_environment_space', TestCaseData(args=['--verbose', '--environment', 'local'], expected_options={'verbosity': 1, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_long_options_environment_environment', TestCaseData(args=['--environment', '--environment'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_long_options_environment_environment_equal', TestCaseData(args=['--environment=local', '--environment=test'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test']}, expected_parameters=[])),
    ('multiple_long_options_environment_space_environment_space', TestCaseData(args=['--environment', 'test', '--environment', 'local'], expected_options={'verbosity': 0, 'help': True, 'environment': ['test', 'local']}, expected_parameters=[])),
    ('multiple_long_options_environment_equal_environment_multi_equal',TestCaseData(args=['--environment=local', '--environment=test,staging'], expected_options={'verbosity': 0, 'help': True, 'environment': ['local', 'test', 'staging']}, expected_parameters=[])),
    ('multiple_multi_options_help_verbosity_long_verbose', TestCaseData(args=['-hv', '--verbose'], expected_options={'verbosity': 2, 'help': True, 'environment': []}, expected_parameters=[])),
    ('multiple_multi_options_verbosity_verbosity_long_environment', TestCaseData(args=['-vv', '--environment=local'], expected_options={'verbosity': 2, 'help': True, 'environment': ['local']}, expected_parameters=[])),
    ('multiple_options_verbosity_help_e_equal_environment_multi_equal', TestCaseData(args=['-e=local', '-hvvv', '--environment=test,staging'], expected_options={'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']}, expected_parameters=[])),
    ('multiple_options_verbosity_help_e_space_environment_multi_space', TestCaseData(args=['-e', 'local', '-vhvv', '--environment', 'test,staging'], expected_options={'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']}, expected_parameters=[])),
    ('multiple_options_verbosity_help_e_space_environment_multi_equal', TestCaseData(args=['-e', 'local', '-vvhv', '--environment=test,staging'], expected_options={'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']}, expected_parameters=[])),
    ('multiple_options_verbosity_help_e_equal_environment_multi_space', TestCaseData(args=['-e=local', '-vvvh', '--environment', 'test,staging'], expected_options={'verbosity': 3, 'help': True, 'environment': ['local', 'test', 'staging']}, expected_parameters=[])),
    ('multiple_options_verbosity_help_e_equal_environment_multi_space', TestCaseData(args=['-e=local', '-hhvv', '--environment', 'local,staging'], expected_options={'verbosity': 2, 'help': True, 'environment': ['local', 'staging']}, expected_parameters=[])),
  ]


def incorrect_option_cases() -> list[tuple[str, TestCaseData]]:
  """
    Return a list of test cases with incorrect options.

    These test cases are used to check the behavior of the command line
    parser when it encounters invalid options. The expected behavior is
    to raise an exception which is caught internally, and the function
    returns help as the expected output. The values of other options
    and parameters are dependent on where the incorrect option is
    located in the args list. For options that are before the incorrect
    option, their values are set to those specified in args list, but
    for options that are after the incorrect option, their values are
    set to the default values.

    :return: A list of tuples, where each tuple consists of two
      elements, the name of the test case and a TestCaseData object
  """
  return [
    ('single_short_option_verbosity_with_wrong_value', TestCaseData(args=['-v=wrong'], expected_options={'verbosity': 0, 'help': True, 'environment': []}, expected_parameters=[]))
  ]


def parameter_present_cases() -> list[tuple[str, TestCaseData]]:
  """
    Return a list of parameterized test cases where there are
    parameters present in the args list.

    Each test case corresponds to three variations of the test cases
    returned by no_parameters_test_cases(), with additional parameters
    ['sample'], ['sample', 'echo'], and ['sample', 'echo', 'dralithus'].

    :return: A list of tuples, where each tuple consists of two
      elements, the name of the test case and a TestCaseData object
  """
  parameter_variations = [['sample'], ['sample', 'echo'], ['sample', 'echo', 'dralithus']]
  test_cases = []

  for name, case in parameter_missing_cases():
    for i, parameters in enumerate(parameter_variations):
      suffix = '_parameters_' + '_'.join(parameters)
      new_name = name + suffix
      new_args = case['args'] + parameters
      new_expected_parameters = parameters
      new_expected_options = case['expected_options'].copy()

      # Adjust the 'help' option based on the rules
      if is_asking_for_help(new_args) or len(new_expected_options['environment']) == 0:
        new_expected_options['help'] = True
      else:
        new_expected_options['help'] = False

      test_cases.append((
        new_name,
        {
          'args': new_args,
          'expected_options': new_expected_options,
          'expected_parameters': new_expected_parameters
        }
      ))

  return test_cases


def all_cases() -> list[tuple[str, TestCaseData]]:
  """
    Return a list of all test cases with their names

    This is a global function rather than a staticmethod
    because it is used in the parameterized decorator. It appears
    that any staticmethod used in the parameterized decorator
    cannot itself call a staticmethod. Not sure if this is a bug
    or a feature of the parameterized library.

    :return: A list of tuples, where each tuple consists of two
      elements, the name of the test case and a TestCaseData object
  """
  return parameter_missing_cases() + incorrect_option_cases() + parameter_present_cases()


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
    self.assertEqual(expected, actual, msg=f"Failed for args: {case['args']}")

  # noinspection PyUnusedLocal
  @parameterized.expand(all_cases())
  def test_cases(self, name: str, case: TestCaseData) -> None:
    """
      Execute the test with the provided case data.

      Note that despite the arrow next to the test in the
      IntelliJ IDEA IDE, you cannot run this test
      by clicking on the arrow. You need to run the whole
      class, the whole file, or all the tests in the project.

      :param name: The name of the test case
      :param case: A test case with input and expected output
      :return: None
    """
    self.execute_test(case)

  @unittest.skip("Debugging for a failing test")
  def test_debug(self) -> None:
    """
      Debug a failing test case

      :return: None
    """
    case = all_cases()[55][1]
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
