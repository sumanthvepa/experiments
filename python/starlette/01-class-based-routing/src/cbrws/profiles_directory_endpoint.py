"""
  profiles_directory_endpoint.py: URL handler for the /profiles/ URL of the cbrws
  web service.
"""
from starlette.requests import Request

from cbrws.template_endpoint import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.directory_endpoint import DirectoryEndpoint
from cbrws.url_util import public_url_for


class ProfilesDirectoryEndpoint(DirectoryEndpoint):
  """
    A URL handler for the /profiles/ URL of the cbrws web service.

    This endpoint lists the profile families supported by the service.
  """
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    # pylint: disable=import-outside-toplevel
    from cbrws.cbrws_directory_endpoint import CBRWSDirectoryEndpoint
    return {
      'profiles_directory_url': public_url_for(request, cls.route_name()),
      'cbrws_directory_url': public_url_for(
        request, CBRWSDirectoryEndpoint.route_name()),
      'description': (
        'This endpoint is the top-level directory of all profile '
        'families supported by the CBRWS web service. A profile is '
        'a document that describes the structure and meaning of an '
        'API response. It tells a client what fields to expect, what '
        'links are available, and what each one means. Profiles are '
        'organized into families, where each family groups related '
        'profiles across versions. This directory lists the available '
        'profile families. Each entry links to a sub-directory that '
        'lists the versions within that family. Clients can use this '
        'directory to discover which profiles the service supports '
        'and navigate to the documentation for any specific endpoint. '
        'The response is available as HAL+JSON (the default, for '
        'machine consumption) or as HTML (for human reading) via '
        'content negotiation on the Accept header.')
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('profiles.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('profiles.json')
