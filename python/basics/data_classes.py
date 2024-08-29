#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  data_classes.py: Explore data classes in Python
"""
# -------------------------------------------------------------------
# data_classes.py: Explore data classes in Python
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

from dataclasses import dataclass, FrozenInstanceError


def explore_dataclasses() -> None:
  """
    Explore data classes in Python
    :return: None
  """
  # Data classes are a feature of Python that allow you to create
  # classes that are meant to store data. Data classes are created
  # using the dataclass decorator from the dataclasses module.
  # The dataclass decorator automatically generates special methods
  # for the class, such as __init__, __repr__, and __eq__. The
  # __init__ method initializes the class, the __repr__ method
  # returns a string representation of the class, and the __eq__
  # method compares two instances of the class for equality.
  # Data classes are created by decorating a class with the
  # dataclass decorator. The dataclass decorator takes several
  # arguments that allow you to customize the behavior of the
  # data class. For example, you can specify whether the class
  # is mutable or immutable, whether the class should be frozen
  # after initialization, and whether the class should be
  # compared using the __eq__ method.
  # Here is an example of a data class that represents a person
  # with a first name, a last name, and an age. The data class
  # is created by decorating a class with the dataclass decorator
  # and specifying the fields of the class as class variables.

  # See this video for more information on data classes:
  # https://www.youtube.com/watch?v=vBH6GRJ1REM

  @dataclass
  class Person:
    """ A data class that represents a person """
    first_name: str
    last_name: str
    age: int

  # You can create an instance of the data class by passing the
  # values of the fields as arguments to the class constructor
  # (the __init__ method). The data class automatically generates
  # an __init__ method that takes the values of the fields as
  # arguments.
  person = Person('John', 'Doe', 30)
  # Person has a __repr__ method that returns a string representation
  # used by the print function.
  # Prints explore_dataclasses.<locals>.Person(first_name='John', last_name='Doe', age=30)
  print(person)

  # Person has an __eq__ method that compares two instances of the class
  # for equality.
  # Prints True
  person2 = Person('John', 'Doe', 30)
  print(f'person == person2: {person == person2}')

  # You can change the values of the fields of the data class by
  # assigning new values to the fields.
  person.age = 40
  print(f'person.age: {person.age}')

  # You can also create a data class with default values for the fields.
  @dataclass
  class PersonWithDefaults:
    """ A data class that represents a person with default values """
    first_name: str = 'John'
    last_name: str = 'Doe'
    age: int = 30

  # You can create an instance of the data class without passing any
  # arguments to the class constructor
  person_with_defaults = PersonWithDefaults()
  # Prints explore_dataclasses.<locals>.PersonWithDefaults(
  # first_name='John', last_name='Doe', age=30)
  print(person_with_defaults)

  # Dataclass decorators have several arguments that allow you to
  # customize the behavior of the data class. These arguments are
  # passed to the dataclass decorator as keyword arguments.
  # They are described below:
  # 1. init: If True, an __init__ method is generated that initializes
  # the fields of the data class. If False, no __init__ method is
  # generated. The default value is True.
  # 2. repr: If True, a __repr__ method is generated that returns a
  # string representation of the data class. If False, no __repr__
  # method is generated. The default value is True.
  # 3. eq: If True, an __eq__ method is generated that compares two
  # instances of the data class for equality. If False, no __eq__
  # method is generated. The default value is True.
  # 4. order: If True, rich comparison methods (__lt__, __le__, __gt__,
  # __ge__) are generated that compare two instances of the data class.
  # If False, no rich comparison methods are generated. The default
  # value is False.
  # 5. unsafe_hash: If True, a __hash__ method is generated that returns
  # a hash value for the data class. If False, no __hash__ method is
  # generated. The default value is False.
  # 6. frozen: If True, the data class is frozen after initialization.
  # This means that the values of the fields cannot be changed after
  # the data class is created. If False, the data class is mutable.
  # The default value is False.
  # 7. metadata: A dictionary that contains metadata for the data class.
  # The metadata is stored in the __dataclass_fields__ attribute of the
  # data class. The default value is None.
  # 8. kw_only: If True, the data class constructor only accepts keyword
  # arguments. If False, the data class constructor accepts both positional
  # and keyword arguments. The default value is False.
  # 9. slots: If True, the data class is created with a __slots__ attribute
  # that restricts the attributes of the data class to the fields specified
  # in the data class. If False, no __slots__ attribute is generated. The
  # default value is False. (See the section on slots for more information.)
  # 10. weakref_slot: If True, the data class is created with a __weakref__
  # attribute that allows weak references to the data class. If False, no
  # __weakref__ attribute is generated. The default value is True.
  # See the documentation for the dataclasses module at:
  # https://docs.python.org/3/library/dataclasses.html for more information.

  # For the next example we will mark the class as immutable
  @dataclass(frozen=True, unsafe_hash=True)
  class GitCommit:
    """ A data class that represents a git commit """
    id: str
    message: str
    timestamp: int

  commit1 = GitCommit('123456', 'Initial commit', 1630000000)
  try:
    # This will raise a FrozenInstanceError
    # noinspection PyDataclass
    commit1.id = '654321'  # type: ignore
  except FrozenInstanceError as fie:
    print(fie)  # Prints: Cannot assign field to id.

  # Dataclasses are not the only solution for the problem of
  # data-only structures. There are other options described
  # in this video: https://www.youtube.com/watch?v=vCLetdhswMg
  # The options include:
  # 1. Named tuples
  # 2. Pydantic
  # 3. attrs
  # 4. TypedDict
  # 5. Marshmallow
  # You should choose the solution that best fits your needs.
