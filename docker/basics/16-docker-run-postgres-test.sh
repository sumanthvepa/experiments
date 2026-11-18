#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 16-docker-run-postgres-test.sh: Create and run a Postgres Docker
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

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./docker-build-postgres-test-utilities.sh
source ./psql-utilities.sh

echo '16-docker-run-postgres-test.sh: connect from the host and exercise SQL'
# Host: bash /path/to/16-docker-run-postgres-test.sh
# Requires the same local Linux Docker/Buildx/native CPU and download tools
# as lesson 15, plus a host psql client. Set PSQL_BINARY to an executable
# path when it is outside PATH and the standard locations. No host package
# installation, mount, sudo or firewall change is performed by this lesson.
# Native arm64/rootful Docker is tested; other host/daemon modes are untested.
# Check the client before downloading or building anything.
if ! PSQL_BINARY=$(psql_binary_path); then
  die 'Could not find an executable psql client. Install the PostgreSQL client or set PSQL_BINARY to its path.'
fi
printf 'Host psql client: %s\n' "$PSQL_BINARY"
"$PSQL_BINARY" --version

# 1. Build the automated image from lesson 15, then publish its server
# This run builds/owns its own image. The helper refuses existing image
# and container names; it never removes someone else's resources.
download_and_build_postgres_test_image
read -r -p 'Press ENTER to start PostgreSQL with a published host port...'

# Docker chooses a free host port. Bind only loopback so this disposable
# database is reachable on this host without exposing it to the network.
# The container still listens on 5432. A fixed mapping such as
# --publish 127.0.0.1:5432:5432 fails when that host port is already in use.
# --env NAME copies an exported host value. These are demonstration-only
# credentials; Docker inspection exposes environment values. PostgreSQL
# recommends a password file for repeated real client use (see docs below).
export POSTGRES_PASSWORD='postgres-demo-only'
POSTGRES_CONTAINER_ID=$(docker container create --name postgres-test-test \
  --publish 127.0.0.1::5432 --env POSTGRES_PASSWORD \
  --env DOCKER_POSTGRES_DEBUG=1 postgres-test)
register_postgres_test_container "$POSTGRES_CONTAINER_ID" postgres-test-test
docker container start "$POSTGRES_CONTAINER_ID"
# pg_isready checks TCP to exclude the initializer's socket-only server.
# The helper bounds attempts and checks stopped containers/Docker errors.
# Readiness alone does not prove authentication or a successful SQL query.
wait_for_postgres_test "$POSTGRES_CONTAINER_ID"
HOST_BINDING=$(docker container port "$POSTGRES_CONTAINER_ID" 5432/tcp)
[[ $HOST_BINDING =~ ^127\.0\.0\.1:([0-9]+)$ ]] || die "Unexpected published endpoint: $HOST_BINDING"
HOST_PORT=${BASH_REMATCH[1]}
printf 'Host PostgreSQL endpoint: 127.0.0.1:%s\n' "$HOST_PORT"

# 2. Connect with the host psql client using real argument boundaries
# An array preserves paths with spaces and each complete SQL statement.
# --no-psqlrc ignores personal settings, --no-password prevents unattended
# password prompts, ON_ERROR_STOP makes SQL failures return nonzero.
# PGPASSWORD applies only to this command, with no eval or shell expansion
# of the password. It can be visible in process environments; use .pgpass
# for real work: https://www.postgresql.org/docs/current/libpq-pgpass.html
PSQL_COMMAND=("$PSQL_BINARY" --no-psqlrc --no-password --set ON_ERROR_STOP=1
  --host=127.0.0.1 --port="$HOST_PORT" --username=postgres)
run_sql() {
  local database=$1 sql=$2
  printf 'SQL in %s: %s\n' "$database" "$sql" >&2
  PGPASSWORD="$POSTGRES_PASSWORD" "${PSQL_COMMAND[@]}" --dbname="$database" --command "$sql"
}
run_sql postgres 'CREATE DATABASE testdb;'
echo 'Test database created successfully.'
run_sql testdb 'CREATE TABLE testtable (id SERIAL PRIMARY KEY, name VARCHAR(255));'
echo 'Test table created successfully.'
run_sql testdb "INSERT INTO testtable (name) VALUES ('test');"
echo 'Data inserted successfully.'
run_sql testdb 'SELECT id, name FROM testtable;'
# A formatted SELECT is readable; a separate exact result proves the
# intended row and value, rather than treating client exit zero as proof.
RESULT=$(PGPASSWORD="$POSTGRES_PASSWORD" "${PSQL_COMMAND[@]}" --dbname=testdb \
  --tuples-only --no-align --command 'SELECT id, name FROM testtable ORDER BY id;')
[[ $RESULT == '1|test' ]] || die "Unexpected testtable result: $RESULT"
echo "Verified host PostgreSQL row: $RESULT"

# 3. Manual access and troubleshooting (run while paused below)
# docker exec creates another process in a RUNNING container. It does not
# fork PID1; docker run creates a NEW container from an image instead.
# The in-container client needs no published port. Its password-authenticated
# TCP query uses the container environment, with the password kept out of argv.
echo 'Manual in-container SQL (in another terminal):'
cat <<'COMMANDS'
docker container exec postgres-test-test bash -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql --no-psqlrc --no-password --host=127.0.0.1 --username=postgres --dbname=testdb --command "SELECT id, name FROM testtable;"'
COMMANDS
printf 'Manual host connection: psql --host=127.0.0.1 --port=%s --username=postgres --dbname=testdb --password\n' "$HOST_PORT"
# That command prompts for the demonstration password above. To supply it
# non-interactively for this disposable example:
printf "PGPASSWORD='postgres-demo-only' psql --host=127.0.0.1 --port=%s --username=postgres --dbname=testdb\n" "$HOST_PORT"
# The running server used DOCKER_POSTGRES_DEBUG=1; inspect its nonsecret
# startup diagnostics using docker container logs postgres-test-test.
# For a separate foreground debug session AFTER this lesson exits, build
# again with lesson 15's helper or the documented Dockerfile command, then:
# export POSTGRES_PASSWORD='postgres-demo-only'
# docker container run --interactive --tty --rm --publish 127.0.0.1::5432 \
#   --env POSTGRES_PASSWORD --env DOCKER_POSTGRES_DEBUG=1 postgres-test
# From another terminal use docker container stop <its-name-or-ID>.
# To troubleshoot initialization in a shell instead:
# docker container run --interactive --tty --rm --entrypoint bash postgres-test
# export POSTGRES_PASSWORD='postgres-demo-only'
# docker-entrypoint.sh bash
# This initializes and opens bash without leaving a server running. Start
# it explicitly with: exec gosu postgres postgres -D /var/lib/pgsql/16/data
# A shell export affects only its container, not an already running server.
read -r -p 'Press ENTER to stop PostgreSQL and remove lesson resources...'

# 4. Graceful shutdown and owned cleanup, also covered by EXIT/INT/TERM
# postgres is PID1 and the image's STOPSIGNAL SIGINT shuts it down cleanly.
docker container stop "$POSTGRES_CONTAINER_ID"
STATUS=$(docker container wait "$POSTGRES_CONTAINER_ID")
[[ $STATUS == 0 ]] || die "PostgreSQL shutdown failed: $STATUS."
clean_up_existing_container
clean_up_existing_image
echo 'Lesson complete; owned PostgreSQL resources removed on exit.'
# EXIT removes only this run's temporary context and any base it pulled.
# Build cache may remain. Ctrl-C returns 130. SIGKILL cannot run traps:
# inspect identified leftovers before removing by ID/tag; never prune.
