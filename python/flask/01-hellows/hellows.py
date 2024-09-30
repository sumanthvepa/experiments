#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  hellows.py: A flask app that respond with JSON {"greeting": "hello"}
"""
# -------------------------------------------------------------------
# hellows.py: A flask app that respond with JSON {"greeting": "hello"}
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License a
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

from flask import Flask, jsonify, Response

app = Flask(__name__)


# See 00-hellows to see how to set up a flask project on
# the command line, in IntellJ IDEA and VSCode.
@app.route('/')
def hello() -> Response:
  """ Return the JSON response {"greeting": "hello"} """
  # This code is different from 00-hellows in that it returns
  # JSON response. The Flask function jsonify is used to convert
  # a python dictionary into a Response object. Note that we
  # have had to import Response so that type hinting can
  # specify Response as the return type.
  message = {'greeting': 'hello'}
  return jsonify(message)
