"""
  cbrws_directory_endpoint.py: URL handler for the /profiles/cbrws URL of
  the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint import LinkHeaderItem, LinkHeaderItems
from cbrws.template_endpoint import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.documentation_directory_endpoint import DocumentationDirectoryEndpoint
from cbrws.url_util import public_url_for


class CBRWSDirectoryEndpoint(DocumentationDirectoryEndpoint):
  """
    A URL handler for the /profiles/cbrws URL of the cbrws web service.

    This endpoint lists the versions of the CBRWS profile supported by
    the service.
  """
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    return {
      'cbrws_profile_url': public_url_for(request, 'cbrws_profiles_endpoint'),
      'cbrws_v1_profile_url': public_url_for(request, 'profile_endpoint')
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('cbrws-profiles.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('cbrws-profiles.json')

  @classmethod
  def link_header_items(cls, request: Request) -> LinkHeaderItems:
    """
      Generate Link header item definitions.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      LinkHeaderItem(
        route_name='cbrws_profiles_endpoint',
        rel='self',
        type=cls.default_response_media_type()),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='item',
        type='application/schema+json',
        title='CBRWS v1 API profile')
    )
