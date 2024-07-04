#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  dynamic_typing.py: Exploring dynamic typing in Python
"""
# -------------------------------------------------------------------
# dynamic_typing.py: Exploring dynamic typing in Python
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

from typing import Any, List


def explore_dynamic_type_creation() -> None:  # pylint: disable=too-many-locals
  """
    Explore dynamic type creation in Python
    :return: None
  """
  # You can create classes dynamically in Python. This is useful
  # when you need to create classes at runtime. You can create
  # classes using the type function. The type function takes three
  # arguments: the name of the class, a tuple of base classes, and
  # a dictionary of attributes. The name of the class is a string
  # that is the name of the class. The tuple of base classes is a
  # tuple of classes that the new class inherits from. The dictionary
  # of attributes is a dictionary that contains the attributes and
  # methods of the new class. The keys of the dictionary are the
  # names of the attributes and methods, and the values are the
  # values of the attributes and methods.
  # Here is an example that creates a class called Person that
  # inherits from the base class object and has four attributes:
  # first_name, last_name, age, and email. The class also has a
  # method called greet that returns a greeting.
  def init_person(self, first_name, last_name, age, email) -> None:
    """

      :return: None
    """
    self.first_name = first_name
    self.last_name = last_name
    self.age = age
    self.email = email

  def greet(self):
    """
      Return a greeting.
      :return: A greeting.
    """
    return f'Hello, my name is {self.first_name} {self.last_name}. ' \
        + f'I am {self.age} years old. You can contact me at {self.email}.'

  # The class is created using the type function.
  # This is equivalent to the following class definition. In fact
  # the class syntax is nothing but syntactic sugar for the type
  # function.
  # class Person(object):
  #  def __init__(self, first_name, last_name, age, email):
  #   self.first_name = first_name
  #   self.last_name = last_name
  #   self.age = age
  #   self.email = email
  #
  #  def greet(self):
  #   return f'Hello, my name is {self.first_name} {self.last_name}. '
  #     + f'I am  {self.age} years old. You can contact me at {self.email}.'
  # noinspection PyPep8Naming
  Person = type('Person', (object,), {
    'first_name': '',
    'last_name': '',
    'age': 0,
    'email': '',
    '__init__': init_person,
    'greet': greet})
  person1 = Person('Alice', 'Smith', 30, 'alice@example.com')
  print(person1.greet())

  # You can also create derived classes dynamically.
  def init_employee(  # pylint: disable=too-many-arguments
    self, first_name: str, last_name: str, age: int, email: str, job: str) -> None:
    """
      Constructor for the derived Employee class.
      :return: None
    """
    # noinspection PyArgumentList
    Person.__init__(self, first_name, last_name, age, email)  # type: ignore
    self.job = job

  def employee_greet(self) -> str:
    """
      Return a greeting.
      :return: A greeting.
    """
    return f'Hello, my name is {self.first_name} {self.last_name}. ' \
        + f'I am {self.age} years old. You can contact me at {self.email}. ' \
        + f'I am a {self.job}.'

  # noinspection PyPep8Naming
  Employee = type(
    'Employee',
    (Person,),
    {
      'job': '',
      '__init__': init_employee,
      'greet': employee_greet
    })

  bob = Employee('Bob', 'Jones', 40, 'bob@example.com', 'Product Manager')
  print(bob.greet())
  susan = Employee('Susan', 'Brown', 35, 'susan@example.com', 'Senior Software Engineer')

  # You can create the functions themselves dynamically.
  # To stop MyPy which is a static type checker, and hence
  # cannot deal with dynamic typing, from complaining, we
  # use the List[Any] type annotation for the direct_reports
  # parameter. Since Employee is not a type at compile time
  # when mypy is doing its type checking, we cannot use it.
  def init_manager(  # pylint: disable=too-many-arguments
    self,
    first_name: str,
    last_name: str,
    age: int,
    email: str,
    department: str,
    direct_reports: List[Any]) -> None:
    """
      Constructor for the derived Manager class.
      :return: None
    """
    Employee.__init__(  # type: ignore
      self, first_name, last_name, age, email, f'Manager of {department}')
    self.department = department
    self.direct_reports = direct_reports

  # noinspection PyPep8Naming
  Manager = type(
    'Manager',
    (Employee,),
    {
      'department': '',
      'direct_reports': [],
      '__init__': init_manager
    })
  charlie = Manager('Charlie', 'Brown', 50, 'charlie@example.com', 'Engineering', [bob, susan])
  print(charlie.greet())
  print(f'Introducing {charlie.first_name}\'s direct reports:')
  for employee in charlie.direct_reports:
    print(employee.greet())

  # Classes can be created even more dynamically, by defining the
  # body of the class as a string and then using the exec function
  # to execute the string as Python code.
  # The namespace passed to the exec function is a dictionary that
  # contains the names of the variables and functions that are
  # defined as part of the class. The type.__prepare__ function
  # is used to create the namespace for the class.
  # Note the use of triple quotes to define the string that contains
  # the body of the class. This allows you to use single and double
  # quotes within the string without escaping them.
  # But you cannot indent the string. The string must be at the
  # beginning of the line.
  sales_person_class_name = 'SalesPerson'
  sales_person_class_bases = (Employee,)
  salesperson_class_namespace = type.__prepare__(sales_person_class_name, sales_person_class_bases)
  salesperson_class_body = '''
def sales_pitch(self):
  return 'Hello, my name is ' + self.first_name + ' ' + self.last_name + '. ' 'Do you want to buy something?'
'''
  # The exec function executes the code in the salesperson_class_body string
  # and adds the attributes and methods defined in the string to the namespace
  # pylint: disable=exec-used
  exec(
    salesperson_class_body,
    globals(),
    salesperson_class_namespace)

  # Finally type is called to create the SalesPerson class.
  # type: ignore
  # noinspection PyPep8Naming,PyTypeChecker
  SalesPerson = type(  # type: ignore
    sales_person_class_name,
    sales_person_class_bases,
    salesperson_class_namespace)

  # You can now create instances of the SalesPerson class.
  # and they will have the sales_pitch method.
  # You may have to disable the no-member pylint check since
  # the SalesPerson class  does not have a sales_pitch attribute
  # at compile time.
  joanne = SalesPerson('Joanne', 'Eastman', 25, 'jeastman@example.com', 'Sales Representative')
  print(joanne.greet())
  print(joanne.sales_pitch())  # pylint: disable=no-member

  # You can also entire create classes dynamically using the exec function.
  # E.g.:
  customer_class_code = '''
class Customer(Person):
  def __init__(self, first_name, last_name, age, email):
    super().__init__(first_name, last_name, age, email)
    
  def greet(self):
    return 'Hi there! I am ' + self.first_name \
      + '. Can you help me buy a widget?'
  '''
  # The exec function executes the code in the customer_class_code string
  # as Python code. The code defines a class called Customer that inherits
  # from the base class Person and has an __init__ method that initializes
  # the attributes of the class, and a greet method that returns a customized
  # greeting. Note that locals() is passed as the second argument to exec
  # so that the class is defined in the local namespace.
  exec(customer_class_code, globals(), locals())

  # But you cannot reference the class by its name in the code that follows
  # since the class does not actually exist at compile/parsing time.

  # Won't work. Class customer does not exist at compile time.
  # customer = Customer('David', 'Smith', 25, 'dsmith@example.com')

  # Instead, you can use the locals() function, which returns a dictionary
  # of local variables, to get a reference to the class by its name at runtime.
  cls = locals()['Customer']  # cls is a class object.
  # You can use it to create instances of the class.
  customer = cls('David', 'Smith', 25, 'dsmith@exmaple.com')

  # ...and it will have a customized greet method.
  print(customer.greet())

  # Dynamic typing is a very powerful feature. Use it wisely.


if __name__ == '__main__':
  explore_dynamic_type_creation()
