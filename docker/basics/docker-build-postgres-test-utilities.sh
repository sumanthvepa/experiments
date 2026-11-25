#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-build-postgres-test-utilities.sh: A collection of utility
# functions for building the postgres-test Docker image
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

# Source by path. Call build functions directly in the caller's shell:
# cleanup_add registrations must survive until that shell exits.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"
POSTGRES_TEST_CONTEXT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/postgres-test"

# Preserve supported host names, and reject every unsupported CPU explicitly.
# Exports the legacy CPU_ARCHITECTURE/ARCH_SUFFIX variables for caller 18.
postgres_test_architecture() {
  CPU_ARCHITECTURE=$(uname -m) || return $?
  case $CPU_ARCHITECTURE in
    x86_64) ARCH_SUFFIX=amd64; POSTGRES_GOSU_SHA=bbc4136d03ab138b1ad66fa4fc051bafc6cc7ffae632b069a53657279a450de3;;
    aarch64|arm64) CPU_ARCHITECTURE=aarch64; ARCH_SUFFIX=arm64; POSTGRES_GOSU_SHA=c3805a85d17f4454c23d7059bcb97e1ec1af272b90126e79ed002342de08389b;;
    *) echo "Unsupported CPU architecture: $CPU_ARCHITECTURE (need x86_64 or aarch64)." >&2; return 1;;
  esac
}

# Internal cleanup for a tag this run acquired after checking its absence.
# Register BEFORE pull/build so interruption after tag creation is covered.
remove_postgres_owned_tag() {
  local existing
  existing=$(docker image ls --quiet "$1") || return $?
  if [[ -n $existing ]]; then docker image rm "$1" || return $?; fi
}

# Legacy cleanup names now mean owned resources only. They never search for
# or delete pre-existing resources. Optional arguments must match ownership.
clean_up_existing_image() {
  [[ -n ${POSTGRES_TEST_OWNED_IMAGE:-} ]] || return 0
  local tag=${1:-$POSTGRES_TEST_OWNED_IMAGE}
  [[ $tag == "$POSTGRES_TEST_OWNED_IMAGE" ]] || { echo 'Image is not owned by this run.' >&2; return 1; }
  remove_postgres_owned_tag "$tag" || return $?
  cleanup_cancel postgres-test-image
  POSTGRES_TEST_OWNED_IMAGE=
}
clean_up_existing_container() {
  [[ -n ${POSTGRES_TEST_CONTAINER_ID:-} ]] || return 0
  local name=${1:-$POSTGRES_TEST_CONTAINER_ID} existing
  [[ $name == "$POSTGRES_TEST_CONTAINER_ID" || $name == "${POSTGRES_TEST_CONTAINER_NAME:-}" ]] || {
    echo 'Container is not owned by this run.' >&2; return 1;
  }
  existing=$(docker container ls --all --quiet --no-trunc --filter "id=$POSTGRES_TEST_CONTAINER_ID") || return $?
  if [[ -n $existing ]]; then docker container rm --force "$POSTGRES_TEST_CONTAINER_ID" || return $?; fi
  cleanup_cancel postgres-test-container
  POSTGRES_TEST_CONTAINER_ID=
}

# create returns an ID first; register before start or any other command.
# Arguments: owned ID, optional name. One active container per caller.
register_postgres_test_container() {
  POSTGRES_TEST_CONTAINER_ID=$1
  POSTGRES_TEST_CONTAINER_NAME=${2:-}
  cleanup_add postgres-test-container docker container rm --force "$1"
}

# Downloads target ONLY the caller-owned temporary context, never fixtures.
download_postgres_repo_rpm() {
  local repo_url="https://download.postgresql.org/pub/repos/yum/reporpms/EL-10-$CPU_ARCHITECTURE/pgdg-redhat-repo-latest.noarch.rpm"
  echo "Downloading EL10 PGDG repository RPM: $repo_url"
  curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 \
    "$repo_url" --output "$POSTGRES_TEST_BUILD_CONTEXT/$ARCH_SUFFIX/pgdg-redhat-repo-latest.noarch.rpm" || return $?
}
download_gosu_binary() {
  local binary="$POSTGRES_TEST_BUILD_CONTEXT/$ARCH_SUFFIX/gosu-$ARCH_SUFFIX" suffix
  for suffix in '' .asc; do
    if [[ ! -f $binary$suffix ]]; then
      curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 \
        "https://github.com/tianon/gosu/releases/download/1.17/gosu-$ARCH_SUFFIX$suffix" \
        --output "$binary$suffix" || return $?
    fi
  done
  # The pinned checksum validates bundled and fallback binaries. Downloading
  # .asc alone is not signature verification. Independent GPG verification:
  # https://github.com/tianon/gosu/blob/1.17/INSTALL.md (private keyring).
  printf '%s  %s\n' "$POSTGRES_GOSU_SHA" "$binary" | sha256sum --check || return $?
}

# Arguments: optional image tag (postgres-test), optional future container
# name (postgres-test-test). Refuse conflicts before downloads/pulls/builds.
# Does not delete/reuse pre-existing images, containers or base images.
# Each shell builds once; it owns a context, derived tag and optional base.
download_and_build_postgres_test_image() {
  local tag=${1:-postgres-test} name=${2:-postgres-test-test}
  local daemon_arch
  die_if_not_available curl sha256sum uname mktemp cp rm mkdir dirname sleep
  [[ -z ${POSTGRES_TEST_BUILD_CONTEXT:-} ]] || { echo 'This shell already prepared a PostgreSQL build.' >&2; return 1; }
  die_if_not_buildx_available
  postgres_test_architecture || return $?
  daemon_arch=$(docker_daemon_cpu_architecture) || return $?
  [[ $daemon_arch == "$ARCH_SUFFIX" ]] || {
    echo 'Use a local Linux daemon matching the host CPU.' >&2; return 1;
  }
  die_if_docker_image_exists "$tag"
  die_if_docker_container_exists "$name"
  POSTGRES_TEST_BUILD_CONTEXT=$(mktemp --directory --tmpdir docker-basics-postgres-test.XXXXXXXX) || return $?
  cleanup_add postgres-test-context rm -rf -- "$POSTGRES_TEST_BUILD_CONTEXT"
  cp -a "$POSTGRES_TEST_CONTEXT/." "$POSTGRES_TEST_BUILD_CONTEXT/" || return $?
  mkdir -p "$POSTGRES_TEST_BUILD_CONTEXT/$ARCH_SUFFIX" || return $?
  download_postgres_repo_rpm || return $?
  download_gosu_binary || return $?
  pull_image_if_absent almalinux:10-minimal
  die_if_image_not_native almalinux:10-minimal
  POSTGRES_TEST_OWNED_IMAGE=$tag
  cleanup_add postgres-test-image remove_postgres_owned_tag "$tag"
  build_postgres_test_image "$tag" || return $?
}

# Internal build step uses the prepared context and explicit architecture.
build_postgres_test_image() {
  local tag=${1:-postgres-test}
  docker image build --tag "$tag" --build-arg "ARCH_SUFFIX=$ARCH_SUFFIX" \
    "$POSTGRES_TEST_BUILD_CONTEXT" || return $?
  echo 'PostgreSQL image built; ENTRYPOINT initializes and starts the server.'
}

# TCP readiness excludes the initializer's temporary socket-only server.
# 30 attempts, each bounded to one second, with a one-second retry delay.
wait_for_postgres_test() {
  local id=$1 running attempt status
  for ((attempt=1; attempt<=30; attempt++)); do
    running=$(docker container inspect --format '{{.State.Running}}' "$id") || return $?
    if [[ $running != true ]]; then
      docker container logs "$id" >&2 || return $?
      echo 'PostgreSQL container stopped before readiness.' >&2; return 1
    fi
    if docker container exec "$id" pg_isready --host=127.0.0.1 --timeout=1 --quiet; then
      echo 'PostgreSQL TCP readiness verified.'; return 0
    else
      status=$?
      [[ $status == 1 || $status == 2 ]] || { echo "Readiness command failed: $status." >&2; return "$status"; }
    fi
    if (( attempt < 30 )); then sleep 1 || return $?; fi
  done
  docker container logs "$id" >&2 || return $?
  echo 'PostgreSQL readiness timed out (30 attempts, 1s timeout/delay).' >&2
  return 1
}
