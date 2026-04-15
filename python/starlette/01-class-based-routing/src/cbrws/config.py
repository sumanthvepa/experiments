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
  log_level: str
  access_log: bool
  allowed_hosts: tuple[str, ...]


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


def log_level_from_env(name: str, default: str = 'INFO') -> str:
  """
    Read a logging level from an environment variable.
    :param name: The name of the environment variable
    :param default: The value to use when the variable is not set
    :return: A normalized logging level name
  """
  valid_levels = {'CRITICAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG', 'NOTSET'}
  value = os.environ.get(name)
  if value is None:
    return default
  level = value.strip().upper()
  if level in valid_levels:
    return level
  return default


def list_from_env(name: str, default: tuple[str, ...]) -> tuple[str, ...]:
  """
    Read a comma-separated list from an environment variable.
    :param name: The name of the environment variable
    :param default: The value to use when the variable is not set
    :return: A tuple of non-empty list items
  """
  value = os.environ.get(name)
  if value is None:
    return default
  values = tuple(
    item.strip()
    for item in value.split(',')
    if item.strip())
  if not values:
    return default
  return values


def settings_from_env() -> Settings:
  """
    Read application settings from environment variables.
    :return: The application settings
  """
  return Settings(
    debug=bool_from_env('CBRWS_DEBUG'),
    log_level=log_level_from_env('CBRWS_LOG_LEVEL'),
    access_log=bool_from_env('CBRWS_ACCESS_LOG', default=True),
    allowed_hosts=list_from_env('CBRWS_ALLOWED_HOSTS', ('*',)))
