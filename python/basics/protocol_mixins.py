#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  protocol_mixins.py: Explore mixins using the Protocol type.

  This is the top-level driver code for my exploration of python.
"""
# -------------------------------------------------------------------
# protocol_mixins.py: Explore mixins using the Protocol type.
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
from typing import Protocol


# Inherit from this class to indicate
# that you require the definition of
# plus_one
# pylint: disable=too-few-public-methods
class RequiresPlusOne(Protocol):
  """ A Protocol that requires the plus_one method."""
  def plus_one(self) -> int:
    """ A method that returns the input number plus one."""


class MixIn(RequiresPlusOne):
  """ A mixin that requires the plus_one method to be available."""
  def print_one_plus_one(self) -> None:
    """ Add one to the number 1 and print it."""
    # Note that plus_one is not implemented
    # anywhere in this class's hierarchy
    print(self.plus_one())


class A:
  """ A class that implements the plus_one method."""
  def __init__(self, number: int = 1) -> None:
    """ Initialize the class with a number."""
    self.number = number

  def plus_one(self) -> int:
    """ A method that returns the input number plus one."""
    # Note that A does not inherit from HasPlusOne
    # but implements the method plus_one
    return self.number + 1


class B(A, MixIn):
  """
    A class that inherits from A and MixIn so now the mixin will work
    Note that A must be inherited before MixIn.
  """
  def do_something(self) -> None:
    """ A method that does something."""
    # This method will call the print_one_plus_one method in the MixIn class
    # that will in turn call the plus_one method in class A
    self.print_one_plus_one()


def explore_protocol_mixins() -> None:
  """ Create an instance of B and call its method."""
  b = B()
  b.do_something()


if __name__ == '__main__':
  explore_protocol_mixins()
