"""
  profiles_endpoint.py: URL handler for the /profiles/ URL of the cbrws
  web service.
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


class ProfilesEndpoint(ProfileDirectoryEndpoint):
  """
    A URL handler for the /profiles/ URL of the cbrws web service.

    This endpoint lists the profile families supported by the service.
  """
  URL_CONTEXT = {
    'profiles_url': 'profiles_endpoint',
    'cbrws_profile_url': 'cbrws_profiles_endpoint'
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

  @classmethod
  def link_header_items(cls, request: Request) -> LinkHeaderItems:
    """
      Generate Link header item definitions.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      LinkHeaderItem(
        route_name='profiles_endpoint',
        rel='self',
        type=ProfileDirectoryEndpoint.response_media_type()),
      LinkHeaderItem(
        route_name='cbrws_profiles_endpoint',
        rel='item',
        type=ProfileDirectoryEndpoint.response_media_type(),
        title='CBRWS profile family')
    )
