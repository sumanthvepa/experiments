#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  printing.py: Exploring printing to console in Python

  This is an exploration of the print function in Python.
"""
# -------------------------------------------------------------------
# printing.py: Exploring printing to console in Python
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


def explore_printing() -> None:
  """
  Explore printing to console in Python
  :return: None
  """
  # The print function in Python is used to print to the console.
  # This prints 'Hello, World!' to the console with a trailing newline.
  print('Hello, World!')

  # You can print pass multiple arguments to the print function.
  # By default, arguments are separated by a space.
  print('first', 1, 1.0, 'second', 2, 2.0)

  # You can change the separator between arguments using the
  # sep keyword argument.
  # This prints the arguments separated by a comma with a space
  # after it.
  print('third', 3, 3.0, 'fourth', 4, 4.0, sep=', ')

  # You can change the terminating string using the end keyword
  # argument. This terminates the print statement with a period.
  # and a newline.
  print('This is it', end='.\n')

  # You can combine the sep and end keyword arguments.
  # This prints the arguments separated by a comma with a space
  # after it and terminates the print statement with a period
  # and a newline.
  print('fifth', 5, 5.0, 'sixth', 6, 6.0, sep=', ', end='.\n')

  # You can print to stderr as follows:
  print('This is an error message', file=sys.stderr)

  # You can combine the sep and end keyword arguments with the file
  # keyword argument as follows.
  print('error1', 'error2', 'error3', sep=', ', end='.\n', file=sys.stderr)
