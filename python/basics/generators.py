#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  generators.py: Explore generators
"""
# -------------------------------------------------------------------
# generators.py: Explore generators
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
from typing import Iterator


def explore_generators() -> None:
  """
    Explore generators

    :return: None
  """
  # Generators are a special type of iterator that allow you to
  # iterate over a sequence of values without having to create the
  # entire sequence in memory. Generators are defined using the
  # yield statement.
  # Note the return type of the fibonacci function is an iterator
  # not a list. This is because the fibonacci function is a
  # generator function.
  def fibonacci(n: int) -> Iterator[int]:
    """
      Generate the first n Fibonacci numbers
      :param n: The number of Fibonacci numbers to generate
      :return: A list of the first n Fibonacci numbers
    """
    a, b = 0, 1
    for _ in range(n):
      yield a
      a, b = b, a + b

  for f in fibonacci(10):
    print(f, end=' ')


if __name__ == '__main__':
  explore_generators()
