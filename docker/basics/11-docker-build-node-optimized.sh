#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 10-docker-build-node.sh: Explore building an optimized nodejs Docker
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

echo '11-docker-build-node-optimized.sh'

# In this script, we will explore how to create optimized Docker images
# by carefully designing the build process. For this example we will
# building an optimized Node.js Docker image from the Node.js
# binary distribution tarball. NodeJS Binary distributions tarballs
# can be found at: https://nodejs.org/dist/

# Let's first set the version of Node.js that we want to use in the
# Docker image. We will use version 20.17.0 for this example.
NODEJS_VERSION='20.17.0'

# First we have to prepare an optimized context for use by the
# Dockerfile. In this case our docker image is built for the
# architecture of CPU that the script is running on.
CPU_ARCHITECTURE=$(uname -m)

echo "CPU architecture as reported by 'uname -m' is $CPU_ARCHITECTURE"

# Determine the architecture suffix to be used to
# get the appropriate Node.js distribution
if [ "$CPU_ARCHITECTURE" == "x86_64" ]; then
  ARCH_SUFFIX='x64'
elif [ "$CPU_ARCHITECTURE" == "aarch64" ]; then
  ARCH_SUFFIX='arm64'
fi

echo "Architecture suffix for Node.js distribution is $ARCH_SUFFIX"

# Now we can now define the distribution tarball name for the
# Node.js version that we want to use.
NODEJS_TARBALL="node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}.tar.gz"

echo "Node.js tarball name is $NODEJS_TARBALL"

# The tarball needs to be downloaded into the Docker build context
# directory. This allows this script to tar/unzip the tarball into
# the correct location for the Dockerfile to use.
DOCKER_BUILD_CONTEXT_DIR='node-test2'

# Check if the tarball already exists in the Docker build context
if [ -f "$DOCKER_BUILD_CONTEXT_DIR"/"$NODEJS_TARBALL" ]; then
  echo "Node.js tarball $DOCKER_BUILD_CONTEXT_DIR/$NODEJS_TARBALL already exists"
else
  # If the tarball does not exist, download it from the Node.js
  # distribution site.
  NODEJS_TARBALL_URL="https://nodejs.org/dist/v${NODEJS_VERSION}/${NODEJS_TARBALL}"
  echo "Downloading Node.js tarball $DOCKER_BUILD_CONTEXT_DIR/$NODEJS_TARBALL"
  echo "from $NODEJS_TARBALL_URL"
  #wget $NODEJS_TARBALL_URL
  # The curl command has the following options: (Taken from the
  # curl man page.)
  # -f: Fail silently (no output at all) on HTTP errors.
  #     This allows the script to fail properly if the download
  #     fails.
  # -s: Silent mode. Don't show progress meter or error messages.
  # -S: Show error. This is used in conjunction with -s to show
  #     errors when they occur.
  # -L: Follow redirects. This is useful in case the URL is
  #    redirected to another location.
  # -o <file>: Write output to <file> instead of stdout.
  if curl -fsSL $NODEJS_TARBALL_URL -o $DOCKER_BUILD_CONTEXT_DIR/$NODEJS_TARBALL; then
    echo "Download of Node.js tarball $NODEJS_TARBALL successful"
  else
    echo "Download of Node.js tarball $NODEJS_TARBALL failed"
    exit 1
  fi
fi

# Remove any existing Node.js directory in the Docker build context
# directory. This is to ensure that the Docker build process is
# idempotent and does not have any stale files from previous builds.
echo "$DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}"
if [ -d "$DOCKER_BUILD_CONTEXT_DIR"/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX} ]; then
  echo "Removing existing Node.js distribution directory in $DOCKER_BUILD_CONTEXT_DIR"
  rm -r $DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}
else
  echo "No pre-existing Node.js distribution directory in $DOCKER_BUILD_CONTEXT_DIR."
  echo "Everything is clean."
fi

# Unzip the tarball into the Docker build context directory
echo "Unzipping Node.js tarball $DOCKER_BUILD_CONTEXT_DIR/$NODEJS_TARBALL"
# The tar command has the following options: (Taken from the tar man page.)
# -x: Extract files from an archive.
# -z: Filter the archive through gzip.
# -f: Use archive file or device ARCHIVE.
# -C: Change to directory DIR before performing any operations.
#     This is used to specify the directory where the tarball
#     should be extracted. Note that the option is order sensitive.
#     because it affects the behavior of the subsequent options.
#     Hence the -C option is the last option for this invocation.
tar -xzf $DOCKER_BUILD_CONTEXT_DIR/$NODEJS_TARBALL -C $DOCKER_BUILD_CONTEXT_DIR

# Remove unnecessary files from the Node.js distribution directory
# that are not required for the Docker image. This is to reduce the
# size of the Docker image.
echo "Removing unnecessary files from Node.js distribution directory"
rm $DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/CHANGELOG.md
rm $DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/LICENSE
rm $DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/README.md
rm -r $DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/share
rm -r $DOCKER_BUILD_CONTEXT_DIR/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/include

# Now we can build the Docker image using the optimized context
# that we have prepared. See the docker file in node-test2 to see
# how the optimized context is used in the Dockerfile.
echo "Building Docker image using optimized context"
docker build -t node-test2 $DOCKER_BUILD_CONTEXT_DIR

# Now we can run the Docker image to test that it works as expected.
echo "Running Docker image node-test2"
docker run --rm node-test2 node -v

# Finally, we can clean up the Docker image
echo "Cleaning up Docker image node-test2"
docker image rm node-test2

# TODO: Explore the possibility that a fully static binary can be
# created for Node.js that could be fit into a scratch image.
# See the link below for more information:
# https://stackoverflow.com/questions/17943595/how-to-compile-nodejs-to-a-single-fully-static-binary-file
