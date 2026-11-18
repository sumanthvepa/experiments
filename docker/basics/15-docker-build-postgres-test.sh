#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 15-docker-build-postgres-test.sh: Build an unoptimized container
# image that runs postgres
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

# Stop on unexpected errors, unset inputs and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# Imports die, cleanup_add/cleanup_cancel and owned PostgreSQL build helpers.
source ./docker-build-postgres-test-utilities.sh

echo '15-docker-build-postgres-test: automate PostgreSQL initialization and startup'
# Host: bash /path/to/15-docker-build-postgres-test.sh
# Requires Bash, Docker/Buildx, curl, sha256sum and the core tools checked
# by the helper; network access to Docker Hub, AlmaLinux and PGDG (GitHub
# if gosu is missing). Use a local Linux daemon matching x86_64 or arm64.
# No host psql, sudo, published port or firewall change is needed here.
# The TCP client runs inside the container. Lesson 16 explores host access.
# No host files are mounted. Other distributions, CPUs, rootless/userns
# remapping and SELinux-enabled daemons are untested; native arm64 tested.
# Lessons 08/09 cover COPY, build context, ENTRYPOINT and CMD. In lesson 14
# the reader invoked setup-postgres.sh manually. Here ENTRYPOINT does that
# work automatically; CMD ["postgres"] supplies the default server command.

# 1. Build a reusable image
# Read postgres-test/Dockerfile and its scripts: PGDG's EL10 PG16 packages
# use /usr/pgsql-16. gosu runs database steps as Linux user postgres while
# POSTGRES_USER names a database role. initdb creates the cluster only once,
# then a socket-only temporary server creates POSTGRES_DB and runs trusted
# initialization files before stopping. A completion marker prevents a
# failed initialization from being mistaken for a usable cluster.
# The helper refuses existing tags/names, refreshes downloads in mktemp,
# verifies the gosu checksum and registers cleanup before pull/build.
echo 'Building postgres-test from its automated Dockerfile...'
download_and_build_postgres_test_image
read -r -p 'Press ENTER to inspect the image startup contract...'

# 2. Informational flags bypass initialization
# Docker appends a replacement CMD to ENTRYPOINT. --version requests a
# result without a password, data directory or server. Create saves an ID
# for cleanup before start; --attach displays output. State.ExitCode proves
# the container command succeeded (start alone is not a readiness check).
CONTAINER_ID=$(docker container create --name postgres-test-test postgres-test --version)
register_postgres_test_container "$CONTAINER_ID" postgres-test-test
docker container start --attach "$CONTAINER_ID"
STATUS=$(docker container inspect --format '{{.State.ExitCode}}' "$CONTAINER_ID")
[[ $STATUS == 0 ]] || die "PostgreSQL --version failed: $STATUS."
docker container rm "$CONTAINER_ID"
cleanup_cancel postgres-test-container
POSTGRES_TEST_CONTAINER_ID=
echo 'Informational --version succeeded without database initialization.'

# 3. Default CMD initializes and execs the server
# --env NAME copies an exported host value without putting its value in
# the command line. These are disposable demonstration credentials only.
# Docker environment inspection can still reveal them; use proper secret
# storage for real deployments. This teaching image does not support _FILE.
# Passing -c and its value as separate quoted argv preserves embedded spaces.
export POSTGRES_PASSWORD='postgres-demo-only'
CONTAINER_ID=$(docker container create --name postgres-test-test \
  --env POSTGRES_PASSWORD --env DOCKER_POSTGRES_DEBUG=1 postgres-test \
  postgres -c 'log_line_prefix=lesson 15: ')
register_postgres_test_container "$CONTAINER_ID" postgres-test-test
docker container start "$CONTAINER_ID"
wait_for_postgres_test "$CONTAINER_ID"
# Password-authenticated TCP SQL proves more than a running container or
# pg_isready alone. --no-psqlrc ignores personal settings, ON_ERROR_STOP
# rejects SQL failures, and unaligned tuples-only output is easy to check.
RESULT=$(docker container exec --env PGPASSWORD="$POSTGRES_PASSWORD" "$CONTAINER_ID" \
  psql --no-psqlrc --set ON_ERROR_STOP=1 --host=127.0.0.1 --username=postgres \
  --dbname=postgres --tuples-only --no-align --command 'SELECT current_user, current_database(), 6 * 7;')
[[ $RESULT == 'postgres|postgres|42' ]] || die "Unexpected automated database result: $RESULT"
echo "Verified automated PostgreSQL TCP query: $RESULT"
# bash mode initializes then opens bash without leaving a server running.
# --help documents retained user/DB/WAL/auth/initdb options and trusted
# .sh, .sql, .sql.gz, .sql.xz, .sql.zst files. --describe-config also skips
# initialization. A completed PGDATA restarts without rerunning init files;
# this lesson uses disposable container storage, not a persistent volume.
read -r -p 'Press ENTER to stop PostgreSQL and remove lesson resources...'

# 4. Visible normal cleanup; EXIT also covers errors and Ctrl-C
# exec makes postgres PID1, so Docker's STOPSIGNAL SIGINT reaches it.
# wait prints the real shutdown status; require zero before removing it.
docker container stop "$CONTAINER_ID"
STATUS=$(docker container wait "$CONTAINER_ID")
[[ $STATUS == 0 ]] || die "PostgreSQL shutdown failed: $STATUS."
docker container rm "$CONTAINER_ID"
cleanup_cancel postgres-test-container
POSTGRES_TEST_CONTAINER_ID=
clean_up_existing_image
echo 'Lesson complete; owned containers, images and temporary context removed on exit.'
# EXIT removes the temporary context and a base pulled by this run, while
# preserving an existing base. Build cache may remain. SIGKILL cannot run
# traps; inspect postgres-test-test and postgres-test before removing only
# identified leftovers by ID/tag. Never prune unrelated resources.
