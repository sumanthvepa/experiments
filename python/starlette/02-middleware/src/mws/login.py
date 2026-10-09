from starlette.authentication import AuthCredentials, AuthenticationBackend, SimpleUser

SESSIONS = {"abc123": "alice"}      # session id -> username (in-memory, for the exercise)

class CookieBackend(AuthenticationBackend):
    async def authenticate(self, conn):
        user = SESSIONS.get(conn.cookies.get("session"))
        if user is None:
            return None             # becomes UnauthenticatedUser
        return AuthCredentials(["authenticated"]), SimpleUser(user)


# from starlette.responses import RedirectResponse

# class LoginGateMiddleware:
#     def __init__(self, app, public_paths=("/hello",), redirect_to="/hello"):
#         self.app = app
#         self.public_paths = set(public_paths)
#         self.redirect_to = redirect_to

#     async def __call__(self, scope, receive, send):
#         if (scope["type"] == "http"
#                 and scope["path"] not in self.public_paths
#                 and not scope["user"].is_authenticated):
#             response = RedirectResponse(self.redirect_to, status_code=303)
#             await response(scope, receive, send)
#             return
#         await self.app(scope, receive, send)