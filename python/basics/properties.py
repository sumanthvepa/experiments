#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  properties.py: Explore properties in Python
"""
# -------------------------------------------------------------------
# properties.py: Explore properties in Python
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

from datetime import date


class Person:
  """
    A class that demonstrates the use of properties in Python

    The class has three properties: name, date_of_birth and age.

    The name property is a string that represents the name of the
    person. It can be changed by simply assigning a new value to it.

    The date_of_birth property is a date object that represents the
    date of birth of the person. It cannot be changed after the object
    is created.

    The age property is an integer that represents the age of the
    person. It is calculated based on the date_of_birth property and
    the current date. So it is a read-only property.
  """
  def __init__(self, name: str, date_of_birth: date) -> None:
    """
      Create a person with a name and date of birth
    """
    # Python will understand that the _name and _date_of_birth
    # are private attributes. It will use these attributes to
    # in the getter and setter methods for the property name
    # and date_of_birth. The underscore is a convention to
    # indicate that the attribute is private. It is not enforced
    # by Python. So you can directly access the attributes, although
    # it is not recommended.
    self._name = name
    self._date_of_birth = date_of_birth

  # Strictly speaking, name does not need to be a property. It can be
  # a public attribute. But we use a property to demonstrate the use
  # of the setter decorator.
  @property
  def name(self) -> str:
    """
      Get the name of the person

      The decorator @property is used to define the getter
    """
    return self._name

  @name.setter
  def name(self, name: str) -> None:
    """
      Set the name of the person

      Note that the decorator @name.setter is used to define the
      setter.
    """
    self._name = name

  @property
  def date_of_birth(self) -> date:
    """
      Get the date of birth of the person
    """
    return self._date_of_birth

  @property
  def age(self) -> int:
    """
      Get the age of the person
    """
    today = date.today()
    return today.year - self._date_of_birth.year \
        - ((today.month, today.day)
            < (self._date_of_birth.month, self._date_of_birth.day))


def explore_properties() -> None:
  """
    Explore properties in Python

    :return: None
  """
  feynman = Person('Richard Feynman', date(1918, 5, 11))
  print(f'Name: {feynman.name}')
  print(f'Date of Birth: {feynman.date_of_birth}')
  print(f'Age: {feynman.age}')
