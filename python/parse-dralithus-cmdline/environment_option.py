"""
  environment_option.py: Define class Environment
"""
from __future__ import annotations
from typing import override

from option import Option

def set_cast(value: str) -> set[str] | None:
  """
    Cast a string to a set of strings or return None if it fails.

    :param value: The string to cast
    :return: The set of strings
  """
  try:
    return set(value.split(','))
  except (ValueError, TypeError):
    return None

class EnvironmentOption(Option):
  """
    A class to represent an environment option.
  """
  def __init__(self, environments: set[str]) -> None:
    """
      Initialize the environment option with a set of environment names.

      :param environments: The set of environment names
    """
    super().__init__()
    self._environments = environments

  @override
  @property
  def value(self) -> set[str]:
    """
      Get the value of the environment option.

      :return: The value of the environment option
    """
    return self._environments

  @override
  def add_to(self, dictionary: dict[str, None | bool | int | str | set[str]]) -> None:
    """
      Add the option to a dictionary.

      :param dictionary: The dictionary to add the option to
    """
    environments = dictionary.get('environments', None)
    if environments is None:
      environments = self.value
    else:
      assert isinstance(environments, set) and all(isinstance(env, str) for env in environments)
      environments = environments | self.value
    dictionary['environments'] = environments

  @classmethod
  def is_option(cls, arg: str) -> bool:
    """
      Check if the argument is an environment option.

      :param arg: The argument string
      :return: True if the argument is an environment option
    """
    flag, _ = Option._split_flag_value(arg)
    return flag in ('-e', '--env', '--environment')

  @classmethod
  def is_valid_type(cls, str_value: str) -> bool:
    """
      Check if the value is a valid verbosity level.
      :param str_value:
      :return:
    """
    return set_cast(str_value) is not None

  @classmethod
  def is_valid_environment(cls, environment: str) -> bool:
    """
      Check if the environment name is valid.

      :param environment: The environment name
      :return: True if the environment name is valid
    """
    return environment in ('local', 'test', 'staging', 'production')

  @classmethod
  def make(cls, current_arg: str, next_arg: str | None) -> tuple[EnvironmentOption, bool]:
    """
      Create an EnvironmentOption object from command line arguments.

      :param current_arg: The current argument string
      :param next_arg: The next argument string
      :return: A tuple containing the EnvironmentOption object and a boolean indicating
        whether to skip the next argument
    """
    assert cls.is_option(current_arg)
    str_value, skip_next_arg = cls._extract_value(current_arg, next_arg)
    if str_value is None:
      raise ValueError(f"Missing value for environment option: {current_arg}")
    environments: set[str] = set(str_value.split(','))
    for environment in environments:
      if not cls.is_valid_environment(environment):
        raise ValueError(f"Invalid environment name: {environment}")
    return EnvironmentOption(environments), skip_next_arg
