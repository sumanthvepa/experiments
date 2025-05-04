"""
  option.py: Define class Option
"""
from __future__ import annotations
from abc import ABC, abstractmethod


class Option(ABC):
  """
    A class to represent a command line option.
  """
  # Note that the order of the decorators is important. The @abstractmethod
  # must be the innermost decorator.
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
