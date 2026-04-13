"""
  not_found.py: URL handler for 404 Not Found errors in the cbrws
  webservice.
"""
import logging

from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette import status


logger = logging.getLogger('cbrws.http')


# noinspection PyUnusedLocal
async def not_found(
  request: Request,
  ex: Exception) -> JSONResponse:  # pylint: disable=unused-argument
  """
    Handle 404 Not Found errors.
    :param request: The HTTP request
    :param ex: The exception that triggered this handler
    :return: A JSON response with a 404 status code and an error message
  """
  logger.info(
    'not found method=%s path=%s',
    request.method,
    request.url.path)
  # The error response conforms to RFC 7807 (Problem Details for HTTP APIs)
  # https://datatracker.ietf.org/doc/html/rfc7807
  # The MDN documentation link for Not Found used as a URI
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/404
  # to uniquely identify the error type.
  error = {
    'type': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/404',
    'title': 'Not Found',
    'status': status.HTTP_404_NOT_FOUND,
    # pylint: disable=line-too-long
    'detail': 'The requested resource was not found on this server. '
              + 'Please check the URL and try again.',
  }
  return JSONResponse(
    error,
    status_code=status.HTTP_404_NOT_FOUND)
