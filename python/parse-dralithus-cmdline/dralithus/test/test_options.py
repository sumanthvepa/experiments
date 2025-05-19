"""
  test_options.py: Unit tests for the Options class
"""
import unittest
from dataclasses import dataclass

from parameterized import parameterized

from dralithus.options import Options


@dataclass
class OptionsTestCaseData:
  """
    Data class for test cases.
  """
  args: list[str]
  expected_dict: dict[str, None | bool | int | str | set[str]]
  expected_end_index: int


@dataclass
class OptionsErrorCaseData:
  """
    Data class for test cases with errors.
  """
  args: list[str]
  expected_exception: type[Exception]


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

def make_multi_option_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of multi-option test cases.
    :return: A list of test cases
  """
  # pylint: disable=line-too-long
  return [
    ('multi-option', OptionsTestCaseData(args=['-vh'], expected_dict={'requires_help': True, 'verbosity': 1, 'environments': set()}, expected_end_index=1)),
    ('multi-option2', OptionsTestCaseData(args=['-hv'], expected_dict={'requires_help': True, 'verbosity': 1, 'environments': set()}, expected_end_index=1)),
    ('multi-option3', OptionsTestCaseData(args=['-vv'], expected_dict={'requires_help': False, 'verbosity': 2, 'environments': set()}, expected_end_index=1)),
    ('multi-option4', OptionsTestCaseData(args=['-vvhvh', '-e', 'local'], expected_dict={'requires_help': True, 'verbosity': 3, 'environments': {'local'}}, expected_end_index=3))
  ]


def combine_cases(
    name1: str, case1: OptionsTestCaseData,
    name2: str | None, case2: OptionsTestCaseData | None,
    insert_terminator: bool = False) -> tuple[str, OptionsTestCaseData]:
  """
    Combine two test cases into a single test case.

    Case 2 can be None and an optional terminator can be inserted between the two cases.
    The terminator, if specified, is always inserted after the first case, and
    the second case, if not none is always appended to the end of that combination.

    :param name1: The name of the first test case
    :param case1: The first test case
    :param name2: The name of the second test case
    :param case2: The second test case
    :param insert_terminator: True if an option terminator should be inserted between the two cases
    :return: The combined test case
  """
  if not insert_terminator:
    if case2 is None:
      combined_args = case1.args
      requires_help = case1.expected_dict['requires_help']
      verbosity = case1.expected_dict['verbosity']
      environments = case1.expected_dict['environments']
      end_index = len(combined_args)
    else:
      combined_args = case1.args + case2.args
      requires_help = case1.expected_dict['requires_help'] or case2.expected_dict['requires_help']
      verbosity = case1.expected_dict['verbosity'] + case2.expected_dict['verbosity']
      environments = case1.expected_dict['environments'] | case2.expected_dict['environments']
      end_index = len(combined_args)
    name = f'{name1}-' if name2 is None else f'{name1}-{name2}'
  else:
    if case2 is None:
      combined_args = case1.args + ['--']
      requires_help = case1.expected_dict['requires_help']
      verbosity = case1.expected_dict['verbosity']
      environments = case1.expected_dict['environments']
      end_index = len(case1.args) + 1
    else:
      combined_args = case1.args + ['--'] + case2.args
      requires_help = case1.expected_dict['requires_help']
      verbosity = case1.expected_dict['verbosity']
      environments = case1.expected_dict['environments']
      end_index = len(case1.args) + 1
    name = f'{name1}-terminator' if name2 is None else f'{name1}-terminator-{name2}'
  combined_expected_dict = {
    'requires_help': requires_help,
    'verbosity': verbosity,
    'environments': environments
  }
  case = OptionsTestCaseData(
    args=combined_args,
    expected_dict=combined_expected_dict,
    expected_end_index=end_index)
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
      double_option_cases.append(
        combine_cases(name1, case1, name2, case2, insert_terminator=False))
      if name1 != name2:
        # pylint: disable=arguments-out-of-order
        double_option_cases.append(
          combine_cases(name2, case2, name1, case1, insert_terminator=False))
  return double_option_cases


def make_option_terminator_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Make valid cases with option terminators.

    :return: A list of test cases
  """
  single_option_cases = make_single_option_cases()
  option_terminator_cases: list[tuple[str, OptionsTestCaseData]] = []
  for name1, case1 in single_option_cases:
    # Add option terminator to the end of the args list in the following
    # three combinations: case1 --,  case1 -- case2, case2 -- case1
    option_terminator_cases.append(
      combine_cases(name1, case1, None, None, insert_terminator=True))
    for name2, case2 in single_option_cases:
      option_terminator_cases.append(
        combine_cases(name1, case1, name2, case2, insert_terminator=True))
      option_terminator_cases.append(
        combine_cases(name2, case2, name1, case1, insert_terminator=True))
  return option_terminator_cases


def make_cases_with_extra_args() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of test cases with extra args.

    :return: A list of test cases
  """
  cases_with_no_extra_args \
    = make_empty_case() \
      + make_single_option_cases() \
      + make_double_option_cases() \
      + make_option_terminator_cases()
  cases_with_extra_args: list[tuple[str, OptionsTestCaseData]] = []
  for name, case in cases_with_no_extra_args:
    # Add extra args to the end of the args list
    extra_args = ['extra_arg1', 'extra_arg2']
    case_with_extra_args = OptionsTestCaseData(
      args=case.args + extra_args,
      expected_dict=case.expected_dict,
      expected_end_index=case.expected_end_index)
    cases_with_extra_args.append((f'{name}-extra-args', case_with_extra_args))
  return cases_with_extra_args

def make_edge_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Make edge cases to test the option class.

    These are cases that don't fall into any particular category

  :return:
  """
  # pylint: disable=line-too-long
  return [
    ('bad-help-value', OptionsTestCaseData(args=['-h', 'True', '-v', '1'], expected_dict={'requires_help': True, 'verbosity': 0, 'environments': set()}, expected_end_index=1)),
    ('option-after-first-parameter', OptionsTestCaseData(args=['-v', '1', 'parameter', '-h'], expected_dict={'requires_help': False, 'verbosity': 1, 'environments': set()}, expected_end_index=2)),
    ('terminator-before-option-value', OptionsTestCaseData(args=['-v', '--', '3', '-h'], expected_dict={'requires_help': False, 'verbosity': 1, 'environments': set()}, expected_end_index=2)),
    ('multiple-terminators', OptionsTestCaseData(args=['-v', '--', '3', '--', '-h'], expected_dict={'requires_help': False, 'verbosity': 1, 'environments': set()}, expected_end_index=2)),
    ('terminator-before-environment-value', OptionsTestCaseData(args=['-e=local,test', '--', '-e=development,staging'], expected_dict={'requires_help': False, 'verbosity': 0, 'environments': {'local', 'test'}}, expected_end_index=2))
  ]

def make_correct_cases() -> list[tuple[str, OptionsTestCaseData]]:
  """
    Generate a list of correct cases for the Options class.
  """
  return \
      make_empty_case() \
      + make_single_option_cases() \
      + make_double_option_cases() \
      + make_multi_option_cases() \
      + make_option_terminator_cases() \
      + make_cases_with_extra_args() \
      + make_edge_cases()


def make_incorrect_cases() -> list[tuple[str, OptionsErrorCaseData]]:
  """
    Generate a list of incorrect cases for the Options class.
  """
  # pylint: disable=line-too-long
  return [
    ('error-short-help-value-equal', OptionsErrorCaseData(args=['-h=True'], expected_exception=ValueError)),
    ('error-short-help-value-equal2', OptionsErrorCaseData(args=['-h=2'], expected_exception=ValueError)),
    ('error-long-help-value-equal', OptionsErrorCaseData(args=['--help=True'], expected_exception=ValueError)),
    ('error-long-help-value-equal2', OptionsErrorCaseData(args=['--help=2'], expected_exception=ValueError)),
    ('error-short-version-bad-value', OptionsErrorCaseData(args=['-v=bad-value'], expected_exception=ValueError)),
    ('error-short-version-bad-value2', OptionsErrorCaseData(args=['-v=True'], expected_exception=ValueError)),
    ('error-long-version-bad-value', OptionsErrorCaseData(args=['--verbose=bad-value'], expected_exception=ValueError)),
    ('error-long-version-bad-value2', OptionsErrorCaseData(args=['--verbose=True'], expected_exception=ValueError)),
    ('error-long-version2-bad-value', OptionsErrorCaseData(args=['--verbosity=bad-value'], expected_exception=ValueError)),
    ('error-long-version2-bad-value2', OptionsErrorCaseData(args=['--verbosity=True'], expected_exception=ValueError)),
    ('error-short-environment-bad-value', OptionsErrorCaseData(args=['-e=bad-value'], expected_exception=ValueError)),
    ('error-short-environment-bad-value2', OptionsErrorCaseData(args=['-e=True'], expected_exception=ValueError)),
    ('error-short-environment-bad-value-multiple', OptionsErrorCaseData(args=['-e=bad-value,local'], expected_exception=ValueError)),
    ('error-short-environment-bad-value-multiple2', OptionsErrorCaseData(args=['-e=local,bad-value'], expected_exception=ValueError)),
    ('error-long-environment-bad-value', OptionsErrorCaseData(args=['--env=bad-value'], expected_exception=ValueError)),
    ('error-long-environment-bad-value2', OptionsErrorCaseData(args=['--env=True'], expected_exception=ValueError)),
    ('error-long-environment-bad-value-multiple', OptionsErrorCaseData(args=['--env=bad-value,local'], expected_exception=ValueError)),
    ('error-long-environment-bad-value-multiple2', OptionsErrorCaseData(args=['--env=local,bad-value'], expected_exception=ValueError)),
    ('error-long-environment2-bad-value', OptionsErrorCaseData(args=['--environment=bad-value'], expected_exception=ValueError)),
    ('error-long-environment2-bad-value2', OptionsErrorCaseData(args=['--environment=True'], expected_exception=ValueError)),
    ('error-long-environment2-bad-value-multiple', OptionsErrorCaseData(args=['--environment=bad-value,local'], expected_exception=ValueError)),
    ('error-long-environment2-bad-value-multiple2', OptionsErrorCaseData(args=['--environment=local,bad-value'], expected_exception=ValueError)),
    ('error-short-help-value-correct-verbosity', OptionsErrorCaseData(args=['-h=1', '-v'], expected_exception=ValueError)),
    ('error-short-help-value-correct-verbosity', OptionsErrorCaseData(args=['-v', '-h=1'], expected_exception=ValueError)),
    ('error-terminator-before-environment-value', OptionsErrorCaseData(args=['--environment', '--', 'local,test'], expected_exception=ValueError))
  ]

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

  # noinspection PyUnusedLocal
  @parameterized.expand(make_incorrect_cases())
  def test_constructor_incorrect_cases(self,
    name: str,  # pylint: disable=unused-argument
    case: OptionsErrorCaseData) -> None:
    """
      Test the constructor of the Options class with errors.
    """
    with self.assertRaises(case.expected_exception):
      Options(case.args)
