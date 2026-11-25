#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 11-docker-build-node-optimized.sh: Explore a binary-distribution Node.js
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

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cleanup_cancel remove owned resources on
# success, failure, Ctrl-C (130) and SIGTERM (143).
source ./bash-utilities.sh
source ./node-utilities.sh

# Check the prerequisites: that the commands the script runs are
# installed, that docker can reach the Docker daemon, that no image or
# container already uses a name that the script creates, and that the
# base image, if it is already here, is built for the daemon's CPU. If
# a check fails, inspect what it names and fix it by hand before
# running the script again.
echo '11-docker-build-node-optimized: build a Node.js image from the binary tarball'
die_if_not_available curl mv rm
die_if_not_docker_available
die_if_docker_image_exists node-test2
die_if_docker_container_exists docker-basics-node-optimized
die_if_image_not_native almalinux:10-minimal


# 1. Download the node binary
# Define the Node.js version and CPU architecture to be used for building the image.
NODEJS_VERSION='26.13.1'
NATIVE_ARCH=$(docker_daemon_cpu_architecture)
ARCH_SUFFIX=$(arch_suffix "$NATIVE_ARCH")

download_node_archive "$NODEJS_VERSION" "$ARCH_SUFFIX" node-test2

# 2. Build the optimized image
# The image is built in two stages. The first unpacks the tarball; the
# second copies only bin, lib and LICENSE from it, and only the second
# becomes the image. See node-test2/Dockerfile.
echo 'Building binary-distribution image node-test2.'
docker image build --tag node-test2 \
  --build-arg "NODEJS_VERSION=$NODEJS_VERSION" \
  --build-arg "ARCH_SUFFIX=$ARCH_SUFFIX" ./node-test2
cleanup_add binary-image docker image rm node-test2

# 3. Verify the result
# Words after the image name replace CMD; see lesson 09. --rm tells the
# Docker daemon to remove the container when it exits, even if the
# docker client is killed.
VERSION=$(docker container run --rm --name docker-basics-node-optimized \
  node-test2 node --version) || die "Node.js verification failed with status $?."
[[ $VERSION == "v$NODEJS_VERSION" ]] ||
  die "Expected Node.js v$NODEJS_VERSION; got $VERSION"
NPM_VERSION=$(docker container run --rm --name docker-basics-node-optimized \
  node-test2 npm --version) || die "npm verification failed with status $?."
NPX_VERSION=$(docker container run --rm --name docker-basics-node-optimized \
  node-test2 npx --version) || die "npx verification failed with status $?."
echo "Verified Node.js $VERSION, npm $NPM_VERSION and npx $NPX_VERSION."
# RPM knows its Node package/dependencies; the copied distribution requires
# you to track Node security updates and library compatibility yourself.
echo 'To compare its size with the image that lesson 10 builds, run'
echo '10-docker-build-node.sh in another terminal until its first'
echo 'Press ENTER prompt, then run:'
echo "  docker image ls --filter 'reference=node-test*'"
read -r -p 'Press ENTER to continue...'

# 4. Remove the images this lesson built or pulled
echo 'Removing demonstration image: node-test2'
docker image rm node-test2
cleanup_cancel binary-image
echo 'Lesson complete; owned containers and images removed.'

# TODO (future work): investigate a fully static Node.js binary using FROM scratch.
# The official binaries need glibc, libstdc++ and libatomic from an OS,
# which is why this image is built on almalinux:10-minimal.

# SIGKILL cannot run traps. After a killed run, inspect before deleting:
# docker container inspect docker-basics-node-optimized
# docker image ls node-test2
# Remove only confirmed leftovers with docker container rm --force ID and
# docker image rm NAME:TAG. Never prune unrelated resources. A killed
# download can leave node-test2/node-v*.tar.gz.part; delete it.
# References:
# https://nodejs.org/dist/
# https://docs.docker.com/reference/dockerfile/#add
# https://docs.docker.com/build/building/multi-stage/
