"""
  option_terminator.py: Define the OptionTerminator class
"""
from __future__ import annotations
from typing import override

from option import Option


class OptionTerminator(Option):
  """
    A class to represent an option terminator: --
  """
  @override
  @property
  def value(self) -> str:
    """
      Get the value of the option terminator.

      :return: The value of the option terminator as a string
    """
    return '--'

  @override
  def add_to(self, dictionary: dict[str, None | bool | int | str | set[str]]) -> None:
    """
      Add the option terminator to a dictionary.

      :param dictionary: The dictionary to add the option terminator to
    """
    raise NotImplementedError("PROGRAM ERROR: OptionTerminator.add_to() should never be called")

  @classmethod
  def is_option(cls, arg: str) -> bool:
    """
      Check if the argument is an option terminator.

      :param arg: The argument string
      :return: True if the argument is an option terminator
    """
    return arg == '--'

  # Note: You cannot use @override here because, @override only works with
  # normal methods. Not with class methods.
  @classmethod
  def make(cls, _: str, __: str | None) \
      -> tuple[OptionTerminator, bool]:
    """
      Create an OptionTerminator object from command line arguments.

      The reason for this signature is that the signature of the make
      method must match the signature of the make methods in other
      subclasses of Option.

      :param _: (current_arg) Not used
      :param __: (next_arg) Not used
      :return: A tuple containing the OptionTerminator object and a
        boolean indicating whether to skip the next argument (always False).
    """
    return OptionTerminator(), False
