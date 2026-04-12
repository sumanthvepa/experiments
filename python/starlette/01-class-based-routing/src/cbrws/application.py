"""
  application.py: Entry point to the cbrws web service.
  cbrws stands for Class Based Routing Web Service.
"""
from starlette.types import ExceptionHandler
from starlette.applications import Starlette
from starlette.routing import Route

from cbrws.cbrws_base_endpoint import CBRWSBaseEndpoint
from cbrws.root_endpoint import RootEndpoint
from cbrws.api_endpoint import APIEndpoint
from cbrws.greeting_endpoint import GreetingEndpoint
from cbrws.greeting_relation_profile_endpoint import GreetingRelationProfileEndpoint
from cbrws.relations_endpoint import RelationsEndpoint
from cbrws.profiles_endpoint import ProfilesEndpoint
from cbrws.cbrws_profiles_endpoint import CBRWSProfilesEndpoint
from cbrws.cbrws_v1_profile_endpoint import CBRWSV1ProfileEndpoint
from cbrws.not_found import not_found


routes: list[Route] = [
  Route('/', endpoint=RootEndpoint, name='root_endpoint'),
  Route('/api', endpoint=APIEndpoint, name='api_endpoint'),
  Route('/api/greeting', endpoint=GreetingEndpoint, name='greeting_endpoint'),
  Route('/profiles/', endpoint=ProfilesEndpoint, name='profiles_endpoint'),
  Route('/profiles/cbrws/v1/rels/', endpoint=RelationsEndpoint,
        name='relations_endpoint'),
  Route('/profiles/cbrws/v1/rels/greeting',
        endpoint=GreetingRelationProfileEndpoint,
        name='greeting_relation_endpoint'),
  Route('/profiles/cbrws', endpoint=CBRWSProfilesEndpoint,
        name='cbrws_profiles_endpoint'),
  Route(CBRWSBaseEndpoint.PROFILE_PATH, endpoint=CBRWSV1ProfileEndpoint, name='profile_endpoint')
]
exception_handlers: dict[int, ExceptionHandler] = {404: not_found}
app = Starlette(
  debug=True,
  routes=routes,
  exception_handlers=exception_handlers)


if __name__ == '__main__':
  import uvicorn
  # Note that Chrome will not allow you to connect to a web service
  # running on certain ports. 6000 is one of those ports, so you
  # will need to either use a different browser or launch Chrome
  # from the command line as follows (on the Mac):
  # open -na "Google Chrome" --args --explicitly-allowed-ports=6000
  # --profile-directory="<Profile Directory Name>"
  # The profile directory name can be "Default" or One of the profile
  # directories listed at ~/Library/Application Support/Google/Chrome/
  uvicorn.run(app, host='0.0.0.0', port=5101)
