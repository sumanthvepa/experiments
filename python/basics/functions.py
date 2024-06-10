#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  functions.py: Explore functions in Python
"""
# -------------------------------------------------------------------
# functions.py: Explore functions in Python
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
from typing import Callable


def explore_functions() -> None:
  """
    Explore functions in Python
    :return: None
  """
  # Functions are blocks of code that perform a specific task.
  # Functions are defined using the def keyword followed by the
  # function name and parentheses. The parentheses can contain
  # parameters that the function takes as input. The function
  # body is indented.
  # The return statement is used to return a value from the function.
  # If the return statement is not used then the function returns None.

  # Functions are first-class objects in Python. This means that
  # functions can be passed as arguments to other functions, returned
  # from functions, and assigned to variables.

  # Functions can be defined inside other functions.

  # With type annotations, you can specify the types of the parameters
  # and the return type of the function.
  # The type annotations are optional, but they can help improve the
  # readability of the code. They are used by mypy for better type
  # checking.
  def f1() -> None:
    """
      Function f1
      :return: None
    """
    print('f1')

  f1()

  def add(a: int, b: int) -> int:
    """
      Function f2
      :param int a: argument 1
      :param int b: argument 2
      :return int: sum of a and b
    """
    return a + b
  n1: int = 5
  n2: int = 3
  print(f'Sum of {n1} and {n2} is {add(n1, n2)}')

  # Python has support for anonymous functions called lambda functions.
  # Lambda functions are defined using the lambda keyword followed by
  # the parameters and the expression.
  # Lambda functions are useful for writing short functions that are
  # used only once.
  # Lambda functions can take any number of arguments but can only have
  # one expression.
  # Lambda functions can be assigned to variables or passed as arguments
  # to other functions.
  # BTW, DO NOT use lambda functions as shown in this example.
  # I do it this way here only for exposition purposes. Use a regular
  # function instead.
  l_add: Callable[[int, int], int] = lambda x, y: x + y
  print(f'Sum of {n1} and {n2} is {l_add(n1, n2)}')

  # Lambda expressions are particularly useful when you need to pass a
  # simple function as an argument to another function.
  # For example, the map() function takes a function and an iterable
  # and applies the function to each element of the iterable.
  # The following code uses a lambda function to square each element
  # of a list.
  a_list: list[int] = [1, 2, 3, 4, 5]
  squared_list: list[int] = list(map(lambda x: x ** 2, a_list))
  print(f'Squared list: {squared_list}')
