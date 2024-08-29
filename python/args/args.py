#!/usr/bin/env python3.12
"""
  args.py: This script prints out all the arguments passed to it.
"""
#--------------------------------------------------------------------
# args.py: A python script the prints all the arguments passed to it
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
#--------------------------------------------------------------------
import sys


def main(argv: list[str]) -> None:
  """
    This function prints out all the arguments passed to it.
    :param argv: list[str] - list of arguments passed to the script
    :return: None
  """
  for arg in argv[1:]:
    print(arg)


if __name__ == '__main__':
  main(sys.argv)
