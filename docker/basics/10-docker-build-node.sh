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

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cleanup_cancel undo owned resources on
# success, failure, Ctrl-C (130), and SIGTERM (143).
source ./bash-utilities.sh

echo '10-docker-build-node: install Node.js from the NodeSource RPM repository'
# Run on the host: bash /path/to/10-docker-build-node.sh
# Needs Bash, Docker with access to a Linux daemon, curl, and network access
# to AlmaLinux and NodeSource. Docker access may require sudo. All commands
# below run on the host; Dockerfile RUN and node execute inside containers.
# No host mounts, ports, host package installs or firewall changes are used.
# Native amd64 and arm64 builds are supported by this saved RPM installer.
# Other architectures are rejected before resources are created. Rootless,
# userns-remap and daemon SELinux do not need bind-mount workarounds here,
# but only the documented rootful arm64 host has been tested.
for TOOL in docker curl mktemp cp chmod mv rm; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL."
done
docker info >/dev/null
DAEMON_OS=$(docker version --format '{{.Server.Os}}')
[[ $DAEMON_OS == linux ]] || die 'This lesson needs a Linux Docker daemon.'
NATIVE_ARCH=$(docker version --format '{{.Server.Arch}}')
case $NATIVE_ARCH in
  amd64|arm64) ;;
  *) die "Unsupported daemon architecture: $NATIVE_ARCH; the RPM installer supports amd64 and arm64." ;;
esac

# Refuse every existing tag of this name: a build would move an existing
# latest tag. Inspect conflicts first; remove only your own unwanted work.
EXISTING=$(docker image ls --quiet node-test)
[[ -z $EXISTING ]] || die 'Image name node-test already exists.' \
  'Inspect it with docker image ls node-test before docker image rm node-test:TAG.'
EXISTING=$(docker container ls --all --quiet \
  --filter 'name=^/docker-basics-node$')
[[ -z $EXISTING ]] || die 'Container name docker-basics-node already exists.' \
  'Inspect it with docker container inspect docker-basics-node before removing it.'

# 1. Prepare the build context
# This repository-install approach lets RPM resolve Node's shared-library
# dependencies. Lesson 11 compares installing a binary distribution instead.
# ARG chooses the major release, not an exact patch: repository updates can
# change the patch version. Keep the saved installer and this value aligned.
NODEJS_MAJOR_VERSION='22'
SETUP_SCRIPT_FILENAME="nodesource_setup_${NODEJS_MAJOR_VERSION}.sh"
SETUP_SCRIPT_URL="https://rpm.nodesource.com/setup_${NODEJS_MAJOR_VERSION}.x"
# The checked-in NodeSource script is third-party code. Preserve its bytes
# and original notices. Only our temporary copy is made executable.
# mktemp creates a unique directory, unlike deleting an existing extraction.
# Under sudo it belongs to root and is still removed here: no chown or
# SUDO_USER is needed, whether that optional variable is set or unset.
CONTEXT=$(mktemp --directory --tmpdir docker-basics-node.XXXXXX)
cleanup_add context rm -r -- "$CONTEXT"
echo "Temporary build context: $CONTEXT"
cp ./node-test/Dockerfile "$CONTEXT/Dockerfile"
if [[ -f ./node-test/$SETUP_SCRIPT_FILENAME ]]; then
  echo "Using saved NodeSource installer: $SETUP_SCRIPT_FILENAME"
  cp "./node-test/$SETUP_SCRIPT_FILENAME" "$CONTEXT/installer.part"
else
  # --fail rejects HTTP errors; --silent hides the progress meter while
  # --show-error keeps diagnostics; --location follows redirects. Finite
  # connection/transfer timeouts bound essential setup. A failed transfer
  # stops the lesson and cleanup removes its partial file.
  echo "Downloading NodeSource installer from $SETUP_SCRIPT_URL"
  curl --fail --silent --show-error --location --connect-timeout 15 \
    --max-time 120 "$SETUP_SCRIPT_URL" --output "$CONTEXT/installer.part"
fi
# Accept the artifact only after a complete transfer/copy and syntax check.
# This is a completeness check, not a cryptographic authenticity check.
[[ -s $CONTEXT/installer.part ]] || die 'NodeSource installer is empty.'
bash -n "$CONTEXT/installer.part"
# The saved installer embeds its major release. Reject a mismatched file
# before executing it during the build. Review downloaded code before use.
INSTALLER_TEXT=$(<"$CONTEXT/installer.part")
[[ $INSTALLER_TEXT == *"NODE_VERSION=\"${NODEJS_MAJOR_VERSION}.x\""* ]] || \
  die 'NodeSource installer does not declare the configured major version.'
chmod a+x "$CONTEXT/installer.part"
mv "$CONTEXT/installer.part" "$CONTEXT/$SETUP_SCRIPT_FILENAME"
echo "Prepared complete NodeSource installer for Node.js $NODEJS_MAJOR_VERSION."

# 2. Build using a native base
# Explicitly pull only an absent base and register its removal before the
# build can fail. Existing bases stay untouched; build cache may remain.
BASE='almalinux:10-minimal'
BASE_CREATED=no
EXISTING=$(docker image ls --quiet "$BASE")
if [[ -z $EXISTING ]]; then
  docker image pull "$BASE"
  cleanup_add base-image docker image rm "$BASE"
  BASE_CREATED=yes
fi
BASE_ARCH=$(docker image inspect --format '{{.Architecture}}' "$BASE")
[[ $BASE_ARCH == "$NATIVE_ARCH" ]] || \
  die "Base architecture $BASE_ARCH differs from daemon architecture $NATIVE_ARCH."
echo "Verified native base architecture: $BASE_ARCH"
# --tag assigns node-test:latest. --build-arg supplies the Dockerfile ARG;
# the last argument is the context whose files COPY can read (lesson 08).
# The installer configures a repository INSIDE the image, then microdnf
# installs nodejs with its dependencies and cleans its package cache.
echo "Building node-test with Node.js major $NODEJS_MAJOR_VERSION..."
docker image build --tag node-test \
  --build-arg "NODEJS_MAJOR_VERSION=$NODEJS_MAJOR_VERSION" "$CONTEXT"
cleanup_add node-image docker image rm node-test:latest
read -r -p 'Press ENTER to verify the Node.js installation...'

# 3. Verify the result
# CMD ["node"] is the default command. Words after the image name replace
# CMD, so node --version reports the installed runtime without opening a
# REPL. Create separately so cleanup can remove by id even if a killed
# Docker client leaves its container behind; see lesson 09 for CMD details.
ID=$(docker container create --name docker-basics-node node-test node --version)
cleanup_add node-container docker container rm --force "$ID"
VERSION=$(docker container start --attach "$ID")
STATE=$(docker container inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$ID")
[[ $STATE == 'exited 0' ]] || die "Node.js verification failed: $STATE"
[[ $VERSION =~ ^v${NODEJS_MAJOR_VERSION}\.[0-9]+\.[0-9]+$ ]] || \
  die "Expected Node.js major $NODEJS_MAJOR_VERSION; got $VERSION"
echo "Verified Node.js version: $VERSION (configured major $NODEJS_MAJOR_VERSION)."
echo 'Removing the verification container...'
docker container rm "$ID"
cleanup_cancel node-container
read -r -p 'Press ENTER to remove the demonstration image...'

# Visible cleanup teaches the commands; keep each fallback armed until its
# removal succeeds. Remove the owned base after its derived image.
echo 'Removing node-test:latest...'
docker image rm node-test:latest
cleanup_cancel node-image
if [[ $BASE_CREATED == yes ]]; then
  docker image rm "$BASE"
  cleanup_cancel base-image
fi
echo "Removing temporary build context: $CONTEXT"
rm -r -- "$CONTEXT"
cleanup_cancel context
echo 'Lesson complete; owned container, images and temporary files removed.'

# SIGKILL cannot run traps. After a killed run, inspect before deleting:
# docker container inspect docker-basics-node
# docker image ls node-test
# Inspect the printed temporary context path too. Remove only confirmed
# leftovers with docker container rm --force ID, docker image rm NAME:TAG,
# and rm -r -- /the/confirmed/context. Never prune unrelated resources.
# References:
# https://github.com/nodesource/distributions
# https://docs.docker.com/reference/dockerfile/#arg
# https://docs.docker.com/build/building/multi-stage/
