"""
  test_command_line.py: Unit tests for the command_line module
"""
# -------------------------------------------------------------------
# test_command_line.py: Unit tests for the command_line module
#
# Copyright (C) 2023-25 Sumanth Vepa.
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
from typing import Any
import unittest

from test_parsec import CaseExecutor


class TestCommandLine(unittest.TestCase, CaseExecutor):
  """
    Unit tests for the CommandLine class and the parse function
  """
  def __init__(self, *args: Any, **kwargs: Any) -> None:
    """
      Initialize the test case.
    """
    unittest.TestCase.__init__(self, *args, **kwargs)
    CaseExecutor.__init__(self)

