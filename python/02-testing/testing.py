# -*- coding: utf-8 -*-
"""
  testing.py: An exploration of python unit tests
"""
# -------------------------------------------------------------------
# testing.py: An exploration of python unit tests
#
# Copyright (C) 2024-25 Sumanth Vepa.
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

# This project demonstrates how one can create a project with
# unit tests in python. The project is structured as follows:
# testing.py - The main driver file (same name as the project itself)
#   |
#   +-- sample/  This directory (which is a package) contains the main
#   |     |      functionality of the project. There can be multiple
#   |     |      such modules at this level.
#   |     |
#   |     +-- sample.py  This module contains functionality used by
#   |                    testing.py. Obviously there can be many such
#   |                    modules.
#   +-- tests/  This directory (which is a package) contains the unit
#          |    tests for the project.
#          |
#          +-- test_sample.py  This module contains the unit tests for
#                              the sample module. It imports the sample
#                              module and tests the functions in it.

from sample import sum_of, broken_sum_of, fibonacci

def main() -> None:
  """
    Main function
    This is just a dummy driver function for the project.

    As a convention, I create function called main that
    calls all the main functionality of the project.

    In general, the main function should be as simple as possible,
    since we typically will not write unit tests for it.

    All important code should be in the modules used by main.

    In this case main is really not useful, as the purpose of the
    project is to demonstrate unit tests.

    # see test/test_sample.py for the unit tests and how to write
    # and run them.

    :return: None
  """
  print(sum_of(45, 67))
  print(broken_sum_of(45, 67))
  print(fibonacci(40))


if __name__ == '__main__':
  main()
