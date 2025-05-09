"""
  test_options.py: Unit tests for the Options class
"""
import unittest
from dataclasses import dataclass

from parameterized import parameterized

from options import Options


@dataclass
class OptionsTestCaseData:
  """
    Data class for test cases.
  """
  args: list[str]
  expected_dict: dict[str, None | bool | int | str | set[str]]
  expected_end_index: int


def make_empty_case() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate the empty test case.
    :return: Return the empty test case in a single element list
  """
  # pylint: disable=line-too-long
  return [
    ('empty', OptionsTestCaseData(args=[], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': set()}, expected_end_index=0))
  ]


def make_single_option_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of single option test cases.

    :return: A list of test cases
  """
  # pylint: disable=line-too-long
  return [
    ('help-short', OptionsTestCaseData(args=['-h'], expected_dict={'requires_help': True, 'verbosity': 0, 'environments': set()}, expected_end_index=1)),
    ('help-long', OptionsTestCaseData(args=['--help'], expected_dict={'requires_help': True, 'verbosity': 0, 'environments': set()}, expected_end_index=1)),
    ('verbosity-short', OptionsTestCaseData(args=['-v'], expected_dict={'requires_help': False, 'verbosity': 1, 'environments': set()}, expected_end_index=1)),
    ('verbosity-long', OptionsTestCaseData(args=['--verbose'], expected_dict={'requires_help': False, 'verbosity': 1, 'environments': set()}, expected_end_index=1)),
    ('verbosity-long-value-equal', OptionsTestCaseData(args=['--verbose=2'], expected_dict={'requires_help': False, 'verbosity': 2, 'environments': set()}, expected_end_index=1)),
    ('verbosity-long-value-space', OptionsTestCaseData(args=['--verbose', '2'], expected_dict={'requires_help': False, 'verbosity': 2, 'environments': set()}, expected_end_index=2)),
    ('verbosity-long2', OptionsTestCaseData(args=['--verbosity'], expected_dict={'requires_help': False, 'verbosity': 1, 'environments': set()}, expected_end_index=1)),
    ('verbosity-long2-value-equal', OptionsTestCaseData(args=['--verbosity=2'], expected_dict={'requires_help': False, 'verbosity': 2, 'environments': set()}, expected_end_index=1)),
    ('verbosity-long2-value-space', OptionsTestCaseData(args=['--verbosity', '2'], expected_dict={'requires_help': False, 'verbosity': 2, 'environments': set()}, expected_end_index=2)),
    ('environment-short', OptionsTestCaseData(args=['-e=local'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local'}}, expected_end_index=1)),
    ('environment-short2', OptionsTestCaseData(args=['-e=development'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development'}}, expected_end_index=1)),
    ('environment-short-space', OptionsTestCaseData(args=['-e', 'local'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local'}}, expected_end_index=2)),
    ('environment-short-space2', OptionsTestCaseData(args=['-e', 'development'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development'}}, expected_end_index=2)),
    ('environment-short-multiple', OptionsTestCaseData(args=['-e=local,test'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=1)),
    ('environment-short-multiple2', OptionsTestCaseData(args=['-e=development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development', 'staging'}}, expected_end_index=1)),
    ('environment-short-multiple-space', OptionsTestCaseData(args=['-e', 'local,test'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=2)),
    ('environment-short-multiple-space2', OptionsTestCaseData(args=['-e', 'development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development', 'staging'}}, expected_end_index=2)),
    ('environment-long', OptionsTestCaseData(args=['--env=local'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local'}}, expected_end_index=1)),
    ('environment-long2', OptionsTestCaseData(args=['--env=development'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development'}}, expected_end_index=1)),
    ('environment-long-space', OptionsTestCaseData(args=['--env', 'local'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local'}}, expected_end_index=2)),
    ('environment-long-space2', OptionsTestCaseData(args=['--env', 'development'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development'}}, expected_end_index=2)),
    ('environment-long-multiple', OptionsTestCaseData(args=['--env=local,test'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=1)),
    ('environment-long-multiple2', OptionsTestCaseData(args=['--env=development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development', 'staging'}}, expected_end_index=1)),
    ('environment-long-multiple-space', OptionsTestCaseData(args=['--env', 'local,test'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=2)),
    ('environment-long-multiple-space2', OptionsTestCaseData(args=['--env', 'development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development', 'staging'}}, expected_end_index=2)),
    ('environment2-long', OptionsTestCaseData(args=['--environment=local'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local'}}, expected_end_index=1)),
    ('environment2-long2', OptionsTestCaseData(args=['--environment=development'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development'}}, expected_end_index=1)),
    ('environment2-long-space', OptionsTestCaseData(args=['--environment', 'local'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local'}}, expected_end_index=2)),
    ('environment2-long2-space', OptionsTestCaseData(args=['--environment', 'development'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development'}}, expected_end_index=2)),
    ('environment2-long-multiple', OptionsTestCaseData(args=['--environment=local,test'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=1)),
    ('environment2-long2-multiple', OptionsTestCaseData(args=['--environment=development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development', 'staging'}}, expected_end_index=1)),
    ('environment2-long-multiple-space', OptionsTestCaseData(args=['--environment', 'local,test'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=2)),
    ('environment2-long2-multiple-space', OptionsTestCaseData(args=['--environment', 'development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'development', 'staging'}}, expected_end_index=2))
  ]


def combine_cases(
    name1: str, case1: OptionsTestCaseData,
    name2: str, case2: OptionsTestCaseData) -> tuple[str, OptionsTestCaseData]:
  """
    Combine two test cases into a single test case.

    :param name1: The name of the first test case
    :param case1: The first test case
    :param name2: The name of the second test case
    :param case2: The second test case
    :return: The combined test case
  """
  combined_args = case1.args + case2.args
  combined_expected_dict = {
    'requires_help': \
      case1.expected_dict['requires_help'] or case2.expected_dict['requires_help'],
    'verbosity': \
      case1.expected_dict['verbosity'] + case2.expected_dict['verbosity'],
    'environments': \
      case1.expected_dict['environments'] | case2.expected_dict['environments']
  }
  case = OptionsTestCaseData(
    args=combined_args,
    expected_dict=combined_expected_dict,
    expected_end_index=len(combined_args))
  name = f'{name1}-{name2}'
  return name, case

def make_double_option_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of double option test cases.

    i.e. cases where the args list has two options.
    These are generated by combining single option cases.

    :return: A list of test cases
  """
  single_option_cases = make_single_option_cases()
  double_option_cases: list[tuple[str, OptionsTestCaseData]] = []
  for name1, case1 in single_option_cases:
    for name2, case2 in single_option_cases:
      double_option_cases.append(combine_cases(name1, case1, name2, case2))
      if name1 != name2:
        # pylint: disable=arguments-out-of-order
        double_option_cases.append(combine_cases(name2, case2, name1, case1))
  return double_option_cases

def make_cases_with_extra_args() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of test cases with extra args.

    :return: A list of test cases
  """
  cases_with_no_extra_args \
    = make_empty_case() + make_single_option_cases() + make_double_option_cases()
  cases_with_extra_args: list[tuple[str, OptionsTestCaseData]] = []
  for name, case in cases_with_no_extra_args:
    # Add extra args to the end of the args list
    extra_args = ['extra_arg1', 'extra_arg2']
    case_with_extra_args = OptionsTestCaseData(
      args=case.args + extra_args,
      expected_dict=case.expected_dict,
      expected_end_index=len(case.args))
    cases_with_extra_args.append((f'{name}-extra-args', case_with_extra_args))
  return cases_with_extra_args


def make_correct_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of correct cases for the Options class.
  """
  return \
      make_empty_case() \
      + make_single_option_cases() \
      + make_double_option_cases() \
      + make_cases_with_extra_args()

class TestOptions(unittest.TestCase):
  """
    Unit tests for the Options class.
  """
  # noinspection PyUnusedLocal
  @parameterized.expand(make_correct_cases())
  def test_constructor(self,
    name: str,  # pylint: disable=unused-argument
    case: OptionsTestCaseData) -> None:
    """
      Test the constructor of the Options class.
    """
    options = Options(case.args)
    self.assertIsInstance(options, Options)
    self.assertDictEqual(case.expected_dict, dict(options))
    self.assertEqual(case.expected_end_index, options.end_index)
