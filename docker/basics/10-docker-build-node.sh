#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 10-docker-build-node.sh: Explore building a standard NodeJS docker
# image
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

echo '10-docker-build-node.sh'

# Some of the ideas in this script are take from ideas in the official
# git repository for official Node.js Docker images:
# https://github.com/nodejs/docker-node


# In this script, we will explore how to create a standard Node.js
# Docker image using using the nodesource dnf repository.
# Instructions for using this can be found at:
# https://github.com/nodesource/distributions

# Let's first set the version of Node.js that we want to use in the
# Docker image. We will use version 22 for this example.
NODEJS_MAJOR_VERSION='22'

# Node dnf repository setup script needs to be downloaded from
# nodesource. This script is used to add the nodesource dnf
# repository to the system. However, the script itself need not
# be downloaded every time we build a Docker image. It is sufficient
# to download the script, for a given version, once, and check it into
# source control. Then we can use the script as needed to build images.

# The setup script needs to be downloaded into the Docker build context
# directory. This allows the Dockerfile to copy the script into the
# Docker image and run it within the image to add the nodesource dnf
# repository to the system.
# So specify the context directory below:
DOCKER_BUILD_CONTEXT_DIR='node-test'

SETUP_SCRIPT_URL="https://rpm.nodesource.com/setup_${NODEJS_MAJOR_VERSION}.x"

SETUP_SCRIPT_FILENAME="nodesource_setup_${NODEJS_MAJOR_VERSION}.sh"

# Check if the setup script already exists in the Docker build context.
# Download it if it does not exist.
if [ -f "$DOCKER_BUILD_CONTEXT_DIR"/"$SETUP_SCRIPT_FILENAME" ]; then
  echo "Node.js setup script $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME already exists"
else
  echo "Downloading Node.js setup script $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME"
  echo "from $SETUP_SCRIPT_URL"
  # See 11-docker-build-node-optimize.sh for an explanation of the curl command
  # options used here.
  if curl -fsSL $SETUP_SCRIPT_URL -o $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME; then
    echo "Download of Node.js setup script $SETUP_SCRIPT_FILENAME successful"
  else
    echo "Download of Node.js setup script $SETUP_SCRIPT_FILENAME failed"
    exit 1
  fi

  # The setup script needs to be made executable before it can be run.
  echo "Making Node.js setup script $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME executable"
  chmod a+x $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME

  # Change the owner of the setup script to the current user.
  # If the script is run as sudo, then the script will be owned by
  # root. We need to change the owner to the current user so that
  # it can live in the git repository and be checked in.

  # To do this we need to check if the script is run as sudo
  # If the script is run as sudo, then $SUDO_USER will be set to the
  # user who ran the script with sudo. We check if $SUDO_USER is non-zero
  # length string, and if it is, we change the owner of the setup script
  # to $SUDO_USER. If $SUDO_USER is not set, then we don't need to do
  # anything, as the script is already owned by the current user.
  if [ -n "$SUDO_USER" ]; then
    echo "Changing owner of Node.js setup script $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME to $SUDO_USER"
    chown $SUDO_USER:$SUDO_USER $DOCKER_BUILD_CONTEXT_DIR/$SETUP_SCRIPT_FILENAME
  fi
fi

# Now we can build the Docker image using the Dockerfile in the
# Docker build context directory.
# Notice that we are passing the NODEJS_MAJOR_VERSION as a build
# argument to the Docker build command. This allows the Dockerfile
# to use the build argument to install the correct version of Node.js
echo "Building Docker image"
docker build --tag node-test \
  --build-arg NODEJS_MAJOR_VERSION=$NODEJS_MAJOR_VERSION \
  $DOCKER_BUILD_CONTEXT_DIR

# Finally test that the Docker image works as expected by running it
# and checking the version of Node.js that is installed in the image.
echo "Running Docker image node-test"
docker run --rm node-test node --version


# Remove docker image that we created earlier to allow for a
# clean build next time.
echo "Removing Docker image node-test"
docker image rm node-test
