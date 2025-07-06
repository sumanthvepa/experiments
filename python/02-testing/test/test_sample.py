# -*- coding: utf-8 -*-
"""
  test_sample.py: Demonstrate how to write unit tests in python
"""
# -------------------------------------------------------------------
# test_sample.py: Demonstrate how to write unit tests in python
#
# Copyright (C) 2024-25 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License a
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

import os
import platform

# Unittest is python's built-in testing framework
# You can find a complete description of the unittest module
# at https://docs.python.org/3/library/unittest.html

# A recommended practice is to place all unittests in a separate
# folder called tests. This folder is marked as a package by
# placing an empty __init__.py file in the folder.
# I use a convention where each file is named test_<module>.py
# So if I'm testing a module called sample.py, I would create a
# file called test_sample.py in the 'tests' folder.

# You can run a unittest by running the following command:
# python -m unittest test_sample.py
# The command above will run all test cases in the test_sample.py file

# Another way is to define a main section at the bottom of this file
# and run the script directly. This is done by running the following command:
# python test_sample.py

# You can run tests within the JetBrains IDE by right-clicking on the
# tests folder and selecting 'Run Unittests in test' from the context menu
# This will create a run configuration that you can run by clicking the
# green play button in the top right corner of the IDE.

# This module explores a couple of testing libraries.
# Unittest is the built-in python test framework. It works well for
# non-parameterized tests but is a bit cumbersome for parameterized tests.
import unittest

# TypedDict is used to illustrate passing of complex data structures
# as parameters to a parametric test. See TestParametric below.
from typing import TypedDict

# Parameterized is a library that makes it easier to write parameterized
# tests. It is not built into python, so you have to install it separately.
# You can install it using pip:
# python3 -m pip install parameterized

# You can find the documentation for parameterized at:
# https://pypi.org/project/parameterized/

# One downside of parameterized is that it does not come with
# type hints. So, you will get type hint errors if you try to use
# it.
# For this project I've generated a stub file for parameterized
# so that I can use type hints. The stub file is in the 'stubs' folder.
# The process of generating a stub file is described here:
# This link describes how to deal with mypy complaining about missing imports
# https://mypy.readthedocs.io/en/stable/running_mypy.html#missing-imports
# This link talk about create a stub file
# https://mypy.readthedocs.io/en/stable/stubs.html#stub-files
# To help you avoid reading all the documentation, following is a concise
# description of how the stub file was generated:
# First you need to create a mypy configuration file named mypy.ini. It should
# be placed in the root folder of the project. The mypy.ini file should specify
# the location where mypy can find type hint stub files (usually named .pyi.)
# See the ini file for how this is specified.
# Then we run the stubgen tool that comes with mypy. The command used is:
# stubgen -m parameterized -o stubs
# The -m specifies the module (like you would when you specify a module to
# python). The -o specifies the directory where the stub file should be placed.
# In this case we create a directory called stubs in the root folder of the
# project before running stubgen. Stubgen will place the stubs files there.
# The stubgen tool will generate a stub file for the parameterized module.
# At this point you should no longer get type hint errors when using
# the parameterized module in your code.
from parameterized import parameterized


# To test the functions in sample.py, we need to import them
from sample import sum_of, broken_sum_of, fibonacci, square_root


# To write test, we first have to define a class that inherits from
# unittest.TestCase. This class will contain the test methods.
# Each test method in the class should start with the word test.
# This is how unittest knows which methods are test methods.
#
# My personal convention is to name the class
# Test<NameOfClassOrFunctionBeingTested>. If I'm testing multiple
# functions or classes, then I would name the test class Test<ModuleName>.
# My personal convention is that each test class should test one function or
# class within a module. Although, for this simple example, I'm testing
# multiple functions in the same class.
class TestSample(unittest.TestCase):
  """
    TestExample: This class contains the unit tests for the
    functions in sample.py
  """
  def test_sum_of(self) -> None:
    """ Test the sum_of function """
    # The assert* methods provide various ways to check if the
    # expected value is equal to the actual value.
    self.assertEqual(sum_of(1, 2), 3)

    # You can call assert methods multiple times in a single test
    self.assertEqual(sum_of(3, 4), 7)

  # Note the expectedFailure decorator. This is used to indicate that
  # the test is expected to fail. This is useful when you want to
  # test a function that is known to be broken. The test will still
  # run, indicating a failure, but it will be marked as an expected
  # failure.
  # In this case we are demonstrating a failing test case. So, this
  # failure is expected. The test will still run, but it will be
  # marked as an expected failure.
  @unittest.expectedFailure
  def test_broken_sum_of(self) -> None:
    """ Test the broken_sum_of function """
    # You can also pass a message to the assert methods to provide
    # more information about the test case that failed.
    self.assertEqual(broken_sum_of(5, 6), 11, 'The sum of 5 and 6 should be 11')

  def test_fibonacci(self) -> None:
    """ Test the fibonacci function """
    expected = [0, 1, 1, 2, 3, 5]
    self.assertListEqual(fibonacci(6), expected)

  # You can skip a test by using the skip decorator. This is useful
  # when you want to temporarily disable a test that is failing, but
  # you don't want to delete it. Unlike the expectedFailure decorator,
  # the test will not run at all, and will be marked as skipped.
  @unittest.skip('This test will be skipped')
  def test_skipped(self) -> None:
    """ This test will be skipped """
    self.assertEqual(1, 2)


  # You can conditionally skip a test by using the skipIf or skipUnless
  # In this case the test will be skipped if the condition is True,
  # i.e. if the platform is Windows.
  @unittest.skipIf(platform.system() == 'Windows', 'This test is not supported on Windows')
  def test_unix_only_function(self) -> None:
    """ Test a function that is only supported on Unix """
    # The load average function only works on Unix systems
    avg5, avg10, avg15 = os.getloadavg()
    self.assertGreater(avg5, 0)
    self.assertGreater(avg10, 0)
    self.assertGreater(avg15, 0)

  # SkipUnless works the other way around. The test will be skipped
  # if the condition is False. In this case the test will be skipped
  # if the platform is NOI Windows.
  @unittest.skipUnless(platform.system() == 'Windows', 'This test is only supported on Windows')
  def test_windows_only_function(self) -> None:
    """ Test a function that is only supported on Windows """
    # The platform.win32_ver function only works on Windows
    version = platform.win32_ver()
    self.assertIsNotNone(version)

# pylint: disable=too-few-public-methods
class Args:
  """
    Args: A class to hold the arguments for a function
  """
  def __init__(self, first: int, second: float) -> None:
    """ Create an Args object """
    self.first = first
    self.second = second

class TestCaseData(TypedDict):
  """ A Data Structure containing input and expected output for a test case """
  n: float
  expected: float | None
  error: type[ValueError] | None


def all_square_root_cases() -> list[tuple[TestCaseData]]:
  """ Return a list of test cases for the square_root function """
  return [
    (TestCaseData(n=4, expected=2.0, error=None),),
    (TestCaseData(n=9, expected=3.0, error=None),),
    (TestCaseData(n=-1, expected=None, error=ValueError),)
  ]


class TestParametric(unittest.TestCase):
  """
    TestParametric: This class demonstrates the use of parametric tests

    Sometimes you want to test a function with multiple sets of
    parameters. It's cumbersome to write a separate test for each
    set of parameters. Parametric tests allow you to test a function
    with multiple sets of parameters in a single test, but still
    provide a separate report for each set of parameters.
  """
  # Parametric tests are tests that are run with multiple sets of
  # parameters. In this case, we are testing the sum_of function
  # with multiple sets of parameters.
  # Each element of the list passed to the parameterized decorator
  # must be an iterable. The first element of the tuple is the first parameter
  # to the test function, the second element is the second parameter,
  # and so on. By convention, the last element of the tuple is the expected result.
  # Unlike normal test functions, parameterized test functions take
  # the parameter values as arguments.

  # Note that IntelliJ IDEA will only detect and run parameterized tests
  # if they are run through the class. i.e. clicking on the parameterized
  # test function's run arrow won't work. You have to run the entire class,
  # or the entire module, or the entire test folder.
  @parameterized.expand([
    (1, 2, 3),
    (3, 4, 7),
    (5, 6, 11)
  ])
  def test_sum_of_params(self, a: int, b: int, expected: int) -> None:
    """ Test the sum_of function with parameters """
    self.assertEqual(sum_of(a, b), expected)


  # The elements of each tuple can be any type. In this case we are
  # passing things like non and Classes as elements. They
  # are passed as arguments to the test function.
  @parameterized.expand([
    (4, 2.0, None),
    (9, 3.0, None),
    (-1, None, ValueError)
  ])
  def test_square_root(
      self, n: int,
      expected: float | None,
      error: type[ValueError] | None) -> None:
    """ Test the square_root function with parameters """
    if error is not None:
      with self.assertRaises(error):
        square_root(n)
    else:
      difference = abs(square_root(n) - expected)
      self.assertLess(difference, 0.0000001)

  # You can give each test case a name by using the name parameter
  # of the parameterized decorator. This is useful when you want to
  # run a specific test case. The name is used to identify the test
  # case in the test report. The decorator will automatically
  # generate a name for each test case name passed.
  # Note the use of noinspection and pylint disable to suppress
  # warnings about unused parameters.

  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('case1', 1, 3, 4),
    ('case2', 9, 12, 21),
    ('case3', -1, 5, 4)
  ])
  def test_sum_of_named_params(
      self, name: str,  # pylint: disable=unused-argument
      a: int, b: int, expected: int) -> None:
    """ Test the sum_of function with named parameters """
    self.assertEqual(sum_of(a, b), expected)

  # To pass test cases, you can wrap each TestCaseData object in
  # tuple. The reason for this is that @parameterized.expand takes
  # an iterable. So you cannot directly, pass a list of TestCaseData
  # Instead, wrap the TestCaseData objects in a tuple with a single
  # element. (Note the comma after the closing parenthesis of the
  # TestCaseData object.)
  @parameterized.expand([
    (TestCaseData(n=4, expected=2.0, error=None),),
    (TestCaseData(n=9, expected=3.0, error=None),),
    (TestCaseData(n=-1, expected=None, error=ValueError),)
  ])
  def test_square_root_data(self, case: TestCaseData) -> None:
    """ Test the square_root function with parameters """
    n = case['n']
    expected = case['expected']
    error = case['error']
    if error is not None:
      with self.assertRaises(error):
        square_root(n)
    else:
      difference = abs(square_root(n) - expected)
      self.assertLess(difference, 0.0000001)


# You need to define this if you want to run the tests by running
# the script directly, as in:
# python test_sample.py
if __name__ == '__main__':
  unittest.main()
