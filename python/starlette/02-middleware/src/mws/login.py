"""
  login.py: Cookie based sign in for the middleware experiment.
"""
# -------------------------------------------------------------------
# login.py: Cookie based sign in for the middleware experiment.
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
import hashlib
import hmac
import secrets

from starlette.authentication import (
  AuthCredentials,
  AuthenticationBackend,
  BaseUser,
  SimpleUser)
from starlette.requests import HTTPConnection

# Session id -> username (in-memory, for the exercise). In a real
# application these ids would be generated at sign in, would expire,
# and would not be known in advance.
SESSIONS: dict[str, str] = {
  'abc123': 'alice',
  'def456': 'bob'
}

_SCRYPT_N = 2 ** 14
_SCRYPT_R = 8
_SCRYPT_P = 1
_SCRYPT_DKLEN = 32
_SALT_BYTES = 16


def _encode(password: str) -> bytes:
  """
    Encode a password as bytes.

    Lone surrogates, which JSON allows in a string, are kept instead of
    raising an error.

    :param password: The password
    :return: The password as UTF-8 bytes
  """
  return password.encode('utf-8', errors='surrogatepass')


def hash_password(password: str, salt: bytes | None = None) -> str:
  """
    Hash a password with scrypt.

    The result has the form scrypt$n$r$p$salt$hash, where the salt and
    the hash are in hex. Keeping the parameters in the string allows
    them to change later without breaking existing hashes.

    :param password: The password to hash
    :param salt: The salt to use. A random salt is used if it is None.
    :return: The hash of the password
  """
  if salt is None:
    salt = secrets.token_bytes(_SALT_BYTES)
  digest = hashlib.scrypt(
    _encode(password),
    salt=salt,
    n=_SCRYPT_N,
    r=_SCRYPT_R,
    p=_SCRYPT_P,
    dklen=_SCRYPT_DKLEN)
  return '$'.join([
    'scrypt',
    str(_SCRYPT_N),
    str(_SCRYPT_R),
    str(_SCRYPT_P),
    salt.hex(),
    digest.hex()])


def verify_password(password: str, stored: str) -> bool:
  """
    Check a password against a hash made by hash_password.

    The hash is recomputed with the parameters and salt stored in the
    string and compared in constant time.

    :param password: The password to check
    :param stored: The hash to check the password against
    :return: True if the password matches the hash
    :raises ValueError: If the stored hash is not in the expected form
  """
  scheme, n, r, p, salt_hex, hash_hex = stored.split('$')
  if scheme != 'scrypt':
    raise ValueError(f'unsupported password hash scheme: {scheme}')
  expected = bytes.fromhex(hash_hex)
  actual = hashlib.scrypt(
    _encode(password),
    salt=bytes.fromhex(salt_hex),
    n=int(n),
    r=int(r),
    p=int(p),
    dklen=len(expected))
  return hmac.compare_digest(actual, expected)


# Username -> password hash. Hard coded for the exercise. The hashes
# are computed when the module is loaded, with a new random salt each
# time.
USERS: dict[str, str] = {
  'alice': hash_password('imalice'),
  'bob': hash_password('imbob')
}

# Checked against when the username is unknown, so that an unknown
# username takes as long as a wrong password.
_DUMMY_HASH = hash_password('not a real password')


def check_credentials(username: str, password: str) -> bool:
  """
    Check a username and password against the known users.

    If the username is unknown, a dummy hash is still computed, so that
    the time taken does not reveal which usernames exist. This is slow
    (tens of milliseconds), so call it from a thread in async code.

    :param username: The username
    :param password: The password
    :return: True if the username is known and the password matches
  """
  stored = USERS.get(username)
  if stored is None:
    verify_password(password, _DUMMY_HASH)
    return False
  return verify_password(password, stored)


def session_id_for(username: str) -> str | None:
  """
    Find the session id of a user in SESSIONS.

    :param username: The username
    :return: The session id of the user, or None if the user has none
  """
  for session_id, user in SESSIONS.items():
    if user == username:
      return session_id
  return None


class CookieBackend(AuthenticationBackend):
  """
    Authentication backend that identifies a user by the session cookie.
  """
  async def authenticate(
        self,
        conn: HTTPConnection) -> tuple[AuthCredentials, BaseUser] | None:
    """
      Identify the user from the 'session' cookie.

      :param conn: The connection to authenticate
      :return: The credentials and the user if the session is known.
               None otherwise, which Starlette turns into an
               UnauthenticatedUser.
    """
    session_id = conn.cookies.get('session')
    if session_id is None:
      return None
    user = SESSIONS.get(session_id)
    if user is None:
      return None
    return AuthCredentials(['authenticated']), SimpleUser(user)


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
