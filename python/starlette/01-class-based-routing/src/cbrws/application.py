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
from cbrws.greeting_schema_endpoint import GreetingSchemaEndpoint
from cbrws.relations_directory_endpoint import RelationsDirectoryEndpoint
from cbrws.profiles_directory_endpoint import ProfilesDirectoryEndpoint
from cbrws.cbrws_directory_endpoint import CBRWSDirectoryEndpoint
from cbrws.api_v1_schema_endpoint import APIV1SchemaEndpoint
from cbrws.not_found import not_found


routes: list[Route] = [
  Route('/',
        endpoint=RootEndpoint,
        name=RootEndpoint.route_name()),
  Route('/api',
        endpoint=APIEndpoint,
        name=APIEndpoint.route_name()),
  Route('/api/greeting',
        endpoint=GreetingEndpoint,
        name=GreetingEndpoint.route_name()),
  Route('/profiles/',
        endpoint=ProfilesDirectoryEndpoint,
        name=ProfilesDirectoryEndpoint.route_name()),
  Route('/profiles/cbrws/v1/rels/',
        endpoint=RelationsDirectoryEndpoint,
        name=RelationsDirectoryEndpoint.route_name()),
  Route('/profiles/cbrws/v1/rels/greeting',
        endpoint=GreetingSchemaEndpoint,
        name=GreetingSchemaEndpoint.route_name()),
  Route('/profiles/cbrws', endpoint=CBRWSDirectoryEndpoint,
        name=CBRWSDirectoryEndpoint.route_name()),
  Route('/profiles/cbrws/v1',
        endpoint=APIV1SchemaEndpoint,
        name=APIV1SchemaEndpoint.route_name())
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


def access_log_middleware(asgi_app: ASGIApp) -> ASGIApp:
  """
    Build the access log middleware.

    Starlette's Middleware helper expects a factory function that takes
    an ASGI application and returns an ASGI application. Passing the
    AccessLogMiddleware class directly works at runtime because calling
    the class creates an ASGI application, but IntelliJ IDEA does not
    detect that this satisfies the factory type. This wrapper gives the
    type checker the factory shape it expects.

    :param asgi_app: The ASGI application to wrap
    :return: The wrapped ASGI application
  """
  return AccessLogMiddleware(asgi_app)


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
    Middleware(access_log_middleware)
  ]


def validate_settings(app_settings: Settings) -> None:
  """
    Validate settings that affect public URL generation.
    :param app_settings: The application settings
    :return: None
  """
  if not app_settings.debug and '*' in app_settings.allowed_hosts:
    raise ValueError(
      'CBRWS_ALLOWED_HOSTS must not contain * when CBRWS_DEBUG is false')


settings = settings_from_env()
validate_settings(settings)
app = Starlette(
  debug=settings.debug,
  routes=routes,
  exception_handlers=exception_handlers,
  middleware=application_middleware(settings))
# Endpoint modules use request.app.state.settings when converting
# request.url_for() output into public URLs. Keeping settings on the
# app gives request handlers the configured trusted-host policy without
# importing this application module back into endpoint modules.
app.state.settings = settings


# See README.md for how to run the application with uvicorn.
