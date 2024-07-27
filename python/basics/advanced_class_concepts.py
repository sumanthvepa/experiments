#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  advanced_class_concepts.py: Explore advanced class concepts
"""
# -------------------------------------------------------------------
# advanced_class_concepts.py: Explore advanced class concepts
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


def explore_slots() -> None:
  """ Explore slots in Python """
  # Slots are a way to optimize memory usage in Python classes.
  # By default, Python classes store their attributes in a dictionary.
  # This allows you to add and remove attributes at runtime.
  # However, this flexibility comes at a cost: each attribute
  # takes up memory in the dictionary. If you have a large number
  # of instances of a class, this can add up to a significant
  # amount of memory.
  # Slots provide a way to avoid this memory overhead by
  # pre-allocating space for a fixed set of attributes.
  # When you define a class with slots,
  # Python will use a more efficient data structure to store
  # the attributes, which can reduce memory usage.

  # This is a normal class:
  class NormalPerson:  # pylint: disable=too-few-public-methods
    """ A class without slots """
    def __init__(self, first_name: str, last_name: str, age: int) -> None:
      self.first_name = first_name
      self.last_name = last_name
      self.age = age

  # The class has a __dict__ attribute that stores the attributes
  # in a dictionary:
  normal_person = NormalPerson('John', 'Doe', 30)
  print(normal_person.__dict__)  # {'first_name': 'John', 'last_name': 'Doe', 'age': 30}

  # Here is an example of a class with slots:
  class SlottedPerson:  # pylint: disable=too-few-public-methods
    """ A class with slots """
    # You define a special class variable called __slots__
    # that defines what attributes a class instance can have.
    __slots__ = ['first_name', 'last_name', 'age']

    def __init__(self, first_name: str, last_name: str, age: int) -> None:
      # You can then initialize the attributes in the __init__ method.
      self.first_name = first_name
      self.last_name = last_name
      self.age = age

  slotted_person = SlottedPerson('John', 'Doe', 30)
  # The class does not have a __dict__ attribute:
  # AttributeError: 'SlottedPerson' object has no attribute '__dict__'
  # But you can access the attributes directly:
  # {'first_name': 'John', 'last_name': 'Doe', 'age': 30}
  print(f"'first_name': '{slotted_person.first_name}', "
        + "'last_name': '{slotted_person.last_name}', "
        + "'age': {slotted_person.age}'")

  # You can modify the attributes of a slotted class:
  slotted_person.first_name = 'Jane'
  print(f"'first_name': '{slotted_person.first_name}', "
        + "'last_name': '{slotted_person.last_name}', "
        + "'age': {slotted_person.age}'")

  # For a normal class you can add new attributes
  # outside the init method. (Although both
  # pylint and mypy will complain about this.)
  # pylint: disable=attribute-defined-outside-init
  normal_person.nickname = 'Fandango'  # type: ignore

  # But you cannot do this for a slotted class:
  # You will get a runtime error even if you supress the
  # pylint, mypy and IntelliJ IDEA warnings
  try:
    # pylint: disable=assigning-non-slot
    # noinspection PyDunderSlots
    slotted_person.nickname = 'Fandango'  # type: ignore
  except AttributeError as ex:
    print(f'AttributeError: {ex}')
