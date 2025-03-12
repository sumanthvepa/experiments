#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  exceptions_and_context_managers.py: Explore exceptions
"""
# -------------------------------------------------------------------
# exceptions_and_context_managers.py: Explore exceptions
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
import os

from contextlib import contextmanager
from typing import Any, Generator


def explore_exceptions() -> None:
  """
    Explore exceptions
    :return: None
  """
  # Python exceptions typically inherit from the Exception class.
  # They are (for the most part *required* to inherit from BaseException)
  # But most user-defined exceptions inherit from Exception.

  # Strictly speaking you can raise a string as an exception,
  # as long as you don't catch a specific exception type.
  # So the following is valid, but not very useful or recommended:
  # noinspection PyBroadException
  try:
    # pylint: disable=raising-bad-type
    raise 'error'  # type: ignore
  except:  # pylint: disable=bare-except
    print('Caught a str exception')

  # In fact, you can raise any object as an exception, say an int,
  # but it has the same limitations as raising a string.
  # noinspection PyBroadException
  try:
    # pylint: disable=raising-bad-type
    raise 42  # type: ignore
  except:  # pylint: disable=bare-except
    print('Caught an int exception')

  # You can even raise a list as an exception, but again, it's not
  # recommended.
  # noinspection PyBroadException
  try:
    # pylint: disable=raising-bad-type
    raise [1, 2, 3]  # type: ignore
  except:  # pylint: disable=bare-except
    print('Caught a list exception')

  # You can directly raise an instance of the Exception class.
  # It is however recommended to raise an instance of a subclass of
  # Exception. So this works although it's not recommended.
  # It is also not recommended to catch an instance of Exception
  # directly or a bare exception with the except: clause.
  # Notice that you can now specify the type of the exception.
  # pylint: disable=broad-exception-caught
  try:
    # pylint: disable=broad-exception-raised
    raise Exception('This is an exception')
  except Exception as ex:
    print(f'Caught an exception: {ex}')

  # A more common way to raise an exception is to raise an instance
  # of a subclass of Exception. Here we raise a ValueError.
  try:
    raise ValueError('This is a ValueError')
  except ValueError as ex:
    print(f'Caught a ValueError: {ex}')

  # You can define your own exceptions by subclassing Exception.
  # Here we define a custom exception called MyException.
  class MyException(Exception):
    """
      Custom exception
    """
    def __init__(self, message: str) -> None:
      """
        Initialize the custom exception
        :param message: The message to display
      """
      super().__init__(message)

  # Now we can raise an instance of MyException.
  try:
    raise MyException('This is my exception')
  except MyException as ex:
    print(f'Caught my exception: {ex}')

  # You can layer exception handling to catch specific exceptions
  # before more general exceptions.
  try:
    raise ValueError('This is a ValueError')
  except ValueError as ex:
    # This will catch a ValueError
    print(f'Caught a ValueError: {ex}')
  except Exception as ex:
    # This will catch any other exception
    # But since value error is thrown, this block will not be executed
    print(f'Caught an Exception: {ex}')

  # You can also catch multiple exceptions in a single block.
  try:
    raise ValueError('This is a ValueError')
  except (ValueError, TypeError) as ex:
    # This will catch a ValueError or a TypeError
    print(f'Caught a ValueError or TypeError: {ex}')
  except Exception as ex:
    # This will catch any other exception
    # But since value error is thrown, this block will not be executed
    print(f'Caught an Exception: {ex}')

  # The 'finally' block is always executed, whether an exception is
  # raised or not. This is useful for cleanup code.
  try:
    raise ValueError('This is a ValueError')
  except ValueError as ex:
    print(f'Caught a ValueError: {ex}')
  finally:
    print('This is the finally block')


def explore_context_managers() -> None:
  """
    Explore context managers
    :return: None
  """
  # Context managers are objects that manage resources. They are
  # typically used to manage resources like files, network connections,
  # locks, etc. The context manager protocol is implemented using the
  # __enter__() and __exit__() methods.
  # This is an example of using a context manager that closes a file
  # automatically.
  with open('file.txt', 'w', encoding='UTF-8') as file:
    file.write('Hello, world!')

  with open('file.txt', encoding='UTF-8') as file:
    print(file.read())

  # Just clean up the created file.
  try:
    os.remove('file.txt')
  except FileNotFoundError:
    pass

  # You can define your own context manager by defining a class with
  # __enter__() and __exit__() methods. Here is an example of a simple
  # context manager that prints a message when entering and exiting.
  # This can be useful as a debugging tool to track entry and exit
  # into a block of code.
  class CodeBlock:
    """
      A simple context manager
    """
    def __init__(self, name: str):
      """
        Initialize the code block context manager
        :param name: The name of the code block
      """
      self.name = name

    def __enter__(self) -> 'CodeBlock':
      """
        Called upon entry into a code block
        :return: The code block
      """
      print(f'Entering block {self.name}')
      return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
      """
        Exit code block
        :param exc_type: The exception type
        :param exc_val: The exception value
        :param exc_tb: The exception traceback
      """
      print(f'Exiting block {self.name}')

  # Now we can use the code block context manager.
  # This really simple context manager can be useful as
  # a debugging tool to track entry and exit into a block
  # of code.
  with CodeBlock('block1') as block:
    print(f'Inside {block.name}')

  # Notice that it does not matter how you exit the
  # block, the __exit__() method is always called.
  # So you always know when the code block has exited.
  try:
    with CodeBlock('block2') as block:
      print(f'Inside {block.name}')
      raise ValueError('This is a ValueError')
  except ValueError as ex:
    print(f'Caught a ValueError: {ex}')

  # There is another way of defining a context manager using the
  # contextmanager decorator from the contextlib module. This is
  # a more concise way of defining a context manager.
  # The contextmanager decorator is a generator-based approach
  # to defining context managers. The generator yields the resource
  # that should be managed and is responsible for cleaning up the
  # resource when the block of code exits.
  # The contextmanager decorator is useful when you want to define
  # a context manager as a function rather than a class.
  # Here is an example of a context manager defined using the
  # contextmanager decorator.
  @contextmanager
  def code_block(name: str) -> Generator[None, Any, None]:
    """
      A simple context manager defined using the contextmanager decorator
      :param name: The name of the code block
      :return: None
    """
    print(f'Entering block {name}')
    try:
      yield
    finally:
      print(f'Exiting block {name}')

  with code_block('block3'):
    print('Inside block')


class TodoList:
  """
    A simple class to manage a TODO list
  """
  def __init__(self, tasks: list[str]):
    """
      Initialize the TODO list
      :param: tasks: The list of tasks
    """
    self.tasks = tasks

  def save(self):
    """
      Save the TODO list to a file
    """
    with open(self.filename, 'w', encoding='UTF-8') as file:
      for task in self.tasks:
        file.write(f'{task}\n')

  @classmethod
  def load(cls, filename: str) -> 'TodoList':
    """
      Load the TODO list from a file
      :param filename: The name of the file
      :return: The TODO list
    """
    tasks = []
    with open(filename, encoding='UTF-8') as file:
      for line in file:
        tasks.append(line.strip())
    return cls(tasks)
