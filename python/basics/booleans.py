#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  booleans.py: Exploring boolean literals in Python

  This is an exploration on the usage of numeric literals in Python
"""
# -------------------------------------------------------------------
# booleans.py: Exploring boolean literals in python
#
# Copyright (C) 2024 Sumanth Vepa.
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


# There are two boolean literals in Python: True and False.
def explore_boolean_literals():
  """
  Explore boolean literals in Python
  """
  # This is a boolean literal. The value True.
  true_literal = True
  print(true_literal)
  # This is a boolean literal. The value False.
  false_literal = False
  print(false_literal)

  # You can also use the bool() function to convert other values to
  # boolean values.
  print(bool(0))  # False
  print(bool(1))  # True
  print(bool(42))  # True
  print(bool(-1))  # True
  print(bool(0.0))  # False
  print(bool(0.1))  # True
  print(bool(0.0+0.0j))  # False
  print(bool(0.0+1.0j))  # True

  # You can also use the bool() function to convert strings to boolean
  # values.
  print(bool(''))  # False
  print(bool(' '))  # True
  print(bool('Hello, World!'))  # True

  # You can also use the bool() function to convert lists to boolean
  # values.
  print(bool([]))  # False
  print(bool([1, 2, 3]))  # True

  # You can also use the bool() function to convert tuples to boolean
  # values.
  print(bool(()))  # False
  print(bool((1, 2, 3)))  # True

  # You can also use the bool() function to convert dictionaries to
  # boolean values.
  print(bool({}))  # False
  print(bool({'a': 1, 'b': 2, 'c': 3}))  # True

  # You can also use the bool() function to convert sets to boolean
  # values.
  print(bool(set()))  # False
  print(bool({1, 2, 3}))  # True

  # You can also use the bool() function to convert None to boolean
  # values.
  print(bool(None))  # False

  # You can also use the bool() function to convert functions to
  # boolean values.
  def my_function():
    return 42
  print(bool(my_function))  # True

  # You can also use the bool
  # function to convert classes to boolean values.
  # pylint: disable=too-few-public-methods
  class MyClass:
    """ A simple class"""
  print(bool(MyClass))  # True
