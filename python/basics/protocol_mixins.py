#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  protocol_mixins.py: Exploring the Protocol type using mixins

  This is the top-level driver code for my exploration of python.
"""
# -------------------------------------------------------------------
# protocol_mixins.py: Exploring the Protocol type using mixins
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
from typing import Protocol


# Inherit from this class to indicate
# that you require the definition of
# plus_one
class RequiresPlusOne(Protocol):
  def plus_one(self, number: int) -> int:
    ...


class MixIn(RequiresPlusOne):
  def print_one_plus_one(self) -> None:
    # Note that plus_one is not implemented
    # anywhere in this class's hierarchy
    print(self.plus_one(1))


class A:
  def plus_one(self, number: int) -> int:
    # Note that A does not inherit from HasPlusOne
    # but implements the method plus_one
    return number + 1


class B(A, MixIn):
  def do_something(self) -> None:
    # This method has full
    self.print_one_plus_one()


def explore_protocol_mixins() -> None:
  b = B()
  b.do_something()


if __name__ == '__main__':
  explore_protocol_mixins()

