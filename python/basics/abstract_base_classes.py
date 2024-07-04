#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  abstract_base_classes.py: Exploring abstract base classes in Python
"""
# -------------------------------------------------------------------
# abstract_base_classes.py: Exploring abstract base classes in Python
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
from abc import ABC, abstractmethod


def explore_abstract_base_classes() -> None:
  """
    Explore abstract base classes in Python
    :return: None
  """
  # Abstract base classes are classes that are meant to be subclassed
  # but not instantiated. Abstract base classes are used to define
  # a common interface for a group of classes. Abstract base classes
  # are created using the ABCMeta metaclass from the abc module.
  # The ABCMeta metaclass is a subclass of the type
  # metaclass. Abstract base classes are created by subclassing the
  # ABCMeta metaclass.

  class Animal(ABC):  # pylint: disable=too-few-public-methods
    """ An abstract base class for animals """
    @abstractmethod
    def speak(self) -> str:
      """
        This is an abstract method that must be implemented by subclasses

        The speak method is marked as an abstract method using the
        abstractmethod decorator from the abc module.
        :return: str
      """

  class Dog(Animal):  # pylint: disable=too-few-public-methods
    """ A subclass of the Animal abstract base class """
    def speak(self) -> str:
      """ This is an implementation of the speak method """
      return 'Woof!'

  # Failing to implement the abstract method will raise an error
  # when an instance of the class is created.
  # It will also cause IntelliJ IDEA to display a warning.
  # (It has been suppressed in this case.)
  # noinspection PyAbstractClass
  class Python(Animal):  # pylint: disable=too-few-public-methods
    """ A subclass of the Animal abstract base class """

    # noinspection PyMethodMayBeStatic
    def hiss(self):
      """ This is an implementation of the hiss method """
      return 'Hiss!'

  rover = Dog()
  print(rover.speak())  # Woof!

  try:
    # This will result in a TypeError at runtime
    # TypeError: Can't instantiate abstract class Python with abstract
    # methods speak. Both Pylint and MyPy will complain about this.
    # (They have been silenced for this example)
    # pylint: disable=abstract-class-instantiated
    sammy = Python()  # type: ignore
    print(sammy.hiss())
  except TypeError as ex:
    print(ex)  # Can't instantiate abstract class Python with abstract methods speak
