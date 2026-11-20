#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 18-docker-stats.sh: Explore the docker stats command
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

# Stop on unexpected failures, unset variables and failed pipelines.
set -euo pipefail
# Imports die and cleanup_add/cleanup_cancel from bash-utilities.sh, plus
# path-safe build/start/HTTP helpers. Cleanup removes only owned resources
# on errors, Ctrl-C (130) and TERM (143); see lesson 03.
source "$(dirname "${BASH_SOURCE[0]}")/docker-build-flask-test-utilities.sh"

echo '18-docker-stats: interpret and stream metrics for one Flask container'
# Run on the HOST: bash /path/to/18-docker-stats.sh
# Needs Bash, Docker with Buildx, curl, jq and a local Linux daemon.
# The helper checks these before building. Registry/package network access
# is needed for an uncached build. Docker access may require sudo.
# All executable commands below run on the host. The service runs inside
# its own container, using lesson 13's native AlmaLinux/Python/venv image.
# Port 5000 must be free: publish 127.0.0.1:5000 to container TCP 5000,
# only for this host's HTTP checks. A conflict fails without stopping the
# other service. No bind mounts, firewall rules or daemon settings change.
# Rootless metrics depend on delegated cgroup controllers; unavailable
# metrics are not evidence of zero usage. Other daemon modes/platforms
# can expose different metrics. This lesson requires usable Linux stats.

# 1. Build and verify the service independently of lesson 13
die_if_not_docker_available
# Existing flask-test tags and stats-test containers are conflicts, never
# resources to replace. Check the container name before even building.
die_if_docker_container_exists stats-test
echo 'Building our own Flask image; existing images are preserved...'
build_flask_test_image
read -r -p 'Press ENTER to continue...'
run_flask_test_container stats-test 5000
ID=$FLASK_CONTAINER_ID
echo "Owned stats container: $ID"
# The helper validates an actual HTTP JSON response, not just start's
# status. Its readiness is bounded: 30 attempts, 2s/request, 1s delay.

# require_running: distinguish a stopped service from missing metrics.
# Failed Docker requests retain their failure status under set -e.
require_running() {
  local running
  running=$(docker container inspect --format '{{.State.Running}}' "$ID")
  [[ $running == true ]] || die 'Owned Flask container is no longer running.'
}

# 2. One sample, then structured fields
# Lesson 04 introduces stats alongside kill/top. Here we interpret the
# service's measurements and verify the container each row describes.
# docker stats is the short alias for docker container stats.
# --no-stream returns one sample; --no-trunc keeps the full container ID.
# Without a container argument stats watches all running containers;
# --all (-a) broadens that selection to stopped containers too. Keep those
# broader views as reader variations, so unrelated workloads stay outside
# this lesson. Names or IDs can be supplied for one or several containers.
read -r -p 'Press ENTER to continue...'
require_running
echo 'One default-table sample, scoped to the owned ID:'
docker container stats --no-stream --no-trunc "$ID"
# Single quotes leave the Go template literal for Docker, rather than
# asking Bash to interpret it. {{json .}} emits one JSON object per row;
# jq checks values without relying on terminal column widths.
METRICS=$(docker container stats --no-stream --no-trunc --format '{{json .}}' "$ID")
printf '%s\n' "$METRICS"
# These are formatted strings with units, not raw API counters. Validate
# exactly one row and its full identity; accept zero CPU/network/block
# usage, but require real memory/limit and at least one running task.
# A successful Docker exit with blank or unavailable data is not a pass.
jq --exit-status --slurp --arg id "$ID" '
  def percent: test("^[0-9]+([.][0-9]+)?%$");
  def pair: test("^[0-9]+([.][0-9]+)?[[:space:]]*[A-Za-z]+ / [0-9]+([.][0-9]+)?[[:space:]]*[A-Za-z]+$");
  length == 1 and (.[0] |
    .ID == $id and .Name == "stats-test" and
    (.CPUPerc | percent) and (.MemPerc | percent) and
    (.MemUsage | pair) and (.NetIO | pair) and (.BlockIO | pair) and
    (.MemUsage | split(" / ") | all(.[]; capture("^(?<n>[0-9]+([.][0-9]+)?)").n | tonumber > 0)) and
    (.PIDs | test("^[0-9]+$") and (tonumber > 0)))
' <<< "$METRICS" >/dev/null || die 'Missing, malformed or mismatched running-container metrics.'
require_running
echo 'Verified one metrics row with owned identity, memory and running tasks.'

# Read each column as a measurement, not an application health check:
# - CPU % is sampled utilization; an idle HTTP service can show 0.00%.
# - MEM USAGE / LIMIT is current CLI memory usage versus its available
#   limit; without a container memory limit this can reflect host memory.
#   MEM % expresses usage relative to that limit, not a reservation.
# - Linux CLI memory subtracts cache from API usage: total_inactive_file
#   on cgroup v1, inactive_file on v2; Docker 19.03 and older used cache.
#   Thus raw API memory and CLI memory need not agree.
# - NET I/O counts received / sent bytes, not requests or bytes/second.
#   BLOCK I/O accounts block-device reads / writes, not image size or
#   every application write: caching and storage affect the observation.
# - PIDS counts kernel tasks, including threads, so it can exceed the
#   process count seen with top. It does not count HTTP requests.
# Values vary with load, Docker version, controllers and storage/network
# setup. Zero block I/O or idle CPU is valid. HTTP readiness and task count
# cannot replace latency/error monitoring; stats is not a history store.
# Cgroup v1/v2 controller files differ; do not copy v1 paths onto v2.
# Official references for columns, cache, threads and cgroup differences:
# https://docs.docker.com/reference/cli/docker/container/stats/
# https://docs.docker.com/engine/containers/runmetrics/

# 3. Stream only this container; Ctrl-C ends the stream and continues
# Unlike --no-stream, stats refreshes until interrupted. After a data row
# appears, press Ctrl-C ONCE. Save and restore the existing INT trap so
# a later Ctrl-C still aborts the lesson and invokes its EXIT cleanup.
# Record that SIGINT actually arrived: status 0/130 alone must not turn
# an unrelated client failure or unexpected end into successful teaching.
read -r -p 'Press ENTER to continue, then press Ctrl-C once after a data row...'
require_running
SAVED_INT_TRAP=$(trap -p INT)
STREAM_INTERRUPTED=no
trap 'STREAM_INTERRUPTED=yes' INT
STREAM_STATUS=0
docker container stats --no-trunc "$ID" || STREAM_STATUS=$?
# trap -p returns shell-quoted, trusted shell state; eval restores it.
if [[ -n $SAVED_INT_TRAP ]]; then
  eval "$SAVED_INT_TRAP"
else
  trap - INT
fi
[[ $STREAM_INTERRUPTED == yes ]] || die "Stats stream ended without Ctrl-C (status $STREAM_STATUS)."
[[ $STREAM_STATUS -eq 0 || $STREAM_STATUS -eq 130 ]] || die "Stats stream failed with status $STREAM_STATUS."
require_running
wait_for_flask_test_http "$ID" 5000
echo 'Verified stats stream ended; owned Flask service still running and serving HTTP.'
read -r -p 'Press ENTER to continue...'

# 4. Visible cleanup
# Stats has no retained history for a stopped container. Some versions
# display zero/unavailable placeholders with --all; do not interpret them
# as a final sample or as proof of application health. Inspect state when
# a service stops; a missing row and an idle running service differ.
echo 'Stopping and removing the owned Flask container...'
stop_and_remove_flask_test_container "$ID"
echo 'Removing the image built by this run...'
remove_flask_owned_image flask-test
cleanup_cancel flask-image
remove_pulled_image almalinux:10-minimal
echo 'Lesson complete; owned container and added images removed.'
# EXIT also cleans up failures/signals. SIGKILL/power loss cannot run it;
# inspect possible leftovers before removing resources you still need:
#   docker container inspect stats-test
#   docker container logs stats-test
#   docker container rm --force stats-test
#   docker image inspect flask-test almalinux:10-minimal
# Remove only tags you know the interrupted run added. Build cache may
# remain; no daemon-wide prune is needed.
