"""
  relations_directory_endpoint.py: URL handler for the /profiles/cbrws/v1/rels/
  URL of the cbrws web service.
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


class RelationsDirectoryEndpoint(DirectoryEndpoint):
  """
    A URL handler for the /profiles/cbrws/v1/rels/ URL of the cbrws
    web service.

    This endpoint lists the custom link relations defined by the v1
    CBRWS API. Each entry links to the documentation for a single
    relation.
  """
  @classmethod
  def context(cls, request: Request) -> dict[str, str]:
    # Imports are placed here to avoid circular import issues
    # pylint still detects a circular import, but it does not
    # occur in practice, because the imports happen at runtime,
    # not at the module level.
    # pylint: disable=cyclic-import, import-outside-toplevel
    from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
    relations_directory_url = public_url_for(request, cls.route_name())
    return {
      'relations_directory_url': relations_directory_url,
      'greeting_relation_url': public_url_for(
        request, GreetingSchemaEndpoint.route_name()),
      'curie_href_template': (
        relations_directory_url.rstrip('/') + '/{rel}'),
      'description': (
        'This endpoint lists the custom link relations defined by '
        'the v1 CBRWS API. A link relation is the short name used '
        'as a key inside the _links block of a HAL+JSON response; '
        'it tells the client what a linked resource is in relation '
        'to the current one. Each entry below points to the '
        'documentation for one such relation. The response is '
        'available as HAL+JSON (the default, for machine '
        'consumption) or as HTML (for human reading) via content '
        'negotiation on the Accept header.')
    }

  @classmethod
  def html_filename(cls) -> HTMLFilename:
    """
      Return the HTML template filename for the endpoint.
      :return: An HTML filename
    """
    return make_html_filename('relations-directory.jinja2')

  @classmethod
  def json_filename(cls) -> JSONFilename:
    """
      Return the JSON filename for the endpoint.
      :return: A JSON filename
    """
    return make_json_filename('relations-directory.json')
