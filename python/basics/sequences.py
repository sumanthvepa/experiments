#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  sequences.py: Explore the basics of sequences in Python
"""
# -------------------------------------------------------------------
# sequences.py: Explore the basics of sequences in Python
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
from array import array


def explore_sequences() -> None:
  """
    Explore the basics of sequences in Python
    :return: None
  """
  # Sequences are ordered collections of items of finite length,
  # indexed by non-negative integers.

  # Sequences are either mutable or immutable.
  # Immutable sequences cannot be changed after they are created.
  # Strings, tuples, bytes, and frozen sets are immutable sequences.

  # Strings are discussed in detail in strings_and_bytes.py.
  a_string: str = 'Hello, World!'  # Immutable sequence
  print(f'a_string = {a_string}')

  # Tuples are discussed in detail in tuples.py.
  a_tuple: tuple[int, int, int] = (1, 2, 3)  # Immutable sequence
  print(f'a_tuple = {a_tuple}')

  # Bytes are discussed in detail in strings_and_bytes.py
  byte_sequence: bytes = b'ascii_chars_only'  # Immutable sequence
  print(f'byte_sequence = {byte_sequence.decode("ascii")}')

  # Frozen sets are discussed in detail in sets.py.
  a_frozenset: frozenset[int] = frozenset([1, 2, 3])  # Immutable sequence
  print(f'a_frozenset = {a_frozenset}')

  # Mutable sequences can be changed after they are created.
  # Lists, bytearrays, and arrays are mutable sequences.

  # Lists are discussed in detail in lists.py
  a_list: list[int] = [1, 2, 3]  # Mutable sequence
  print(f'a_list = {a_list}')

  # Bytearrays are discussed in detail in strings_and_bytes.py
  a_byte_array: bytearray = bytearray(b'ascii_chars_only')  # Mutable sequence
  print(f'a_byte_array = {a_byte_array.decode("ascii")}')

  # Arrays are discussed in detail in arrays.py
  # Note that arrays are not builtin types, but are part of the
  # array module.
  an_array: array[int] = array('i', [1, 2, 3])  # Mutable sequence
  print(f'an_array = {an_array}')
