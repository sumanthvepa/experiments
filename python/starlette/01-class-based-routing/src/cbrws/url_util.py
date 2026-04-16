"""
  url_util.py: Helpers for building public URLs safely.
"""
from collections.abc import Sequence
from urllib.parse import urlsplit


def _hostname_matches(pattern: str, hostname: str) -> bool:
  """
    Check whether a hostname matches a trusted host pattern.

    * will match any hostname
    *.example.com will match example.com and any subdomain of
    example.com, but not example.com itself example.com will only
    match example.com
    Otherwise an exact match is performed. i.e. the function
    only returns true if the hostname matches the pattern
    exactly.

    :param pattern: A trusted host pattern
    :param hostname: The hostname to check
    :return: True when the hostname matches the pattern
  """
  if pattern == '*':
    return True
  if pattern.startswith('*.'):
    suffix = pattern[1:]
    return hostname.endswith(suffix) and hostname != pattern[2:]
  return hostname == pattern


def _format_origin(scheme: str, host: str, port: int | None) -> str:
  """
    Format a URL origin from trusted parts.
    :param scheme: The URL scheme
    :param host: The trusted host
    :param port: The URL port
    :return: A formatted URL origin
  """
  if port is None:
    return f'{scheme}://{host}'
  return f'{scheme}://{host}:{port}'


def resolve_public_origin(
  url: str,
  trusted_hosts: Sequence[str],
  debug: bool = False) -> str:
  """
    Resolve the public origin for a request-derived URL.

    In production mode the returned host is copied from trusted_hosts,
    not from the supplied URL. The URL may only influence which trusted
    host is selected.

    :param url: The request-derived URL
    :param trusted_hosts: The configured trusted host patterns
    :param debug: True when the application is running in debug mode
    :return: The public URL origin
  """
  if not trusted_hosts:
    raise ValueError('trusted_hosts must not be empty')
  if not debug and '*' in trusted_hosts:
    raise ValueError('trusted_hosts must not contain * when debug is false')

  parsed_url = urlsplit(url)
  if parsed_url.scheme not in {'http', 'https'}:
    raise ValueError(f'unsupported URL scheme: {parsed_url.scheme}')
  if parsed_url.hostname is None:
    raise ValueError('URL must include a hostname')

  request_hostname = parsed_url.hostname.lower()
  for trusted_host in trusted_hosts:
    normalized_host = trusted_host.lower()
    if _hostname_matches(normalized_host, request_hostname):
      if normalized_host == '*':
        return _format_origin(
          parsed_url.scheme,
          request_hostname,
          parsed_url.port)
      if normalized_host.startswith('*.'):
        return _format_origin(
          parsed_url.scheme,
          normalized_host[2:],
          parsed_url.port)
      return _format_origin(
        parsed_url.scheme,
        trusted_host,
        parsed_url.port)

  raise ValueError(f'URL host is not trusted: {request_hostname}')


def resolve_public_url(
  url: str,
  trusted_hosts: Sequence[str],
  debug: bool = False) -> str:
  """
    Resolve a public URL from a request-derived URL.

    The returned URL uses the public origin selected from trusted_hosts
    and the path and query string from the supplied URL.

    :param url: The request-derived URL
    :param trusted_hosts: The configured trusted host patterns
    :param debug: True when the application is running in debug mode
    :return: The resolved public URL
  """
  parsed_url = urlsplit(url)
  public_url = f'{resolve_public_origin(url, trusted_hosts, debug)}{parsed_url.path}'
  if parsed_url.query:
    return f'{public_url}?{parsed_url.query}'
  return public_url
