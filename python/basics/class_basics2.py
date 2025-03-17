#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  class_basics2.py: Continue exploring basics of classes in Python
"""
# -------------------------------------------------------------------
# class_basics2.py: Continue exploring basics of classes in Python
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


def explore_dunder_methods() -> None:
  """
    Explore dunder methods in Python
    :return: None
  """
  # Explore the comparison dunder methods
  # Consider a class NA with two attributes a and b
  class NA:  # pylint: disable=too-few-public-methods
    """ A class with no __eq__ method """
    def __init__(self, a: str, b: str) -> None:
      """
        Initialize the class NA with attributes a and b
        :param a: str: The first attribute
        :param b: str: The second attribute
      """
      self.a = a
      self.b = b

  # Let's create two objects of class NA
  na1 = NA('Hello', 'World')
  na2 = NA('Hello', 'World')
  # A check for equality will return False, because the
  # default __eq__ method compares the references.
  # clearly na1 and na2 are different objects.
  print(na1 == na2)  # False

  # This is not always desirable. Sometimes we want to compare
  # the attributes of the objects, rather than the references
  # of the objects. This is where the __eq__ method comes in.

  # Now Consider a class A with two attributes a and b, that
  # defines the __eq__ method.
  class A:  # pylint: disable=too-few-public-methods
    """ A class that demonstrate the purpose of the __eq__ method """
    def __init__(self, a: str, b: str) -> None:
      """
        Initialize the class A with attributes a and b
        :param a: str: The first attribute
        :param b: str: The second attribute
      """
      self.a = a
      self.b = b

    def __eq__(self, other: object) -> bool:
      """
        Compare two objects of class A
        :param other: Another object
        :return: True if the objects are equal, False otherwise
      """
      # Note how we check if the other object is an instance of A
      # and only then compare the attributes. If we didn't do this
      # we might end up attempt to de-reference an attribute that
      # doesn't exist in the other object or, even if it belongs
      # to a different class, leading to an error.
      if not isinstance(other, A):
        return False
      return self.a == other.a and self.b == other.b

  # Now, let's create two objects of class A
  a1 = A('Hello', 'World')
  a2 = A('Hello', 'World')

  # This time the check for equality will return True, because
  # the __eq__ method compares the attributes of the objects.
  # The objects are equal.
  print(a1 == a2)  # True

  # Consider lists of objects of type class NA and A respectively
  l1: list[NA] = [na1, na2]
  na3: NA = NA('Hello', 'World')
  na4: NA = NA('Hello', 'World')
  l2: list[NA] = [na3, na4]
  print(l1 == l2)  # False. The default __eq__ method compares references, which are different

  l3: list[A] = [a1, a2]
  a3: A = A('Hello', 'World')
  a4: A = A('Hello', 'World')
  l4: list[A] = [a3, a4]
  print(l3 == l4)  # True. The __eq__ method compares attributes, which are the same
