#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  metaclasses.py: Exploring metaclasses in Python
"""
# -------------------------------------------------------------------
# metaclasses.py: Exploring metaclasses in Python
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


def explore_metaclasses() -> None:
  """
  Explore metaclasses in Python
  :return: None
  """
  # Metaclasses are a powerful feature of Python. A Metaclass is
  # essentially a 'class' of a 'class' (or equivalently the 'type' of a
  # 'type'.)
  # Normally, when you create a class in Python, the class is an
  # instance of the type class. The type class is the metaclass of
  # all classes in Python (that are not instances of a different
  # metaclass.)
  # Metaclasses are explained very well in this mCoding video, by
  # James Murphy:
  # https://www.youtube.com/watch?v=yWzMiaqnpkI

  # pylint: disable=too-few-public-methods
  class A:
    """ A sample class. """

  a = A()
  print(type(a))  # <class '__main__.A'> is an instance of the class A
  print(type(A))  # <class 'type'> is an instance of the class 'type'.

  # You can create a metaclass by subclassing the type class. Here is
  # a trivial example of a metaclass that prints a message when a class
  # is created.
  class ClassCreationLogger(type):
    """ A sample metaclass. """
    def __new__(mcs, name: str, bases: tuple, dct: dict) -> type:
      print(f'Creating class {name}')
      return super().__new__(mcs, name, bases, dct)

  # You can use a metaclass by setting the metaclass keyword argument
  # in the class definition. Here is an example of a class that uses
  # the MyMeta metaclass.
  class B(metaclass=ClassCreationLogger):
    """ A sample class that uses the MyMeta metaclass. """

  b = B()
  # <class 'metaclasses.explore_metaclasses.<locals>.B> is an instance
  # of the class B
  print(type(b))

  class C(metaclass=ClassCreationLogger):
    """ Another sample class that uses the MyMeta metaclass. """
  c = C()
  # <class 'metaclasses.explore_metaclasses.<locals>.C> is an instance
  # of the class C
  print(type(c))

  # The class creation logger even works with dynamically created
  # classes. You need to set the __metaclass__ attribute in the
  # namespace of the class to the metaclass (ClassCreationLogger)
  def message(self) -> str:
    """ A sample method. """
    return self._message  # pylint: disable=protected-access

  namespace = {
    '__metaclass__': ClassCreationLogger,
    '_message': 'I am an object of type D',
    'message': message
  }

  # noinspection PyPep8Naming
  D = type('D', (object, ), namespace)  # pylint: disable=invalid-name
  d = D()
  print(type(d))  # <class 'metaclasses.D'> is an instance of the class D
  print(d.message())  # I am an object of type D

  # Metaclasses are useful when you want to modify the behavior of
  # classes at the class level. For example, you can use a metaclass
  # to enforce a particular interface on all classes that use the
  # metaclass. You can also use a metaclass to add methods to all
  # classes that use the metaclass.

  # Metaclasses are a powerful feature of Python, but they are also
  # complex and can be difficult to understand. They are not needed
  # in most Python programs, but they can be useful in some cases.
