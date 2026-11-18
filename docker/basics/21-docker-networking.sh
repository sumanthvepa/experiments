#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 21-docker-networking.sh: Explore networking in Docker
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

# Strict Bash propagates failed commands, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# The build helper imports die and owned EXIT/INT/TERM cleanup from
# bash-utilities.sh. Call its build function directly, so registrations
# remain in this shell. The psql helper returns one executable path.
source ./docker-build-postgres-test-utilities.sh
source ./psql-utilities.sh

echo '21-docker-networking: inspect networks and attach PostgreSQL to a bridge'
# Host: bash /path/to/21-docker-networking.sh
# Requires Bash, Docker/Buildx, jq, a host psql client and the native Linux
# build/download tools from lesson 15. Internet access supplies the base,
# PGDG repository and packages. No host package installation, sudo, host
# mount or firewall-cmd change is needed. Docker manages publishing rules.
# Tested on native arm64/rootful Linux Docker; other hosts/modes untested.
for TOOL in docker jq dirname; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL before setup."
done
PSQL_BINARY=$(psql_binary_path)
"$PSQL_BINARY" --version
docker info >/dev/null
NETWORK=sample
NETWORK_ID=
CONTAINER=sample-db
IMAGE=postgres-test
OWNER_LABEL=io.github.svepa.docker-basics.networking-run
RUN_TOKEN="networking-$$-$RANDOM"
# Retain readable names for inspection. Refuse conflicts rather than reuse
# or delete a reader's resources; never assume a familiar name is disposable.
EXISTING=$(docker network ls --quiet --filter "name=^$NETWORK$")
[[ -z $EXISTING ]] || die "Network name $NETWORK already exists. Inspect it with docker network inspect $NETWORK."
# The helper checks both the image tag and future container name before
# downloading/building; do this before creating the network as well.

# 1. Built-in networks on this Linux daemon
# docker network manages networks; ls (an alias of list) shows their IDs,
# names, drivers and scope. Output also includes networks other users made.
# Docker commonly manages firewall rules for bridging/NAT; the details vary
# with daemon/firewall configuration. Do not edit those rules for this lesson.
echo 'Built-in and user-created networks:'
docker network ls
# Without --network, ordinary docker run/create uses the default bridge.
# inspect returns JSON metadata; addresses and options vary across hosts.
echo 'Default bridge: containers use it when no network is specified.'
docker network inspect bridge
# Linux host mode shares the host network namespace: no separate container
# IP, and --publish is ignored. Applications can conflict with host ports.
echo 'Host network: shares the Linux host network namespace.'
docker network inspect host
# none supplies only loopback, rather than a connection to other containers
# or the host. This does not remove non-network channels such as mounts.
echo 'None network: only the container loopback interface.'
docker network inspect none

# 2. A user-defined bridge and its existing database example
# The advertised sample application will have a frontend, backend and DB.
# TODO (Step 4): implement the missing frontend/backend application and
# verify its inter-container requests. This existing portion only starts
# and verifies its database; it does not claim a working three-tier app.
# Unlike the default bridge, user-defined bridges provide name/alias DNS
# between attached containers. A normal bridge permits outbound traffic
# through the host by default; "user-defined" does NOT mean --internal.
# --internal on network create explicitly restricts external connectivity.
# Optional syntax (not executed here):
# docker network create --driver bridge --internal sample-internal
# Internal networks are not an authorization boundary against the host.
# The application connectivity/isolation demonstrations belong to Step 4.
download_and_build_postgres_test_image "$IMAGE" "$CONTAINER"
read -r -p 'Press ENTER to create the sample bridge and start its database...'

# Prefer create's returned ID. Before the assignment completes, cleanup may
# discover the exact name but must verify our unique label. Do not disconnect
# unknown endpoints: network rm correctly refuses a network still in use.
remove_owned_network() {
  local existing owner network_id=${NETWORK_ID:-} filter="name=^$NETWORK$"
  if [[ -n $network_id ]]; then filter="id=$network_id"; fi
  existing=$(docker network ls --quiet --no-trunc --filter "$filter") || return $?
  [[ -n $existing ]] || return 0
  [[ $existing != *$'\n'* ]] || { echo "Refusing ambiguous network $NETWORK." >&2; return 1; }
  network_id=$existing
  owner=$(docker network inspect --format "{{index .Labels \"$OWNER_LABEL\"}}" "$network_id") || return $?
  [[ $owner == "$RUN_TOKEN" ]] || { echo "Refusing changed network $NETWORK." >&2; return 1; }
  docker network rm "$network_id" || return $?
}
# Register before create to cover interruption after the daemon creates it;
# container registration below runs first during reverse-order cleanup.
cleanup_add networking-network remove_owned_network
NETWORK_ID=$(docker network create --driver bridge --label "$OWNER_LABEL=$RUN_TOKEN" "$NETWORK")
echo 'Created ordinary user-defined bridge (Internal=false):'
docker network inspect "$NETWORK_ID"
docker network inspect "$NETWORK_ID" | jq -e '
  .[0].Driver == "bridge" and .[0].Scope == "local" and
  (.[0].Internal | not) and (.[0].Containers | length) == 0' >/dev/null
docker network ls

# Use the local image actually built above, with its required demo password.
# --network selects this bridge; --name provides a readable DNS/CLI name.
# Split create/start registers ownership by immutable ID before startup.
# No fixed host port: --publish 127.0.0.1::5432 asks Docker for a free port,
# reachable only on this host. EXPOSE alone would not publish a host port.
# Environment values are visible in inspect; these are disposable credentials.
export POSTGRES_PASSWORD='networking-demo-only'
DB_ID=$(docker container create --name "$CONTAINER" --network "$NETWORK_ID" \
  --publish 127.0.0.1::5432 --env POSTGRES_PASSWORD "$IMAGE")
register_postgres_test_container "$DB_ID" "$CONTAINER"
docker container start "$DB_ID"
# The unchanged helper bounds TCP readiness (30 one-second probes/delays),
# checks stopped containers and propagates Docker failures.
wait_for_postgres_test "$DB_ID"
HOST_BINDING=$(docker container port "$DB_ID" 5432/tcp)
[[ $HOST_BINDING =~ ^127\.0\.0\.1:([0-9]+)$ ]] || die "Unexpected published endpoint: $HOST_BINDING"
HOST_PORT=${BASH_REMATCH[1]}
printf 'Host PostgreSQL endpoint: 127.0.0.1:%s\n' "$HOST_PORT"
# Argument arrays retain real argv boundaries. Ignore personal psql settings,
# disallow password prompts, and fail on SQL errors. PGPASSWORD applies only
# to this command; for real credentials prefer .pgpass (lesson 16).
PSQL_COMMAND=("$PSQL_BINARY" --no-psqlrc --no-password --set ON_ERROR_STOP=1
  --host=127.0.0.1 --port="$HOST_PORT" --username=postgres --dbname=postgres)
RESULT=$(PGCONNECT_TIMEOUT=5 PGPASSWORD="$POSTGRES_PASSWORD" "${PSQL_COMMAND[@]}" \
  --tuples-only --no-align --command "SELECT 'sample-db-ready';")
[[ $RESULT == sample-db-ready ]] || die "Unexpected database result: $RESULT"
echo "Verified sample database query: $RESULT"
# Inspect both sides of the live endpoint instead of assuming --network
# succeeded. The IP is assigned by Docker and can change each run.
docker network inspect "$NETWORK_ID" | jq -e --arg id "$DB_ID" --arg name "$CONTAINER" '
  (.[0].Containers | length) == 1 and .[0].Containers[$id].Name == $name and
  (.[0].Containers[$id].IPv4Address | contains("/"))' >/dev/null
docker container inspect "$DB_ID" | jq -e --arg network "$NETWORK" --arg id "$NETWORK_ID" '
  .[0].State.Running and .[0].NetworkSettings.Networks[$network].NetworkID == $id and
  (.[0].NetworkSettings.Networks | length) == 1' >/dev/null
echo 'Verified database membership in the sample bridge.'
echo 'Frontend/backend and application communication are unfinished (Step 4).'
read -r -p 'Press ENTER to stop the database and remove the sample bridge...'

# 3. Remove endpoints before their network, then the owned image
# The image's SIGINT shuts PostgreSQL down cleanly; check its process status.
docker container stop "$DB_ID"
STATUS=$(docker container wait "$DB_ID")
[[ $STATUS == 0 ]] || die "PostgreSQL shutdown failed: $STATUS."
clean_up_existing_container
remove_owned_network
cleanup_cancel networking-network
clean_up_existing_image
echo 'Existing networking examples complete; owned resources removed.'
# EXIT removes the owned temporary build context and a base pulled by this
# run. Ctrl-C/TERM return 130/143 with cleanup. SIGKILL cannot run traps:
# inspect identified leftovers manually; never prune unrelated resources.
