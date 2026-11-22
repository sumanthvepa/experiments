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
# Run on the host: bash /path/to/11-docker-build-node-optimized.sh
# Needs Bash, Docker access to a Linux daemon, curl, tar, and network access
# to AlmaLinux and NodeSource (and nodejs.org if the saved archive is absent).
# Docker access may require sudo; nothing is installed on the host. Commands
# here run on the host; Dockerfile RUN and verification shells run inside
# containers. Native amd64 and arm64 daemons are supported. No host mounts,
# ports or firewall changes are used. Other distributions, rootless Docker,
# userns-remap and daemon SELinux have not been tested for this lesson.
die_if_not_available curl tar mktemp cp mv rm mkdir du
die_if_not_docker_available
NATIVE_ARCH=$(docker version --format '{{.Server.Arch}}')
# Use the daemon's platform: it is the machine that executes the image.
# Node calls amd64 x64, whereas both Docker and Node call aarch64 arm64.
case $NATIVE_ARCH in
  amd64) ARCH_SUFFIX=x64 ;;
  arm64) ARCH_SUFFIX=arm64 ;;
  *) die "Unsupported daemon architecture: $NATIVE_ARCH; use amd64 or arm64." ;;
esac
die_if_docker_image_exists node-test2 node-test2-repository-baseline
die_if_docker_container_exists docker-basics-node-optimized

# 1. Prepare a smaller runtime context without changing the saved archive
NODEJS_VERSION='26.13.1'
NODEJS_MAJOR_VERSION='26'
# The repository baseline in step 2 is built from node-test.
download_node_setup_script "$NODEJS_MAJOR_VERSION"
NODEJS_DIRECTORY="node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}"
NODEJS_TARBALL="${NODEJS_DIRECTORY}.tar.gz"
# mktemp gives this run its own directory. No SUDO_USER, chown, or deletion
# of an existing extraction is needed, even when invoked under sudo.
CONTEXT=$(mktemp --directory --tmpdir docker-basics-node-optimized.XXXXXX)
cleanup_add context rm -r -- "$CONTEXT"
echo "Temporary build workspace: $CONTEXT"
mkdir "$CONTEXT/binary"
cp ./node-test2/Dockerfile "$CONTEXT/binary/Dockerfile"
if [[ -f ./node-test2/$NODEJS_TARBALL ]]; then
  echo "Using saved Node.js archive: $NODEJS_TARBALL"
  cp "./node-test2/$NODEJS_TARBALL" "$CONTEXT/archive.part"
else
  # --fail rejects HTTP errors, --silent/--show-error hide the progress
  # meter but retain errors, --location follows redirects. Finite timeouts
  # bound the transfer. A failed curl never becomes an accepted archive.
  URL="https://nodejs.org/dist/v${NODEJS_VERSION}/${NODEJS_TARBALL}"
  echo "Downloading Node.js archive from $URL"
  curl --fail --silent --show-error --location --connect-timeout 15 \
    --max-time 180 "$URL" --output "$CONTEXT/archive.part"
fi
[[ -s $CONTEXT/archive.part ]] || die 'Node.js archive is empty.'
# Reading the complete table checks compression/archive completeness, not
# authenticity. Obtain trusted release signatures/checksums for deployment.
tar --list --gzip --file "$CONTEXT/archive.part" > "$CONTEXT/archive-members"
# Official archives have one expected top-level directory. Reject absolute
# paths and parent traversal before extraction; never use arbitrary archives.
while IFS= read -r MEMBER; do
  [[ $MEMBER == "$NODEJS_DIRECTORY/"* && $MEMBER != *'/../'* ]] || \
    die 'Node.js archive contains an unexpected path.'
done < "$CONTEXT/archive-members"
mv "$CONTEXT/archive.part" "$CONTEXT/$NODEJS_TARBALL"
echo "Accepted complete Node.js archive: $NODEJS_TARBALL"
tar --extract --gzip --file "$CONTEXT/$NODEJS_TARBALL" \
  --directory "$CONTEXT/binary" --no-same-owner
DISTRIBUTION="$CONTEXT/binary/$NODEJS_DIRECTORY"
echo 'Untrimmed extracted distribution (KiB of host disk usage):'
du --summarize --block-size=1K "$DISTRIBUTION"
# The runtime keeps bin (node and command links), lib (npm with its
# dependency notices), and the upstream LICENSE. Only host-side
# copies of headers, manuals/debugger helpers and top-level prose are cut.
# Removing headers means compiling native addons needs a separate toolchain
# and matching headers. npm and npx remain available; this does not
# install a compiler.
rm -r -- "$DISTRIBUTION/include" "$DISTRIBUTION/share"
rm -- "$DISTRIBUTION/CHANGELOG.md" "$DISTRIBUTION/README.md"
[[ -s $DISTRIBUTION/LICENSE ]] || die 'The upstream Node.js LICENSE is missing.'
echo 'Trimmed distribution, retaining LICENSE (KiB of host disk usage):'
du --summarize --block-size=1K "$DISTRIBUTION"

# 2. Build both approaches independently
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
  --build-arg "ARCH_SUFFIX=$ARCH_SUFFIX" "$CONTEXT/binary"
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

# 4. Remove the images this lesson built or pulled, and the temporary build context
for IMAGE in node-test2-repository-baseline node-test2; do
  echo "Removing demonstration image: $IMAGE"
  docker image rm "$IMAGE"
done
cleanup_cancel repository-image
cleanup_cancel binary-image
remove_pulled_image "$BASE"
rm -r -- "$CONTEXT"
cleanup_cancel context
echo 'Lesson complete; owned containers, images and temporary files removed.'
# Build cache may remain. SIGKILL cannot run traps: inspect the printed
# workspace, docker image ls node-test2, docker image ls
# node-test2-repository-baseline and docker container inspect
# docker-basics-node-optimized before removing confirmed leftovers with
# rm -r -- PATH, docker image rm TAG, or docker container rm --force ID.
# Never prune unrelated workloads.
# A killed download can leave node-test/nodesource_setup_*.sh.part;
# delete it.
# TODO (future work): investigate a fully static Node.js binary for scratch.
# This lesson deliberately retains the supported binary distribution.
# References:
# https://nodejs.org/download/release/v26.13.1/docs/api/process.html#processarch
# https://docs.docker.com/reference/cli/docker/image/inspect/
# https://docs.docker.com/build/building/multi-stage/
