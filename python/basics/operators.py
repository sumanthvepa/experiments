#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  operators.py: Explore the basics of operators in Python
"""
# -------------------------------------------------------------------
# operators.py: Explore the basics of operators in Python
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


def explore_operators() -> None:  # pylint: disable='too-many-statements
  """
    Explore the basics of operators in Python
    :return: None
  """
  # Operators are special symbols that represent computations.
  # The values the operators work on are called operands.
  # Operators can be unary, binary, or ternary.
  # Unary operators work on one operand.
  # Binary operators work on two operands.
  # Ternary operators work on three operands.

  # Arithmetic operators
  # +, -, *, /, //, %, **
  # + is the unary plus operator
  # - is the unary minus operator
  # ** is the exponentiation operator
  # / is the division operator
  # // is the floor division operator
  # % is the modulo operator
  # * is the multiplication operator
  print(f'5 + 3 = {5 + 3}')
  print(f'5 - 3 = {5 - 3}')
  print(f'5 * 3 = {5 * 3}')
  print(f'5 / 3 = {5 / 3}')
  print(f'5 // 3 = {5 // 3}')
  print(f'5 % 3 = {5 % 3}')
  print(f'5 ** 3 = {5 ** 3}')

  # Comparison operators
  # ==, !=, >, <, >=, <=
  # == is the equality operator
  # != is the inequality operator
  # > is the greater than operator
  # < is the less than operator
  # >= is the greater than or equal to operator
  # <= is the less than or equal to operator

  # pylint: disable='comparison-of-constants'
  print(f'5 == 3 = {5 == 3}')  # type: ignore[comparison-overlap]
  # pylint: disable='comparison-of-constants'
  print(f'5 != 3 = {5 != 3}')  # type: ignore[comparison-overlap]
  # pylint: disable='comparison-of-constants'
  print(f'5 > 3 = {5 > 3}')
  # pylint: disable='comparison-of-constants'
  print(f'5 < 3 = {5 < 3}')
  # pylint: disable='comparison-of-constants'
  print(f'5 >= 3 = {5 >= 3}')
  # pylint: disable='comparison-of-constants'
  print(f'5 <= 3 = {5 <= 3}')

  # Logical operators
  # and, or, not
  # and is the logical AND operator
  # or is the logical OR operator
  # not is the logical NOT operator
  # pylint: disable='comparison-of-constants'
  print(f'5 == 3 and 5 > 3 = {5 == 3 and 5 > 3}')  # type: ignore[comparison-overlap]
  # pylint: disable='comparison-of-constants'
  print(f'5 == 3 or 5 > 3 = {5 == 3 or 5 > 3}')  # type: ignore[comparison-overlap]
  # pylint: disable='comparison-of-constants, unnecessary-negation
  print(f'not 5 == 3 = {not 5 == 3}')  # type: ignore[comparison-overlap]

  # Bitwise operators
  # &, |, ^, ~, <<, >>
  print(f'5 & 3 = {5 & 3}')
  print(f'5 | 3 = {5 | 3}')
  print(f'5 ^ 3 = {5 ^ 3}')
  print(f'~5 = {~5}')
  print(f'5 << 3 = {5 << 3}')
  print(f'5 >> 3 = {5 >> 3}')

  # Assignment operators
  # =, +=, -=, *=, /=, //=, %=, **=, &=, |=, ^=, <<=, >>=
  a: int | float = 5
  a += 3
  print(f'a += 3 = {a}')
  a -= 3
  print(f'a -= 3 = {a}')
  a *= 3
  print(f'a *= 3 = {a}')
  a /= 3
  print(f'a /= 3 = {a}')
  a //= 3
  print(f'a //= 3 = {a}')
  a %= 3
  print(f'a %= 3 = {a}')
  a **= 3  # Exponentiation
  print(f'a **= 3 = {a}')
  # Force 'a' back to int. Bitwise operators do not work on floats.
  a = 32
  a &= 3
  print(f'a &= 3 = {a}')
  a |= 3
  print(f'a |= 3 = {a}')
  a ^= 3
  print(f'a ^= 3 = {a}')
  a <<= 3
  print(f'a <<= 3 = {a}')
  a >>= 3
  print(f'a >>= 3 = {a}')

  # Identity operators
  # is, is not
  # is returns True if the operands are identical
  # is not returns True if the operands are not identical
  b = None
  if b is None:
    print('a is None')
  if b is not None:
    print('a is not None')

  # Membership operators
  # in, 'not in'
  # in returns True if the first operand is in the second operand
  # not in returns True if the first operand is not in the second operand
  a_list: list[int] = [1, 2, 3]
  if 1 in a_list:
    print('1 is in a_list')
  if 4 not in a_list:
    print('4 is not in a_list')

  # Ternary operator
  # x if condition else y
  # If condition is True, the value of x is returned.
  # If condition is False, the value of y is returned.
  a = 5
  b = 3
  c = a if a > b else b
  print(f'c = {c}')

  # The Walrus operator
  # The Walrus operator is a new operator in Python 3.8.
  # It is denoted by :=. It is also called the assignment expression operator.
  # It assigns a value to a variable as part of an expression.
  # This allows you to create a variable and use it in the same expression
  # or code block.
  a = 5
  b = 3
  if (c := a + b) > 5:
    print(f'c = {c}')

  # Operator precedence
  # Operators with higher precedence are evaluated first.
  # Parentheses can be used to override precedence.
  # The precedence of operators can be found at:
  # https://docs.python.org/3/reference/expressions.html#operator-precedence

  # Unlike Javascript Python does not do type coercion during comparison
  # If the types do not match then the comparison will always return False
  print(f'5 == "5" = {5 == "5"}')  # False

  # You have to convert the string to an int before comparison
  print(f'5 == int("5") = {5 == int("5")}')  # True
