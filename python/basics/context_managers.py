#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  context_managers.py: Explore context managers
"""
# -------------------------------------------------------------------
# context_managers.py: Explore context managers
#
# Copyright (C) 2024-25 Sumanth Vepa.
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
from __future__ import annotations
import copy
import os
import types

from contextlib import contextmanager
from typing import Generator, Self, Type


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

    def __enter__(self) -> Self:
      """
        Called upon entry into a code block
        :return: The code block
      """
      print(f'Entering block {self.name}')
      return self

    def __exit__(
      self,
      exc_type: Type[BaseException] | None,
      exc_val: BaseException | None,
      exc_tb: types.TracebackType) -> None:
      """
        Handle exit from a with block.
        The parameters indicate how the block was exited.
        If exit was due to an exception, the parameters
        exc_type, exc_val, and exc_tb will be set to non-None
        values. If the block exited normally, these parameters
        will be none.

        This method can do any clean up that is needed when the
        with block exits.

        :param exc_type: The exception type or None if no exception
        was raised.
        :param exc_val: The exception value
        :param exc_tb: The exception traceback
        :return: None  Context manager __exit__() method return
        values could be either a boolean or None.
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
  # contextmanager decorator from the 'contextlib' module. This is
  # a more concise, way of defining a context manager.
  # The contextmanager decorator is a generator-based approach
  # to defining context managers. The generator yields the resource
  # that should be managed and is responsible for cleaning up the
  # resource when the block of code exits.
  # The contextmanager decorator is useful when you want to define
  # a context manager as a function rather than a class.
  # Here is an example of a context manager defined using the
  # contextmanager decorator.

  # Note the return type of the context manager is a Generator.
  # A Generator type indicates that the function is a generator
  @contextmanager
  def code_block(name: str) -> Generator[None, None, None]:
    """
      A simple context manager defined using the contextmanager decorator
      :param name: The name of the code block
      :return: Generator[None, Any, None]
    """
    print(f'Entering block {name}')
    try:
      yield
    finally:
      print(f'Exiting block {name}')

  with code_block('block3'):
    print('Inside block')

  # You can yield a resource created within the context manager to
  # the code block gated by it. For example, you want to create handle
  # to a resource and return it to the code block. The resource is
  # cleaned up when the code block exits.
  @contextmanager
  def resource_manager(name: str) -> Generator[dict[str, str], None, None]:
    """
      A context manager that manages a resource
      :param name: The name of the resource.
      :return: The resource
    """
    print(f'Creating resource {name}')
    a_resource = {'name': name}
    try:
      yield a_resource
    finally:
      print(f'Cleaning up resource {name}')
      del a_resource

  # We can use the resource manager context manager to create a
  # resource and use it in the code block. The resource is cleaned
  # up when the code block exits.
  with resource_manager('resource1') as resource:
    print(f'Using resource {resource["name"]}')
    # Do something with the resource
    resource['name'] = 'new_resource1'
    print(f'Using resource {resource["name"]}')


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

  def add(self, task: str) -> int:
    """
      Add a task to the TODO list
      :param task: The task to add
    """
    index = len(self.tasks) + 1
    self.tasks.append(f'{index}: {task}')
    return index

  def remove(self, index: int) -> None:
    """
    Remove a task from the TODO list
    :param index:
    :return:
    """
    del self.tasks[index]

  def save(self, filename: str) -> None:
    """
      Save the TODO list to a file
    """
    with open(filename, 'w', encoding='UTF-8') as file:
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

  @staticmethod
  def save_task(task: str, index: int, filename: str) -> None:
    """
      Save a task to the TODO list and return the index of the task
      :param task: The task to save
      :param index: The index of the task in the TODO list
      :param filename: The name of the file to save the task to
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
      Committer.save_task(task, task_index, tmp_commit_filename)
      working_copy.save(tmp_todo_filename)
      os.rename(tmp_commit_filename, self.commit_filename)
      os.rename(tmp_todo_filename, self.todo_filename)
      self.todo = working_copy
    except (OSError, ValueError, TypeError) as ex:
      remove_file_silent(self.commit_filename)
      remove_file_silent(tmp_commit_filename)
      remove_file_silent(tmp_todo_filename)
      raise ex


def explore_two_phase_commit() -> None:
  """
    Explore two-phase commit
    :return: None
  """
  print(os.getcwd())
  original_todo = TodoList.load('todo.txt')
  try:
    committer = Committer('todo.txt', 'commit.log')
    committer.commit('Do the dishes')
  finally:
    os.remove('commit.log')
    original_todo.save('todo.txt')


if __name__ == '__main__':
  explore_context_managers()
  explore_two_phase_commit()
