# -*- coding: utf-8 -*-
"""
  samply.py: Sample python file with some functions that need testing
"""
# -------------------------------------------------------------------
# sample.py: Sample python file with some functions that need testing
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


def sum_of(a: int, b: int) -> int:
  """
  Add two numbers
  :param int a: The first number
  :param int b: The second number
  :return int: The sum of the two numbers
  """
  return a + b

def broken_sum_of(a: int, b: int) -> int:
  """
  Add two numbers incorrectly

  This is used to demonstrate a failing test case

  :param int a: The first number
  :param int b: The second number
  :return int: The sum of the two numbers plus 1
  """
  return a + b + 1

# noinspection PyUnusedLocal
def fibonacci(n: int) -> list[int]:  # pylint: disable=unused-argument
  """
  Generate the first n Fibonacci numbers
  :param n: The number of Fibonacci numbers to generate
  :return: A list of the first n Fibonacci numbers
  """
  result: list[int] = []
  index: int = 0
  while index < n:
    if index <= 1:
      result.append(index)
    else:
      result.append(result[index - 1] + result[index - 2])
    index += 1
  return result


def square_root(n: float) -> float:
  """
  Calculate the square root of a number
  :param n: The number to calculate the square root of
  :return: The square root of the number
  """
  if n < 0:
    raise ValueError('Cannot calculate the square root of a negative number')
  return n ** 0.5
