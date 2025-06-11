#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 12-docker-build-python.sh: Explore building a python Docker image
#
# Copyright (C) 2024-25 Sumanth Vepa.
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

echo '12-docker-build-python.sh'

# There isn't much to do outside of the Dockerfile to build a Python
# image
docker build --tag python-test ./python-test

# Now we can run the image
docker container run --rm python-test python -c 'print("Hello, World!")'

# We can also run the image interactively
echo 'Running a python container interactively'
echo 'Type quit() to exit'
docker container run --rm --interactive --tty python-test python

# Finally we clean up by removing the image
docker image rm python-test

