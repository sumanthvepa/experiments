#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  comments.py: Exploring comments in Python
"""
# -------------------------------------------------------------------
# comments.py: Explore comments in Python
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


def exploring_comments() -> None:
  """
  This function is used to explore comments in Python.
  This is a docstring. It is used to document the purpose of the function.
  Docstrings are used to document the purpose of a function, class, or module.
  They are enclosed in triple quotes. Docstrings are used by the help()
  function to display information about a function, class, or module.

  Note that a return type of None is specified. This is not necessary,
  for Python itself, but if not present will cause MyPy to skip
  type checking inside the function. This is because if no type
  annotation is present in a functions definition, Mypy assumes that
  it should not be type checked.

  :return: None
  """
  # Python uses the hash character to start a comment which ends with
  # a newline token. Comments are ignored by the Python interpreter.
  # This allows for the #! (shebang) line on the first line of the file.
  # Comments can be on their own line or at the end of a line of code
  print('Exploring comments in Python')
