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


def explore_functions() -> None:  # pylint: disable='too-many-locals'
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

  # Function can be invoked with the arguments specified in the order
  # in which they are defined. E.g.:
  def divide(dividend: int, divisor: int) -> int:
    """
      Divide quotient by divisor
      :param int dividend: dividend
      :param int divisor: divisor
      :return int: quotient
    """
    return int(dividend / divisor)
  divide(10, 5)  # Arguments are passed in the order in which they are defined

  # You can mix and match positional arguments with named arguments, but
  # positional arguments must always precede named arguments.
  # E.g.:
  def concatenate(a: int, b: int, c: int) -> str:
    """
      Concatenate the stings of the decimal representation
      of a, b and c
      :param int a: argument 1
      :param int b: argument 2
      :param int c: argument 3
      :return int: Concatenated string of the decimal representation of a, b and c
    """
    return str(a) + str(b) + str(c)
  # In this call to concatenate, arguments are passed in the order in
  # which they are defined, despite c and b being shuffled around.
  # 'a' is passed as a positional argument and 'b' and 'c' are
  # passed as named arguments.
  print(f'Concatenated string: {concatenate(1, c=3, b=2)}')

  # A Function can take a variable number of arguments using the
  # *args and *kwargs
  # If you want to only take multiple positional arguments, you can
  # use *args. *args is a tuple that contains all the positional
  # arguments passed to the function. E.g.
  def add_all(*args: int) -> int:
    """
      Add all arguments.
      :param int args: The arguments to be added.
      :return int: sum of all the arguments
    """
    return sum(args)

  # Note that each call to 'add_all' has a different number of
  # arguments.
  print(f'Sum of 1, 2, 3, 4, 5 is {add_all(1, 2, 3, 4, 5)}')
  print(f'Sum of 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 is {add_all(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)}')

  # Or the arguments can be passed in any order by specifying the
  # argument name. E.g.:
  # Arguments are passed in any order, by specifying the argument name
  divide(divisor=5, dividend=10)

  # If you want to take multiple keyword arguments, you can use **kwargs.
  # **kwargs is a dictionary that contains all the keyword arguments
  # passed to the function. E.g.:
  def print_all(**kwargs: int) -> None:
    """
      Print all keyword arguments
      :param int kwargs: The keyword arguments to be printed
      :return None
    """
    for key, value in kwargs.items():
      print(f'{key}: {value}')
  # Note that the calls to print each have a variable number of
  # arguments and the arguments can have any names.
  print_all(a=1, b=2, c=3)
  print_all(x=10, y=20, z=30)
  print_all(a=1, b=2, c=3, x=10, y=20, z=30)

  # You can combine both *args and **kwargs in the same function.
  # E.g.:
  def print_all_args_and_kwargs(*args: int, **kwargs: int) -> None:
    """
      Print all arguments and keyword arguments
      :param int args: The arguments to be printed
      :param int kwargs: The keyword arguments to be printed
      :return None
    """
    print(f'args: {args}')
    for key, value in kwargs.items():
      print(f'{key}: {value}')
  # Note that the calls to print_all_args_and_kwargs each have a
  # variable number of arguments, some of which are positional and the
  # rest are keywords. The arguments can have any names.
  print_all_args_and_kwargs(1, 2, 3, a=1, b=2, c=3)
  print_all_args_and_kwargs(10, 30, a=10, b=20, c=30, d=25)

  # You can pass a tuple to a function by unpacking it using the * operator.
  # E.g.:
  t = (23, 30)
  print(f'Sum of {t[0]} and {t[1]} is {add(*t)}')

  # You can pass a dictionary to a function by unpacking it using the ** operator.
  # E.g.:
  d = {'a': 23, 'b': 30}
  print(f'Sum of {d["a"]} and {d["b"]} is {add(**d)}')

  # You can of course use both in order, but *, must precede ** in the
  # function call. Note that the function itself does not need to
  # take variable args or kwargs. However, the total number of args
  # and their types must match the function signature.
  # E.g.:
  print_all_args_and_kwargs(*t, **d)

  # Functions can have default values for their parameters. This means that
  # if the parameter is not passed, the default value will be used.
  # E.g.:
  def add_with_default(a: int, b: int = 0) -> int:
    """
      Add two numbers with a default value for b
      :param int a: argument 1
      :param int b: argument 2
      :return int: sum of a and b
    """
    return a + b
  # In this call to add_with_default, b is not passed and the default
  # value of 0 is used.
  print(f'Sum of {n1} and default value is {add_with_default(n1)}')

  # In this call to add_with_default, b is passed and the value of
  # b is used.
  print(f'Sum of {n1} and {n2} is {add_with_default(n1, n2)}')

  # However, be careful when using default values that are mutable
  # reference types. The dafault value is only evaluated once when the
  # function is defined, not each time the function is called. This
  # means that if the default value is a mutable reference type, it
  # will be shared between all calls to the function. This can lead
  # to unexpected behavior. E.g.:
  def append_to_list(value: int, lst: list[int] = []) -> list[int]:
    """
      Append a value to a list
      :param int value: The value to be appended
      :param list[int] lst: The list to which the value is appended
      :return list[int]: The list with the value appended
    """
    lst.append(value)
    return lst
  # In this call to append_to_list, the default value of lst is used
  # and the value 1 is appended to it.
  print(f'List after appending 1: {append_to_list(1)}') # [1]
  # In this call to append_to_list, the default value of lst is used
  # again and the value 2 is appended to it. However, since the
  # default value is a mutable reference type, the value 2 is
  # appended to the same list that was used in the previous call.
  # This means that the list now contains both 1 and 2.
  print(f'List after appending 2: {append_to_list(2)}')  # [1, 2], not [2] as expected

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

  # Escaping closures are nothing special in python,
  # unlike in swift. Lambdas can outlive the functions that
  # they are passed to.
  func_list: list[Callable[[int], int]] = []

  def add_to_func_list(func: Callable[[int], int]) -> None:
    """
      Add a function to the function list
      :param Callable[[int], int] func: The function to be added
      :return None
    """
    func_list.append(func)

  add_to_func_list(lambda x: x + 1)
  add_to_func_list(lambda x: x + 2)
  for f in func_list:
    print(f'f(5) = {f(5)}')  # 6, 7
