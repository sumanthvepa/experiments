"""
  inheritance.py: Explore inheritance
"""
from __future__ import annotations
from abc import ABC, abstractmethod


class HasIntegerAdd(ABC):
  """
  Abstract base class that defines an interface for classes that
  can be added to an integer.
  """

  @abstractmethod
  def __add__(self, other: int) -> HasIntegerAdd:
    """
    Add the object to an integer.
    :param other: The integer to add to the object.
    :return: The result of the addition.
    """
