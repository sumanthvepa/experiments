#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 05-docker-envvars.sh: Explore passing environment variables to
# Docker containers
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

# To demonstrate the use of environment variables in Docker containers
# we are going to use a custom image that runs the curl command with
# the value of the environment variable FETCH_URL
# We will build the docker image and then delete it at the end of the
# script.
docker build --tag curl-test ./curl-test

# You can see that the image has been created
docker image ls

# You can pass environment variable to docker containers using the
# -e/--env flag
# Set the environment variable on the host and pass the name of the
# environment variable to the docker run command via the --env option
# In the following example we pass the environment variable
# FETCH_URL=http://www.google.com to a custom container that
# runs curl. The value of this variable is passed to the curl command
# in the container.
export FETCH_URL=https://www.google.com
docker run --env FETCH_URL --rm curl-test

# Notice that the command above dumped the HTML content of the
# google.com homepage to the terminal.

# Let us unset the environment variable to demonstrate other
# ways of passing environment variables to docker containers.
unset FETCH_URL

# You can also pass the value of the environment variable directly
# to the docker run command
docker run --env FETCH_URL=https://www.google.com --rm curl-test

# You can also pass multiple environment variables to the docker
# container. Although in this case, the second environment variable
# ANOTHER_VAR is not used by the container.
docker run --env FETCH_URL=https://www.google.com --env ANOTHER_VAR=foo --rm curl-test

# You can also pass environment variables from a file to the docker
docker run --env-file ./curl-test.env --rm curl-test

# Finally we delete the docker image
docker image rm curl-test
