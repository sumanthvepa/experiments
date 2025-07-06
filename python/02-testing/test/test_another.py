# -*- coding: utf-8 -*-
"""
  test_another.py: Another test class in a different file to illustrate
  splitting up of tests between files.
"""

import unittest


class AnotherTest(unittest.TestCase):
  """ Another Test """
  def test_dummy(self):
    """ Dummy test to check if IntelliJ IDEA runs all tests """
    self.assertEqual(1, 1)


