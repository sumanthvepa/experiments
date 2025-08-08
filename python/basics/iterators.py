#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  iterators.py: Explore iterators
"""
from __future__ import annotations
import collections.abc
import random
from typing import Iterable, Iterator, Self, override


# -------------------------------------------------------------------
# generators.py: Explore generators
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

# pylint: disable=too-many-statements
def explore_iterators() -> None:
  """
  Explore iterators
  """
  # An iterable is an object that can be iterated over, meaning you
  # can traverse through all the elements in the object. Examples of
  # iterables include lists, tuples, strings, and dictionaries. You
  # can use a for loop to traverse through the elements of an
  # iterable.
  my_list = [1, 2, 3, 4, 5]  # my_list is an iterable
  for item in my_list:
    print(item)

  # Formally an iterable is an object that implements the __iter__()
  # method. The __iter__() method returns an iterator object,

  # An iterator is an object that represents a stream of data. It
  # implements two methods: __iter__() and __next__(). The __iter__()
  # method returns the iterator object itself, and the __next__()
  # method returns the next value from the iterator. When there are
  # no more items to return, the __next__() method raises a StopIteration
  # exception to signal that the iteration is complete.

  # One benefit of using iterators is that they allow you multiple
  # concurrent traversals of the same iterable in a reentrant way.
  # This is because the state of the iteration is maintained separately
  # from the iterable itself. Each iterator maintains its own
  # state, so you can have multiple iterators over the same iterable.

  # Let's create a custom iterator class.
  class PseudoRandomNumberIterator(collections.abc.Iterator[int]):
    """
      Represents an iterator over the class PseudoRandomNumbers.
    """
    def __init__(self, sequence: PseudoRandomNumbers, index: int) -> None:
      """
        Initialize the iterator
        :param index: The index of the next element to return
        :param sequence: The sequence of integers to iterate over
      """
      self._index = index
      self._sequence = sequence

    @override
    def __iter__(self) -> Self:
      """
        Returns the iterator object itself.
        :return: self
      """
      return self

    @override
    def __next__(self) -> int:
      """
        Returns the next pseudo-random number in the range.
      """
      if self._index >= len(self._sequence):
        raise StopIteration
      value = self._sequence.get_number(self._index)
      self._index += 1
      return value

  # Let's create a custom iterable class.
  # Note that we are inheriting from collections.abc.Iterable.
  # This is not strictly necessary, as Python uses duck typing,
  # If the class implements the __iter__() method, it is considered
  # an iterable. However, inheriting from collections.abc.Iterable
  # provides a formal way to indicate that the class is an iterable
  # and allows for better type checking and documentation. In general,
  # if you are creating a class that is intended to be an iterable,
  # it is a good practice to inherit from collections.abc.Iterable.
  class PseudoRandomNumbers(collections.abc.Iterable[int]):
    # noinspection GrazieInspection
    """
          Represents a list of pseudo-random numbers in a range.

          Objects of this class can be created to return numbers in a
          specified range[begin, end). The number of elements in the
          list can be specified by the count parameter.
        """
    @override
    def __init__(self, begin: int, end: int, count: int):
      self._begin = begin
      self._end = end
      self._count = count
      self._sequence: dict[int, int] = {}

    def get_number(self, index: int) -> int:
      # noinspection GrazieInspection
      """
              Returns a pseudo-random number in the range [begin, end).
              This is a placeholder for the actual random number generation logic.

              This is a private method intended to be used only by
              the iterator.

              :param index: The index of the number to return
              :return: A pseudo-random number in the range [begin, end).
            """
      if index < 0 or index >= self._count:
        raise IndexError("Index out of range")
      # This needs to be in a critical section if multiple threads
      # are accessing this method. But for normal python
      # this is not an issue.
      value = self._sequence.get(index)
      if value is None:
        value = random.randrange(self._begin, self._end)
        self._sequence[index] = value
      return value

    def __len__(self) -> int:
      # This is only needed if you want to use the len() function
      # which we do in the iterator.
      return self._count

    def __iter__(self) -> Iterator[int]:
      return PseudoRandomNumberIterator(self, 0)

  # Now we can create an instance of the PseudoRandomNumbers class
  # and iterate over it using a for loop.
  random_numbers = PseudoRandomNumbers(0, 100, 10)
  print('10 random numbers in the range [0, 100):')
  for number in random_numbers:
    print(number)

  # You can also explicitly create an iterator from the iterable
  # and use it to iterate over the elements.
  print('Iterating over the random numbers using an iterator:')
  iterator = iter(random_numbers)
  while True:
    try:
      number = next(iterator)
      print(number)
    except StopIteration:
      break

  # Notice that the numbers do not change when iterating over the same
  # iterable. That is a consequence of how we implemented the class
  # PseudoRandomNumbers. If you want a different set of numbers
  # create a new instance of the class.
  print('Creating a new instance of PseudoRandomNumbers:')
  random_numbers2 = PseudoRandomNumbers(0, 100, 10)
  print('10 random numbers in the range [0, 100):')
  for number in random_numbers2:
    print(number)

  # You can have multiple iterators over the same iterable.
  print('Creating two iterators over the same iterable:')
  iterator1 = iter(random_numbers)
  iterator2 = iter(random_numbers)
  iterator1_exhausted = False
  iterator2_exhausted = False
  while not (iterator1_exhausted and iterator2_exhausted):
    if not iterator1_exhausted:
      try:
        print(f'iterator1: {next(iterator1)}')
        print(f'iterator1: {next(iterator1)}')
      except StopIteration:
        iterator1_exhausted = True
        print('iterator1 exhausted')
    if not iterator2_exhausted:
      try:
        print(f'iterator2: {next(iterator2)}')
      except StopIteration:
        iterator2_exhausted = True
        print('iterator2 exhausted')
  print('Finished iterating over both iterators.')

  # Note on type annotations:
  # All iterables are of type typing.Iterable[T] where T is the type of
  # the elements in the iterable. All iterators are of type typing.Iterator[T]
  # where T is the type of the elements in the iterator.
  # However, when specifically implementing an iterator, it is
  # recommended to inherit from collections.abc.Iterable[T] and
  # collections.abc.Iterator[T] respectively. Use the former when
  # specifying that the 'type' of a variable is an iterable or iterator.
  # Use the latter when implementing an iterable or iterator.
  # The class PseudoRandomNumbers is an iterable tha returns integers,
  # so it is derived from class collections.abc.Iterable[int]. It is
  # of type iterator[int].
  # For example, the function below takes an iterable of integers
  # and not collections.abc.Iterable[int] as a parameter.
  # This allows it to accept any iterable of integers, including
  # classes that do not explicitly inherit from
  # collections.abc.Iterable[int],
  def sum_of(numbers: Iterable[int]) -> int:
    """
      Returns the sum of the numbers in the iterable.
      :param numbers: An iterable of integers
      :return: The sum of the numbers
    """
    # This function duplicates the functionality of the built-in
    # sum() function, but it is implemented using an iterator.
    s: int = 0
    for n in numbers:
      s += n
    return s

  # you can use the sum_of function to sum the random_numbers
  print(f'Sum of random numbers: {sum_of(random_numbers)}')
  # This will work with any iterable of integers, including lists,
  # tuples, and even generators.
  some_numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  print(f'Sum of some numbers: {sum_of(some_numbers)}')


if __name__ == '__main__':
  explore_iterators()
