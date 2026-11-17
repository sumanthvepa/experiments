# flask_test.py: A simple Flask application that returns JSON
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

"""
  explore_flask.py: A simple flask application that returns a
  json string
"""
from flask import Flask, jsonify, Response

app = Flask(__name__)

@app.route('/')
def flask_test() -> Response:
  """
    Return a JSON dictionary indicating that the python app works
    :returns
  """
  message = {'flask_test': 'works'}
  return jsonify(message)
