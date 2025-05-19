"""
  dralithus/test/__init__.py: Module file for the test package.
"""
from typing import Callable, Protocol


class CaseData:
  """
    A test case for the command line parser.
  """
  def __init__(self,
               args: list[str],
               expected: tuple[dict[str, None | bool | int | str | set[str]], set[str]] | None, error: type[Exception] | None):
    """
      Initialize the test case.

      :param args: The input to the test case
      :param expected: The expected output of the test case
      :param error: The expected error of the test case
    """
    assert ((expected is not None) and (error is None)) \
      or ((expected is None) and (error is not None)), \
      "If expected is set, then error must be none, and vice versa."
    self._args = args
    self._expected = expected
    self._error = error

  @property
  def args(self) -> list[str]:
    """
      Get the input of the test case.

      :return: The input of the test case
    """
    return self._args

  @property
  def expected(self) -> tuple[dict[str, None | bool | int | str | set[str]], set[str]] | None:
    """
      Get the expected output of the test case.

      :return: The expected output of the test case
    """
    return self._expected

  @property
  def error(self) -> type[Exception] | None:
    """
      Get the expected error of the test case.

      :return: The expected error of the test case
    """
    return self._error


class HasAsserts(Protocol):
  """ Protocol for objects that have 'assert*' methods usable by CaseExecutor. """
  # pylint: disable=invalid-name
  # noinspection PyPep8Naming
  def assertDictEqual(
      self,
      first: dict[str, None | bool | int | str | set[str]],
      second: dict[str, None | bool | int | str | set[str]]) -> None:
    """ Compare two dictionaries for equality. """

  # pylint: disable=invalid-name
  # noinspection PyPep8Naming
  def assertSetEqual(
      self,
      first: set[str],
      second: set[str]) -> None:
    """ Compare two sets for equality. """

  # pylint: disable=invalid-name
  # noinspection PyPep8Naming
  def assertRaises(self, expected_exception, *args, **kwargs):
    """ Assert that an exception is raised. """


# pylint: disable=too-few-public-methods
class CaseExecutor(HasAsserts):
  """
    A class to execute test cases.
  """
  def __init__(self, function: Callable[[list[str]], tuple[dict[str, None | bool | int | str | set[str]], set[str]]]):
    """
      Initialize the CaseExecutor.
    """
    self.function = function

  def execute(self, case: CaseData) -> None:
    """
      Execute a test case.

      :param case: The test case to execute
    """
    if case.expected is not None:
      expected_options, expected_parameters = case.expected
      options, parameters = self.function(case.args)
      self.assertDictEqual(expected_options, options)
      self.assertSetEqual(expected_parameters, parameters)
    else:
      assert case.error is not None
      with self.assertRaises(case.error):
        self.function(case.args)
