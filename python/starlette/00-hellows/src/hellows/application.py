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
  # Note that Chrome will not allow you to connect to a web service
  # running on certain ports. 5100 is not one of those ports, so you
  # okay here. But ports like 6000 will be blocked with an
  # ERR_UNSAFE_PORT.
  # To overcome this you need to either use a different browser or
  # launch Chrome from the command line as follows (on the Mac):
  # open -na "Google Chrome" --args --explicitly-allowed-ports=6000 --profile-directory="<Profile Directory Name>"
  # The profile directory name can be "Default" or One of the profile
  # directories listed at ~/Library/Application Support/Google/Chrome/
  uvicorn.run(app, host='0.0.0.0', port=5100)
