"""
  test_application.py: Unit tests for the application module.
"""
import unittest
from unittest.mock import patch

from cbrws.application import app
from cbrws.config import bool_from_env, int_from_env, settings_from_env


class TestApplication(unittest.TestCase):
  """
    Unit tests for the application module.
  """
  def test_debug_mode_defaults_to_false(self) -> None:
    """
      Test that the application does not enable debug mode by default.
      :return: None
    """
    self.assertFalse(app.debug)

  def test_bool_from_env_returns_default_when_unset(self) -> None:
    """
      Test that bool_from_env returns the default for unset variables.
      :return: None
    """
    with patch.dict('os.environ', {}, clear=True):
      self.assertFalse(bool_from_env('CBRWS_DEBUG'))
      self.assertTrue(bool_from_env('CBRWS_DEBUG', default=True))

  def test_bool_from_env_accepts_enabled_values(self) -> None:
    """
      Test that bool_from_env recognizes enabled values.
      :return: None
    """
    for value in ('1', 'true', 'TRUE', 'yes', 'on'):
      with self.subTest(value=value):
        with patch.dict('os.environ', {'CBRWS_DEBUG': value}):
          self.assertTrue(bool_from_env('CBRWS_DEBUG'))

  def test_bool_from_env_rejects_other_values(self) -> None:
    """
      Test that bool_from_env rejects values that are not enabled.
      :return: None
    """
    for value in ('0', 'false', 'no', 'off', ''):
      with self.subTest(value=value):
        with patch.dict('os.environ', {'CBRWS_DEBUG': value}):
          self.assertFalse(bool_from_env('CBRWS_DEBUG'))

  def test_int_from_env_returns_default_when_unset(self) -> None:
    """
      Test that int_from_env returns the default for unset variables.
      :return: None
    """
    with patch.dict('os.environ', {}, clear=True):
      self.assertEqual(5101, int_from_env('CBRWS_PORT', 5101))

  def test_int_from_env_parses_integer_values(self) -> None:
    """
      Test that int_from_env parses integer values.
      :return: None
    """
    with patch.dict('os.environ', {'CBRWS_PORT': '8000'}):
      self.assertEqual(8000, int_from_env('CBRWS_PORT', 5101))

  def test_int_from_env_returns_default_for_invalid_values(self) -> None:
    """
      Test that int_from_env returns the default for invalid values.
      :return: None
    """
    with patch.dict('os.environ', {'CBRWS_PORT': 'abc'}):
      self.assertEqual(5101, int_from_env('CBRWS_PORT', 5101))

  def test_settings_from_env_returns_defaults(self) -> None:
    """
      Test that settings_from_env returns default application settings.
      :return: None
    """
    with patch.dict('os.environ', {}, clear=True):
      settings = settings_from_env()
      self.assertFalse(settings.debug)
      self.assertEqual('0.0.0.0', settings.host)
      self.assertEqual(5101, settings.port)

  def test_settings_from_env_reads_config_values(self) -> None:
    """
      Test that settings_from_env reads application settings.
      :return: None
    """
    with patch.dict(
          'os.environ',
          {
            'CBRWS_DEBUG': 'true',
            'CBRWS_HOST': '127.0.0.1',
            'CBRWS_PORT': '8000'
          }):
      settings = settings_from_env()
      self.assertTrue(settings.debug)
      self.assertEqual('127.0.0.1', settings.host)
      self.assertEqual(8000, settings.port)
