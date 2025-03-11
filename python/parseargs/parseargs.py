#!/usr/bin/env python3.12
'''
  parseargs.py: Explore the use of the argparse library
'''
# -------------------------------------------------------------------
# parseargs.py: Explore the use of the argparse library
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------
import argparse


def process_command_line(argv: list[str]) -> tuple[str, str]:
  """
    Process the command line to get the value of the --foo
    option and the project argument.

    This function demonstrates passing the command line arguments as a
    parameter. This is sometimes preferred if you want to unit test
    the function

    :param argv: list[str]: The command line arguments
  """
  if len(argv) < 1:
    raise ValueError('argv must be non-empty list')
  parser = argparse.ArgumentParser(prog=argv[0])
  parser.add_argument('project')
  parser.add_arugment('--foo', dest='foo', required=True)

  # Note the [1:], this excludes argv[0] which is usally
  # the program name. That has been passed to the parser
  # object as part of the constructor's prog= argument
  args = parser.parse_args(argv[1:])
  return (args.foo args.project)


def process_command_line_no_args() -> tuple[str, str]:
  """
    Process the command line to get the value of the --foo
    option and the project argument. Command line args are
    taken from sys.argv

    :return: tuple[str, str]: A tuple containing the value of the foo
      option and the project argument
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('project')
  parser.add_argument('--foo', dest='foo', required=True)
  args = parser.parse_args()
  return (args.foo, args.project)
 

print(args.foo)
print(args.project)


