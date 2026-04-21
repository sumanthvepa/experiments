"""
  cbrws_directory_endpoint.py: URL handler for the /profiles/cbrws URL of
  the cbrws web service.
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


class CBRWSDirectoryEndpoint(DirectoryEndpoint):
  """
    A URL handler for the /profiles/cbrws URL of the cbrws web service.

    This endpoint lists the versions of the CBRWS profile supported by
    the service.
  """
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    # Imports are placed here to avoid circular import issues
    # pylint still detects a circular import, but it does not
    # occur in practice, because the imports happen at runtime,
    # not at the module level.
    # pylint: disable=cyclic-import, import-outside-toplevel
    from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
    return {
      'cbrws_directory_url': public_url_for(request, cls.route_name()),
      'api_v1_schema_url': public_url_for(request, APIV1SchemaEndpoint.route_name()),
      'description': (
        'This endpoint lists the versions of the CBRWS schema '
        'supported by this web service. Each version describes the '
        'structure of responses from the CBRWS API, including the '
        'discovery document and its custom link relations. Clients '
        'can use this directory to locate the JSON Schema for the '
        'version that their API responses conform to. The '
        'response is available as HAL+JSON (the default, for machine '
        'consumption) or as HTML (for human reading) via content '
        'negotiation on the Accept header.')
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('cbrws-directory.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('cbrws-directory.json')
