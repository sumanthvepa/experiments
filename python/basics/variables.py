#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  variables.py: Exploring variables in Python

  This is an exploration on the usage of variables in Python.
"""
# -------------------------------------------------------------------
# variables.py: Exploring variables in Python
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

# Variables in Python are used to store data. Variables are created
# when a value is assigned to them. Variables can be assigned
# different types of data. Python is a dynamically typed language,
# which means that the 'type' of a variable is determined at runtime.

# In python variables are block scoped. And variables declared at
# file scope are global variables.

# So the following is a global variable. The ': str' is a type hint.
# Note that global variables are 'global' to module, not to the
# entire program. They are still local to the module.
global_variable_a: str = 'This is a global variable'
print(global_variable_a)

# You can change the value of a variable by reassigning it.
# Note the pylint disable directive. This is because pylint will
# complain about an invalid name for what it thinks is a constant.
# This is a global variable. So, it is okay to reassign it.
# However, pylint does not know that. So, we need to disable the
# warning.

# In general, it is not a good idea to use global variables.
# So this sort of situation should not occur.

# pylint: disable=invalid-name
global_variable_a = 'This is a new value for the global variable'
print(global_variable_a)

# Because we have used a type hint of str for global_variable_a
# attempting to assign a value of a different type will result in
# a type error from mypy:
# Mypy: Incompatible types in assignment (expression has type "int",
# variable has type "str")
# Note that you have remove the ignore directive for mypy to catch
# this error.
# Python itself won't complain. This code will run fine.
# The following #type: directive causes mypy to ignore the mypy
# assignment error described above.
global_variable_a = 2  # type: ignore[assignment]

# Changing types of variables is a common source of bugs in Python.
# Don't do it unless you have a good reason.


def explore_variables() -> None:
  """
    Explore variables in Python
    :return: None
  """
  # Since variables are block scoped, the following is a local
  # variable.
  local_variable_a = 'This is a local variable'
  print(local_variable_a)

  # Python itself will allow you to assign a value of a different
  # type to a variable. However, mypy will complain about it.
  # Mypy: Incompatible types in assignment (expression has type "int",
  # variable has type "str")
  # Mypy error!  It's suppressed for the sake of allowing the code to run
  # error free.
  local_variable_a = 2  # type: ignore[assignment]
  print(local_variable_a)

  # You can access the value of a variable in an outer scope
  # from within an inner scope. So value of local_variable_a
  # is available within print_local_variable_a.
  def print_local_variable_a() -> None:
    print(local_variable_a)
  print_local_variable_a()  # Will print 2

  # However, changing the value of a variable in an outer scope
  # requires some care. The following WILL NOT WORK as expected.
  def wrong_change_variable() -> None:
    # This assignment will create a new variable named
    # 'local_variable_a' that shadows the outer definition
    # This is usually NOT what you want.
    # Because we are doing this deliberately, we disable
    # IntelliJ warnings about shadowing.
    # noinspection PyShadowingNames
    local_variable_a: str = 'This is not the variable you are looking for'
    print('This version of local_variable_a has the value: ' + local_variable_a)

  def correct_change_variable() -> None:
    """
      This is an inner function that changes the value of
      local_variable_a in the outer function correctly.
      :return: None
    """
    # To change the value of a variable in an outer function
    # you have to first declare it as nonlocal.
    nonlocal local_variable_a
    local_variable_a = 'This has been changed from within the inner function'

  wrong_change_variable()
  print(local_variable_a)  # Will print 2

  correct_change_variable()
  print(local_variable_a)  # Will print 'This has been changed from within the inner function'


def wrong_change_global_variable() -> None:
  """
    Explore setting global variables in Python
    :return: None
  """
  # If you want to modify a global variable from within a function,
  # the following won't work as expected, for the same reason that not
  # declaring local_variable_a as nonlocal in wrong_change_variable
  # didn't work. The assignment will create a new variable named
  # global_variable_a that shadows the global definition.
  # Because we are doing this deliberately for demonstration
  # purposes, we disable both the pylint warnings about
  # redefined-outer-name and IntelliJ warnings about shadowing.
  # pylint: disable=redefined-outer-name
  # noinspection PyShadowingNames
  global_variable_a = 'This is not the global variable you are looking for'
  print(global_variable_a)


wrong_change_global_variable()
print(global_variable_a)  # Will print 2


def correct_change_global_variable() -> None:
  """
    Explore setting global variables in Python
    :return: None
  """
  # To change the value of a global variable from within a function,
  # you have to first declare it as global.
  # Pylint will still complain about using a global variable,
  # because it is generally not a good idea to use global variables.
  # So the following directive is needed to disable the warning.
  # pylint: disable=global-statement
  global global_variable_a
  global_variable_a = 'This has been changed from within the function'


correct_change_global_variable()
print(global_variable_a)  # Will print 'This has been changed from within the function'


def print_global_variable_a() -> None:
  """
    Print the global variable global_variable_a
    :return: None
  """
  print(global_variable_a)
