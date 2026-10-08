"""
  application.py: A Starlette web service that illustrates middleware.
"""
# -------------------------------------------------------------------
# application.py: A Starlette web service that illustrates middleware.
#
# Copyright (C) 2026 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------
from starlette.applications import Starlette
from starlette.endpoints import HTTPEndpoint
from starlette.middleware import Middleware as DeferConstruction
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette.routing import Route

from mws.logger import SimpleLogger, FullASGIAccessLogger


class Hello(HTTPEndpoint):
  """
    Endpoint that responds with a hello message.

    This is just a simple HTTP endpoint used to illustrate how
    middleware works in a Starlette application.
  """
  async def get(self, request: Request) -> JSONResponse:
    """
      Handle a GET request.
      :param request: The incoming request
      :return: A JSON response containing a hello message
    """
    return JSONResponse({'message': 'hello'})


starlette_app = Starlette(
  routes=[Route('/', Hello)],
  # This logger operates at the middleware level and logs requests
  # and responses as they pass through. It is simpler and less
  # intrusive than the FullASGIAccessLogger, but it does not have
  # access to the full ASGI scope.
  middleware=[DeferConstruction(SimpleLogger)]
)

# The FullASGIAccessLogger wraps the Starlette app to provide detailed
# logging of all ASGI events. Notice that its maessages are not
# filtered and edited with 'INFO' or 'DEBUG' or any log level. This is
# entirely outside of starlette's logging mechanism.

# The benefit is that it can capture and log all ASGI events,
# providing complete visibility into the request and response
# lifecycle.

# The down side is that it  gets none of the built-in Starlette
# logging features, such as structured log messages and log levels.
app = FullASGIAccessLogger(starlette_app)
# app = starlette_app