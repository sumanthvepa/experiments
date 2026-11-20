#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 13-docker-build-flask.sh: Explore building a flask application image
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
# Imports die, cleanup_add/cleanup_cancel and the Flask build/run helpers.
source ./docker-build-flask-test-utilities.sh

echo '13-docker-build-flask: build and query a Flask application'
# Run on the host: bash /path/to/13-docker-build-flask.sh
# Needs Bash, Docker/Buildx, curl, jq, sleep and a local Linux daemon,
# plus network access to Docker Hub, AlmaLinux repositories and PyPI.
# Docker access may require sudo. No host Python or pip is required.
# The host queries port 5000 on 127.0.0.1; a remote daemon is unsuitable.
# Leave a conflicting port alone and inspect its owner instead of stopping
# another program. Loopback publishing needs no firewall rule changes.
# No host files are mounted: SELinux labels/userns ownership of bind
# mounts do not apply. Other architectures, rootless/userns-remap and
# SELinux-enabled daemons were not tested; only native arm64 was tested.
# Dockerfile details build on lessons 08 (COPY/context), 09 (CMD/exec),
# and 12 (AlmaLinux Python). This lesson adds a venv and HTTP service.
for TOOL in curl jq sleep dirname; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL."
done
die_if_not_docker_available
die_if_docker_container_exists flask-test

# 1. Build the application
# Read flask-test/Dockerfile: install Python, create an unprivileged user
# and a venv, install pinned application requirements and Gunicorn, then
# COPY the package. CMD starts entrypoint.sh; FLASK_DEBUG=0 selects
# Gunicorn with two workers, while 1 selects Flask's development server.
# The latter is for local development only. FLASK_APP is module:object;
# FLASK_PORT configures the listener inside the container.
# The helper refuses existing image tags and preserves an existing base.
echo 'Building flask-test from its Dockerfile...'
build_flask_test_image
read -r -p 'Press ENTER to continue...'

# 2. Start and query the service
# --publish 127.0.0.1:5000:5000 maps host loopback port to container port.
# The server binds 0.0.0.0 INSIDE the container so Docker can forward to it.
# create returns an ID before start; the helper saves removal by that ID
# for errors and Ctrl-C. HTTP readiness has 30 bounded attempts, not a
# fixed startup sleep. curl --fail rejects HTTP errors; jq checks JSON.
echo 'Starting Flask on http://127.0.0.1:5000/ ...'
run_flask_test_container flask-test 5000
read -r -p 'Press ENTER to continue...'
RESPONSE=$(curl --noproxy '*' --fail --silent --show-error \
  --connect-timeout 1 --max-time 2 http://127.0.0.1:5000/)
printf '%s\n' "$RESPONSE"
jq --exit-status '. == {"flask_test":"works"}' <<< "$RESPONSE" >/dev/null
echo 'The API returned the expected JSON object.'

# 3. Remove this run's resources
# stop sends SIGTERM; entrypoint exec lets Gunicorn receive it directly.
# wait prints the exit status, then rm removes the stopped container.
# The image tag follows the container, and a newly pulled base follows
# the derived image. Build cache may remain; pre-existing images remain.
read -r -p 'Press ENTER to continue...'
stop_and_remove_flask_test_container
remove_flask_owned_image flask-test
cleanup_cancel flask-image
echo 'Lesson complete; owned containers and images removed.'
# SIGKILL cannot run traps. Inspect leftovers before removing anything:
# docker container inspect flask-test; docker image ls flask-test
# After verifying ownership: docker container rm --force <id>, then
# docker image rm flask-test. Never prune unrelated resources to recover.
