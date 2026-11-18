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

echo '21-docker-networking: inspect networks and run a three-container application'
# Host: bash /path/to/21-docker-networking.sh
# Requires Bash 4+ (associative arrays), Docker/Buildx, jq, host psql, curl,
# and the native Linux
# build/download tools from lesson 15. Internet access supplies the base,
# PGDG repository and packages. No host package installation, sudo, host
# mount or firewall-cmd change is needed. Docker manages publishing rules.
# Tested on native arm64/rootful Linux Docker; other hosts/modes untested.
for TOOL in docker jq dirname curl sleep; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL before setup."
done
PSQL_BINARY=$(psql_binary_path)
"$PSQL_BINARY" --version
docker info >/dev/null
NETWORK=sample
NETWORK_ID=
DATA_NETWORK_ID=
APP_IMAGE=sample-network-app
APP_IMAGE_ID=
declare -A APP_CONTAINER_IDS=()
CONTAINER=sample-db
IMAGE=postgres-test
OWNER_LABEL=io.github.svepa.docker-basics.networking-run
RUN_TOKEN="networking-$$-$RANDOM"
# Retain readable names for inspection. Refuse conflicts rather than reuse
# or delete a reader's resources; never assume a familiar name is disposable.
EXISTING=$(docker network ls --quiet --filter "name=^$NETWORK$")
[[ -z $EXISTING ]] || die "Network name $NETWORK already exists. Inspect it with docker network inspect $NETWORK."
# Check every future name before building or acquiring any resources.
EXISTING=$(docker network ls --quiet --filter 'name=^sample-data$')
[[ -z $EXISTING ]] || die 'Network name sample-data already exists.'
for NAME in sample-frontend sample-backend sample-app-db; do
  EXISTING=$(docker container ls --all --quiet --filter "name=^/$NAME$")
  [[ -z $EXISTING ]] || die "Container name $NAME already exists."
done
EXISTING=$(docker image ls --quiet "$APP_IMAGE")
[[ -z $EXISTING ]] || die "Image name $APP_IMAGE already exists."

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
# Unlike the default bridge, user-defined bridges provide name/alias DNS
# between attached containers. A normal bridge permits outbound traffic
# through the host by default; "user-defined" does NOT mean --internal.
# --internal on network create explicitly restricts external connectivity.
# Optional syntax (not executed here):
# docker network create --driver bridge --internal sample-internal
# Internal networks are not an authorization boundary against the host.
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

# All lesson containers use label-verified pre-create cleanup, then retain
# their immutable IDs. The fallback remains registered throughout handoff.
remove_app_container() {
  local name=$1 id=$2 owner
  if [[ -z $id ]]; then id=${APP_CONTAINER_IDS[$name]:-}; fi
  if [[ -z $id ]]; then
    id=$(docker container ls --all --quiet --no-trunc --filter "name=^/$name$") || return $?
  else
    id=$(docker container ls --all --quiet --no-trunc --filter "id=$id") || return $?
  fi
  [[ -n $id ]] || return 0
  [[ $id != *$'\n'* ]] || return 1
  owner=$(docker container inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$id") || return $?
  [[ $owner == "$RUN_TOKEN" ]] || { echo "Refusing changed container $name." >&2; return 1; }
  docker container rm --force "$id" || return $?
}
create_app_container() {
  local name=$1
  shift
  cleanup_add "$name" remove_app_container "$name" ''
  APP_CONTAINER_ID=$(docker container create --name "$name" \
    --label "$OWNER_LABEL=$RUN_TOKEN" "$@")
  APP_CONTAINER_IDS[$name]=$APP_CONTAINER_ID
}
# Use the local image actually built above, with its required demo password.
# --network selects this bridge; --name provides a readable DNS/CLI name.
# Split create/start registers ownership by immutable ID before startup.
# No fixed host port: --publish 127.0.0.1::5432 asks Docker for a free port,
# reachable only on this host. EXPOSE alone would not publish a host port.
# Environment values are visible in inspect; these are disposable credentials.
export POSTGRES_PASSWORD='networking-demo-only'
cleanup_add networking-pending-db remove_app_container "$CONTAINER" ''
DB_ID=$(docker container create --name "$CONTAINER" --network "$NETWORK_ID" \
  --label "$OWNER_LABEL=$RUN_TOKEN" \
  --publish 127.0.0.1::5432 --env POSTGRES_PASSWORD "$IMAGE")
register_postgres_test_container "$DB_ID" "$CONTAINER"
cleanup_cancel networking-pending-db
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
read -r -p 'Press ENTER to replace the database example with the application...'

# 3. A frontend -> backend -> database request across two bridges
# First finish the original host-SQL example. The application DB below has
# no published port and belongs only to sample-data. EXPOSE is metadata.
docker container stop "$DB_ID"
STATUS=$(docker container wait "$DB_ID")
[[ $STATUS == 0 ]] || die "PostgreSQL shutdown failed: $STATUS."
clean_up_existing_container

# A private image tag is refused above, labelled per run, and registered
# before build. No bind mounts or prerequisite lesson runtime are needed.
remove_app_image() {
  local id='' owner existing
  if [[ -n $APP_IMAGE_ID ]]; then
    existing=$(docker image ls --quiet --no-trunc) || return $?
    if [[ $'\n'$existing$'\n' == *$'\n'"$APP_IMAGE_ID"$'\n'* ]]; then id=$APP_IMAGE_ID; fi
  else
    id=$(docker image ls --quiet --no-trunc "$APP_IMAGE") || return $?
  fi
  [[ -n $id ]] || return 0
  owner=$(docker image inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$id") || return $?
  [[ $owner == "$RUN_TOKEN" ]] || { echo 'Refusing changed application image.' >&2; return 1; }
  docker image rm "$id" || return $?
}
cleanup_add networking-app-image remove_app_image
docker image build --label "$OWNER_LABEL=$RUN_TOKEN" --tag "$APP_IMAGE" ./networking-test
APP_IMAGE_ID=$(docker image inspect --format '{{.Id}}' "$APP_IMAGE")

remove_data_network() {
  local NETWORK=sample-data NETWORK_ID=${DATA_NETWORK_ID:-}
  remove_owned_network
}
cleanup_add networking-data-network remove_data_network
DATA_NETWORK_ID=$(docker network create --driver bridge --internal \
  --label "$OWNER_LABEL=$RUN_TOKEN" sample-data)
# Register before create for the tiny create/assignment signal window; use
# the returned immutable ID thereafter and verify the per-run label.
create_app_container sample-app-db --network "$DATA_NETWORK_ID" \
  --network-alias database --env POSTGRES_PASSWORD "$IMAGE"
APP_DB_ID=$APP_CONTAINER_ID
docker container start "$APP_DB_ID"
wait_for_postgres_test "$APP_DB_ID"
export PGPASSWORD=$POSTGRES_PASSWORD
create_app_container sample-backend --network "$NETWORK_ID" \
  --network-alias backend --env ROLE=backend \
  --env PGPASSWORD "$APP_IMAGE"
BACKEND_ID=$APP_CONTAINER_ID
# Aliases belong to a network. The backend joins both; the frontend does not.
docker network connect "$DATA_NETWORK_ID" "$BACKEND_ID"
docker container start "$BACKEND_ID"
create_app_container sample-frontend --network "$NETWORK_ID" \
  --publish 127.0.0.1::8080 --env ROLE=frontend "$APP_IMAGE"
FRONTEND_ID=$APP_CONTAINER_ID
docker container start "$FRONTEND_ID"
BINDING=$(docker container port "$FRONTEND_ID" 8080/tcp)
[[ $BINDING =~ ^127\.0\.0\.1:([0-9]+)$ ]] || die "Unexpected HTTP endpoint: $BINDING"
APP_URL="http://127.0.0.1:${BASH_REMATCH[1]}/"
printf 'Application URL: %s\n' "$APP_URL"
# Bound startup retry only for transient transport failures. HTTP/SQL errors
# fail immediately, rather than accepting any listening socket as ready.
for ((ATTEMPT=1; ATTEMPT<=20; ATTEMPT++)); do
  if RESPONSE=$(curl --noproxy '*' --fail --silent --show-error \
    --connect-timeout 1 --max-time 8 "$APP_URL"); then break; else
    STATUS=$?
    case $STATUS in 7|28|52|56) ;; *) exit "$STATUS";; esac
  fi
  [[ $ATTEMPT != 20 ]] || die 'Application HTTP readiness timed out.'
  sleep 1
done
[[ $RESPONSE == 'frontend -> backend -> database-ready' ]] || die "Unexpected application response: $RESPONSE"
printf 'Verified application request: %s\n' "$RESPONSE"
# These are real in-container clients: curl resolves backend, psql resolves
# database via Docker's embedded DNS on their respective shared bridges.
RESPONSE=$(docker container exec "$FRONTEND_ID" curl --noproxy '*' \
  --fail --silent --show-error --connect-timeout 2 --max-time 8 http://backend:8080/)
[[ $RESPONSE == 'backend -> database-ready' ]] || die 'Backend discovery/request failed.'
RESULT=$(docker container exec "$BACKEND_ID" env PGCONNECT_TIMEOUT=3 \
  psql --no-psqlrc --no-password --set ON_ERROR_STOP=1 --host=database \
  --username=postgres --dbname=postgres --tuples-only --no-align \
  --command "SELECT 'database-ready';")
[[ $RESULT == database-ready ]] || die 'Database discovery/query failed.'
echo 'Verified service discovery: frontend -> backend and backend -> database.'

# Different network membership isolates the DB from the frontend, even if
# its current IP is known. --internal also restricts external connectivity;
# neither property makes the DB inaccessible to the Docker host/admin.
DB_IP=$(docker container inspect --format '{{(index .NetworkSettings.Networks "sample-data").IPAddress}}' "$APP_DB_ID")
# Check DNS absence separately from a refused or timed-out TCP request.
if docker container exec "$FRONTEND_ID" timeout 5 getent ahostsv4 database; then
  die 'Frontend unexpectedly resolved the private database alias.'
else
  STATUS=$?
  [[ $STATUS == 2 ]] || die "Database DNS isolation probe failed: $STATUS"
fi
for HOST in database "$DB_IP"; do
  if docker container exec "$FRONTEND_ID" pg_isready --host="$HOST" \
    --timeout=2; then
    die "Frontend unexpectedly reached database at $HOST."
  else
    STATUS=$?
    [[ $STATUS == 2 ]] || die "Isolation probe failed unexpectedly: $STATUS"
  fi
done
docker network inspect "$DATA_NETWORK_ID" | jq -e --arg db "$APP_DB_ID" --arg backend "$BACKEND_ID" '
  .[0].Internal and (.[0].Containers | length) == 2 and
  .[0].Containers[$db] != null and .[0].Containers[$backend] != null' >/dev/null
docker container inspect "$APP_DB_ID" "$BACKEND_ID" | jq -e '
  all(.[]; (.HostConfig.PortBindings | length) == 0)' >/dev/null
docker container inspect "$FRONTEND_ID" | jq -e '
  (.[0].NetworkSettings.Networks | keys) == ["sample"] and
  .[0].HostConfig.PortBindings["8080/tcp"][0].HostIp == "127.0.0.1"' >/dev/null
echo 'Verified isolation: frontend cannot resolve/reach DB; only frontend publishes HTTP.'
read -r -p 'Press ENTER to stop the application and remove its networks...'

# 4. Remove endpoints before networks, then the images they used
remove_app_container sample-frontend "$FRONTEND_ID"
cleanup_cancel sample-frontend
remove_app_container sample-backend "$BACKEND_ID"
cleanup_cancel sample-backend
docker container stop "$APP_DB_ID"
STATUS=$(docker container wait "$APP_DB_ID")
[[ $STATUS == 0 ]] || die "Application PostgreSQL shutdown failed: $STATUS."
remove_app_container sample-app-db "$APP_DB_ID"
cleanup_cancel sample-app-db
remove_data_network
cleanup_cancel networking-data-network
remove_owned_network
cleanup_cancel networking-network
remove_app_image
cleanup_cancel networking-app-image
clean_up_existing_image
echo 'Networking tutorial complete; owned resources removed.'
# EXIT removes the owned temporary build context and a base pulled by this
# run. Ctrl-C/TERM return 130/143 with cleanup. SIGKILL cannot run traps:
# inspect identified leftovers manually; never prune unrelated resources.
