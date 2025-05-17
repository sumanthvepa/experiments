"""
  test_parse_command_line.py: Unit tests for the command line parser
"""
import unittest

from parameterized import parameterized

from dralithus.test import CaseData, CaseExecutor
from dralithus.parse_command_line import parse_command_line


# noinspection SpellCheckingInspection
def base_cases() -> list[tuple[str, CaseData]]:
  """
    A list of cases that are have correct options, but no parameters.

    DO NOT DIRECTLY TEST FOR THESE CASES, they will all fail,
    since by default an empty parameter set will always casse the
    command line parser to raise an exception.

    Instead, these are used to generate the correct no parameter and
    parameter cases.

    :return: A list of test cases
  """
  # pylint: disable=line-too-long
  return [
    ('no_arguments', CaseData(args=[], expected=({'verbosity': 0, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_short_option_verbosity', CaseData(args=['-v'], expected=({'verbosity': 1, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_short_option_verbosity_with_value', CaseData(args=['-v2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_short_option_verbosity_with_value_equal', CaseData(args=['-v=2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_short_option_verbosity_with_value_space', CaseData(args=['-v', '2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_short_option_help', CaseData(args=['-h'], expected=({'verbosity': 0, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('single_short_option_environment_with_value', CaseData(args=['-e=test'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'test'}}, set()), error=None)),
    ('single_short_option_environment_with_multi_value', CaseData(args=['-e=test,local'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'test', 'local'}}, set()), error=None)),
    ('single_long_option_verbose', CaseData(args=['--verbose'], expected=({'verbosity': 1, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_long_option_verbose_with_value', CaseData(args=['--verbose=2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_long_option_verbose_with_value_space', CaseData(args=['--verbose', '2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_long_option_verbosity_with_value', CaseData(args=['--verbosity=2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_long_option_verbosity_with_value_space', CaseData(args=['--verbosity', '2'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('single_long_option_help', CaseData(args=['--help'], expected=({'verbosity': 0, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('single_long_option_environment_with_value', CaseData(args=['--environment=local'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('single_long_option_environment_with_value_space', CaseData(args=['--environment', 'local'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('single_long_option_env_with_value', CaseData(args=['--env=local'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('single_long_option_env_with_value_space', CaseData(args=['--env', 'local'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('single_long_option_environment_with_multi_value', CaseData(args=['--environment=local,test'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local', 'test'}}, set()), error=None)),
    ('single_long_option_environment_with_multi_value_space', CaseData(args=['--environment', 'local,test'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local', 'test'}}, set()), error=None)),
    ('single_long_option_env_with_multi_value', CaseData(args=['--env=local,test'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local', 'test'}}, set()), error=None)),
    ('multi_option_verbose', CaseData(args=['-vvv'], expected=({'verbosity': 3, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('multi_option_verbose_help', CaseData(args=['-vvvh'], expected=({'verbosity': 3, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multi_option_help_help', CaseData(args=['-hh'], expected=({'verbosity': 0, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multi_option_verbose_help_help', CaseData(args=['-hvh'], expected=({'verbosity': 1, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_short_options_verbosity', CaseData(args=['-v', '-v'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('multiple_short_options_help', CaseData(args=['-h', '-h'], expected=({'verbosity': 0, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_short_options_help_verbosity', CaseData(args=['-h', '-v'], expected=({'verbosity': 1, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_short_options_verbosity_environment_equal', CaseData(args=['-v', '-e=local'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_short_options_verbosity_environment_space', CaseData(args=['-v', '-e', 'local'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_short_options_verbosity_environment_multi_space', CaseData(args=['-v', '-e', 'local,test'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local', 'test'}}, set()), error=None)),
    ('multiple_short_options_verbosity_environment_multi_equal', CaseData(args=['-v', '-e=local,test'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local', 'test'}}, set()), error=None)),
    ('multiple_short_options_environment_equal_verbosity_equal', CaseData(args=['-e=local', '-v=1'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_short_options_environment_space_verbosity_space', CaseData(args=['-e', 'local', '-v', '1'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_long_options_verbosity_verbosity', CaseData(args=['--verbosity', '--verbosity'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('multiple_long_options_verbose_verbose', CaseData(args=['--verbose', '--verbose'], expected=({'verbosity': 2, 'requires_help': False, 'environments': set()}, set()), error=None)),
    ('multiple_long_options_help_help', CaseData(args=['--help', '--help'], expected=({'verbosity': 0, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_long_options_help_verbosity_equal', CaseData(args=['--help', '--verbosity=3'], expected=({'verbosity': 3, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_long_options_help_verbosity_space', CaseData(args=['--help', '--verbosity', '3'], expected=({'verbosity': 3, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_long_options_verbose_environment_equal', CaseData(args=['--verbose', '--environment=local'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_long_options_verbose_environment_space', CaseData(args=['--verbose', '--environment', 'local'], expected=({'verbosity': 1, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_long_options_environment_environment_equal', CaseData(args=['--environment=local', '--environment=test'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local', 'test'}}, set()), error=None)),
    ('multiple_long_options_environment_space_environment_space', CaseData(args=['--environment', 'test', '--environment', 'local'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'test', 'local'}}, set()), error=None)),
    ('multiple_long_options_environment_equal_environment_multi_equal', CaseData(args=['--environment=local', '--environment=test,staging'], expected=({'verbosity': 0, 'requires_help': False, 'environments': {'local', 'test', 'staging'}}, set()), error=None)),
    ('multiple_multi_options_help_verbosity_long_verbose', CaseData(args=['-hv', '--verbose'], expected=({'verbosity': 2, 'requires_help': True, 'environments': set()}, set()), error=None)),
    ('multiple_multi_options_verbosity_verbosity_long_environment', CaseData(args=['-vv', '--environment=local'], expected=({'verbosity': 2, 'requires_help': False, 'environments': {'local'}}, set()), error=None)),
    ('multiple_options_verbosity_help_e_equal_environment_multi_equal', CaseData(args=['-e=local', '-hvvv', '--environment=test,staging'], expected=({'verbosity': 3, 'requires_help': True, 'environments': {'local', 'test', 'staging'}}, set()), error=None)),
    ('multiple_options_verbosity_help_e_space_environment_multi_space', CaseData(args=['-e', 'local', '-vhvv', '--environment', 'test,staging'], expected=({'verbosity': 3, 'requires_help': True, 'environments': {'local', 'test', 'staging'}}, set()), error=None)),
    ('multiple_options_verbosity_help_e_space_environment_multi_equal', CaseData(args=['-e', 'local', '-vvhv', '--environment=test,staging'], expected=({'verbosity': 3, 'requires_help': True, 'environments': {'local', 'test', 'staging'}}, set()), error=None)),
    ('multiple_options_verbosity_help_e_equal_environment_multi_space', CaseData(args=['-e=local', '-vvvh', '--environment', 'test,staging'], expected=({'verbosity': 3, 'requires_help': True, 'environments': {'local', 'test', 'staging'}}, set()), error=None)),
    ('multiple_options_verbosity_help_e_equal_environment_multi_space', CaseData(args=['-e=local', '-hhvv', '--environment', 'local,staging'], expected=({'verbosity': 2, 'requires_help': True, 'environments': {'local', 'staging'}}, set()), error=None)),
    ('single_short_option_verbosity_with_wrong_value', CaseData(args=['-v=wrong'], expected=None, error=ValueError)),
    ('single_short_option_environment', CaseData(args=['-e'], expected=None, error=ValueError)),
    ('single_short_option_environment_with_wrong_value', CaseData(args=['-e=wrong'], expected=None, error=ValueError)),
    ('single_long_option_environment', CaseData(args=['--environment'], expected=None, error=ValueError)),
    ('single_long_option_env', CaseData(args=['--env'], expected=None, error=ValueError)),
    ('multi_option_environment_wrong', CaseData(args=['-vve=local'], expected=None, error=ValueError)),
    ('multiple_long_options_environment_environment', CaseData(args=['--environment', '--environment'], expected=None, error=ValueError))
  ]


def no_parameter_cases() -> list[tuple[str, CaseData]]:
  """
    Return all test cases for the command line parser where options are
    correct and no parameters are present

    This function takes the base_correct_option_cases, and sets the
    expected field to None, and the error field to ValueError.

    :return: A list of test cases
  """
  cases: list[tuple[str, CaseData]] = []
  for case_name, case in base_cases():
    no_parameter_case = CaseData(case.args, None, ValueError)
    cases.append((case_name, no_parameter_case))
  return cases


def parameter_variations() -> list[set[str]]:
  """
    List of parameter variations to test with.
    :return: A list of parameter variations
  """
  return [{'sample'}, {'sample', 'echo'}, {'sample', 'echo', 'dralithus'}]


def parameter_cases() -> list[tuple[str, CaseData]]:
  """
    Return all test cases for the command line parser where options are
    correct and parameters are present

    This function takes the base_correct_option_cases, and sets the
    expected field to also include the parameters, and the error
    field to None.

    :return: A list of test cases
  """
  variations = parameter_variations()
  cases: list[tuple[str, CaseData]] = []
  for no_parameter_case_name, no_parameter_case in base_cases():
    no_parameter_environments = set()
    if no_parameter_case.expected is not None:
      no_parameter_case_expected_options = no_parameter_case.expected[0]
      no_parameter_environments = no_parameter_case_expected_options['environments']
    for parameters in variations:
      parameter_case_name = no_parameter_case_name + '_with_parameters_' + '_'.join(parameters)
      parameter_case_args = no_parameter_case.args + list(parameters)
      if no_parameter_case.error is not None or not no_parameter_environments:
        error = no_parameter_case.error if no_parameter_case.error is not None else ValueError
        parameter_case = CaseData(
          args=parameter_case_args,
          expected=None,
          error=error)
      else:
        parameter_case = CaseData(
          args=parameter_case_args,
          expected=(no_parameter_case.expected[0], parameters),
          error=None)
      cases.append((parameter_case_name, parameter_case))
  return cases



def all_cases() -> list[tuple[str, CaseData]]:
  """
    Return all test cases for the command line parser.
  """
  return no_parameter_cases() + parameter_cases()


class TestParseCommandLine(unittest.TestCase, CaseExecutor):
  """
    Unit tests for the command line parser.
  """
  def __init__(self, *args, **kwargs):
    """
      Initialize the test case.
    """
    unittest.TestCase.__init__(self, *args, **kwargs)
    CaseExecutor.__init__(self, parse_command_line)

  # pylint: disable=unused-argument
  # noinspection PyUnusedLocal
  @parameterized.expand(all_cases())
  def test_parse_command_line(self, name: str, case: CaseData) -> None:
    """
      Test the parse_command_line function.
    """
    self.execute(case)


if __name__ == '__main__':
  unittest.main()
