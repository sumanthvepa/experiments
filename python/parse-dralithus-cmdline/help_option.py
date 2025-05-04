"""
  help_option.py: Define class HelpOption
"""
from __future__ import annotations
from typing import override

from option import Option


class HelpOption(Option):
  """
    A class to represent a help option.
  """
  @override
  @property
  def value(self) -> bool:
    """
      Get the value of the help option. Is always True!

      :return: The value of the help option as a boolean
    """
    return True

  @override
  def add_to(self, dictionary: dict[str, None | bool | int | str | set[str]]) -> None:
    """
      Add the help option to a dictionary.

      :param dictionary: The dictionary to add the help option to
    """
    dictionary['requires_help'] = True

  @classmethod
  def is_option(cls, arg: str) -> bool:
    """
      Check if the argument is a help option.

      :param arg: The argument string
      :return: True if the argument is a help option
    """
    return arg in ('-h', '--help')

  @classmethod
  def make(cls, current_arg: str, next_arg: str | None) -> tuple[HelpOption, bool]:
    """
      Create a HelpOption object from command line arguments.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing the HelpOption object and a boolean indicating
        whether to skip the next argument
    """
    assert cls.is_option(current_arg)
    return HelpOption(), False
