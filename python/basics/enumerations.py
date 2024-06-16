#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  enumerations.py: Explore enumerations
"""
# -------------------------------------------------------------------
# enumerations.py: Explore enumerations
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

# Enumerations are a set of symbolic names bound to unique, constant
# values. Enumerations are defined using the Enum class from the enum
# module. Enumerations are useful when you have a fixed set of values
# that are related in some way.
from enum import Enum


def explore_enumerations() -> None:
  """
    Explore enumerations
    :return: None
  """
  # You can define an enumeration by subclassing the Enum class.
  # The values of the enumeration are defined as class attributes.
  class HttpError(Enum):
    """
      Enumeration for HTTP errors
    """
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404

  # You can access the values of the enumeration using the dot
  # notation.
  print(HttpError.BAD_REQUEST)  # HttpError.BAD_REQUEST

  # You can access the name of the enumeration using the name
  # attribute.
  print(HttpError.BAD_REQUEST.name)  # BAD_REQUEST

  # You can access the value of the enumeration using the value
  # attribute.
  print(HttpError.BAD_REQUEST.value)  # 400

  # You can iterate over the enumeration.
  for error in HttpError:
    print(error)

  # You can check if a value is a member of the enumeration.
  print(HttpError.BAD_REQUEST in HttpError)  # True

  # You can compare enumerations using the equality operator.
  print(HttpError.BAD_REQUEST == HttpError.BAD_REQUEST)  # True
  print(HttpError.BAD_REQUEST == HttpError.UNAUTHORIZED)  # False

  # You can compare enumerations using the inequality operator.
  print(HttpError.BAD_REQUEST != HttpError.BAD_REQUEST)  # False
  print(HttpError.BAD_REQUEST != HttpError.UNAUTHORIZED)  # True

  # You can access the enumeration using the value.
  print(HttpError(400))  # HttpError.BAD_REQUEST

  # You can access the enumeration using the name.
  print(HttpError['BAD_REQUEST'])  # HttpError.BAD_REQUEST

  # You can also emulate Swifts enums with associated values
  # by using the Enum class with a custom __init__ method.
  class Result(Enum):
    """
      Enumeration for results
    """
    SUCCESS = 0, 'Success'
    FAILURE = 1, 'Failure'

    def __init__(self, code: int, message: str) -> None:
      self.code = code
      self.message = message

  # You can access the value of the enumeration using the value
  # attribute.
  print(Result.SUCCESS.value)  # (0, 'Success')
  print(Result.FAILURE.value)  # (1, 'Failure')

  print(Result.SUCCESS.code)  # 0
  print(Result.FAILURE.code)  # 1

  # You can access the message of the enumeration using the message
  # attribute.
  print(Result.SUCCESS.message)  # Success
  print(Result.FAILURE.message)  # Failure

  # You can return a Result enum from a function and
  # check whether it returned a success or failure.
  def do_something() -> Result:
    """
      Do something
      :return: Result
    """
    return Result.SUCCESS

  result = do_something()
  if result == Result.SUCCESS:
    print(f'Yes: {result.message}')
  else:
    print(f'Oh No!: {result.message}')

  # See https://stackoverflow.com/questions/12680080/python-enums-with-attributes
  # for a more advanced example of using enums with attributes.
  # The code from the link is shown below:
  class EnumWithAttributes(Enum):
    """
      This code is from https://stackoverflow.com/questions/12680080/python-enums-with-attributes
      It defines an enumeration with custom attributes ('a' and 'b') and assigns
      each member(GREEN, BLUE etc.) a unique integer value starting from 0, while also
      initializing the custom attributes with the values passed to the enumeration member.
    """

    def __new__(cls, *args, **kwargs):
      """
        Create a new instance of the class with a custom value that is
        unique for each member of the enumeration. The value indicates
        the position of the member in the enumeration starting from 0.

        :param cls: The class to instantiate
        :param args: Not used.
        :param kwargs: Not used.
      """
      # The new method is called when a new instance of the class
      # is created. The __new__ method is a class method that
      # takes the class as the first argument. The new method
      # is responsible for creating a new instance of the class.
      # Once the new method returns, the __init__ method is called
      # to initialize the class.

      # We implement a custom __new__ method in order to get access
      # to a count of the number of members in the enumeration.
      # The number of members in the enumeration is essentially the
      # number of instances of the class at the time of creation.
      # Knowing the number of members in the enumeration allows us
      # to assign ordinal numbers to them when they are created.

      # The attribute cls.__members__ is a dictionary that contains
      # the members of the enumeration. The length of the dictionary
      # is the number of members in the enumeration.

      # The _value_ variable is set to the length of the dictionary.
      # This means that the first member of the enumeration will get
      # a value 0, the second 1 and so on. Since 'GREEN' is the
      # first member of the enumeration, __new__ will be called
      # first for it and the value will be set to 0. The next
      # member is 'BLUE' and its value will be set to 1.

      # The _value_ is special in that it stores the value that is
      # retrieved when the attribute value is accessed. (This is
      # done as part of the Enum class implementation.)
      # So GREEN.value will return 0 and BLUE.value will return 1.
      # You cannot access the _value_ attribute directly.

      obj = object.__new__(cls)
      obj._value_ = len(cls.__members__)
      return obj

    def __init__(self, a: int, b: str):
      self.a = a
      self.b = b

    GREEN = 'a', 'b'
    BLUE = 'c', 'd'

  print(EnumWithAttributes.GREEN.value)  # 0
  print(EnumWithAttributes.GREEN.a)  # a
  print(EnumWithAttributes.GREEN.b)  # b
  print(EnumWithAttributes.BLUE.value) # 1
  print(EnumWithAttributes.BLUE.a)  # c
  print(EnumWithAttributes.BLUE.b)  # d
