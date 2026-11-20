#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 12-docker-build-python.sh: Explore building a python Docker image
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
# die reports errors; cleanup_add/cleanup_cancel remove owned resources
# on failure, Ctrl-C (130), SIGTERM (143), and normal completion.
source ./bash-utilities.sh

echo '12-docker-build-python: build and try a packaged Python interpreter'
# Run on the host: bash /path/to/12-docker-build-python.sh
# Needs Bash, Docker/Buildx with access to a Linux daemon, a terminal,
# and network access to Docker Hub and AlmaLinux repositories. Docker
# access may require sudo. No Python installation on the host is needed.
# Host commands below ask Docker to run Python INSIDE containers. There
# are no host mounts, published ports or firewall changes. Native image
# support comes from AlmaLinux; only the recorded arm64 host was tested.
for TOOL in dirname; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL."
done
die_if_not_docker_available
docker buildx version >/dev/null
DAEMON_OS=$(docker version --format '{{.Server.Os}}')
[[ $DAEMON_OS == linux ]] || die 'This lesson needs a Linux Docker daemon.'
die_if_docker_image_exists python-test
die_if_docker_container_exists docker-basics-python

# 1. Build the interpreter image
# Read python-test/Dockerfile: microdnf installs Python and pip from Alma
# repositories, then cleans downloaded metadata in the same RUN layer.
# Local aliases leave the package-owned /usr/bin paths alone. The build
# checks the requested major.minor; repository updates choose the patch.
# See lesson 08 for build contexts and 09 for CMD replacement details.
PYTHON_VERSION='3.12'
BASE='almalinux:10-minimal'
pull_image_if_absent "$BASE"
die_if_image_not_native "$BASE"
# --tag names the result; --build-arg supplies the Dockerfile ARG. The
# relative context works from any starting directory because of cd above.
echo "Building python-test for Python $PYTHON_VERSION..."
docker image build --tag python-test \
  --build-arg "PYTHON_VERSION=$PYTHON_VERSION" ./python-test
cleanup_add python-image docker image rm python-test:latest
read -r -p 'Press ENTER to continue...'

# 2. Run a command and verify the installation
# python -c executes the following string as Python, then exits. Single
# host-shell quotes preserve its double quotes. Capture output before
# comparing it so a failing Docker command cannot hide in a condition.
# Separate create/start lets us register cleanup by id before execution,
# even if a killed Docker client leaves its container running. --attach
# copies output to this terminal. The container has no stdin or TTY here.
ID=$(docker container create --name docker-basics-python python-test \
  python -c 'print("Hello, World!")')
cleanup_add python-container docker container rm --force "$ID"
OUTPUT=$(docker container start --attach "$ID")
STATE=$(docker container inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$ID")
[[ $STATE == 'exited 0' ]] || die "Python greeting failed: $STATE"
[[ $OUTPUT == 'Hello, World!' ]] || die "Unexpected Python greeting: $OUTPUT"
echo "$OUTPUT"
docker container rm "$ID"
cleanup_cancel python-container

# Check the version, all four aliases, their targets and pip's interpreter.
# These checks run inside the image; pip --version installs no packages.
ID=$(docker container create --name docker-basics-python python-test \
  /bin/sh -ec 'python --version; python3 --version; pip --version; pip3 --version;
    test "$(readlink /usr/local/bin/python)" = /usr/bin/python3;
    test "$(readlink /usr/local/bin/python3)" = /usr/bin/python3;
    test "$(readlink /usr/local/bin/pip)" = /usr/bin/pip3;
    test "$(readlink /usr/local/bin/pip3)" = /usr/bin/pip3;
    rpm -q python3 python3-pip')
cleanup_add python-container docker container rm --force "$ID"
OUTPUT=$(docker container start --attach "$ID")
STATE=$(docker container inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$ID")
[[ $STATE == 'exited 0' ]] || die "Python installation checks failed: $STATE"
[[ $OUTPUT == "Python $PYTHON_VERSION."* &&
   $OUTPUT == *"(python $PYTHON_VERSION)"* ]] || \
  die "Expected Python $PYTHON_VERSION and matching pip; got $OUTPUT"
echo "$OUTPUT"
echo "Verified Python $PYTHON_VERSION, pip and local aliases. Patch versions may vary."
docker container rm "$ID"
cleanup_cancel python-container
read -r -p 'Press ENTER to continue...'

# 3. Try the default command interactively
# CMD ["python"] starts the interpreter when no command follows the image.
# --interactive keeps stdin open; --tty allocates the terminal needed for
# prompts. create/start are separate for cleanup; start --interactive
# attaches stdin as well as --attach output. The >>> prompt belongs to
# Python, not a Linux shell. Type these Python commands there:
echo 'In the Python REPL, type these commands at >>>:'
echo '  print("Hello from the REPL!")'
echo '  6 * 7'
echo '  import sys; print(sys.version_info[:2])'
echo '  quit()'
echo 'Expect the greeting, 42, and (3, 12). quit() returns to this lesson.'
ID=$(docker container create --name docker-basics-python \
  --interactive --tty python-test)
cleanup_add python-container docker container rm --force "$ID"
docker container start --attach --interactive "$ID"
STATE=$(docker container inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$ID")
[[ $STATE == 'exited 0' ]] || die "Python REPL did not exit successfully: $STATE"
echo 'Removing the REPL container...'
docker container rm "$ID"
cleanup_cancel python-container
read -r -p 'Press ENTER to continue...'

# 4. Visible cleanup: containers before images, and only an owned base.
# Keep fallbacks registered until each normal removal succeeds. Build
# cache may remain; existing base images and unrelated workloads stay.
echo 'Removing python-test:latest...'
docker image rm python-test:latest
cleanup_cancel python-image
remove_pulled_image "$BASE"
echo 'Lesson complete; owned containers and images removed.'

# SIGKILL cannot run cleanup. A killed client may leave a container alive.
# Inspect first: docker container inspect docker-basics-python
#               docker image ls python-test
# Remove only confirmed leftovers: docker container rm --force ID
#                                 docker image rm python-test:TAG
# References:
# https://wiki.almalinux.org/release-notes/10.0
# https://docs.python.org/3.12/using/cmdline.html
# https://docs.python.org/3.12/tutorial/interpreter.html
# https://docs.docker.com/reference/dockerfile/
