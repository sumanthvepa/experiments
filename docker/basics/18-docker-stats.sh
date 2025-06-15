#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 18-docker-stats.sh: Explore the docker stats command
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

echo '18-docker-stats'

# The docker stats command is used to get real-time statistics about
# running containers. It provides information about CPU usage, memory
# usage, network I/O, and block I/O for each container. The output is
# displayed in a tabular format, and is updated every second by default.


# We use the flask-test image to demonstrate the docker stats command.
# So we need to source the utilities script that provides functions
# building and running the flask-test images.
source ./docker-build-flask-test-utilities.sh

# First we need to build the flask-test image
build_flask_test_image
if [[ $? -ne 0 ]]; then
  echo "Failed to build the flask-test image. Exiting."
  exit 1
fi

# Now start a test container using the flask-test image.
run_flask_test_container stats-test 5000
if [[ $? -ne 0 ]]; then
  echo "Failed to run the flask-test container. Exiting."
  exit 1
fi

# You can use the docker stats command to get real-time statistics
# about all running containers. This is a bit like the top command
# use Ctrl-C to stop the command.
echo "Running docker stats command. Use Ctrl-C twice to stop it."
docker container stats

# You can use the --no-stream flag to get a single snapshot of the
# statistics instead of a continuous stream.
docker container stats --no-stream

# If you want to see the statistics for a specific container, you can
# specify the container name or ID.
docker container stats --no-stream stats-test

# Finally stop and remove the test container and its image.
docker container stop stats-test
docker wait stats-test
docker container rm stats-test
docker image rm flask-test
