"""
  root_endpoint.py: URL handler for the root URL of the cbrws
  web service.
"""
from starlette.requests import Request
from starlette.responses import RedirectResponse
from starlette import status

from cbrws.functional_endpoint import FunctionalEndpoint


class RootEndpoint(FunctionalEndpoint):
  """
    A URL handler for the root URL of the cbrws web service.
    It handles GET, HEAD, and OPTIONS requests.

    This is a class based routing endpoint. The class
    handles all requests to the root URL ('/') of the web service.

    As a matter of convention, all web services should provide
    actual service at the /api endpoint. The root URL should
    always redirect to the /api endpoint.
  """
  # noinspection PyMethodMayBeStatic,PyUnusedLocal
  async def get(
        self, request: Request) -> RedirectResponse:  # pylint: disable=unused-argument
    """
      Redirect GET requests to the API endpoint.
      :param request: The HTTP request
      :return: A 308 Permanent Redirect response
    """
    return RedirectResponse(
      url='/api', status_code=status.HTTP_308_PERMANENT_REDIRECT)
