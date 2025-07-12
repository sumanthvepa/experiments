#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  exception_handling.py: Explore exceptions
"""
# -------------------------------------------------------------------
# exception_handling.py: Explore exceptions
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


def explore_exception_chaining() -> None:
  """
    Explore exception chaining.

    :return: None
  """
  # Exception chaining is a way to raise a new exception while
  # preserving the original exception. This is useful for debugging
  # and logging.
  # You can use the 'from' keyword to chain exceptions.

  # Here we raise a ValueError, catch it and then raise
  # a MyException with the original exception as the cause.

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

  def raises_my_exception() -> None:
    """
      A function that raises a MyException
    """
    try:
      raise ValueError('This is a ValueError')
    except ValueError as my_ex:
      raise MyException('This is a MyException') from my_ex

  try:
    raises_my_exception()
  except MyException as an_ex:
    print(f'Caught a MyException: {an_ex}')
    print(f'Original exception: {an_ex.__cause__}')

  # You can also use the 'raise' statement with no exception to re-raise
  # the original exception. This is useful when you want to catch an
  # exception do some processing and then re-raise the original exception.
  # Here we catch a ValueError and then re-raise it.
  def re_raises_exception() -> None:
    """
      A function that raises a ValueError
    """
    try:
      raise ValueError('This is a ValueError')
    except ValueError as value_ex:
      print(f'Caught a ValueError: {value_ex}')
      raise  # Re-raise the original exception

  try:
    re_raises_exception()
  except ValueError as an_ex:
    print(f'Caught a ValueError: {an_ex}')


if __name__ == '__main__':
  explore_exceptions()
  explore_exception_chaining()