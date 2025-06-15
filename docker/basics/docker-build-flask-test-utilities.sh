#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-build-flask-test-utilities.sh: A collection of utility
# functions for building and running the flask-test Docker image
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

function build_flask_test_image() {
  # Check if the flask-test image exists, and delete it if it does
  # This is to ensure that we always build the latest version of the
  # image.
  docker inspect flask-test > /dev/null 2>&1 
  if [[ $? -eq 0 ]]; then
    docker imge rm flask-test > /dev/null 2>&1
  fi
  # Now we can build the image
   docker build --tag flask-test ./flask-test
}

function run_flask_test_container() {
  # Get the name of the container from the first argument to the function
  # or use 'flask-test-test' as the default container name.
  local container_name=${1:-'flask-test'0}
  local flask_port=${2:-5000}

  # Check if the container already exists, and remove it if it does.
  local container_exists=$(docker container ps --quiet --all --filter name=$container_name)
  if [[ -n "$container_exists" ]]; then
    docker container stop "$container_name" > /dev/null 2>&1
    docker wait "$container_name" > /dev/null 2>&1
    docker container rm "$container_name" > /dev/null 2>&1
  fi

  docker container run \
    --name="$container_name" \
    --detach \
    --publish "$flask_port":"$flask_port" \
    --env FLASK_PORT="$flask_port" \
    flask-test
}

function stop_and_remove_flask_test_container() {
  # Get the name of the container from the first argument to the function
  # or use 'flask-test' as the default container name.
  local container_name=${1:-'flask-test'}

  # Check if the container exists before doing anything
  local container_exists=$(docker container ps --quiet --all --filter name=$container_name)
  if [[ -n "$container_exists" ]]; then
    docker container stop "$container_name" > /dev/null 2>&1
    docker wait "$container_name" > /dev/null 2>&1
    docker container rm "$container_name" > /dev/null 2>&1
  fi
}
