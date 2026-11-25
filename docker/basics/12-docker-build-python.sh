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

# What this lesson teaches
# ------------------------
# This lesson builds an image with a language interpreter: AlmaLinux
# 10 minimal with Python 3.14 and pip installed, so that containers can
# run Python with python and install packages with pip. Other images
# can start FROM it.
#
# Lesson 10 added a vendor's repository to install Node.js. Python
# needs none, because AlmaLinux's own repositories ship it. The
# Dockerfile installs it with a single RUN and copies nothing from
# the build context. That RUN also cleans the package metadata, so
# the downloaded files are never saved in a layer:
#
#   ARG PYTHON_VERSION   chooses the packages, as lesson 10's ARG
#                        chooses the Node.js release: python3.14 and
#                        python3.14-pip for PYTHON_VERSION=3.14.
#   RUN microdnf install -y python${PYTHON_VERSION} \
#       python${PYTHON_VERSION}-pip && microdnf clean all ...
#
# The packages install only the versioned commands python3.14 and
# pip3.14. The same RUN adds python, python3, pip and pip3 links in
# /usr/local/bin, which comes before /usr/bin in PATH. There is no
# virtual environment: the container's own filesystem already keeps
# an application apart from everything else.
#
# Lessons 09 and 10 replaced CMD with a one-off command. This lesson
# also runs the default command itself:
#
#   python-test python -c 'print("Hello, World!")'
#                        Words after the image name replace
#                        CMD ["python"], so Python runs the string
#                        and exits.
#   --interactive --tty python-test
#                        Nothing follows the image name, so
#                        CMD ["python"] starts the Python REPL. The
#                        REPL needs stdin and a terminal, which
#                        --interactive and --tty provide (lesson 02).
#
# In between, a container checks that python, pip and pip3.14 are
# version 3.14. The lesson removes everything that it creates, and the
# base image too if the lesson pulled it.

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cleanup_cancel remove owned resources
# on failure, Ctrl-C (130), SIGTERM (143), and normal completion.
source ./bash-utilities.sh

# Check the prerequisites: that the commands the script runs are
# installed, that docker can reach the Docker daemon, and that no image
# or container already uses a name that the script creates. If a check
# fails, inspect what it names and fix it by hand before running the
# script again.
echo '12-docker-build-python: build and try a packaged Python interpreter'
die_if_not_available dirname
die_if_not_docker_available
die_if_docker_image_exists python-test
die_if_docker_container_exists docker-basics-python

# 1. Build the interpreter image
# Read python-test/Dockerfile: microdnf installs Python and pip from
# AlmaLinux repositories, and links add the unversioned names.
# PYTHON_VERSION chooses major.minor; repository updates choose the
# patch. See lesson 08 for build contexts and 09 for CMD replacement.
PYTHON_VERSION='3.14'
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
# Words after the image name replace CMD ["python"]. python -c runs the
# string that follows as Python, then exits. --rm tells the Docker
# daemon to remove the container when it exits, even if the docker
# client is killed.
OUTPUT=$(docker container run --rm --name docker-basics-python python-test \
  python -c 'print("Hello, World!")') || die "Python greeting failed with status $?."
[[ $OUTPUT == 'Hello, World!' ]] || die "Unexpected Python greeting: $OUTPUT"
echo "$OUTPUT"

# Check the versions that python, pip and pip3.14 report. pip --version
# installs no packages.
OUTPUT=$(docker container run --rm --name docker-basics-python python-test \
  /bin/sh -ec "python --version; pip --version; pip$PYTHON_VERSION --version") ||
  die "Python installation checks failed with status $?."
[[ $OUTPUT == "Python $PYTHON_VERSION."* &&
   $OUTPUT == *"(python $PYTHON_VERSION)"*"(python $PYTHON_VERSION)" ]] || \
  die "Expected Python $PYTHON_VERSION and matching pip; got $OUTPUT"
echo "$OUTPUT"
echo "Verified Python $PYTHON_VERSION and pip. Patch versions may vary."
read -r -p 'Press ENTER to continue...'

# 3. Try the default command interactively
# CMD ["python"] starts the interpreter when no command follows the image.
# --interactive keeps stdin open; --tty allocates the terminal needed for
# prompts. The >>> prompt belongs to Python, not a Linux shell. --rm
# removes the container only when Python exits. If the terminal closes
# first, the docker client ends but Python can keep running, so the
# container is also removed by name if the script stops early.
echo 'In the Python REPL, type these commands at >>>:'
echo '  print("Hello from the REPL!")'
echo '  6 * 7'
echo '  import sys; print(sys.version_info[:2])'
echo '  quit()'
echo 'Expect the greeting, 42, and (3, 14). quit() returns to this lesson.'
cleanup_add python-container docker container rm --force docker-basics-python
docker container run --rm --name docker-basics-python --interactive --tty \
  python-test || die "Python REPL exited with status $?."
cleanup_cancel python-container
read -r -p 'Press ENTER to continue...'

# 4. Remove the images this lesson built or pulled
# Build cache may remain; base images that were already here stay.
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
# https://docs.python.org/3.14/using/cmdline.html
# https://docs.python.org/3.14/tutorial/interpreter.html# https://docs.docker.com/reference/dockerfile/
