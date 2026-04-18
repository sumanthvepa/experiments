"""
  logging_config.py: Logging setup for the cbrws web service.
"""
import logging
import time

from starlette.types import ASGIApp, Message, Receive, Scope, Send

from cbrws.config import Settings


class AccessLogMiddleware:  # pylint: disable=too-few-public-methods
  """
    Middleware that logs completed HTTP requests.

    This middleware is implemented directly against the ASGI interface
    instead of Starlette's BaseHTTPMiddleware helper. Access logging only
    needs transport-level metadata and the final response status, so
    wrapping the ASGI send callable is enough. Staying at the ASGI layer
    avoids BaseHTTPMiddleware's extra request/response adaptation and its
    known limitations around streaming bodies.
  """
  def __init__(self, app: ASGIApp, settings: Settings) -> None:
    """
      Initialize the middleware.
      :param app: The wrapped ASGI application
      :param settings: The application settings
    """
    self.app = app
    self.settings = settings
    self.logger = logging.getLogger('cbrws.access')

  async def __call__(
    self,
    scope: Scope,
    receive: Receive,
    send: Send) -> None:
    """
      Log completed HTTP requests.
      :param scope: The ASGI connection scope
      :param receive: The ASGI receive callable
      :param send: The ASGI send callable
      :return: None
    """
    if scope['type'] != 'http':
      await self.app(scope, receive, send)
      return

    start = time.perf_counter()
    status_code = 500

    async def send_wrapper(message: Message) -> None:
      """
        Observe the response status before forwarding the ASGI message.
        :param message: The ASGI message
        :return: None
      """
      nonlocal status_code
      if message['type'] == 'http.response.start':
        status_code = message['status']
      await send(message)

    try:
      await self.app(scope, receive, send_wrapper)
    finally:
      duration_ms = (time.perf_counter() - start) * 1000
      if self.settings.access_log:
        client_host = '-'
        client = scope.get('client')
        if isinstance(client, tuple) and client:
          client_host = str(client[0])
        self.logger.info(
          'request completed method=%s path=%s status=%s duration_ms=%.2f client=%s',
          scope['method'],
          scope['path'],
          status_code,
          duration_ms,
          client_host)
