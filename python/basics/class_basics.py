#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  class_basics.py: Exploring basics of classes in Python
"""
# -------------------------------------------------------------------
# class_basics.py: Exploring basics of classes in Python
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

# Allow forward references in type hints.
from __future__ import annotations

# Mark an attribute as a class attribute in type hints.
# This causes mypy to warn if you try to access this attribute
# via an instance of the class.
from typing import ClassVar


class F:  # pylint: disable=too-few-public-methods
  """
    This class is declared at module scope.
  """
  def __init__(self) -> None:
    """
      This is the constructor of class D.
      See explore_class_basics for more details on constructors.

      This constructor creates and initializes an instance attribute
      called 'value' to 'f'.
    """
    self.value: str = 'f'


def explore_class_basics() -> None:  # pylint: disable=too-many-locals, too-many-statements
  """
    Explore the basics of classes in Python
    :return: None
  """
  # A class is a blueprint for creating objects. An object is an
  # instance of a class. A class is defined using the class keyword.
  # A class is defined as follows:
  class ClassA:  # pylint: disable=too-few-public-methods, missing-class-docstring
    # Note the pylint directive above. This is because the class
    # definition is empty. The directive disables the warning that
    # the class has too few public methods. The directive also disables
    # the warning that the class is missing a docstring. Class
    # docstrings are described in the next section.

    # Note the indentation. Everything inside the class is indented.

    # The pass keyword below indicates that the class definition is
    # empty.This is needed because of the indentation rules in Python.
    # and the lack of braces to indicate the start and end of a block.
    # The pass statement is only necessary if there is no code in the
    # class definition. If there is code, the pass statement is not
    # needed.
    pass

  # This creates an instance of class ClassA. An instance of a class
  # is called an object.
  a = ClassA()
  print(a)  # Displays <class_basics.explore_class_basics.<locals>.ClassA object at 0xmemoryaddress>

  # A class definition with a docstring describing the class
  # is not technically empty so a pss statement is not needed.
  # If you must create an empty class (and sometimes it makes sense
  # to do so), you should prefer this form over using pass.
  # Once again we disable pylint warnings about too few public
  # methods.
  class B:  # pylint: disable=too-few-public-methods
    """
      This is a class with docstring. So pass is not needed.
    """

  # Create an instance of b.
  b = B()
  print(b)  # <class_basics.explore_class_basics.<locals>.B object at 0xmemoryaddress>

  # An instance of a class can have attributes. An attribute is a
  # variable that is associated with an object. An attribute is
  # accessed using the dot operator. An instance attribute is defined
  # in the constructor of the class. The constructor is a special method
  # called __init__. It is called when an object of the class is
  # created. The constructor is used to initialize the object.
  class C:  # pylint: disable=too-few-public-methods
    """
      This is a class with an instance attribute.
    """
    def __init__(self) -> None:
      """
        This is the constructor of class C. It is called when an object
        of class C is created. The self argument is automatically passed
        to this method by the python interpreter, so that it has access
        to the object being constructed. There is no need to explicitly
        pass the self object.

        This constructor, creates an attribute called 'value' and
        initializes it to 42.
      """
      self.value: int = 42

  c = C()
  print(c)  # Displays <class_basics.explore_class_basics.<locals>.C object at 0xmemoryaddress>

  # You can access the value attribute of the class C using the dot operator.
  print(c.value)  # Displays 42

  # value of the attribute of any given instance of the class can be changed
  c.value = 43
  print(c.value)

  # The change in attribute of one instance of the class does not
  # affect the attribute of another instance of the class.
  c1 = C()
  c2 = C()
  c1.value = 10
  print(c1.value)  # Displays 10.
  print(c2.value)  # Still displays 42.
  c2.value = 11
  print(c2.value)  # Displays 11.
  print(c1.value)  # Still displays 10.

  # However, unlike primitive types, classes are reference types.
  # So, if you assign one instance of a class to another, both
  # variables will refer to the same object. Changing the value
  # of the attribute of one instance will change the value of the
  # attribute of the other instance.
  c3 = C()
  c4 = c3
  c3.value = 20
  print(c3.value)  # Displays 20.
  print(c4.value)  # Also displays 20.
  c4.value = 10
  print(c4.value)  # Displays 10.
  print(c3.value)  # Also displays 10.

  # Classes can also have class attributes. A class attribute is an
  # attribute that is associated with the class itself rather than
  # any particular instance of the class. A class attribute is defined
  # outside the constructor. It is accessed using the class name.
  class D:  # pylint: disable=too-few-public-methods
    """
      This is a class with a class attribute.
    """
    # Class attributes are defined outside the constructor.
    # They are accessed using the class name.
    value: ClassVar[str] = 'd'

  # Class attributes are accessed using the class name.
  # No instance is required.
  print(D.value)  # Displays d

  # Here's foot-gun that you want to avoid. It is possible to access
  # a class attribute via an instance of the class. But this can lead
  # to confusion.
  # For example:
  d = D()
  # You can access the class attribute via the instance.
  # The following print 'd' as expected:
  print(d.value)  # Displays d.
  # But if you change the value of the attribute via the instance,
  # you are not changing the class attribute. Instead, you are creating
  # a new instance attribute that shadows the class attribute.
  # Note that mypy will warn you about using an instance to access
  # class variable. To supress this for the purpose of demonstration
  # the type: ignore directive is used. This is not recommended in
  # production code.
  # Also note the noinspection directive to suppress the warning about
  # accessing a class attribute via an instance. This tells IntelliJ
  # IDEA not to warn about this for this demonstration. Once
  # again this is not recommended in production code.
  # noinspection PyClassVar
  d.value = 'e'  # type: ignore
  print(d.value)  # Displays e.
  # The class attribute is still 'd'.
  print(D.value)  # Displays d.
  # In general avoid accessing class attributes via instances. It can
  # lead to confusion.

  # Classes can have methods. The constructor __init__ described above
  # is a special method. (More on special methods later) Methods are
  # functions that are associated with a class. Methods are defined
  # inside the class definition. Methods are accessed using the dot
  # operator. Methods can take arguments and return values. Methods
  # can also modify the state of an object.
  # There are 3 kinds of methods in python:
  # 1. Instance methods: These methods are the ones described above.
  #    They act on instances of the class and can access and modify the
  #    state of the object. They take self, a reference to the object
  #    that method is acting on as the first argument.
  # 2. Class methods: These methods are associated with the class
  #    itself rather than any particular instance of the class. They
  #    take cls, a reference to the class that the classmethod is
  #    acting on, as the first argument. They are defined using the
  #    @classmethod decorator. Decorators will be described in more
  #    detail later.
  #    They are used when you want to define a method that is logically
  #    associated with a class but does not need access to any
  #    particular instance of the class. A good example would be a
  #    class method that returns the number of instances of the class
  #    that have been created.
  # 3. Static methods: These methods are not associated with any particular
  #    instance of the class or the class itself. They are defined using the
  #    @staticmethod decorator. They do not take self or cls as the first
  #    argument. They are used when you want to define a method that is
  #    logically associated with a class but does not need access to the
  #    class or any of its instances. A good example would be a static
  #    method that creates new instances of the class based on some input.

  class E:  # pylint: disable=too-few-public-methods
    """
      This is a class with some methods and a constructor.
    """
    # This is a class attribute that keeps track of the number of
    # instances created.
    # Note the use of ClassVar to indicate to mypy that this is a
    # class attribute. This will cause mypy to warn if you try to
    # access this attribute via an instance of the class.
    instances_created: ClassVar[int] = 0  # Initialized to zero.

    def __init__(self, value: str) -> None:
      """
        This is a constructor of class E. It is called when an object
        of class E is created. The self argument is automatically passed
        to this method by the python interpreter, so that it has access
        to the object being constructed. There is no need to explicitly
        pass the self object.

        For purposes of illustration this constructor takes a single
        argument called value. The value argument is used to
        initialize the value attribute of the object.

        In addition, for this example, the class attribute
        instances_created is incremented by one to indicate the
        creation of a new instance of the class.

        Note that if an explicit constructor is not defined, Python
        provides a default constructor that takes no arguments. Which
        is why you could create objects of previous classes like this:
        a = ClassA()

        Note that by convention we do not annotate the self parameter.
        Nor do we describe the self parameter in documentation, since
        it is obvious from the context that it refers to the object
        being acted upon. This convention applies to all methods.

        :param value: Initialize the value attribute of the object with
                     this.
      """
      # Value is an instance attribute. It is associated with the object
      # being created. It is initialized to the value passed to the
      # constructor.
      self.value: str = value
      E.instances_created += 1

    def __del__(self) -> None:
      """
        This is a destructor of class E. It is called when an object
        of class E is deleted. The self argument is automatically passed
        to this method by the python interpreter, so that it has access
        to the object being destroyed. There is no need to explicitly
        pass the self object.

        Note that the __del__ method is not normally needed unless
        you need to do some cleanup, like closing files, or in this case
        decrementing instance counts, when an object is deleted.

        For purposes of illustration this destructor decrements the
        class attribute instances_created by one to indicate the
        deletion of an instance of the class.

        :return: None
      """
      E.instances_created -= 1

    def change_value(self, value: str) -> None:
      """
        Set change the value property to the given value.
        :return: None
      """
      # Self refers to the object that the method is called on.
      self.value = value

    def repeated_value(self, repeat: int) -> str:
      """
      This is a method of class E that takes an argument.
      :return: None
      """
      return self.value * repeat

    @classmethod
    def instances(cls) -> int:
      """
        This is a class method of class E. It returns the number of
        active instances of the class. Note the use of the
        @classmethod decorator. This decorator indicates that this
        is a class method. The cls argument is automatically passed
        to this method by the python interpreter, so that it has
        access to the class that the method is acting on.

        This method simply returns the value of the instances_created
        variable.

        :return: The number of instances of class E that have been created.
      """
      return cls.instances_created

    @staticmethod
    def make_e(int_value: int) -> E:
      """
        This is a static method of class E. It returns an instance of
        class E. Note the use of the @staticmethod decorator. This
        decorator indicates that this is a static method. Static methods
        do not take self or cls as the first argument. They are used
        when you want to define a method that is logically associated
        with a class but does not need access to the class or any of
        its instances.

        This code uses the import from __future__ import annotations
        to get around the limitation of forward references. The type
        E is not yet fully defined. The traditional solution would be
        to use a string 'E' as the type hint. The from __future__ import
        annotations directive allows you to use E as a type hint.
      """
      str_value = str(int_value)
      return E(str_value)

  e = E('e')  # This calls the constructor of class E.
  e.value = 'e'
  print(f'e.value = {e.value}')  # Displays e
  e.change_value('f')
  print(f'e.value = {e.value}')  # Displays f
  print(f'e.repeated_value(3) = {e.repeated_value(3)}')  # Displays fff

  print('E.instances() = {E.instances()}')  # Displays 1
  # Let's create a few instances to increase the count.
  e1 = E('e1')
  print(f'e1.value = {e1.value}')  # Displays e1
  e2 = E('e2')
  print(f'e2.value = {e2.value}')  # Displays e1
  e3 = E('e3')
  print(f'e3.value = {e3.value}')  # Displays e1
  print(f'E.instances() = {E.instances()}')  # Displays 4

  # Demonstrate the calling of the destructor.
  # We create a new instance of E called e4. Which
  # increments the instance count to 5. Then we
  # delete the instance by calling del, which reduces
  # the instance count back to 4.
  e4 = E('e4')
  print(f'e4.value = {e4.value}')  # Displays e4
  print(f'Before del: E.instances() = {E.instances()}')  # Displays 5
  del e4  # force delete.
  print(f'After del: E.instances() = {E.instances()}')  # Displays 4

  # Demonstrates static method:
  e5 = E.make_e(5)
  print(f'e5.value = {e5.value}')  # Displays 5

  # Private name mangling
  # Python does not have private variables in the same sense as
  # other languages like Java or C++. However, Python does have
  # a mechanism called name mangling that allows you to create
  # variables that are not easily accessible from outside the class.
  # Name mangling is done by prefixing the variable name with two
  # underscores. This causes the variable name to be mangled by
  # adding the class name to the variable name. This makes it
  # difficult to access the variable from outside the class.
  # Here is an example:
  class G:  # pylint: disable=too-few-public-methods
    """
      This is a class with a private variable.
    """
    def __init__(self) -> None:
      """
        Constructor of class G.
        :return: None
      """
      # This is a private variable. It is not accessible from outside
      # the class.
      self.__private_value: str = 'private value'

    def get_private_value(self) -> str:
      """
        Return the value of the private variable.
        :return: The value of the private variable.
      """
      return self.__private_value

    def set_private_value(self, value: str) -> None:
      """
        Set the value of the private variable.
        :return: None
      """
      self.__private_value = value

  g = G()
  # This will raise an AttributeError because the private variable
  # cannot be accessed from outside the class.
  try:
    # noinspection PyUnresolvedReferences
    print(g.__private_value)  # pylint: disable=protected-access
  except AttributeError as e:
    print(f'AttributeError: {e}')

  # Assigning to the private variable will not raise an error.
  # But will create a new instance variable that shadows the private
  # variable. This can be very confusing. DO NOT assign to private
  # variables from outside the class.
  g.__private_value = 'new value'  # pylint: disable=protected-access
  print(g.get_private_value())  # Displays private value
  # noinspection PyUnresolvedReferences
  print(g.__private_value)  # Displays new value # pylint: disable=protected-access

  # All the classes defined above are defined at function scope. This
  # means that they are only available within the explore_class_basics
  # function. If you try to access any of these classes outside the
  # function, you will get a NameError.
  #
  # But class D is defined at module scope. This means that it is available
  # throughout the module. You can access class D from anywhere in the
  # module.
  f = F()
  print(f)  # Displays <class_basics.D object at 0xmemoryaddress>
  print(f.value)  # Displays d


def explore_inheritance() -> None:
  """
    Explore inheritance in Python
    :return: None
  """
  # Inheritance is a mechanism by which a class can inherit
  # attributes and methods from another class. The class that
  # is inherited from is called the base class or superclass.
  # The class that inherits from the base class is called the
  # derived class or subclass. Inheritance is defined using
  # the following syntax:
  class Person:  # pylint: disable=too-few-public-methods
    """
      A representation of a person.
    """
    def __init__(self, first_name, last_name, age, email) -> None:
      """
        Constructor of the base class.
        :param str first_name: First name of the person.
        :param str last_name: Last name of the person.
        :param int age: Age of the person.
        :param str email: Email of the person.
        :return: None
      """
      self.first_name = first_name
      self.last_name = last_name
      self.age = age
      self.email = email

    def full_name(self) -> str:
      """
        Return the full name of the person.
        :return: The full name of the person.
      """
      return self.first_name + ' ' + self.last_name

    def greet(self) -> str:
      """
        Return a greeting.
        :return: A greeting.
      """
      return f'Hello, my name is {self.full_name()}. ' \
          + f'I am {self.age} years old. You can contact me at {self.email}.'

  class Employee(Person):  # pylint: disable=too-few-public-methods
    """
      A representation of an employee.
    """
    def __init__(  # pylint: disable=too-many-arguments
      self,
      first_name: str,
      last_name: str,
      age: int,
      email: str,
      job: str) -> None:
      """
        Constructor of the derived class.
        :return: None
      """
      # Call the constructor of the base class.
      super().__init__(first_name, last_name, age, email)
      self.job = job

    def greet(self) -> str:
      """
        Method of the derived class.
        :return: The value attribute of the object.
      """
      return super().greet() + f' I work as a {self.job}.'

  # Create an instance of the Employee class
  employee1 = Employee('Alice', 'Smith', 30, 'alice@example.com', 'Software Engineer')
  print(employee1.greet())


if __name__ == '__main__':
  explore_class_basics()
  explore_inheritance()
