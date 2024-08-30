#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  number_literals.py: Exploring numeric literals in Python

  This is an exploration on the usage of numeric literals in Python
"""
# -------------------------------------------------------------------
# number_literals.py: Exploring numeric literals in Python
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


# There are three types of numeric literals in Python: integers, floats,
# and imaginary numbers.
def explore_integer_literals() -> None:
  """
  Explore integer literals in Python
  :return: None
  """
  # This is an integer literal. A normal decimal number.
  decimal_literal: int = 42
  print(decimal_literal)
  # This is a binary literal. The number 42 in binary. Note the 0b
  # prefix.
  binary_literal: int = 0b101010  # 32*1+ 16*0 + 8*1 + 4*0 + 2*1 + 1*0 = 42 decimal
  # Note that the binary literal is printed as a decimal number.
  print(binary_literal)
  # To print the binary literal as a binary number, use the bin function.
  print(bin(binary_literal))
  # You can also use 0B as prefix for binary literals. Although
  # I prefer 0b.
  binary_literal = 0B101
  print(bin(binary_literal))

  # This is an octal literal. Note the 0o prefix.
  octal_literal: int = 0o52  # 5*8 + 2 = 42 in decimal.
  # Once again the octal literal is printed as a decimal number.
  print(octal_literal)
  # To print the octal literal as an octal number, use the oct function.
  print(oct(octal_literal))
  # You can also use 0O as prefix for octal literals. Although
  # I prefer 0o, as it is less confusing.
  octal_literal = 0O5  # 5 in octal is 5 in decimal.
  print(oct(octal_literal))

  # This is a hexadecimal literal. Note the 0x prefix.
  hex_literal: int = 0x2A  # 2*16 + 10 = 42 in decimal.
  # Once again the hexadecimal literal is printed as a decimal number.
  print(hex_literal)
  # To print the hexadecimal literal as a hexadecimal number, use the hex
  # function.
  print(hex(hex_literal))
  # You can also use 0X as prefix for hexadecimal literals. Although
  # I prefer 0x.
  hex_literal = 0X5  # 5 in hexadecimal is 5 in decimal.
  print(hex(hex_literal))

  # Leading zeros are not allowed in decimal literals.
  # SyntaxError: leading zeros in decimal integer literals are not
  # permitted; use an 0o prefix for octal integers
  # decimal_literal = 052

  # Very interestingly, in Python 3, there is no language limit to
  # the size of integers. You are only limited by the amount of memory
  # in your system. This is because Python 3 integers are arbitrary
  # precision. This is not the case in Python 2, where integers are
  # limited to 32 bits.
  # For more information see:
  # https://docs.python.org/3/library/stdtypes.html#int
  # For large numbers, it is convenient to use underscores to separate
  # groups of digits.
  large_number: int = 123_456_789_012_345_678_901_234_567_890_123_456_789
  print(large_number)
  # Printing comma separated numbers in Python is best done with
  # f-strings. The downside to this particular method is that it
  # does not take locale into account. For example, in India the comma
  # separator is a lakh, not a thousand. I'll have to explore locales
  # in a different file.
  print(f'{large_number:,}')


def explore_floating_point_literals() -> None:
  """
  Explore floating point literals in Python
  :return: None
  """
  # This is a floating point literal. A normal decimal number.
  floating_point_literal: float = 42.0
  print(floating_point_literal)

  # You can use scientific notation to represent floating point numbers.
  # This is the number 42.0 times 10 to the power of 3.
  scientific_literal: float = 42.0e3
  print(scientific_literal)

  # You can also use a capital E for the exponent.
  scientific_literal = 42.0E3
  print(scientific_literal)

  # You can also use underscores to separate groups of digits.
  large_number: float = 123_456_789.012_345_678_901_234_567_890_123_456_789
  print(large_number)

  # You can also use underscores to separate groups of digits in the
  # exponent.
  scientific_literal = 42.0e3_4

  print(scientific_literal)
  # You can also use underscores to separate groups of digits in the
  # mantissa.
  scientific_literal = 42_0.0e3
  print(scientific_literal)
  # You can also use underscores to separate groups of digits in the
  # mantissa and the exponent.
  scientific_literal = 42_0.0e3_4
  print(scientific_literal)


def explore_complex_literals() -> None:
  """
  Explore complex literals in Python
  :return: None
  """
  # Complex literals are represented by a number added to an imaginary part.
  # This is a number of the form a + bj, where 'a' is the real part and 'b' is
  # the imaginary part. For purely imaginary numbers, 'a' is 0 and can be
  # omitted.

  # This is an imaginary literal. The number 42 times the imaginary unit.
  imaginary_literal: complex = 42j
  print(imaginary_literal)

  # You can also use underscores to separate groups of digits.
  imaginary_literal = 123_456_789.012_345_678_901_234_567_890_123_456_789j
  print(imaginary_literal)

  # You can also use underscores to separate groups of digits in the
  # real part.
  imaginary_literal = 42_0j
  print(imaginary_literal)

  # A complex number can be represented by a real part added to an
  # imaginary part.
  complex_literal: complex = 42 + 42j
  print(complex_literal)
