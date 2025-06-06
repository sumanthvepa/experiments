#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  language.py: Exploring Python.

  This is the top-level driver code for my exploration of python.
"""
# -------------------------------------------------------------------
# language.py: Explore strings in Javascript
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
import sys

import booleans
import comments
import printing
import constants
import variables
import strings_and_bytes
import number_literals
import none_not_implemented
import class_basics
import class_basics2
import properties
import sequences
import operators
import control_flow
import functions
import enumerations
import dynamic_typing
import metaclasses
import abstract_base_classes
import data_classes
import advanced_class_concepts
import protocol_mixins
import exceptions_and_context_managers
import generators
import async_await

print('Exploring Python')

# This is the top-level driver code for a series of notes/tutorials
# an exploration of the python language.

# Project Setup
# This project depends on some third party packages installed with
# pip. To recreate the environment first create the venv if it
# does not already exist:
# 1. python3 -m venv venv

# Then install the required packages
# 2. python3 -m pip install -r requirements.txt

# TODO: Explain how to upgrade a python package

# These notes are written as a series of heavily commented python files.
# Each file explores a different aspect of the Python language. The files
# organized as follows:
# 1. language.py: This file describes setting up your environment for
#   Python development, some general notes on the language, and then
#   calls other files that explore specific aspects of the language.

# For more information on the Python Programming Language refer to the
# following resources:
# 1. Python 3 Documentation: https://docs.python.org/3/
# 2. Python 3 Tutorial: https://docs.python.org/3/tutorial/index.html
# 3. The Python Language Reference: https://docs.python.org/3/reference/

# The Shebang Line
# Note the #! line at the top of the file. This is called a shebang
# line, and it tells the operating system to use the python3.
# I use the env trampoline to find the python3 executable. This is
# useful because it allows me to run the script on different systems
# where python3 might be installed in different locations.

# Encoding Declaration
# The second line is the encoding declaration. This tells the python
# interpreter that the source code is encoded in utf-8. This is
# important because python 3 uses Unicode strings by default. The
# encoding declaration allows you to use Unicode characters in your
# source code.
# The encoding declaration is optional, if no encoding is specified,
# Python assumes UTF-8. Some UTF-8 files may start with a UTF-8 byte
# order mark. Python will ignore this if it is present when the
# encoding is considered to be UTF-8. Otherwise, an error will be
# signalled.

# Setting up the Environment
# I first create a directory for the python project I want to work on.
# One directory per project. A project here refers to an IntelliJ
# IDEA project, but it more generally refers to a collection of files
# that are related, when built, will result in a single executable/
# process or library.
#
# I use python's venv module to create a virtual environment for my
# projects. This allows me to create a clean environment for each
# project, and to install dependencies without affecting the global
# python installation. To create a virtual environment, use the
# following commands:
# $ python3 -m venv venv
# $ source venv/bin/activate
# This creates a virtual environment in the venv directory, and
# activates it. You can deactivate the virtual environment by using
# the command:
# $ deactivate
# Add the venv directory to your .gitignore file to avoid checking
# it into version control.

# I primarily use IntelliJ IDEA for my python development. You need to
# have the Python plugin installed.

# I typically DO NOT create a Python project in IntelliJ IDEA. I just
# open the directory containing the venv. Then I go to File -> Project
# Structure -> Project Settings -> Project -> Project SDK and select
# the python interpreter in the venv. Look in the venv/bin directory
# for the python3 executable.

# I then edit run configurations to run the python script. The exact
# steps depend on the type of project. For a simple script, I just
# choose Python when adding a new configuration, then pick the python
# interpreter for the venv, and specify the script to run.

# A Python program consists of a sequence of logical lines. A logical
# line is a sequence of characters that end with the NEWLINE token.
# Note that not every newline sequence (\n \r\n or \r) is considered
# a NEWLINE token, because some newline sequences may be escaped or
# occur in a context where they are either considered whitespace or
# part of a string. There is no need for semicolons to terminate
# a statement.

# Comments in Python start with a hash and end with a newline sequence.
# Comments can be on their own line or at the end of a line of code.
# Blank lines, or lines with only comments, are ignored by the interpreter.


# Python famously uses indentation to define blocks of code.

# It is a modern convention to define a main function.
# Python itself does not require it.
def main():

  # It is a modern convention to define a main function.
  # Python itself does not require it.
  """
    This is the main function for the exploration of Python.
    :return: None
  """
  print('This is a block of code')
  print('This is also part of the block')
  print('This is the last line of the block')

  # A Note on PyLint and MyPy:
  # PyLint is a static code analysis tool for Python that checks for
  # errors in Python code. It checks for errors such as syntax errors,
  # unused variables, and other common programming errors. PyLint is
  # useful for catching errors early in the development process.

  # I use PyLint in the following way:
  # I install the pylint package within the virtual environment by using
  # pip.
  # $ python -m pip install pylint

  # I use a standard configuration file for PyLint. This file called
  # pylintrc is placed in the root directory of the project (The root
  # as it appears to IntelliJ IDEA.)
  # A default pylintrc file can be generated by running the following
  # command:
  # pylint --generate-rcfile > pylintrc
  # There are two differences in the pylintrc file from the default
  # one:
  #
  # The first is that I set the indentation level to 2 spaces. This
  # is achieved by setting the indent-string option to '  '
  #
  # The second is that it modifies sys.path of the pylint process
  # to include the root directory of the project. This is necessary
  # because PyLint when run via a plugin in IntelliJ IDEA does not
  # include the root directory in sys.path. This causes PyLint to
  # report import errors for modules in the project.

  # I run PyLint from the command line using the following command:
  # pylint filename.py
  # This will run PyLint on the specified file and output any errors.

  # However,the most common way I use PyLint is through the IntelliJ IDEA
  # plugin. The plugin will automatically run PyLint on the file when
  # you save it. The plugin will highlight any errors in the code and
  # provide suggestions for how to fix them.

  # To use the plugin, you need to install it from the IntelliJ IDEA
  # plugin repository. Make sure you've modified the pylintrc file as
  # described above.

  # To suppress pylint warnings. You can use the following directives:
  # \p\y\l\i\n\t: disable=<pylint-short-error-name>
  # This comment should be placed on the line that generates the error.
  # The escape characters are to prevent pylint from treating this
  # instruction itself as a directive. The short error name will be
  # displayed in the pylint output. For example, to suppress the
  # 'invalid-name' error, you would use the following directive:
  # \p\y\l\i\n\t: disable=invalid-name

  # A Note on Type Annotations and MyPy:
  # I also use MyPy, a static type checker for Python. MyPy is useful
  # for improving type safety in Python code. You can use MyPy by
  # adding type annotations to your code, and then running MyPy to
  # check for type errors. MyPy can catch type errors at compile time,
  # See the greeting function below with type annotations for both the
  # input parameters and the return type.
  # For details see MyPy documentation. https://mypy.readthedocs.io/en/stable/
  # and the Python typing specification: https://typing.readthedocs.io/en/latest/spec/

  # Note that MyPy will only check code that has type annotations. In
  # particular, if a function has no type annotations, MyPy will not
  # check anything inside the function. This is why I have added type
  # annotations to all the function signatures in the code.

  # To supress mypy warnings. You can use the following directives:
  # # \t\y\p\e: ignore[error-name]
  # This comment should be placed on the line that generates the error.
  # The escape characters are to prevent mypy from treating this
  # instruction itself as a directive. The error name will be displayed
  # in the mypy output. For example, to suppress the 'assignment' error,
  # you would use the following directive:
  # # \t\y\p\e: ignore[assignment]

  # IntelliJ IDEA runs mypy with default settings. To get more extensive
  # checking, you can run mypy from the command line with additional
  # options. I use the following command:
  # $ mypy --extra-checks --strict filename.py

  # A Note on Python Coding Style:
  # I follow PEP 8, the official Python coding style guide, with
  # one exception. I use two spaces for indentation instead of four.
  # Pylint checks for PEP8 compliance. I also generally confirm to
  # Google's Python Style Guide:
  # https://google.github.io/styleguide/pyguide.html

  def greeting(name: str) -> str:
    """
      Return a greeting for the given name.
    :param name: The name you wish to greet.
    :return: A string that says hello to the given name.
    """
    return 'Hello ' + name

  greeting('Sumanth')
  print(sys.path)

  # Note 0: Explore Comments
  # Note that the comments module is imported at the top of this file.
  comments.exploring_comments()

  # Note 1: Explore Printing to console
  # Note that the printing module is imported at the top of this file.
  printing.explore_printing()

  # Note 2: Explore constants
  # Note that the constants module is imported at the top of this file.
  # Importing a module allows the importing code to access all constants
  # defined in the module.
  print(constants.PI)

  # The only exception are constants that start with a single underscore.
  # By convention these are considered private to the module.
  # Python itself will execute the code below without complaint, but
  # pylint will warn about access to a protected member of a module.
  # For this demonstration, I have disabled the pylint warning as well
  # as the IntelliJ IDEA warning.
  # pylint: disable=protected-access
  # noinspection PyProtectedMember
  print(constants._PRIVATE_CONSTANT)

  # Note 3: Explore variables
  # Note that the variables module is imported at the top of this file.
  # Variables are accessed the same way as constants. Note that the
  # name of the module has to be prepended if you don't explicitly
  # import the variable using a from x import y statement.
  print(variables.global_variable_a)
  variables.print_global_variable_a()  # prints 'This is a global variable'

  # Of course change an imported variable
  variables.global_variable_a = 'This is a new value for the global variable'
  variables.print_global_variable_a()  # prints 'This is a new value for the global variable'

  # Explore changing variables in functions
  variables.explore_variables()

  # Note 4: Explore numbers
  number_literals.explore_integer_literals()
  number_literals.explore_floating_point_literals()
  number_literals.explore_complex_literals()

  # Note 5: Explore strings
  strings_and_bytes.explore_string_literals()
  strings_and_bytes.explore_formatted_string_literals()
  strings_and_bytes.explore_raw_string_literals()
  strings_and_bytes.explore_byte_string_literals()
  strings_and_bytes.explore_string_comparisons()

  # Note 6: Explore boolean literals
  booleans.explore_boolean_literals()

  # Note 7: Explore None and NotImplemented
  none_not_implemented.explore_none()
  none_not_implemented.explore_not_implemented()

  # Note 8: Explore sequences
  sequences.explore_sequences()

  # Note 9: Explore operators
  operators.explore_operators()

  # Note 10: Explore control flow
  control_flow.explore_control_flow()

  # Note 11: Explore functions
  functions.explore_functions()

  # Note 12: Explore class basics
  class_basics.explore_class_basics()
  class_basics.explore_inheritance()

  # Note 13: Explore dunder methods
  class_basics2.explore_dunder_methods()

  # Note 14: Explore properties
  properties.explore_properties()

  # Note 15: Explore enums
  enumerations.explore_enumerations()

  # Note 16: Explore dynamic typing
  dynamic_typing.explore_dynamic_type_creation()

  # Note 17: Explore metaclasses
  metaclasses.explore_metaclasses()

  # Note 18: Explore abstract base classes
  abstract_base_classes.explore_abstract_base_classes()

  # Note 19: Explore Dataclasses
  data_classes.explore_dataclasses()

  # Note 20: Explore advanced class concepts
  advanced_class_concepts.explore_slots()

  # Note 21: Explore protocol mixins
  protocol_mixins.explore_protocol_mixins()

  # Note 22: Explore exceptions
  exceptions_and_context_managers.explore_exceptions()
  exceptions_and_context_managers.explore_exception_chaining()
  exceptions_and_context_managers.explore_context_managers()

  # Note 23: Explore generators
  generators.explore_generators()

  # Note 24: Explore async/await and asyncio
  async_await.explore_async_await()

  # Future explorations
  # Note: Explore MRO and multiple inheritance
  # Note: Explore tuples
  # Note: Explore named tuples
  # Note: Explore lists
  # Note: Explore arrays
  # Note: Explore sets
  # Note: Explore decorators
  # Note: Explore context managers
  # Note: Explore descriptors
  # Note: Explore generators, yield, coroutines, and async/await
  # Note: Explore __getattr_,  __setattr__ and __delattr__ and the attrs module
  # Note: Explore functools module
  # Note: Explore weak references


# The following line is a common idiom in Python. It tells the interpreter
# to run the main function if this file is executed as the main program.
# This allows the file to be imported as a module without running the main
# function.
if __name__ == '__main__':
  main()
