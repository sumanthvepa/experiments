"""
  test_url_util.py: Unit tests for public URL helpers.
"""
import unittest

from starlette.applications import Starlette
from starlette.requests import Request
from starlette.responses import Response
from starlette.routing import Route
from starlette.testclient import TestClient

from cbrws.config import Settings
from cbrws.url_util import (
  public_url_for,
  resolve_public_origin,
  resolve_public_url)


async def url_response(request: Request) -> Response:
  """
    Return a public URL generated from the request.
    :param request: The HTTP request
    :return: A response containing the public URL
  """
  return Response(public_url_for(request, 'url_endpoint'))


class TestURLUtil(unittest.TestCase):
  """
    Unit tests for public URL helpers.
  """
  def test_resolve_public_origin_returns_trusted_exact_host(self) -> None:
    """
      Test that an exact trusted host is used in the public origin.
      :return: None
    """
    self.assertEqual(
      'https://api.example.com',
      resolve_public_origin(
        'https://api.example.com/api',
        ('api.example.com',)))

  def test_resolve_public_origin_preserves_configured_host_case(self) -> None:
    """
      Test that the returned host comes from trusted_hosts.
      :return: None
    """
    self.assertEqual(
      'https://API.example.com',
      resolve_public_origin(
        'https://api.example.com/api',
        ('API.example.com',)))

  def test_resolve_public_origin_preserves_request_port(self) -> None:
    """
      Test that the request URL port is retained in the origin.
      :return: None
    """
    self.assertEqual(
      'http://localhost:5101',
      resolve_public_origin(
        'http://localhost:5101/api',
        ('localhost',)))

  def test_resolve_public_origin_rejects_untrusted_host(self) -> None:
    """
      Test that an untrusted URL host is rejected.
      :return: None
    """
    with self.assertRaisesRegex(ValueError, 'URL host is not trusted'):
      resolve_public_origin(
        'https://attacker.example/api',
        ('api.example.com',))

  def test_resolve_public_origin_rejects_empty_trusted_hosts(self) -> None:
    """
      Test that at least one trusted host is required.
      :return: None
    """
    with self.assertRaisesRegex(ValueError, 'trusted_hosts must not be empty'):
      resolve_public_origin('https://api.example.com/api', ())

  def test_resolve_public_origin_rejects_wildcard_in_production(self) -> None:
    """
      Test that production mode rejects the unsafe wildcard host.
      :return: None
    """
    with self.assertRaisesRegex(
          ValueError,
          r'trusted_hosts must not contain \* when debug is false'):
      resolve_public_origin(
        'https://api.example.com/api',
        ('*',),
        debug=False)

  def test_resolve_public_origin_allows_wildcard_in_debug(self) -> None:
    """
      Test that debug mode can use the request host for wildcard config.
      :return: None
    """
    self.assertEqual(
      'http://localhost:5101',
      resolve_public_origin(
        'http://localhost:5101/api',
        ('*',),
        debug=True))

  def test_resolve_public_origin_uses_configured_wildcard_base(self) -> None:
    """
      Test that wildcard patterns do not emit the request hostname.
      :return: None
    """
    self.assertEqual(
      'https://example.com',
      resolve_public_origin(
        'https://tenant.example.com/api',
        ('*.example.com',)))

  def test_resolve_public_origin_rejects_wildcard_base_domain(self) -> None:
    """
      Test that a wildcard pattern does not match the base domain.
      :return: None
    """
    with self.assertRaisesRegex(ValueError, 'URL host is not trusted'):
      resolve_public_origin(
        'https://example.com/api',
        ('*.example.com',))

  def test_resolve_public_origin_rejects_unsupported_scheme(self) -> None:
    """
      Test that only HTTP and HTTPS URLs are supported.
      :return: None
    """
    with self.assertRaisesRegex(ValueError, 'unsupported URL scheme'):
      resolve_public_origin(
        'ftp://api.example.com/api',
        ('api.example.com',))

  def test_resolve_public_origin_rejects_missing_hostname(self) -> None:
    """
      Test that an absolute URL with a hostname is required.
      :return: None
    """
    with self.assertRaisesRegex(ValueError, 'URL must include a hostname'):
      resolve_public_origin('https:///api', ('api.example.com',))

  def test_resolve_public_url_preserves_path(self) -> None:
    """
      Test that the URL path is preserved.
      :return: None
    """
    self.assertEqual(
      'https://api.example.com/profiles/cbrws/v1',
      resolve_public_url(
        'https://api.example.com/profiles/cbrws/v1',
        ('api.example.com',)))

  def test_resolve_public_url_preserves_query_string(self) -> None:
    """
      Test that the URL query string is preserved.
      :return: None
    """
    self.assertEqual(
      'https://api.example.com/api?format=hal',
      resolve_public_url(
        'https://api.example.com/api?format=hal',
        ('api.example.com',)))

  def test_resolve_public_url_uses_configured_host(self) -> None:
    """
      Test that the resolved URL host comes from trusted_hosts.
      :return: None
    """
    self.assertEqual(
      'https://API.example.com/api/greeting',
      resolve_public_url(
        'https://api.example.com/api/greeting',
        ('API.example.com',)))

  def test_resolve_public_url_uses_configured_wildcard_base(self) -> None:
    """
      Test that wildcard patterns do not emit the request hostname.
      :return: None
    """
    self.assertEqual(
      'https://example.com/api/greeting',
      resolve_public_url(
        'https://tenant.example.com/api/greeting',
        ('*.example.com',)))

  def test_resolve_public_url_rejects_untrusted_host(self) -> None:
    """
      Test that an untrusted URL host is rejected.
      :return: None
    """
    with self.assertRaisesRegex(ValueError, 'URL host is not trusted'):
      resolve_public_url(
        'https://attacker.example/api',
        ('api.example.com',))

  def test_public_url_for_uses_application_settings(self) -> None:
    """
      Test that public_url_for uses settings stored on the application.
      :return: None
    """
    test_app = Starlette(routes=[
      Route('/url', url_response, name='url_endpoint')
    ])
    test_app.state.settings = Settings(
      debug=False,
      access_log=True,
      allowed_hosts=('API.example.com',))
    client = TestClient(test_app, 'https://api.example.com')

    response = client.get('/url')

    self.assertEqual('https://API.example.com/url', response.text)
