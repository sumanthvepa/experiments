#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-build-flask-test-utilities.sh: A collection of utility
# functions for building and running the flask-test Docker image
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

# Source by path so both callers can run from another working directory.
# These helpers use die and cleanup_add/cleanup_cancel from lesson 03.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"
FLASK_CONTEXT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/flask-test"

# Remove only a tag acquired by this run. A caller may already have
# removed it on the normal path; errors inspecting Docker still fail.
remove_flask_owned_image() {
  local tag=$1 existing
  existing=$(docker image ls --quiet "$tag") || return $?
  if [[ -n $existing ]]; then
    docker image rm "$tag" || return $?
  fi
}

# Build flask-test without replacing an existing tag. Register a newly
# pulled base before building, so EXIT removes it after derived images.
# Call directly, not in $(...), because cleanup lives in this shell.
build_flask_test_image() {
  local tool existing native_arch base_arch daemon_os
  for tool in docker curl jq sleep dirname; do
    command -v "$tool" >/dev/null || {
      echo "This lesson needs $tool." >&2; return 1;
    }
  done
  docker info >/dev/null || return $?
  docker buildx version >/dev/null || return $?
  daemon_os=$(docker version --format '{{.Server.Os}}') || return $?
  [[ $daemon_os == linux ]] || { echo 'A Linux daemon is required.' >&2; return 1; }
  existing=$(docker image ls --quiet flask-test) || return $?
  [[ -z $existing ]] || {
    echo 'Image name flask-test already exists. Inspect it with docker image ls flask-test.' >&2
    return 1
  }
  existing=$(docker image ls --quiet almalinux:10-minimal) || return $?
  if [[ -z $existing ]]; then
    docker image pull almalinux:10-minimal || return $?
    cleanup_add flask-base remove_flask_owned_image almalinux:10-minimal
  fi
  native_arch=$(docker version --format '{{.Server.Arch}}') || return $?
  base_arch=$(docker image inspect --format '{{.Architecture}}' almalinux:10-minimal) || return $?
  [[ $base_arch == "$native_arch" ]] || {
    echo "Base architecture $base_arch differs from daemon architecture $native_arch." >&2
    return 1
  }
  echo "Verified native base architecture: $base_arch"
  docker image build --tag flask-test "$FLASK_CONTEXT" || return $?
  cleanup_add flask-image remove_flask_owned_image flask-test
}

# Wait at most 30 attempts, with a one-second delay and two-second HTTP
# timeout per request. Reject another service's successful HTTP response
# unless it is the expected JSON. Docker failures are fatal, not retries.
wait_for_flask_test_http() {
  local id=$1 port=$2 attempt running response
  echo 'Waiting for Flask HTTP readiness (30 attempts, 2s requests, 1s delay)...'
  for ((attempt=1; attempt<=30; attempt++)); do
    running=$(docker container inspect --format '{{.State.Running}}' "$id") || return $?
    if [[ $running != true ]]; then
      docker container logs "$id" >&2 || return $?
      echo 'Flask container stopped before HTTP readiness.' >&2
      return 1
    fi
    if response=$(curl --noproxy '*' --fail --silent --show-error \
        --connect-timeout 1 --max-time 2 "http://127.0.0.1:$port/" 2>/dev/null); then
      if jq --exit-status '. == {"flask_test":"works"}' <<< "$response" >/dev/null; then
        echo 'Verified Flask HTTP JSON: {"flask_test":"works"}'
        return 0
      fi
      echo 'Unexpected Flask HTTP JSON response.' >&2
      return 1
    fi
    if (( attempt < 30 )); then sleep 1 || return $?; fi
  done
  docker container logs "$id" >&2 || return $?
  echo 'Flask HTTP readiness timed out.' >&2
  return 1
}

# Arguments: optional name (flask-test), host/container TCP port (5000).
# Publish on host loopback only. Create first, register cleanup by ID,
# then start and wait. FLASK_CONTAINER_ID belongs to this shell; callers
# must invoke this function directly, not through command substitution.
run_flask_test_container() {
  local container_name=${1:-flask-test} flask_port=${2:-5000} existing
  if [[ ! $flask_port =~ ^[0-9]{1,5}$ ]]; then
    echo 'Flask port must be an integer from 1 through 65535.' >&2; return 1
  fi
  if (( 10#$flask_port == 0 || 10#$flask_port > 65535 )); then
    echo 'Flask port must be an integer from 1 through 65535.' >&2; return 1
  fi
  existing=$(docker container ls --all --quiet --filter "name=^/$container_name$") || return $?
  [[ -z $existing ]] || {
    echo "Container name $container_name already exists. Inspect it with docker container inspect $container_name." >&2
    return 1
  }
  FLASK_CONTAINER_ID=$(docker container create --name "$container_name" \
    --publish "127.0.0.1:$flask_port:$flask_port" \
    --env "FLASK_PORT=$flask_port" flask-test) || return $?
  cleanup_add flask-container docker container rm --force "$FLASK_CONTAINER_ID"
  docker container start "$FLASK_CONTAINER_ID" || return $?
  wait_for_flask_test_http "$FLASK_CONTAINER_ID" "$flask_port" || return $?
}

# Remove the caller-owned ID returned in FLASK_CONTAINER_ID, never a
# substring name match. Cancel only after successful visible cleanup.
stop_and_remove_flask_test_container() {
  local id=${1:-${FLASK_CONTAINER_ID:-}}
  [[ -n $id && $id == "${FLASK_CONTAINER_ID:-}" ]] || {
    echo 'No owned Flask container ID was supplied.' >&2; return 1;
  }
  docker container stop "$id" || return $?
  docker container wait "$id" || return $?
  docker container rm "$id" || return $?
  cleanup_cancel flask-container
}
