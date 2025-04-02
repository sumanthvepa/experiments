#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  text_file_io.py: Explore reading and writing text files in Python
"""
# -------------------------------------------------------------------
# text_file_io.py: Explore reading and writing text files in Python
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

import os
from contextlib import suppress


def read_file(filename: str) -> str:
  """
  Read the content of a file and return it as a string
  :param filename: The name of the file to read
  :return: The content of the file as a string
  """
  with open(filename, 'r', encoding='utf-8') as file:
    return file.read()


def read_file_by_line(filename: str) -> list[str]:
  """
  Read the contents of a file line by line into a list of strings.

  :param: filename: The name of the file to read
  :return: A list of strings, each element in the string is a line in the file
  """
  with open(filename, 'r', encoding='utf-8') as file:
    lines: list[str] = []
    for line in file:
      lines.append(line)
    return lines


def write_file(filename: str, content: str) -> None:
  """
  Write the content to a file
  :param filename: The name of the file to write to
  :param content: The content to write to the file
  :return: None
  """
  with open(filename, 'w', encoding='utf-8') as file:
    file.write(content)


def main() -> None:
  # Note the use of the 'suppress' context manager to ignore
  # FileNotFoundError when reading or deleting a file.
  # This a more elegant way to handle exceptions that
  # you don't want to propagate and don't want to handle
  # explicitly.
  with suppress(FileNotFoundError, OSError):
    print('Reading file file original.txt')
    original = read_file('original.txt')
    print(original)
    print('Writing to file copy.txt')
    write_file('copy.txt', original)
    print('Reading back from file copy.txt')
    copy = read_file('copy.txt')
    print(copy)
    print('Cleaning up. Deleting file copy.txt')
    os.remove('copy.txt')

  # If you want explicitly handle exceptions that might occur
  # during file operations, you can use a try-except block.
  try:
    print('Reading file non_existent.txt')
    non_existent = read_file('non_existent.txt')
    print(non_existent)
  except FileNotFoundError as ex:
    # This is a specific exception that is raised when a file
    # is not found.
    print(f'Error reading file: {ex}')
  except OSError as ex:
    # This is the base exception class for all I/O related
    # errors. It is a good idea to catch this exception to
    # handle any other I/O related errors.
    print(f'Error reading file: {ex}')

  # As shown above you can read a file line by line
  # This is sometimes more efficient if you need to
  # say create a list of objects. The read_by_line
  # function does just that. It creates a list
  # of strings.
  lines = read_file_by_line('original.txt')
  # Print only the first line
  print(lines[0])


if __name__ == '__main__':
  main()
