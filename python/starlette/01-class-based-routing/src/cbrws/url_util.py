"""
  url_util.py: Utility functions for URL handling in the cbrws web
  service.
"""
from starlette.requests import Request


def make_url(request: Request, path: str) -> str:
  """
    Create a URL for the given path based on the request's scheme and netloc.
    This is used to construct URLs for schema and media type links.
    :param request: The HTTP request
    :param path: The path to append to the base URL
    :return: A URL for the given path
  """
  return f'{request.url.scheme}://{request.url.netloc}/{path}'
