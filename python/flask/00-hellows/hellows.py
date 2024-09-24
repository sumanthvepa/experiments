#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  hellows.py: A simple flask application that sends the string 'hello'
"""
# -------------------------------------------------------------------
# hellows.py: A simple flask application that sends the string 'hello'
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

from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello() -> str:
  """ Return the string 'hello'"""
  return "hello"
