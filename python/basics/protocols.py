#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  protocols.py: Explore protocols
"""
# -------------------------------------------------------------------
# protocols.py: Explore protocols
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
from typing import Protocol


def explore_protocols() -> None:
  """ Explore protocols """
  # In Python, Protocols are a way to define structural subtyping
  # (also known as "duck typing with static checking"). Introduced
  # in PEP 544, Protocols let you specify that a class conforms to a
  # given interface without requiring explicit inheritance.

  # There are two kind of sub-typing in programming languages:
  # 1. Nominal sub-typing: A class is a subtype of another class if it
  #    explicitly declares that it is a subtype (e.g., through
  #    inheritance).
  # 2. Structural sub-typing: A class is a subtype of another class if
  #    it has the same structure (i.e., the same methods and attributes)
  #    as the other class, regardless of whether it explicitly declares
  #    that it is a subtype. This type of sub-typing is also called
  #    "duck typing" because it is based on the idea that "if it walks
  #    like a duck and quacks like a duck, then it is a duck".

  # Python obviously supports nominal sub-typing through inheritance.
  # Python has always supported duck typing, but it was not possible
  # to use duck typing with static type checking. This is where
  # Protocols come in. They allow you to define an interface that a
  # class must conform to, without requiring explicit inheritance.

  # Static type checkers like mypy can then use this information to
  # check that a class conforms to a given interface, even if it does
  # not explicitly declare that it is a subtype of that interface.
  # This is useful for defining interfaces that can be implemented by
  # multiple classes, or for defining interfaces that can be used with
  # third-party libraries that do not explicitly declare their
  # interfaces.

  # Here is an example of how to use Protocols in Python:
  # Note that there none of the methods defined in the class
  # below has a definition. They are just declarations.
  # pylint: disable=too-few-public-methods
  class Savable(Protocol):
    """ A Protocol that requires a save method """
    def save(self) -> None:
      """ Save the object """

  # Class Document provides a save method whose signature matches
  # the one declared in the Savable Protocol. This means that
  # Document is a structural subtype of Savable, i.e. it implements
  # the Savable protocol.
  class Document:
    """ A class that implements the RequiresSave Protocol """
    def __init__(self, title: str) -> None:
      self.title = title

    def load(self, filename: str) -> None:
      """ Load the document from a file """
      print(f"Document '{self.title}' loaded from {filename}.")

    def save(self) -> None:
      """ Save the document """
      print(f"Document with title '{self.title}' saved.")

  # Similar to Document, Spreadsheet also implements the
  # Savable protocol.
  class Spreadsheet:
    """ A class that implements the RequiresSave Protocol """
    def __init__(self, title: str) -> None:
      self.title = title

    def load(self, filename: str) -> None:
      """ Load the spreadsheet from a file """
      print(f"Spreadsheet '{self.title}' loaded from {filename}.")

    def save(self) -> None:
      """ Save the spreadsheet """
      print(f'Spreadsheet with title "{self.title}" saved.')

  # Checkpoint is a function that takes a list of Savables.
  # Mypy can check that objects passed to this function implement
  # the methods declared in the Savable Protocol. Otherwise, it will
  # raise a type error.
  def checkpoint(savables: list[Savable]) -> None:
    """ A checkpoint function that saves all the object passed to it """
    # This function can accept any object that implements the
    # RequiresSave Protocol, regardless of whether it explicitly
    # declares that it is a subtype of RequiresSave.
    for savable in savables:
      savable.save()

  # Example usage of the Protocol
  doc1 = Document('document1')
  doc2 = Document('document2')
  doc3 = Document('document3')
  spreadsheet1 = Spreadsheet('spreadsheet1')
  spreadsheet2 = Spreadsheet('spreadsheet2')
  open_documents: list[Savable] = [doc1, spreadsheet2, doc2, doc3, spreadsheet1]
  checkpoint(open_documents)  # Okay. A list of savables is passed.

  class CPU:
    """ A class that does not implement the Savable Protocol """
    def __init__(self, title: str) -> None:
      self.title = title

  cpu1 = CPU('CPU 1')
  cpu2 = CPU('CPU 2')
  cpus = [cpu1, cpu2]
  print(cpus)

  # mypy will flag an error here because CPU does not implement
  # the Savable Protocol. The save method is not defined in CPU.
  # Argument 1 to "checkpoint" has incompatible  type "list[CPU]";
  # It will also result in a runtime error if you try to run this code.
  # expected "list[Savable]"
  # checkpoint(cpus)


if __name__ == '__main__':
  explore_protocols()
