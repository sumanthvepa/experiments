"""
  config.py: Environment-based configuration for the cbrws web service.
"""
from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
  """
    Runtime settings for the cbrws web service.
  """
  debug: bool
  host: str
  port: int


def bool_from_env(name: str, default: bool = False) -> bool:
  """
    Read a boolean value from an environment variable.
    :param name: The name of the environment variable
    :param default: The value to use when the variable is not set
    :return: True when the variable contains an enabled value
  """
  value = os.environ.get(name)
  if value is None:
    return default
  return value.strip().lower() in {'1', 'true', 'yes', 'on'}


def int_from_env(name: str, default: int) -> int:
  """
    Read an integer value from an environment variable.
    :param name: The name of the environment variable
    :param default: The value to use when the variable is not set
    :return: The parsed integer, or the default for invalid values
  """
  value = os.environ.get(name)
  if value is None:
    return default
  try:
    return int(value.strip())
  except ValueError:
    return default


def settings_from_env() -> Settings:
  """
    Read application settings from environment variables.
    :return: The application settings
  """
  return Settings(
    debug=bool_from_env('CBRWS_DEBUG'),
    host=os.environ.get('CBRWS_HOST', '0.0.0.0'),
    port=int_from_env('CBRWS_PORT', 5101))
