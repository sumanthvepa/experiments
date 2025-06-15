#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 13-docker-build-flask.sh: Explore building a flask application image
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

echo '13-docker-build-flask.sh'

# We will use the docker-build-flask-test-utilities.sh script to build
# and run the flask-test image. This script contains utility functions
# that will help us build and run the flask-test image.
# See the script for details on how to build a flask server image.
source ./docker-build-flask-test-utilities.sh

# First we need to build the flask-test image.
build_flask_test_image
if [[ $? -ne 0 ]]; then
  echo "Failed to build the flask-test image. Exiting."
  exit 1
fi

# Now we can run a container using the flask-test image.
run_flask_test_container flask-test 5000
if [[ $? -ne 0 ]]; then
  echo "Failed to run the flask-test container. Exiting."
  exit 1
fi

# You can now query the flask API
curl http://localhost:5000/ 

# There isn't much to do outside of the Dockerfile to build
# a Flask application image.
docker build --tag flask-test ./flask-test

# Clean up after this exploration
docker container stop flask-test
docker wait flask-test
docker container rm flask-test
docker image rm flask-test
