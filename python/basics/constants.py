#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  constants.py: Exploring constants in Python

  This is an exploration of how to define constants in Python.
"""
# -------------------------------------------------------------------
# constants.py: Exploring constants in Python
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
from typing import Final

# To be clear, Python does not have a built-in constant type. However,
#  the convention for defining constants in Python is to use all-caps.
#  This is a convention, not a requirement. The Python interpreter
#  does not enforce the immutability of variables with all-caps names.
PI = 3.14159  # No type or constant annotation here.

# But you can use type annotations to indicate to tools like mypy that
# the variable should not be reassigned. So, for example the type hint
# below indicates that the value PLANCK_CONSTANT is a float and should
# not be reassigned.
PLANCK_CONSTANT: Final[float] = 6.62607015e-34

# For details on the Final type annotation, see:
# https://stackoverflow.com/questions/2682745/how-do-i-create-a-constant-in-python
# Also take a look at PEP 591: https://peps.python.org/pep-0591/

# To avoid exporting a constant to other modules declare it with a
# leading underscore:
_PRIVATE_CONSTANT: Final[int] = 42
