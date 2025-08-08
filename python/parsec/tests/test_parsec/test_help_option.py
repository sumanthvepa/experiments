"""
  test_help_option.py: Unit tests for class HelpOption
"""
# -------------------------------------------------------------------
# test_help_option.py: Unit tests for class HelpOption
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

from parameterized import parameterized

from parsec.help_option import HelpOption


class TestHelpOption(unittest.TestCase):
  """
    Unit tests for class HelpOption
  """

  def test_value(self) -> None:
    """
      Test the value of the help option.
    """
    help_option = HelpOption('h')
    self.assertTrue(help_option.value)

  def test_add_to(self) -> None:
    """
      Test the add_to method.
    """
    help_option = HelpOption('h')
    dictionary: dict[str, None | bool | int | str | set[str]] = {}
    help_option.add_to(dictionary)
    self.assertTrue(dictionary['requires_help'])

    dictionary = {'requires_help': False}
    help_option.add_to(dictionary)
    self.assertTrue(dictionary['requires_help'])

  # noinspection PyUnusedLocal
  @parameterized.expand([
    ('short-help', '-h', None, True),
    ('long-help', '--help', None, True),
    ('short-help-with-value', '-h=True', None, False),
    ('short-help-with-value1', '-h=1', None, False),
    ('short-help-with-value2', '-h1', None, False),
    ('long-help-with-value', '--help=True', None, False),
    ('long-help-with-value2', '--help=2', None, False),
    ('not-help', '-v', None, False),
    ('not-help-parameter', 'parameter', None, False),
  ])
  def test_is_option(self,
    name: str,  # pylint: disable=unused-argument
    arg: str, next_arg: str | None,
    expected_value: bool) -> None:
    """
      Test the is_option method.
    """
    self.assertEqual(expected_value, HelpOption.is_option(arg, next_arg))

  def test_make(self) -> None:
    """
      Test the make method.
    """
    help_option, skip_next = HelpOption.make('--help', None)
    self.assertIsInstance(help_option, HelpOption)
    self.assertTrue(help_option.value)
    self.assertFalse(skip_next)
