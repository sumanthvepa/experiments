"""
  application.py: Entry point to the hellows webservice
"""
from urllib.request import Request

from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route


# pylint: disable=unused-argument
# noinspection PyUnusedLocal
async def home(request: Request) -> JSONResponse:
  """
    Return a JSON message with a greeting
    :param request: The HTTP request
    :return: A JSON response
  """
  message = {'greeting': 'hello'}
  return JSONResponse(message)


app = Starlette(debug=True, routes=[
  Route('/', home)
])

if __name__ == '__main__':
  import uvicorn
  uvicorn.run(app, host='0.0.0.0', port=5100)
