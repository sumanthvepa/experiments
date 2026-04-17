"""
  cbrws_profiles_endpoint.py: URL handler for the /profiles/cbrws URL of
  the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint_base import LinkHeaderItem, LinkHeaderItems
from cbrws.profile_endpoint_base import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.profile_directory_endpoint import ProfileDirectoryEndpoint


class CBRWSProfilesEndpoint(ProfileDirectoryEndpoint):
  """
    A URL handler for the /profiles/cbrws URL of the cbrws web service.

    This endpoint lists the versions of the CBRWS profile supported by
    the service.
  """
  URL_CONTEXT = {
    'cbrws_profile_url': 'cbrws_profiles_endpoint',
    'cbrws_v1_profile_url': 'profile_endpoint'
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
        type=ProfileDirectoryEndpoint.response_media_type()),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='item',
        type='application/schema+json',
        title='CBRWS v1 API profile')
    )
