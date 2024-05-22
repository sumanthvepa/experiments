#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  none_not_implemented.py: Explore None and NotImplemented.
"""
# -------------------------------------------------------------------
# language.py: Explore strings in Javascript
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
from typing import Optional, Self


def explore_none() -> None:
  """
  Explore the None literal in Python
  :return: None
  """
  # None is used to indicate the absence of a value.
  # It is similar to null in other languages. None is
  # a singleton object in Python. Note below that
  # the type of None is None.
  value_a: None = None
  print(f'value_a = {value_a}')  # Displays None

  # When checking for equality to None, use the is operator.
  # instead of the == operator shown above. This is because
  # the == operator can be overridden, for any given type.
  # The is operator cannot be overridden.
  equal = value_a is None
  print(f'value_a is None is {equal}')  # Displays True

  # Also useful in if statements:
  if value_a is None:
    print('value_a is None')  # Displays value_a is None
  else:
    print('value_a is not None')

  # None is equal to itself.
  value_b: None = None
  print(f'value_b = {value_b}')  # Displays None
  equal = value_a == value_b
  print(f'value_a == value_b is {equal}')  # Displays True

  # None is not equal to any other value.
  value_c: int = 0
  equal = value_a == value_c
  print(f'value_a == value_c is {equal}')  # Displays False

  # Optional is a type hint that is related to a value that
  # might be None. Optional[T] is equivalent to Union[T, None].
  # To use the Optional type hint, import it from the typing module.
  # For details about the Optional type hint, see
  # https://docs.python.org/3/library/typing.html#typing.Optional
  value_d: Optional[int] = None
  print(f'value_d = {value_d}')  # Displays None

  # The Optional annotation is more useful when defining function
  # signatures. It indicates that the function can return None.
  def clamp_value(value: int) -> Optional[int]:
    """
    Clamp a value to between 0 and 10.
    :param value: The value to clamp to between 0 and 10
    :return: value, if it is between 0 and 10, else None
    """
    return value if 0 < value < 10 else None

  value_e: Optional[int] = clamp_value(36)
  print(f'value_e = {value_e}')  # Displays None

  value_f: Optional[int] = clamp_value(5)
  print(f'value_f = {value_f}')  # Displays 5


def explore_not_implemented() -> None:
  """
  Explore the NotImplemented literal in Python
  :return: None
  """
  # NotImplemented is used to indicate that a method is not implemented.
  # It is primarily used to indicate that a method is not implemented in
  # a subclass. But unlike a NotImplementedError which can be raised,
  # will not break chain of computation done by the python runtime.
  # For example consider class A which implements the __add_ and
  # __radd__ methods.
  class A:
    """
    A class that implements the __add__ and __radd__ methods.
    """
    property: int = 0

    def __add__(self, other: int | Self) -> int:
      """
      Add the property of this object to the property of another object.
      Or, if the other object is an int, add the property of this object
      to the int.

      The type hint int | Self is a type hint that indicates that
      the other object can be an int, a float, or an object of class A.
      It is shorthand for Union[int, A].

      :param other: The other object to add to this object
      :return: Sum of the properties of this object and the other object
      """
      if isinstance(other, A):
        return self.property + other.property
      if isinstance(other, int):
        return self.property + other
      return NotImplemented

    def __radd__(self, other: int | Self) -> int:
      """
      Reverse add the property of this object to the property of another object.
      Or, if the other object is an int, add the property of this object
      to the int.

      The type hint int | Self is a type hint that indicates that
      the other object can be an int, a float, or an object of class A.
      It is shorthand for Union[int, A].

      :param other:
      :return:
      """
      if isinstance(other, A):
        return other.property + self.property
      if isinstance(other, int):
        return other + self.property
      return NotImplemented

  a: A = A()
  a.property = 10
  print(f'a.property = {a.property}')  # Displays a.property = 10
  b: A = A()
  b.property = 20
  print(f'b.property = {b.property}')  # Displays b.property = 20
  c: int = a + b
  print(f'a + b = {c}')  # Displays a + b = 30

  d: int = 5 + a
  print(f'5 + a = {d}')  # Displays 5 + a = 15

  e: int = a + 5
  print(f'a + 5 = {e}')  # Displays a + 5 = 15

  try:
    # This will result in a mypy error, which
    # has been suppressed with a type ignore comment.
    # But the code will run but throw an exception
    # at runtime.
    f: float = a + 5.0  # type: ignore[operator]
    print(f'a + 5.0 = {f}')  # Displays a + 5.0 = NotImplemented
  except TypeError as ex:
    print(ex)  # Displays unsupported operand type(s) for +: 'A' and 'float'
