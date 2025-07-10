"""
  parser.py: Define the Parser class.
"""
# -------------------------------------------------------------------
# parser.py: Define the Parser class.
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
from parsec.options import Options
from parsec.command_line import CommandLine, _compute_verbosity
from parsec.errors import CommandLineError


class Parser:
  """ Parse command line arguments into a CommandLine object."""
  def __init__(self) -> None:
    """
      Initialize the Parser object.
    """

  def _parse_program(self, args: list[str]) -> tuple[str, int]:
    """
      Parse the program name from the command line arguments.

      :param args: The command line arguments
      :return: A tuple containing the program name and the next index
      :raises: ValueError if the program name is not found
    """
    assert len(args) > 0, "args must contain at least one argument (the name of the program)"
    return args[0], 1

  def _parse_global_options(self, args: list[str], index: int) -> tuple[Options, int, bool]:
    """
      Parse the global options from the command line arguments.

      :param args: The command line arguments
      :param index: The current index in the arguments list
      :return: A tuple containing the global options and the next index,
        and a boolean indicating if the last argument was a terminator
      :raises: ValueError if the global options are invalid
    """
    global_options = Options(args[index:])
    return (
      global_options,
      index + global_options.end_index,
      args[index + global_options.end_index - 1] == '--')

  def _parse_command_name(self, args: list[str], index: int) -> tuple[str | None, int]:
    """
      Parse the command name from the command line arguments.

      :param args: The command line arguments
      :param index: The current index in the arguments list
      :return: A tuple containing the command name and the next index
      :raises: ValueError if the command name is not found
    """
    return (args[index], index + 1) if index < len(args) else (None, index)

  def _parse_command_options(self, args: list[str], index: int) -> tuple[Options, int]:
    """
      Parse the command options from the command line arguments.

      :param args: The command line arguments
      :param index: The current index in the arguments list
      :return: A tuple containing the command options and the next index
      :raises: ValueError if the command options are invalid
    """
    command_options = Options(args[index:])
    return command_options, index + command_options.end_index

  def _parse_parameters(self, args: list[str], index: int) -> set[str]:
    """
      Parse the parameters from the command line arguments.

      :param args: The command line arguments
      :param index: The current index in the arguments list
      :return: A set containing the parameters
      :raises: ValueError if the parameters are invalid
    """
    return set(args[index:]) if index < len(args) else set()

  def parse(self, args: list[str]) -> CommandLine:
    """
      Parse the command line arguments to create a CommandLine object.

      :param args: Command line arguments
      :return: A CommandLine object
      :raises: CommandLineError if the arguments are invalid
               AssertionError if there is bug in the code
    """
    assert len(args) > 0, 'args must contain at least one argument (the name of the program)'
    command_name = None
    global_options = None
    command_options = None
    program, index = self._parse_program(args)
    try:
      global_options, index, found_terminator = self._parse_global_options(args, index)
      command_name, index \
        = self._parse_command_name(args, index) if not found_terminator else (None, index)
      command_options, index \
        = self._parse_command_options(args, index) if not found_terminator else (Options([]), index)
      parameters = self._parse_parameters(args, index)
      return CommandLine(program, command_name, global_options, command_options, parameters)
    except ValueError as ex:
      verbosity = _compute_verbosity(global_options, command_options)
      raise CommandLineError(program, command_name, verbosity,
                             f'Invalid command line arguments: {ex}') from ex
