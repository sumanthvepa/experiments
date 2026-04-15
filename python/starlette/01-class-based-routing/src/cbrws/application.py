"""
  application.py: Entry point to the cbrws web service.
  cbrws stands for Class Based Routing Web Service.
"""
from collections.abc import Sequence

from starlette.types import ASGIApp, ExceptionHandler
from starlette.applications import Starlette
from starlette.middleware import Middleware
from starlette.middleware.trustedhost import TrustedHostMiddleware
from starlette.routing import Route

from cbrws.config import Settings, settings_from_env
from cbrws.logging_config import AccessLogMiddleware
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
  Route('/',
        endpoint=RootEndpoint,
        name='root_endpoint'),
  Route('/api',
        endpoint=APIEndpoint,
        name='api_endpoint'),
  Route('/api/greeting',
        endpoint=GreetingEndpoint,
        name='greeting_endpoint'),
  Route('/profiles/',
        endpoint=ProfilesEndpoint,
        name='profiles_endpoint'),
  Route('/profiles/cbrws/v1/rels/',
        endpoint=RelationsEndpoint,
        name='relations_endpoint'),
  Route('/profiles/cbrws/v1/rels/greeting',
        endpoint=GreetingRelationProfileEndpoint,
        name='greeting_relation_endpoint'),
  Route('/profiles/cbrws', endpoint=CBRWSProfilesEndpoint,
        name='cbrws_profiles_endpoint'),
  Route('/profiles/cbrws/v1',
        endpoint=CBRWSV1ProfileEndpoint,
        name='profile_endpoint')
]
exception_handlers: dict[int, ExceptionHandler] = {404: not_found}


def trusted_host_middleware(
  asgi_app: ASGIApp,
  allowed_hosts: Sequence[str]) -> ASGIApp:
  """
    Build the trusted host middleware.

    Starlette's Middleware helper expects a factory function that takes
    an ASGI application and returns an ASGI application. Passing the
    TrustedHostMiddleware class directly works at runtime because
    calling the class creates an ASGI application, but IntelliJ IDEA
    does not detect that this satisfies the factory type. This wrapper
    gives the type checker the factory shape it expects.

    :param asgi_app: The ASGI application to wrap
    :param allowed_hosts: The accepted Host header values
    :return: The wrapped ASGI application
  """
  return TrustedHostMiddleware(asgi_app, allowed_hosts=allowed_hosts)


def access_log_middleware(
  asgi_app: ASGIApp,
  app_settings: Settings) -> ASGIApp:
  """
    Build the access log middleware.

    Starlette's Middleware helper expects a factory function that takes
    an ASGI application and returns an ASGI application. Passing the
    AccessLogMiddleware class directly works at runtime because calling
    the class creates an ASGI application, but IntelliJ IDEA does not
    detect that this satisfies the factory type. This wrapper gives the
    type checker the factory shape it expects.

    :param asgi_app: The ASGI application to wrap
    :param app_settings: The application settings
    :return: The wrapped ASGI application
  """
  return AccessLogMiddleware(asgi_app, settings=app_settings)


def application_middleware(app_settings: Settings) -> list[Middleware]:
  """
    Build the application middleware stack.
    :param app_settings: The application settings
    :return: The configured middleware list
  """
  # TrustedHostMiddleware rejects requests whose Host header is not in
  # the configured allow list. The service builds absolute URLs from
  # request data, so validating Host prevents clients from smuggling an
  # unexpected public host through a reverse proxy and into generated
  # links.
  return [
    Middleware(
      trusted_host_middleware,
      allowed_hosts=list(app_settings.allowed_hosts)),
    Middleware(access_log_middleware, app_settings=app_settings)
  ]


settings = settings_from_env()
app = Starlette(
  debug=settings.debug,
  routes=routes,
  exception_handlers=exception_handlers,
  middleware=application_middleware(settings))


# See README.md for how to run the application with uvicorn.
