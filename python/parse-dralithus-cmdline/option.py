"""
  option.py: Define class Option
"""
from __future__ import annotations
from abc import ABC, abstractmethod


class Option(ABC):
  """
    A class to represent a command line option.

    This is an abstract base class that defines the interface for
    all option objects.
  """
  @staticmethod
  def _split_flag_value(arg: str) -> tuple[str, str | None]:
    """
      Split the argument into flag and value parts.

      This is intended to be used by derived classes to parse command line
      arguments.

      :param arg: The argument string
      :return: A tuple containing the flag and value parts
    """
    flag_value: list[str] = arg.split('=', 1)
    if len(flag_value) > 1:
      return flag_value[0], flag_value[1]
    if not flag_value[0].startswith('--') and len(flag_value[0]) > 2:
      return flag_value[0][:2], flag_value[0][2:]
    return flag_value[0], None

  @classmethod
  def _extract_value(cls, current_arg: str, next_arg: str | None) -> tuple[str | None, bool]:
    """
      Extract the value from the current argument or the next argument.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing value of the flag, if present (on None if
        not) and a boolean indicating whether to skip the next argument
    """
    _, str_value = Option._split_flag_value(current_arg)
    if str_value is not None:
      return str_value, False
    if next_arg is not None and cls.is_valid_value_type(next_arg):
      return next_arg, True
    return None, False


  # pylint: disable=line-too-long
  # Note that the order of the decorators is important. The @abstractmethod
  # must be the innermost decorator.
  # See: https://stackoverflow.com/questions/72736760/making-abstract-property-in-python-3-results-in-attributeerror
  @property
  @abstractmethod
  def value(self) -> None | bool | int | str | set[str]:
    """
      Get the value of the option.

      :return: The value of the option
    """
    raise NotImplementedError("Option.value is an abstract property")

  @abstractmethod
  def add_to(self, dictionary: dict[str, None | bool | int | str | set[str]]) -> None:
    """
      Add the option to a dictionary.

      Derived classes must implement this method to add their specific
      option to the dictionary. The way each type of option is added
      will vary. For example, a boolean option may set a key to True,
      while the environments set will be added to any existing set
      via a set union operation.

      :param dictionary: The dictionary to add the option to
    """
    raise NotImplementedError("Option.add_to() is an abstract method")

  @classmethod
  def is_option(cls, arg: str) -> bool:
    """
      Check if a string is an option that can be represented by this
      class.

      This class checks, only to see if the string conforms to the
      format of a command line option. It does not check if the
      option matches the specific option that a derived class might
      represent.

      Derived classes must implement this method to check if the
      string represent the specific option that the derived class
      represents.

      :param arg: The argument string
      :return: True if the argument can be represented by this class
    """
    return arg.startswith('--') or (arg.startswith('-') and len(arg) > 1 and arg[1:].isalpha())

  @classmethod
  @abstractmethod
  def is_valid_value_type(cls, str_value: str) -> bool:
    """
      Check if the value is valid for this option.

      :param str_value: The value to check
      :return: True if the value is valid, False otherwise
    """
    raise NotImplementedError("Option.is_valid_value() is an abstract method")

  @staticmethod
  def type_of(arg: str) -> type[Option] | None:
    """
      Determine the type of option based on the argument string.

      :param arg: The argument string
      :return: The type of option or None if not found
    """
    # Note the import statements are inside the function. This is done
    # to avoid circular imports.
    # pylint: disable=import-outside-toplevel
    from option_terminator import OptionTerminator
    from help_option import HelpOption
    from verbosity_option import VerbosityOption
    from environment_option import EnvironmentOption

    if OptionTerminator.is_option(arg):
      return OptionTerminator
    if HelpOption.is_option(arg):
      return HelpOption
    if VerbosityOption.is_option(arg):
      return VerbosityOption
    if EnvironmentOption.is_option(arg):
      return EnvironmentOption
    return None

  @classmethod
  def make(cls, current_arg: str, next_arg: str | None) -> tuple[Option | None, bool]:
    """
      Create an Option object from command line arguments.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing the Option object and a boolean
        indicating whether to skip the next argument
    """
    actual_class: type[Option] | None = Option.type_of(current_arg)
    if actual_class is None:
      if cls.is_option(current_arg): # The arg is an option, but not a recognized one.
        raise ValueError(f"Invalid option: {current_arg}")
      return None, False
    return actual_class.make(current_arg, next_arg)
