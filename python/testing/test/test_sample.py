"""
  test_sample.py: This module contains the unit tests for the
  functions in sample.py
"""
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
# file called test_sample.py in the tests folder.

# You can run a unittest by running the following command:
# python -m unittest test_sample.py
# The command above will run all test cases in the test_sample.py file

# Another way is to define a main section at the bottom of this file
# and run the script directly. This is done by running the following command:
# python test_sample.py

# You can run tests within the JetBrains IDE by right-clicking on the
# the tests folder and selecting 'Run Unittests in test' from the context menu
# This will create a run configuration that you can run by clicking the
# green play button in the top right corner of the IDE.

import unittest

# To test the functions in sample.py, we need to import them
from sample import sum_of, broken_sum_of, fibonacci


# The unittest fra
class TestExample(unittest.TestCase):
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


# You need to define this if you want to run the tests by running
# the script directly, as in:
# python test_sample.py
if __name__ == '__main__':
  unittest.main()
