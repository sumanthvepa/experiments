"""
  test_application.py: Unit tests for the application module.
"""
# -------------------------------------------------------------------
# test_application.py: Unit tests for the application module.
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
import unittest

from starlette.testclient import TestClient

from mws.application import app


class TestApplication(unittest.TestCase):
  """
    Unit tests for the application module.
  """
  def test_root_returns_ok(self) -> None:
    """
      Test that a GET request to the root returns 200.
      :return: None
    """
    client = TestClient(app)
    response = client.get('/')
    self.assertEqual(200, response.status_code)

  def test_root_returns_hello_message(self) -> None:
    """
      Test that the root returns the hello message as JSON.
      :return: None
    """
    client = TestClient(app)
    response = client.get('/')
    self.assertEqual({'message': 'hello'}, response.json())

  def test_root_returns_json_content_type(self) -> None:
    """
      Test that the root responds with a JSON content type.
      :return: None
    """
    client = TestClient(app)
    response = client.get('/')
    self.assertEqual('application/json', response.headers['content-type'])

  def test_unknown_path_returns_not_found(self) -> None:
    """
      Test that an unknown path returns 404.
      :return: None
    """
    client = TestClient(app)
    response = client.get('/unknown')
    self.assertEqual(404, response.status_code)

  def test_post_to_root_returns_method_not_allowed(self) -> None:
    """
      Test that a POST request to the root returns 405.
      :return: None
    """
    client = TestClient(app)
    response = client.post('/')
    self.assertEqual(405, response.status_code)
