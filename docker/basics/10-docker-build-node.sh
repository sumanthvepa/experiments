#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 10-docker-build-node.sh: Explore building a standard NodeJS docker
# image
#
# Copyright (C) 2024-26 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
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

# What this lesson teaches
# ------------------------
# This lesson builds a useful image: AlmaLinux 10 minimal with the
# Node.js runtime installed, so that containers can run JavaScript
# with node.
#
# It installs Node.js the way many vendors ship Linux software. A
# setup script from NodeSource adds NodeSource's RPM repository to the
# image, and the package manager then installs nodejs from it, along
# with the shared libraries that it needs.
#
# Lesson 08 introduced COPY and ARG. Here they work together:
#
#   ARG NODEJS_MAJOR_VERSION   chooses the Node.js major release at
#                              build time; --build-arg sets it.
#   COPY nodesource_setup_${NODEJS_MAJOR_VERSION}.sh .
#                              uses the argument to pick the matching
#                              setup script from the build context.
#
# The new concept is the multi-stage build. Each FROM starts a stage,
# and only the last stage becomes the image:
#
#   FROM almalinux:10-minimal AS unoptimized   installs Node.js.
#   FROM scratch                               starts from nothing.
#   COPY --from=unoptimized / /                copies the first
#                                              stage's filesystem.
#
# The image is a single layer, without the base image's layers or the
# layer that held the deleted setup script. It still contains the
# whole AlmaLinux filesystem, so it is not a minimal image.
#
# Finally, the lesson runs node --version in a container, replacing
# CMD ["node"] as in lesson 09, and checks the reported major release.
# It removes everything that it creates.

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Import utility functions
# die reports errors; cleanup_add/cleanup_cancel undo owned resources on
# success, failure, Ctrl-C (130), and SIGTERM (143).
source ./bash-utilities.sh
source ./node-utilities.sh

echo '10-docker-build-node: install Node.js from the NodeSource RPM repository'
# Check the prerequisites: that docker can reach the Docker daemon, and
# that no image or container already uses a name that the script
# creates. If one does, inspect it and remove it by hand before
# running the script again.
die_if_not_docker_available
die_if_docker_image_exists node-test
die_if_docker_container_exists docker-basics-node

# 1. Download the NodeJS setup script
# The setup script is downloaded (if not already present) into the
# context directory where the Dockerfile for the node-test image is
# located. This allows the COPY instruction in the Dockerfile to
# locate the setup script during docker image build to copy the setup
# script into the container image.
NODEJS_MAJOR_VERSION='26'
download_node_setup_script "$NODEJS_MAJOR_VERSION"

# 2. Build using a native base
BASE='almalinux:10-minimal'
pull_image_if_absent "$BASE"
die_if_image_not_native "$BASE"
# --tag assigns node-test:latest. --build-arg supplies the Dockerfile ARG;
# the last argument is the context whose files COPY can read (lesson 08).
# The installer configures a repository INSIDE the image, then microdnf
# installs nodejs with its dependencies and cleans its package cache.
echo "Building node-test with Node.js major $NODEJS_MAJOR_VERSION..."
docker image build --tag node-test \
  --build-arg "NODEJS_MAJOR_VERSION=$NODEJS_MAJOR_VERSION" ./node-test
cleanup_add node-image docker image rm node-test:latest
echo 'To explore node-test, run these in another terminal:'
echo '  docker image history node-test'
echo "  docker image inspect --format '{{json .Config.Cmd}}' node-test"
read -r -p 'Press ENTER to continue...'

# 3. Verify the result
# CMD ["node"] is the default command. Words after the image name replace
# CMD, so node --version reports the installed runtime without opening a
# REPL; see lesson 09 for CMD details. --rm tells the Docker daemon to
# remove the container when it exits, even if the docker client is killed.
VERSION=$(docker container run --rm --name docker-basics-node node-test \
  node --version) || die "Node.js verification failed with status $?."
[[ $VERSION =~ ^v${NODEJS_MAJOR_VERSION}\.[0-9]+\.[0-9]+$ ]] || \
  die "Expected Node.js major $NODEJS_MAJOR_VERSION; got $VERSION"
echo "Verified Node.js version: $VERSION (configured major $NODEJS_MAJOR_VERSION)."
echo 'To try node interactively, run this in another terminal:'
echo '  docker container run --rm --interactive --tty node-test'
echo 'Exit node with .exit before you press ENTER: the image is removed next.'
read -r -p 'Press ENTER to continue...'

# 4. Remove the images this lesson built or pulled
echo 'Removing node-test:latest...'
docker image rm node-test:latest
cleanup_cancel node-image
remove_pulled_image "$BASE"
echo 'Lesson complete; owned container and images removed.'

# SIGKILL cannot run traps. After a killed run, inspect before deleting:
# docker container inspect docker-basics-node
# docker image ls node-test
# Remove only confirmed leftovers with docker container rm --force ID and
# docker image rm NAME:TAG. Never prune unrelated resources. A killed
# download can leave node-test/nodesource_setup_*.sh.part; delete it.
# References:
# https://github.com/nodesource/distributions
# https://docs.docker.com/reference/dockerfile/#arg
# https://docs.docker.com/build/building/multi-stage/
