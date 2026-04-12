"""
  accept_util.py: Utilities for HTTP Accept header negotiation.
"""
from collections.abc import Iterable

from werkzeug.datastructures import MIMEAccept
from werkzeug.http import parse_accept_header


def select_media_type(
  accept_header: str | None,
  supported_media_types: Iterable[str]) -> str | None:
  """
    Select the best supported media type for an Accept header.
    :param accept_header: The HTTP Accept header value
    :param supported_media_types: Concrete media types the endpoint can return
    :return: The selected media type, or None if no media type is acceptable
  """
  media_types = [
    media_type
    for media_type in supported_media_types
    if media_type != '*/*'
  ]
  if not media_types:
    return None

  accept = parse_accept_header(accept_header or '*/*', MIMEAccept)
  return accept.best_match(media_types)
