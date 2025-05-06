"""
  verbosity_option.py: Define class VerbosityOption
"""
from __future__ import annotations
from typing import override

from option import Option

def int_cast(value: str) -> int | None:
  """
    Cast a string to an integer or return None if it fails.

    :param value: The string to cast
    :return: The integer value
  """
  try:
    return int(value)
  except (ValueError, TypeError):
    return None


class VerbosityOption(Option):
  """
    A class to represent a verbosity option.
  """
  @staticmethod
  def _split_flag_value(arg: str) -> tuple[str, str | None]:
    """
      Split the argument into flag and value parts.

      :param arg: The argument string
      :return: A tuple containing the flag and value parts
    """
    flag_value: list[str] = arg.split('=', 1)
    if len(flag_value) > 1:
      return flag_value[0], flag_value[1]
    if not flag_value[0].startswith('--') and len(flag_value[0]) > 2:
      return flag_value[0][:2], flag_value[0][2:]
    return flag_value[0], None

  @staticmethod
  def _extract_value(current_arg: str, next_arg: str | None) -> tuple[str | None, bool]:
    """
      Extract the value from the current argument or the next argument.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing of the flag, if present (on None if
        not) and a boolean indicating whether to skip the next argument
    """
    _, str_value = VerbosityOption._split_flag_value(current_arg)
    if str_value is not None:
      return str_value, False
    if next_arg is not None and int_cast(next_arg) is not None:
      return next_arg, True
    return None, False

  def __init__(self, verbosity: int) -> None:
    """
      Initialize the verbosity option with a verbosity level.

      :param verbosity: The verbosity level
    """
    self._verbosity = verbosity

  @override
  @property
  def value(self) -> int:
    """
      Get the value of the verbosity option.

      :return: The value of the verbosity option
    """
    return self._verbosity

  @override
  def add_to(self, dictionary: dict[str, None | bool | int | str | set[str]]) -> None:
    """
      Add the verbosity option to a dictionary.

      :param dictionary: The dictionary to add the verbosity option to
    """
    verbosity = dictionary.get('verbosity', 0)
    verbosity = 0 if verbosity is None else verbosity
    assert isinstance(verbosity, int)
    dictionary['verbosity'] \
      = self.value if verbosity is None else verbosity + self.value

  @classmethod
  def is_option(cls, arg: str) -> bool:
    """
      Check if the argument is a verbosity option.

      :param arg: The argument string
      :return: True if the argument is a verbosity option
    """
    flag, _ = cls._split_flag_value(arg)
    return flag in ('-v', '--verbose', '--verbosity')

  @classmethod
  def make(cls, current_arg: str, next_arg: str | None) -> tuple[VerbosityOption, bool]:
    """
      Create a VerbosityOption object from command line arguments.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing the VerbosityOption object and a boolean indicating
        whether to skip the next argument
      :raises ValueError: If the verbosity level is not a valid integer
    """
    assert VerbosityOption.is_option(current_arg)
    str_value, skip_next_arg = cls._extract_value(current_arg, next_arg)
    value: int = int(str_value) if str_value is not None else 1
    if value < 1:
      raise ValueError(f"Verbosity must a positive number, not {value}")
    return VerbosityOption(value), skip_next_arg
