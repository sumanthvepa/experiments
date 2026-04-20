"""
  cbrws_v1_schema_endpoint.py: URL handler for the /profiles/cbrws/v1
  URL of the cbrws web service.
"""
from starlette.requests import Request

from cbrws.http_endpoint import LinkHeaderItem, LinkHeaderItems
from cbrws.documentation_endpoint import (
  HTMLFilename,
  JSONFilename,
  make_html_filename,
  make_json_filename
)
from cbrws.schema_endpoint import SchemaEndpoint
from cbrws.url_util import public_url_for


class CBRWSV1SchemaEndpoint(SchemaEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1 URL of the cbrws web service.

    This endpoint describes the concrete v1 CBRWS API profile.
  """
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    profile_url = public_url_for(request, 'profile_endpoint')
    return {
      'profile_url': profile_url,
      'schema_url': profile_url,
      'version': '1.0',
      'title': 'CBRWS V1 API Profile'
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('api-profile-v1.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('api-profile-v1.json')

  @classmethod
  def link_header_items(cls, request: Request) -> LinkHeaderItems:
    """
      Generate Link header item definitions.
      :param request: The HTTP request
      :return: A tuple of Link header item definitions
    """
    return (
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='profile',
        type='application/ld+json',
        title='Documentation for V1 of the CBRWS web service API'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='describedBy',
        type=cls.default_response_media_type(),
        title='JSON schema of the response'),
      LinkHeaderItem(
        route_name='profile_endpoint',
        rel='documentation',
        type='text/html',
        title='Documentation for V1 of the CBRWS web service API')
    )
