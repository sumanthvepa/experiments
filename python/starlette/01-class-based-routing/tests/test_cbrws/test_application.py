"""
  test_application.py: Unit tests for the application module.
"""
import unittest
from unittest.mock import patch

from starlette.applications import Starlette
from starlette.testclient import TestClient

from cbrws.application import app, application_middleware, routes
from cbrws.config import (
  Settings,
  bool_from_env,
  list_from_env,
  log_level_from_env,
  settings_from_env)


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

  def test_settings_from_env_returns_defaults(self) -> None:
    """
      Test that settings_from_env returns default application settings.
      :return: None
    """
    with patch.dict('os.environ', {}, clear=True):
      settings = settings_from_env()
      self.assertFalse(settings.debug)
      self.assertEqual('INFO', settings.log_level)
      self.assertTrue(settings.access_log)
      self.assertEqual(('*',), settings.allowed_hosts)

  def test_settings_from_env_reads_config_values(self) -> None:
    """
      Test that settings_from_env reads application settings.
      :return: None
    """
    with patch.dict(
          'os.environ',
          {
            'CBRWS_DEBUG': 'true',
            'CBRWS_LOG_LEVEL': 'debug',
            'CBRWS_ACCESS_LOG': 'false',
            'CBRWS_ALLOWED_HOSTS': 'localhost, api.example.com'
          }):
      settings = settings_from_env()
      self.assertTrue(settings.debug)
      self.assertEqual('DEBUG', settings.log_level)
      self.assertFalse(settings.access_log)
      self.assertEqual(
        ('localhost', 'api.example.com'),
        settings.allowed_hosts)

  def test_list_from_env_returns_default_when_unset(self) -> None:
    """
      Test that list_from_env returns the default for unset variables.
      :return: None
    """
    with patch.dict('os.environ', {}, clear=True):
      self.assertEqual(('*',), list_from_env('CBRWS_ALLOWED_HOSTS', ('*',)))

  def test_list_from_env_parses_comma_separated_values(self) -> None:
    """
      Test that list_from_env parses comma-separated values.
      :return: None
    """
    with patch.dict(
          'os.environ',
          {'CBRWS_ALLOWED_HOSTS': 'localhost, api.example.com,, '}):
      self.assertEqual(
        ('localhost', 'api.example.com'),
        list_from_env('CBRWS_ALLOWED_HOSTS', ('*',)))

  def test_trusted_host_middleware_allows_configured_hosts(self) -> None:
    """
      Test that configured Host headers are accepted.
      :return: None
    """
    settings = Settings(
      debug=False,
      log_level='INFO',
      access_log=True,
      allowed_hosts=('api.example.com',))
    test_app = Starlette(
      routes=routes,
      middleware=application_middleware(settings))
    client = TestClient(test_app, 'http://api.example.com')
    response = client.get('/api')
    self.assertEqual(200, response.status_code)

  def test_trusted_host_middleware_rejects_other_hosts(self) -> None:
    """
      Test that unexpected Host headers are rejected.
      :return: None
    """
    settings = Settings(
      debug=False,
      log_level='INFO',
      access_log=True,
      allowed_hosts=('api.example.com',))
    test_app = Starlette(
      routes=routes,
      middleware=application_middleware(settings))
    client = TestClient(test_app, 'http://attacker.example')
    response = client.get('/api')
    self.assertEqual(400, response.status_code)

  def test_log_level_from_env_returns_default_when_unset(self) -> None:
    """
      Test that log_level_from_env returns the default for unset values.
      :return: None
    """
    with patch.dict('os.environ', {}, clear=True):
      self.assertEqual('INFO', log_level_from_env('CBRWS_LOG_LEVEL'))

  def test_log_level_from_env_normalizes_valid_values(self) -> None:
    """
      Test that log_level_from_env normalizes valid logging levels.
      :return: None
    """
    with patch.dict('os.environ', {'CBRWS_LOG_LEVEL': 'debug'}):
      self.assertEqual('DEBUG', log_level_from_env('CBRWS_LOG_LEVEL'))

  def test_log_level_from_env_returns_default_for_invalid_values(self) -> None:
    """
      Test that log_level_from_env returns the default for invalid values.
      :return: None
    """
    with patch.dict('os.environ', {'CBRWS_LOG_LEVEL': 'verbose'}):
      self.assertEqual('INFO', log_level_from_env('CBRWS_LOG_LEVEL'))

  def test_access_log_records_completed_requests(self) -> None:
    """
      Test that access logging records completed requests.
      :return: None
    """
    client = TestClient(app, 'http://localhost:5101')
    with self.assertLogs('cbrws.access', level='INFO') as logs:
      response = client.get('/api')
    self.assertEqual(200, response.status_code)
    self.assertTrue(any(
      'request completed method=GET path=/api status=200' in message
      for message in logs.output))

  def test_not_found_logs_problem_response(self) -> None:
    """
      Test that Not Found responses are logged.
      :return: None
    """
    client = TestClient(app, 'http://localhost:5101')
    with self.assertLogs('cbrws.http', level='INFO') as logs:
      response = client.get('/unknown')
    self.assertEqual(404, response.status_code)
    self.assertTrue(any(
      'not found method=GET path=/unknown' in message
      for message in logs.output))

  def test_method_not_allowed_logs_problem_response(self) -> None:
    """
      Test that Method Not Allowed responses are logged.
      :return: None
    """
    client = TestClient(app, 'http://localhost:5101')
    with self.assertLogs('cbrws.http', level='WARNING') as logs:
      response = client.post('/api')
    self.assertEqual(405, response.status_code)
    self.assertTrue(any(
      'method not allowed method=POST path=/api allowed=GET, HEAD, OPTIONS'
      in message
      for message in logs.output))
