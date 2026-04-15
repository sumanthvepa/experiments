"""
  logging_config.py: Logging setup for the cbrws web service.
"""
import logging
import time

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response

from cbrws.config import Settings


class AccessLogMiddleware(BaseHTTPMiddleware):
  """
    Middleware that logs completed HTTP requests.
  """
  def __init__(self, app: object, settings: Settings) -> None:
    """
      Initialize the middleware.
      :param app: The wrapped ASGI application
      :param settings: The application settings
    """
    super().__init__(app)
    self.settings = settings
    self.logger = logging.getLogger('cbrws.access')

  async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint) -> Response:
    """
      Log completed HTTP requests.
      :param request: The HTTP request
      :param call_next: The next request handler
      :return: The HTTP response
    """
    start = time.perf_counter()
    response = await call_next(request)
    duration_ms = (time.perf_counter() - start) * 1000
    if self.settings.access_log:
      client = request.client.host if request.client else '-'
      self.logger.info(
        'request completed method=%s path=%s status=%s duration_ms=%.2f client=%s',
        request.method,
        request.url.path,
        response.status_code,
        duration_ms,
        client)
    return response

