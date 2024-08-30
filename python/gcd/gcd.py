#!/usr/bin/env python3.12
"""
  gcd.py : Compute the greatest common divisor of two numbers.
"""
# -------------------------------------------------------------------
# gcd.py: Compute the greatest common divisor of two numbers.
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

import sys


def gcd(m: int, n: int) -> int:
  """
    Compute the greatest common divisor of m and n.
    :param m: The quotient
    :param n: The divisor
    :return: The greatest common divisor of m and n
  """
  while n != 0:
    m, n = n, m % n
  return m


def main(args: list[str]) -> int:
  """
    Main entry point for the program.

    Process the command line arguments to print the greatest common
    divisor of the two numbers passed in the arguments list.

    If the number of arguments is not exactly two, print a usage.

    :param args:
      The command line arguments. Exactly two arguments are expected.
      The first argument is the quotient and the second argument is
      the divisor.
    :return: The program exit status
  """
  if len(args) != 2:
    print("Usage: gcd.py <a> <b>")
    return 1
  m = int(args[0])
  n = int(args[1])
  print(gcd(m, n))
  return 0


if __name__ == "__main__":
  sys.exit(main(sys.argv[1:]))
