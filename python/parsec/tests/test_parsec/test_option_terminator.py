"""
  test_option_terminator.py: Unit tests for class OptionTerminator
"""
# -------------------------------------------------------------------
# test_option_terminator.py: Unit tests for class OptionTerminator
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
import unittest

from parsec.option_terminator import OptionTerminator


class TestOptionTerminator(unittest.TestCase):
  """
    Unit tests for class OptionTerminator
  """

  def test_value(self) -> None:
    """
      Test the value of the option terminator.
    """
    terminator = OptionTerminator()
    self.assertEqual(None, terminator.value)


  def test_is_option(self) -> None:
    """
      Test the is_option method.
    """
    self.assertTrue(OptionTerminator.is_option('--', None))
    self.assertFalse(OptionTerminator.is_option('-h', None))


  def test_make(self) -> None:
    """
      Test the make method.
    """
    terminator, skip_next = OptionTerminator.make('--', None)
    self.assertIsInstance(terminator, OptionTerminator)
    self.assertEqual('-', terminator.flag)
    self.assertEqual(None, terminator.value)
    self.assertFalse(skip_next)
