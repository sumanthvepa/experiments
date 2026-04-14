"""
  link_header.py: Parse and validate the Link header in HTTP responses.
"""
from typing import Any

class Link:
  """
    Represents a single link in the Link header.
    :param url: The URL of the link
    :param rel: The relationship type of the link
    :param media_type: The media type of the link (optional)
    :param title: The title of the link (optional)
  """
  def __init__(self, url: str, rel: str, media_type: str | None = None, title: str | None = None):
    self.url = url
    self.rel = rel
    self.media_type = media_type
    self.title = title

  def __repr__(self) -> str:
    return f'Link(url={self.url}, rel={self.rel}, media_type={self.media_type}, title={self.title})'

  def __eq__(self, other: Any) -> bool:
    if not isinstance(other, Link):
      return NotImplemented
    return (self.url == other.url and
            self.rel == other.rel and
            self.media_type == other.media_type and
            self.title == other.title)


def parse(link_header: str) -> dict[str, Link]:
  """
    Parse the Link header and return a dictionary of links.
    :param link_header: The Link header as a string
    :return: A dictionary of links
  """
  links: dict[str, Link] = {}
  for link_str in link_header.split(', '):
    parts = link_str.split('; ')
    url = parts[0].strip('<>')
    rel: str | None = None
    media_type: str | None = None
    title: str | None = None
    for part in parts[1:]:
      if '=' not in part:
        raise ValueError('Malformed Link header component (expecting key = value): ' + part)
      key, value = part.split('=', 1)
      key = key.strip()
      value = value.strip('"')
      if key == 'rel':
        rel = value
      elif key == 'type':
        media_type = value
      elif key == 'title':
        title = value
      else:
        raise ValueError('Unknown key in Link header component: ' + key)
    if rel is None:
      raise ValueError('Missing rel attribute in Link header component: ' + link_header)
    link = Link(url, rel, media_type, title)
    links[rel] = link
  if not links:
    raise ValueError('No valid links found in Link header: ' + link_header)
  return links
