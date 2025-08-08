"""
  command_line.py: Define the CommandLine class.
"""
# -------------------------------------------------------------------
# command_line.py: Define the CommandLine class.
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
from typing import override

from parsec.options import Options


def _compute_verbosity(global_options: Options | None, command_options: Options | None) -> int:
  """
    Calculate the verbosity level from global and command options.

    :param global_options: The global options for the command line
    :param command_options: The command options for the command line
    :return: The calculated verbosity level
    :raises: AssertionError if there is a bug in the code
  """
  global_verbosity = global_options.get('verbosity', 0) if global_options else 0
  assert isinstance(global_verbosity, int)
  command_verbosity = command_options.get('verbosity', 0) if command_options else 0
  assert isinstance(command_verbosity, int)
  return min(global_verbosity + command_verbosity, 3)


class CommandLine:
  """
    Represents parsed command line arguments.

    The CommandLine class takes a list of command line arguments,
    parses them, and provides methods to access the parsed arguments.
  """
  # pylint: disable=too-many-arguments, too-many-positional-arguments
  def __init__(self,
      program: str,
      command_name: str | None,
      global_options: Options,
      command_options: Options,
      parameters: set[str]) -> None:
    """
      Initialize the command line with arguments

      :param program: The name of the program
      :param command_name: The name of the command
      :param global_options: Any global options specified before the command
      :param command_options: Any command specific options
      :param parameters: Any parameters specified after the options
    """
    self._program = program
    self._command_name = command_name
    self._global_options = global_options
    self._command_options = command_options
    self._parameters = parameters

  @override
  def __eq__(self, other: object) -> bool:
    """
      Check if two CommandLine objects are equal.

      :param other: The other CommandLine object to compare with
      :return: True if the two CommandLine objects are equal, False otherwise
    """
    if not isinstance(other, CommandLine):
      return False
    return (self.program == other.program and
            self.command_name == other.command_name and
            self.global_options == other.global_options and
            self.command_options == other.command_options and
            self.parameters == other.parameters)

  @override
  def __repr__(self) -> str:
    """
      Return a string representation of the CommandLine object.

      :return: A string representation of the CommandLine object
    """
    # The !r operator is used to tell python to use the __repr__ method
    # of the object when converting it to a string. So
    # self.global_options!r will call the __repr__ method of the
    # Options class and return a string representation of the global
    # options.
    return (f"CommandLine(program={self.program!r}, "
            f"command_name={self.command_name!r}, "
            f"global_options={self.global_options!r}, "
            f"command_options={self.command_options!r}, "
            f"parameters={self.parameters!r})")

  @property
  def program(self) -> str:
    """
      The name of the program.

      :return: The name of the program
    """
    return self._program

  @property
  def command_name(self) -> str | None:
    """
      The name of the command.

      :return: The name of the command
    """
    return self._command_name

  @property
  def global_options(self) -> Options:
    """
      The global options for the command line.

      :return: The global options
    """
    return self._global_options

  @property
  def command_options(self) -> Options:
    """
      The command options for the command line.

      :return: The command options
    """
    return self._command_options

  @property
  def parameters(self) -> set[str]:
    """
      The parameters for the command line.

      :return: The parameters
    """
    return self._parameters

  @property
  def verbosity(self) -> int:
    """
      The verbosity level for the command line.

      :return: The verbosity level
    """
    return _compute_verbosity(self.global_options, self.command_options)
