#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  strings_and_bytes.py: Explore string and bytes in Python
"""
# -------------------------------------------------------------------
# strings_and_bytes.py: Explore string and bytes in Python
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
import re
from typing import Final

# Unidecode is a third-party library that can be used to remove accents
# and normalize Unicode strings. You can install it using pip:
# pip install unidecode
import unidecode


def explore_string_literals() -> None:  # pylint: disable=too-many-locals
  """
    Explore string literals in Python
    :return: None
  """
  # The following description of strings is taken from the Python
  # documentation at:
  # https://docs.python.org/3/reference/datamodel.html#sequences
  # Strings are sequences of values representing Unicode code points.
  # All code points in the range U+0000 to U+10FFFF can be represented
  # in a string.

  # Strings in python can be either single or double-quoted. There is no
  # difference between the two. You can use either single or double quotes
  # to define a string. However, if you want to include a single quote in
  # a single quoted string, you must escape it with a backslash. Similarly,
  # if you want to include a double quote in a double-quoted string, you
  # must escape it with a backslash. If you want to include both single
  # and double quotes in a string, you can use triple quotes. Triple quotes
  # can be single or double quotes. Triple quotes are useful for defining
  # multi-line strings.

  # Prefer single quote strings where possible.

  single_quote_string: Final[str] = '"Hey!" said the mock turtle.'
  print(single_quote_string)

  double_quote_string: Final[str] = "I'm not a tortoise!"
  print(double_quote_string)

  escaped_single_quote_string: Final[str] = 'I\'m not a tortoise!'
  print(escaped_single_quote_string)

  escaped_double_quote_string: Final[str] = "\"Hey!\" said the mock turtle."
  print(escaped_double_quote_string)

  triple_quote_string: Final[str] \
      = '''"Hey!" said the mock turtle. "I'm not a tortoise!"'''
  print(triple_quote_string)

  # Python strings are immutable. This is similar to Javascript
  # Java, and Swift, but different from C/C++. This means that you
  # cannot change the value of a string once it is created.
  # For example, the following code will raise an error:
  immutable: Final[str] = "Hello, World!"
  # immutable[7] = 'w' # TypeError: 'str' object does not support item assignment
  print(immutable)

  # Python does not have a separate character type. A character is
  # simply a string of length one. The built-in function ord() converts
  # a character to its Unicode code point, and the built-in function
  # chr() converts a Unicode code point to a character. The built-in
  # function len() returns the length of a string.
  character: Final[str] = 'A'
  print(f'The Unicode code point of {character} is {ord(character)}')
  code_point: Final[int] = 65
  print(f'The character with Unicode code point {code_point} is {chr(code_point)}')
  string: Final[str] = 'Hello, World!'
  print(f'The length of {string} is {len(string)}')

  # You can concatenate strings using the '+' operator. This creates a new
  # string that is the concatenation of the two strings. The original strings
  # are not modified.
  first_name: Final[str] = 'Alice'
  last_name: Final[str] = 'Smith'
  full_name: Final[str] = first_name + ' ' + last_name
  print(full_name)

  # Although you can use the increment operator to concatenate strings,
  # the actual effect is to create a new string that is the concatenation
  # of the two strings. The original string is simply replaced with the
  # new string.
  append_string: str = 'Hello, '
  append_string += 'World!'
  print(append_string)

  # Because strings are immutable, there is no practical difference between
  # them being a value type or a reference type. You can pass a string to
  # a function, but since any modification will result in a new string
  # being created and because the parameter is local to the function,
  # the original variable will still have its original value.
  def modify_string(s: str) -> None:
    s += '!'
    print(s)
  value_type: str = 'Hello'
  print(value_type)  # Prints 'Hello'
  modify_string(value_type)  # Prints 'Hello!'
  print(value_type)  # Prints 'Hello' so the original string is not changed

  # You can get the length of a string using the len() function.
  a_string: str = 'Hello, World!'
  print(len(a_string))  # Prints 13


def explore_raw_string_literals() -> None:
  """
    Explore raw string literals in Python
    :return: None
  """
  # A raw string literal is a string that is prefixed with an 'r' or 'R'.
  # The string is interpreted as is, without any escape sequences. This
  # is useful when you want to include backslashes in a string without
  # having to escape them. For example, if you want to include a Windows
  # file path in a string, you can use a raw string literal.
  windows_path: Final[str] = r"C:\Users\Alice\Documents"
  print(windows_path)
  # Raw string literals are useful when working with regular expressions.
  # Regular expressions use backslashes to escape special characters.
  # Using raw string literals makes it easier to write regular expressions.
  # For example, the regular expression \d+ matches one or more digits.
  # To write this regular expression as a string, you would need to escape
  # the backslash with another backslash: '\\d+'. With raw string literals,
  # you can write the regular expression as r'\d+'.
  pattern = r'\d+'
  print(pattern)
  a_number: Final[str] = '123'
  match = re.fullmatch(pattern, a_number)
  if match:
    print(f'{a_number} is a number.')
  else:
    print(f'{a_number} is not a number.')
  a_string = 'abc'
  match = re.fullmatch(pattern, a_string)
  if match:
    print(f'{a_string} is a number.')
  else:
    print(f'{a_string} is not a number.')


def explore_formatted_string_literals() -> None:
  """
    Explore formatted string literals in Python
    :return: None
  """
  # Formatted strings are strings that contain placeholders that are
  # replaced with values at runtime. The placeholders are enclosed in
  # curly braces. The values that replace the placeholders are passed.
  # This proces is called string interpolation. Formatted strings are
  # prefixed with an 'f' or 'F'. The placeholders can contain expressions
  # that are evaluated at runtime. For example, you can use formatted
  # strings to print the value of variables.
  name: Final[str] = "Alice"
  age: Final[int] = 25
  formatted_string: Final[str] = f"Hello, {name}. You are {age} years old."
  print(formatted_string)

  # You can put an additional format specifier within the curly braces
  # to format the value that replaces the placeholder. For example, you
  # can specify the number of decimal places for a floating-point number.
  pi: Final[float] = 3.141592653589793
  formatted_pi: Final[str] = f"Pi is approximately {pi:.2f}."
  print(formatted_pi)

  # To print a large real number with commas separating the thousands,
  # rounded to two decimal places, you can use the following format
  # Note the ',' which is used to separate the thousands and the .2f
  # which is used to round the number to two decimal places.
  large_real: Final[float] = 1234567890.1295
  formatted_large_real: Final[str] = f"{large_real:,.2f}"
  print(formatted_large_real)

  # The complete specification for the format specifier can be found at
  # https://docs.python.org/3/library/string.html#format-specification-mini-language
  # For examples see:
  # https://docs.python.org/3/library/string.html#formatexamples
  # See Python documentation on Input/Output for other ways of
  # formating strings
  # https://docs.python.org/3/tutorial/inputoutput.html

  # There is no good way to print a localized number with commas separating
  # the thousands and a period separating the fractional part using
  # f-strings. You can use the locale module to achieve this.
  # https://docs.python.org/3/library/locale.html
  # https://docs.python.org/3/tutorial/inputoutput.html#old-string-formatting


def explore_byte_string_literals() -> None:
  """
    Explore byte string literals in Python
    :return: None
  """
  # Byte strings are sequences of bytes. They are prefixed with a 'b' or 'B'.
  # Byte strings are immutable and can contain any sequence of bytes. Byte
  # strings are useful when working with binary data. For example, you can
  # read a file as a byte string. Byte strings can contain escape sequences
  # as well. This allows you to include non-printable characters in a byte
  # string.
  byte_string: Final[bytes] = b'\x48\x65\x6c\x6c\x6f\x2c\x20\x57\x6f\x72\x6c\x64\x21'

  # Notice that byte strings are of a different type than regular strings.
  print(type(byte_string))  # Prints <class 'bytes'>

  # Use the decode method to convert a byte string to a regular string.
  # You must know what the encoding of the byte string is to decode it.
  print(byte_string.decode('utf-8'))  # Prints 'Hello, World!'

  # If the byte string only contains ASCII characters, you can use the
  # ASCII encoding to decode it.
  ascii_byte_string: Final[bytes] = b'Hello, World!'
  print(ascii_byte_string.decode('ascii'))  # Prints 'Hello, World!'

  # You can convert a string to bytes using the encode method. You must
  # know what encoding to use. The default encoding is UTF-8.
  utf8_string: Final[str] = 'π is approximately 3.14159'
  print(utf8_string)  # Prints 'π is approximately 3.14159'
  utf8_byte_string: Final[bytes] = utf8_string.encode('utf-8')
  print(utf8_byte_string)  # Prints b'\xcf\x80 is approximately 3.14159'

  # Note that len returns different values for utf8_string and utf8_byte_string
  # This is because π is represented by two bytes in UTF-8.
  print(f'len(utf_8_string) = {len(utf8_string)}')  # Prints 26
  print(f'len(utf_8_byte_string) = {len(utf8_byte_string)}')  # Prints 27


def explore_string_comparisons() -> None:  # pylint: disable=too-many-locals
  """
    Explore string comparisons in Python
    :return: None
  """
  # Comparison on real world strings can be tricky because of the presence
  # of accents, diacritics, and other special characters. For example, the
  # strings "cafe" and "café" are not equal because the second string contains
  # an accent. Another example is the german word for street, "straße".
  # The letter ß is equivalent to ss. However, Python does not consider them
  # equal. You can use the unidecode library to remove accents and normalize
  # Unicode strings. You can install it using pip:
  # https://pypi.org/project/Unidecode/
  # https://stackoverflow.com/questions/517923/what-is-the-best-way-to-remove-accents-normalize-in-a-python-unicode-string
  # pip install unidecode
  string1: Final[str] = 'cafe'
  string2: Final[str] = 'café'
  print(string1 == string2)  # Prints False
  string3: Final[str] = 'straße'
  string4: Final[str] = 'strasse'
  print(string3 == string4)  # Prints False
  string5: Final[str] = unidecode.unidecode(string3)
  string6: Final[str] = unidecode.unidecode(string4)
  print(string5 == string6)  # Prints True

  # If you want to compare two strings in a case-insensitive manner,
  # ignoring accents and diacritics, you can do the following:
  # 1. Convert both strings to lowercase using the 'casefold' method.
  # 2. Remove accents and diacritics using the unidecode method.
  # 3. Compare the resulting strings.
  string7: Final[str] = 'eß'
  string8: Final[str] = 'Éss'
  string9: Final[str] = unidecode.unidecode(string7).casefold()
  string10: Final[str] = unidecode.unidecode(string8).casefold()
  if string9 == string10:
    print(f'{string7} compared to {string8}: {string9} == {string10}')
  else:
    print(f'{string7} compared to {string8}: {string9} != {string10}')

  # If you want to remove both accents and diacritics, you can use the
  # normalize method from the unicodedata module. The normalize method
  # takes two arguments: the form and the string. The form can be 'NFD',
  # 'NFC', 'NFKD', or 'NFKC'. The 'NFD' form decomposes the string into
  # its base characters and diacritics. The 'NFC' form composes the string
  # into precomposed characters. The 'NFKD' form decomposes the string into
  # its base characters and diacritics, and then applies compatibility
  # decomposition. The 'NFKC' form composes the string into precomposed
  # characters, and then applies compatibility composition.
  # https://docs.python.org/3/library/unicodedata.html#unicodedata.normalize
  # TODO: Add example of unicodedata.normalize

  # If you want to compare strings in a case-insensitive manner, you can
  # convert the strings to lowercase using the lower method and then compare
  # them. You can also use the casefold method, which is more aggressive in
  # removing case distinctions. The casefold method is useful when comparing
  # strings in different languages.
  string11: Final[str] = 'Hello, World!'
  string12: Final[str] = 'hello, world!'
  print(string11.lower() == string12.lower())  # Prints True
  print(string11.casefold() == string12.casefold())  # Prints True

  # You can use the startswith and endswith methods to check if a string
  # starts or ends with a particular substring. The methods return True
  # if the string starts or ends with the substring, and False otherwise.
  string13: Final[str] = 'Hello, World!'
  print(string13.startswith('Hello'))  # Prints True
  print(string13.endswith('World!'))  # Prints True

  # You can use the in operator to check if a string contains a particular
  # substring. The operator returns True if the substring is present in
  # the string, and False otherwise.
  string14: Final[str] = 'Hello, World!'
  print('Hello' in string14)  # Prints True
  print('World' in string14)  # Prints True
  print('Python' in string14)  # Prints False

  # You can use the find and index methods to find the index of a substring
  # in a string. The find method returns the index of the first occurrence
  # of the substring, or -1 if the substring is not present. The index method
  # raises a ValueError if the substring is not present.
  string15: Final[str] = 'Hello, World!'
  print(string15.find('World'))  # Prints 7
  print(string15.find('Python'))  # Prints -1
  print(string15.index('World'))  # Prints 7
  try:
    print(string11.index('Python'))  # ValueError: substring not found
  except ValueError as ex:
    print(ex)
