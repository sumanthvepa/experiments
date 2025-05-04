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
  @abstractmethod
  def is_option(cls, arg: str) -> bool:
    """
      Check if a string is an option that can be represented by this
      class.

      Derived classes must implement this method to check if the
      argument string can be represented by this class.

      :param arg: The argument string
      :return: True if the argument can be represented by this class
    """
    raise NotImplementedError("Option.is_option() is an abstract method")

  @classmethod
  @abstractmethod
  def make(cls, current_arg: str, next_arg: str | None) -> tuple[Option, bool]:
    """
      Create an Option object from command line arguments.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing the Option object and a boolean
        indicating whether to skip the next argument
    """
    raise NotImplementedError("Option.make() is an abstract method")
