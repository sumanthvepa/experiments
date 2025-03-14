#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  exceptions_and_context_managers.py: Explore exceptions
"""
import copy
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


def remove_file_silent(filename: str) -> None:
  """
    Remove a file silently
    :param filename: The name of the file
  """
  try:
    os.remove(filename)
  except (OSError, IOError, ValueError):
    pass


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
    self.unsaved_tasks: list[str] = []

  def add(self, task: str) -> int:
    """
      Add a task to the TODO list
      :param task: The task to add
    """
    self.unsaved_tasks.append(task)
    return len(self.tasks) + len(self.unsaved_tasks) - 1

  def remove(self, index: int):
    """
    Remove a task from the TODO list
    :param index:
    :return:
    """
    del self.tasks[index]

  def save(self, filename: str):
    """
      Save the TODO list to a file
    """
    try:
      os.rename(filename, f'{filename}.bak')
      with open(filename, 'w', encoding='UTF-8') as file:
        task_count = 1
        for task in self.tasks:
          file.write(f'{task_count}: {task}\n')
          task_count += 1
        for task in self.unsaved_tasks:
          file.write(f'{task_count}: {task}\n')
          task_count += 1
      self.tasks += self.unsaved_tasks
      self.unsaved_tasks = []
    except (OSError, IOError, ValueError) as ex:
      remove_file_silent(filename)
      os.rename(f'{filename}.bak', filename)
      raise ex
    finally:
      remove_file_silent(f'{filename}.bak')

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


class Committer:
  """
    A class to add tasks to a TODO and log the commit to a file.

    The key characteristic of this class is that either successfully
    modifies both the TODO list and the commit log file, or does not
    modify either.
  """
  def __init__(self, todo_filename: str, commit_filename: str) -> None:
    """
      Create a Committer instance
      :param todo_filename: The name of the TODO file
      :param commit_filename: The name of the commit log file
    """
    self.todo_filename = todo_filename
    self.commit_filename = commit_filename
    self.todo = TodoList.load(todo_filename)

  def save_task(self, task: str, index: int, filename: str) -> None:
    """
      Save a task to the TODO list and return the index of the task
      :param task: The task to save
      :param index: The index of the task in the TODO list
      :return: The index of the task
    """
    with open(filename, 'a', encoding='UTF-8') as file:
      try:
        file.write(f'Added task {index}: {task}\n')
      except (OSError, IOError, ValueError) as ex:
        remove_file_silent(filename)
        raise ex

  def commit(self, task: str) -> None:
    """
      Add a task to the TODO list and log the commit to a file
      :param task: The task to add
    """
    # The commit should atomically create two files: the commit log
    # and the updated todo list file.
    # If it fails to create either file, the original todo list file
    # should kept unchanged, and there should be no commit log file.
    # To accomplish this we create a working copy of the todo list.
    # We then add the task to the working copy and save the task to
    # a temporary commit log file. Then we save the working copy to
    # a temporary todo list file.
    # If all goes well we will rename the temporary commit log file
    # to the actual commit log file and the temporary todo list file
    # to the actual todo list file. If either rename fails, we will
    # remove any commit log file and temporary files created.
    # Only if all these steps succeed will we update the todo list
    # in memory to reflect the changes.
    # This is a two-phase commit protocol.
    working_copy = copy.deepcopy(self.todo)
    tmp_commit_filename = f'{self.commit_filename}.tmp'
    tmp_todo_filename = f'{self.todo_filename}.tmp'
    try:
      task_index = working_copy.add(task)
      self.save_task(task, task_index, tmp_commit_filename)
      working_copy.save(tmp_todo_filename)
      os.rename(tmp_commit_filename, self.commit_filename)
      os.rename(tmp_todo_filename, self.todo_filename)
      self.todo = working_copy
    except (OSError, ValueError, TypeError) as ex:
      remove_file_silent(self.commit_filename)
      remove_file_silent(tmp_commit_filename)
      remove_file_silent(tmp_todo_filename)
      raise ex
