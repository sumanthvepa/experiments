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

echo '11-docker-build-node-optimized: compare a Node.js binary distribution with RPM installation'
# Check the prerequisites: that the commands the script runs are
# installed, that docker can reach the Docker daemon, and that no image
# or container already uses a name that the script creates. If one
# does, inspect it and remove it by hand before running the script
# again.
die_if_not_available curl mv rm
die_if_not_docker_available
die_if_docker_image_exists node-test2 node-test2-repository-baseline
die_if_docker_container_exists docker-basics-node-optimized

# 1. Make sure that the build context holds the Node.js archive
NODEJS_VERSION='26.13.1'
NODEJS_MAJOR_VERSION='26'
NATIVE_ARCH=$(docker_daemon_cpu_architecture)
ARCH_SUFFIX=$(arch_suffix "$NATIVE_ARCH")
NODEJS_TARBALL="node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}.tar.gz"
download_node_setup_script "$NODEJS_MAJOR_VERSION"

# node-test2 is the build context for the binary-distribution image,
# and the Node.js archives for amd64 and arm64 are saved in it. The
# builder reads only the files that the Dockerfile uses, so only the
# archive for the daemon's CPU is sent to it.
if [[ -f ./node-test2/$NODEJS_TARBALL ]]; then
  echo "Using saved Node.js archive: node-test2/$NODEJS_TARBALL"
else
  URL="https://nodejs.org/dist/v${NODEJS_VERSION}/${NODEJS_TARBALL}"
  echo "Downloading node-test2/$NODEJS_TARBALL from $URL"
  cleanup_add node-archive rm --force -- "./node-test2/$NODEJS_TARBALL.part"
  curl --fail --silent --show-error --location --connect-timeout 15 \
    --max-time 180 "$URL" --output "./node-test2/$NODEJS_TARBALL.part"
  mv "./node-test2/$NODEJS_TARBALL.part" "./node-test2/$NODEJS_TARBALL"
  cleanup_cancel node-archive
fi

# 2. Build both approaches independently
# The binary-distribution image is built in two stages. The first
# unpacks the archive; the second copies only bin, lib and LICENSE from
# it, and only the second becomes the image. See node-test2/Dockerfile.
# The baseline is built from lesson 10's build context, node-test: its
# repository-install Dockerfile and the saved NodeSource major-26 setup
# script. Its final scratch stage copies the entire installed filesystem.
# This run builds it under a separate name, so any node-test image stays
# untouched. NodeSource selects a current patch in major 26; the binary
# archive pins 26.13.1. Report both versions: this is an approach
# comparison, not a controlled same-patch benchmark. Package versions and
# bases change sizes.
BASE='almalinux:10-minimal'
pull_image_if_absent "$BASE" --platform "linux/$NATIVE_ARCH"
die_if_image_not_native "$BASE"
echo 'Building binary-distribution image node-test2.'
docker image build --platform "linux/$NATIVE_ARCH" --tag node-test2 \
  --build-arg "NODEJS_VERSION=$NODEJS_VERSION" \
  --build-arg "ARCH_SUFFIX=$ARCH_SUFFIX" ./node-test2
cleanup_add binary-image docker image rm node-test2
echo 'Building repository baseline node-test2-repository-baseline.'
docker image build --platform "linux/$NATIVE_ARCH" \
  --tag node-test2-repository-baseline \
  --build-arg "NODEJS_MAJOR_VERSION=$NODEJS_MAJOR_VERSION" ./node-test
cleanup_add repository-image docker image rm node-test2-repository-baseline
echo 'To compare the two images, run this in another terminal:'
echo "  docker image ls --filter 'reference=node-test2*'"
read -r -p 'Press ENTER to continue...'

# 3. Check real runtime versions and CPU, then measure images
# check_runtime IMAGE MODE: run a named, short-lived verification shell.
# --rm tells the Docker daemon to remove the container when it exits, even
# if the docker client is killed. Argument expansion inside single quotes
# happens in the container, not on the host.
# process.arch identifies the Node binary itself; uname/image metadata alone
# could conceal a wrong binary that happens to execute through QEMU.
check_runtime() {
  local image=$1 mode=$2
  die_if_image_not_native "$image"
  docker container run --rm --name docker-basics-node-optimized "$image" \
    /bin/sh -eu -c '
      version=$(node --version)
      arch=$(node -p process.arch)
      [ "$arch" = "$1" ]
      if [ "$2" = binary ]; then
        [ "$version" = "v$3" ]
        test -s "/opt/node/$3/LICENSE"
        test ! -e "/opt/node/$3/include"
        test ! -e "/opt/node/$3/share"
        npm --version
        npx --version
      else
        case $version in v"$4".*) ;; *) exit 1 ;; esac
      fi
      printf "Verified %s runtime: %s, process.arch=%s\n" "$2" "$version" "$arch"
    ' sh "$ARCH_SUFFIX" "$mode" "$NODEJS_VERSION" "$NODEJS_MAJOR_VERSION" ||
    die "Runtime verification for $image failed with status $?."
}
check_runtime node-test2 binary
check_runtime node-test2-repository-baseline repository
# inspect Size is cumulative uncompressed image bytes, not compressed
# registry download size or the extra disk space when layers are shared.
# Fewer layers alone do not prove a smaller image (see lessons 08 and 10).
BINARY_SIZE=$(docker image inspect --format '{{.Size}}' node-test2)
REPOSITORY_SIZE=$(docker image inspect --format '{{.Size}}' node-test2-repository-baseline)
echo "Measured binary-distribution image: $BINARY_SIZE bytes."
echo "Measured repository-install baseline: $REPOSITORY_SIZE bytes."
echo "Repository minus binary distribution: $((REPOSITORY_SIZE - BINARY_SIZE)) bytes."
# A negative saving is valid evidence too: report the measurement as observed.
# The binary image still includes AlmaLinux, shared libraries, microdnf,
# npm and licenses. It is neither a static executable nor scratch.
# RPM knows its Node package/dependencies; the copied distribution requires
# you to track Node security updates and library compatibility yourself.
echo 'To see the layers of the binary-distribution image, run this in another terminal:'
echo '  docker image history node-test2'
read -r -p 'Press ENTER to continue...'

# 4. Remove the images this lesson built or pulled
for IMAGE in node-test2-repository-baseline node-test2; do
  echo "Removing demonstration image: $IMAGE"
  docker image rm "$IMAGE"
done
cleanup_cancel repository-image
cleanup_cancel binary-image
remove_pulled_image "$BASE"
echo 'Lesson complete; owned containers and images removed.'
# Build cache may remain. SIGKILL cannot run traps: inspect
# docker image ls node-test2, docker image ls
# node-test2-repository-baseline and docker container inspect
# docker-basics-node-optimized before removing confirmed leftovers with
# docker image rm TAG or docker container rm --force ID.
# Never prune unrelated workloads.
# A killed download can leave node-test/nodesource_setup_*.sh.part or
# node-test2/node-v*.tar.gz.part; delete it.
# TODO (future work): investigate a fully static Node.js binary for scratch.
# This lesson deliberately retains the supported binary distribution.
# References:
# https://nodejs.org/download/release/v26.13.1/docs/api/process.html#processarch
# https://docs.docker.com/reference/cli/docker/image/inspect/
# https://docs.docker.com/build/building/multi-stage/
