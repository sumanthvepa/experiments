#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  control_flow.py: Explore control flow in Python
"""
# -------------------------------------------------------------------
# control_flow.py: Explore control flow in Python
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


def explore_control_flow() -> None:  # pylint: disable='too-many-statements, too-many-branches'
  """
    Explore control flow in Python
    :return: None
  """
  # Control flow statements are used to control the flow of execution
  # in a program. The control flow statements in Python are:
  # if, elif, else, for, while, break, continue, pass.
  # The if statement is used to check a condition and execute a block
  # of code if the condition is True.
  # The elif statement is used to check additional conditions if the
  # condition in the if statement is False.
  # The else statement is used to execute a block of code if the
  # condition in the if statement is False.
  # if statement
  x = 5
  if x > 3:
    print('x is greater than 3')

  # if-else statement
  if x > 3:
    print('x is greater than 3')
  else:
    print('x is less than or equal to 3')

  # if-elif-else statement
  if x > 3:
    print('x is greater than 3')
  elif x == 3:
    print('x is equal to 3')
  else:
    print('x is less than 3')

  # The match statement is used to compare a value against multiple
  # patterns.
  # match statement
  x = 5
  match x:
    case 1:
      print('x is 1')
    case 2:
      print('x is 2')
    case 3:
      print('x is 3')
    case _:
      print('x is not 1, 2, or 3')

  # The match statement can also be used with strings.
  name = 'Alice'
  match name:
    case 'Alice':
      print('Hello, Alice!')
    case 'Bob':
      print('Hello, Bob!')
    case _:
      print('Hello, stranger!')

  # Unlike Java which supports pattern matching for switch statements,
  # Python does not support pattern matching for switch statements.

  # The for statement is used to iterate over a sequence.
  # for statement
  for i in range(5):
    print(i)

  # The while statement is used to execute a block of code as long as
  # the condition is True.
  # while statement
  i = 0
  while i < 5:
    print(i)
    i += 1

  # The break statement is used to exit a loop.
  # break statement
  for i in range(5):
    if i == 3:
      break
    print(i)

  # The continue statement is used to skip the rest of the code in a loop.
  # continue statement
  for i in range(5):
    if i == 3:
      continue
    print(i)

  # The pass statement is used as a placeholder for future code.
  # pass statement
  for i in range(5):
    pass

  # for-else statement
  # For loops can have an else block that is executed when the loop
  # exits without encountering a break. This is useful for checking
  # if a value exists in a list and if not raising an exception or
  # taking some other action.
  try:
    a_list = [1, 2, 3, 5, 6]
    for i in a_list:
      if i == 4:
        break
    else:
      raise ValueError('Value 4 not found in list')
  except ValueError as ex:
    print(f'Exception: {ex}')

  # The assert statement is used to check if an expression is True.
  # assert statement. It will raise an AssertionError if the expression
  # is False.
  try:
    x = 2
    assert x > 3
  except AssertionError:
    print('Caught AssertionError')

  # The assert statement can also have an optional message.
  # assert statement with message
  try:
    x = 1
    assert x > 3, 'x is not greater than 3'
  except AssertionError as ex:
    print(f'AssertionError: {ex}')  # AssertionError: x is not greater than 3

  # The return statement is used to return a value from a function.
  # return statement
  def add(a: int, b: int) -> int:
    return a + b
  c = add(3, 5)
  print(f'c = {c}')
