#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 25-docker-compose-networking.sh: Explore Compose networking
#
# Copyright (C) 2026 Sumanth Vepa.
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

# Stop on failed commands/pipelines and unset variables.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cancel undo owned work on errors,
# normal exit, Ctrl-C (130), and TERM (143), in reverse order.
source ./bash-utilities.sh

echo '25-docker-compose-networking: discover services and verify network boundaries'
# Host: bash /path/to/25-docker-compose-networking.sh
# Prerequisites: lesson 24's Compose workflow and lesson 21's bridge/DNS/
# publication fundamentals. This lesson teaches their Compose configuration.
# Needs Bash 4+, Docker/Buildx, Compose plugin 2.32.2+ (the course baseline),
# jq, Python 3, curl and cmp, plus network access for native AlmaLinux/nginx.
# Use a local Linux daemon: published loopback belongs to the daemon host.
# No host packages, credentials, bind mounts or firewall changes are needed.
# Tested on Fedora/arm64 rootful Docker with classic overlay2. Other hosts,
# rootless, userns-remap and SELinux-enabled daemons have not been tested.
(( BASH_VERSINFO[0] >= 4 )) || die 'This lesson needs Bash 4 or later.'
die_if_not_available jq python3 curl cmp mktemp rm dirname sleep cat kill
die_if_not_docker_available
COMPOSE_VERSION=$(docker compose version --short)
if [[ $COMPOSE_VERSION =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  (( BASH_REMATCH[1] > 2 || (BASH_REMATCH[1] == 2 && (BASH_REMATCH[2] > 32 || (BASH_REMATCH[2] == 32 && BASH_REMATCH[3] >= 2))) )) || die 'This lesson requires Compose plugin 2.32.2+.'
else
  die "Cannot identify Compose plugin version: $COMPOSE_VERSION"
fi
printf 'Compose plugin: %s\n' "$COMPOSE_VERSION"
die_if_not_buildx_available
BASE=almalinux:10-minimal
EXISTING=$(docker image ls --quiet "$BASE")
if [[ -n $EXISTING ]]; then
  die_if_image_not_native "$BASE"
fi

PROJECT="compose25-$$-$RANDOM"
RUN_TOKEN="$PROJECT-$RANDOM"
OWNER_LABEL=io.github.svepa.docker-basics.compose-run
IMAGE="$PROJECT-http:lesson"
IMAGE_ID=
UP_PID=
declare -A SERVICE_IDS=() NETWORK_IDS=()
SCRATCH=$(mktemp --directory --tmpdir 'docker-basics-compose25.XXXXXXXX')
cleanup_add compose-files rm --recursive --force -- "$SCRATCH"
FILE="$SCRATCH/compose.yaml"
printf 'Compose project: %s\nCompose file: %s\n' "$PROJECT" "$FILE"
# Every invocation, including down, selects this unique project/private file.
# Ignore ambient .env and orphan-removal settings. Private BUILDX_CONFIG
# preserves the reader's builder selection/activity; build cache may grow.
compose() {
  BUILDX_CONFIG="$SCRATCH/buildx" COMPOSE_REMOVE_ORPHANS=false COMPOSE_IGNORE_ORPHANS=true \
    docker compose --project-name "$PROJECT" --file "$FILE" \
    --project-directory "$SCRATCH" --env-file /dev/null "$@"
}

# Refuse both project-labelled resources and every future generated name.
# Called before build AND immediately before each up: setup can take time.
# On a conflict, leave its owner alone and inspect before retrying:
# docker container ls --all --filter label=com.docker.compose.project=PROJECT
# docker network ls --filter label=com.docker.compose.project=PROJECT
# docker volume ls --filter label=com.docker.compose.project=PROJECT
# docker image inspect PROJECT-http:lesson
assert_empty_project() {
  local type ids name data
  for type in container network volume; do
    if [[ $type == container ]]; then
      ids=$(docker container ls --all --quiet --filter "label=com.docker.compose.project=$PROJECT") || return $?
    else
      ids=$(docker "$type" ls --quiet --filter "label=com.docker.compose.project=$PROJECT") || return $?
    fi
    [[ -z $ids ]] || { echo "ERROR: Compose project $PROJECT already has $type resources." >&2; return 1; }
  done
  die_if_docker_container_exists "$PROJECT-frontend-1" "$PROJECT-app-1" \
    "$PROJECT-backend-1"
  for name in default frontend backend; do
    ids=$(docker network ls --quiet --filter "name=^${PROJECT}_$name$") || return $?
    [[ -z $ids ]] || { echo "ERROR: Generated network ${PROJECT}_$name already exists." >&2; return 1; }
  done
  ids=$(docker image ls --quiet "$IMAGE") || return $?
  if [[ -n $ids ]]; then
    [[ -n $IMAGE_ID ]] || { echo "ERROR: Image name $IMAGE already exists." >&2; return 1; }
    data=$(docker image inspect "$IMAGE") || return $?
    jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg id "$IMAGE_ID" \
      '.[0] | .Id == $id and .Config.Labels[$key] == $token' <<<"$data" >/dev/null || {
      echo 'ERROR: Built image changed before up.' >&2; return 1;
    }
  else
    [[ -z $IMAGE_ID ]] || { echo 'ERROR: Built image disappeared before up.' >&2; return 1; }
  fi
}
# Resource labels recover partial up/pre-ID creations. Recorded immutable
# IDs additionally reject replacements; a run --rm one-off can be discovered
# even if its Docker client is killed before it reports a container ID.
owned_container() {
  local id=$1 data service oneoff
  data=$(docker container inspect "$id") || return $?
  jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg project "$PROJECT" \
    '.[0].Config.Labels | .[$key] == $token and .["com.docker.compose.project"] == $project and
      (.["com.docker.compose.service"] | IN("frontend", "app", "backend"))' <<<"$data" >/dev/null || return 1
  service=$(jq -r '.[0].Config.Labels["com.docker.compose.service"]' <<<"$data") || return $?
  oneoff=$(jq -r '.[0].Config.Labels["com.docker.compose.oneoff"]' <<<"$data") || return $?
  [[ -z ${SERVICE_IDS[$service]:-} || $id == "${SERVICE_IDS[$service]}" || $oneoff == True ]] || return 1
  [[ -z $IMAGE_ID ]] || jq -e --arg id "$IMAGE_ID" '.[0].Image == $id' <<<"$data" >/dev/null || return 1
}
owned_network() {
  local id=$1 data name endpoint endpoints
  data=$(docker network inspect "$id") || return $?
  jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg project "$PROJECT" \
    '.[0].Labels | .[$key] == $token and .["com.docker.compose.project"] == $project and
      (.["com.docker.compose.network"] | IN("default", "frontend", "backend"))' <<<"$data" >/dev/null || return 1
  name=$(jq -r '.[0].Labels["com.docker.compose.network"]' <<<"$data") || return $?
  [[ -z ${NETWORK_IDS[$name]:-} || $id == "${NETWORK_IDS[$name]}" ]] || return 1
  endpoints=$(jq -r '.[0].Containers | keys[]' <<<"$data") || return $?
  for endpoint in $endpoints; do owned_container "$endpoint" || return 1; done
}
# Gate down, which otherwise trusts project metadata. Unexpected volumes,
# orphans, same-name replacements or foreign network endpoints block it.
verify_project() {
  local ids id name
  for name in frontend app backend; do
    ids=$(docker container ls --all --quiet --no-trunc --filter "name=^/$PROJECT-$name-1$") || return $?
    [[ -z $ids ]] || owned_container "$ids" || return 1
  done
  for name in default frontend backend; do
    ids=$(docker network ls --quiet --no-trunc --filter "name=^${PROJECT}_$name$") || return $?
    [[ -z $ids ]] || owned_network "$ids" || return 1
  done
  ids=$(docker volume ls --quiet --filter "label=com.docker.compose.project=$PROJECT") || return $?
  [[ -z $ids ]] || return 1
  ids=$(docker container ls --all --quiet --no-trunc --filter "label=com.docker.compose.project=$PROJECT") || return $?
  for id in $ids; do owned_container "$id" || return 1; done
  ids=$(docker network ls --quiet --no-trunc --filter "label=com.docker.compose.project=$PROJECT") || return $?
  for id in $ids; do owned_network "$id" || return 1; done
}
cleanup_project() {
  local ids id status=0
  if verify_project; then compose down --timeout 5 || status=1; else
    echo 'Refusing Compose down: unverified project resource.' >&2
    status=1
  fi
  # Independent fallback removes only confirmed owned IDs if down fails.
  ids=$(docker container ls --all --quiet --no-trunc --filter "label=$OWNER_LABEL=$RUN_TOKEN") || return $?
  for id in $ids; do
    if owned_container "$id"; then docker container rm --force "$id" || status=1
    else echo "Retaining unverified container $id." >&2; status=1; fi
  done
  ids=$(docker network ls --quiet --no-trunc --filter "label=$OWNER_LABEL=$RUN_TOKEN") || return $?
  for id in $ids; do
    if owned_network "$id"; then docker network rm "$id" || status=1
    else echo "Retaining unverified network $id." >&2; status=1; fi
  done
  return "$status"
}
remove_image() {
  local ids id data
  ids=$(docker image ls --quiet --no-trunc --filter "label=$OWNER_LABEL=$RUN_TOKEN") || return $?
  for id in $ids; do
    [[ -z $IMAGE_ID || $id == "$IMAGE_ID" ]] || return 1
    data=$(docker image inspect "$id") || return $?
    jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg tag "$IMAGE" \
      '.[0] | .Config.Labels[$key] == $token and
        ((.RepoTags // []) | all(. == $tag))' <<<"$data" >/dev/null || return 1
    docker image rm "$id" || return $?
  done
}
stop_up_client() {
  local status=0
  [[ -n $UP_PID ]] || return 0
  if kill -0 "$UP_PID" 2>/dev/null; then kill -TERM "$UP_PID" || return $?; fi
  wait "$UP_PID" || status=$?
  UP_PID=
  [[ $status == 0 || $status == 130 || $status == 143 ]]
}
# Capture IDs after up; the cleanup fallback does not depend on this handoff.
record_ids() {
  local name id ids
  for name in "$@"; do
    id=$(compose ps --all --quiet "$name") || return $?
    [[ -n $id && $id != *$'\n'* ]] || return 1
    SERVICE_IDS[$name]=$id
    owned_container "$id" || return 1
  done
  ids=$(docker network ls --quiet --no-trunc --filter "label=com.docker.compose.project=$PROJECT") || return $?
  for id in $ids; do
    name=$(docker network inspect --format '{{index .Labels "com.docker.compose.network"}}' "$id") || return $?
    NETWORK_IDS[$name]=$id
    owned_network "$id" || return 1
  done
  verify_project || return $?
}
# Curl flags bound each request and ignore personal proxies. Compare exact
# packaged content, so an unrelated listener/HTTP error cannot pass readiness.
request() {
  local service=$1 url=$2
  compose exec -T "$service" curl --noproxy '*' --fail --silent --show-error \
    --connect-timeout 1 --max-time 3 "$url" > "$SCRATCH/response.html" || return $?
  cmp website-test/index.html "$SCRATCH/response.html" || return $?
}
host_request() {
  local binding
  binding=$(compose port frontend 80) || return $?
  [[ $binding =~ ^127\.0\.0\.1:([0-9]+)$ ]] || return 1
  curl --noproxy '*' --fail --silent --show-error --connect-timeout 1 --max-time 3 \
    "http://$binding/" > "$SCRATCH/index.html" || return $?
  cmp website-test/index.html "$SCRATCH/index.html" || return $?
  printf 'Host endpoint: http://%s/; service endpoint: http://frontend:80/\n' "$binding"
}

assert_empty_project
# Reuse lesson 20's source content; never depend on an earlier runtime image.
# A generated Dockerfile adds a client to the same small nginx fixture.
# BuildKit resolves native FROM without creating/replacing a shared base tag.
cat > "$SCRATCH/Dockerfile" <<'DOCKERFILE'
FROM almalinux:10-minimal
RUN microdnf -y install nginx curl-minimal && microdnf clean all && command -v getent timeout
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html style.css /usr/share/nginx/html/
RUN chmod 644 /etc/nginx/nginx.conf /usr/share/nginx/html/* && nginx -t
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE
CONTEXT=$(python3 -c 'import json, os; print(json.dumps(os.path.abspath("website-test")))')
# A YAML anchor shares the owned image/label definition, not network state.
# No service-level networks entry means joining the project's default bridge.
cat > "$FILE" <<YAML
x-common: &common
  image: "$IMAGE"
  labels:
    $OWNER_LABEL: "$RUN_TOKEN"
services:
  frontend:
    <<: *common
    build:
      context: $CONTEXT
      dockerfile: "$SCRATCH/Dockerfile"
      labels:
        $OWNER_LABEL: "$RUN_TOKEN"
    ports: ["127.0.0.1::80"]
    healthcheck:
      test: ["CMD", "curl", "--noproxy", "*", "--fail", "--silent", "--max-time", "2", "http://127.0.0.1:80/"]
      interval: 1s
      timeout: 3s
      retries: 20
  app:
    <<: *common
    command: ["sleep", "infinity"]
networks:
  default:
    labels:
      $OWNER_LABEL: "$RUN_TOKEN"
YAML
# 1. Compose registers service names in its project network's DNS. The host
# uses a dynamically assigned loopback port; app uses frontend:80, the
# CONTAINER port. localhost in app names app itself, which has no HTTP server.
# Lessons 24/21 cover the lifecycle and bridge mechanics in detail.
compose config --quiet
compose config
read -r -p 'Press ENTER to continue...'
assert_empty_project
cleanup_add compose-image remove_image
compose build frontend
IMAGE_ID=$(docker image inspect --format '{{.Id}}' "$IMAGE")
die_if_image_not_native "$IMAGE"
cleanup_add compose-project cleanup_project
assert_empty_project
compose up --detach --no-build --pull never --wait --wait-timeout 60
record_ids frontend app
host_request
request app http://frontend:80/
echo 'Verified default discovery: app requested frontend:80 and received the packaged page.'
if request app http://127.0.0.1:80/; then die 'App unexpectedly served HTTP on localhost.'; else
  STATUS=$?
  [[ $STATUS == 7 ]] || die "Unexpected localhost probe status: $STATUS"
fi
echo 'Verified app localhost is its own namespace: no HTTP listener (curl status 7).'
# Inspect by resource IDs, not names guessed from a working directory.
docker network inspect "${NETWORK_IDS[default]}"
docker network inspect "${NETWORK_IDS[default]}" | jq -e \
  --arg app "${SERVICE_IDS[app]}" --arg front "${SERVICE_IDS[frontend]}" \
  '.[0].Containers | keys == ([$app, $front] | sort)' >/dev/null
echo 'Verified default network membership by container IDs.'
read -r -p 'Press ENTER to continue...'
cleanup_project
cleanup_cancel compose-project
SERVICE_IDS=() NETWORK_IDS=()

# 2. Service-level networks selects memberships; top-level networks declares
# project-scoped bridges. App is a worker/client on BOTH, frontend on just
# frontend, backend on just backend. No proxy or forwarding is configured.
# Only frontend publishes a host port. The backend bridge is internal too;
# the blocked request below tests distinct membership, not absent publishing.
# A deliberate eight-second startup delay makes readiness gating observable.
# healthcheck bounds each HTTP probe and its initial retry budget. depends_on
# service_healthy holds app's FIRST start until backend can answer HTTP.
# App's first command makes one real dependency request, with no retry loop.
cat > "$FILE" <<YAML
x-common: &common
  image: "$IMAGE"
  labels:
    $OWNER_LABEL: "$RUN_TOKEN"
services:
  frontend:
    <<: *common
    networks: [frontend]
    ports: ["127.0.0.1::80"]
  backend:
    <<: *common
    networks: [backend]
    command: ["sh", "-ec", "sleep 8; exec nginx -g 'daemon off;'"]
    healthcheck:
      test: ["CMD", "curl", "--noproxy", "*", "--fail", "--silent", "--max-time", "2", "http://127.0.0.1:80/"]
      interval: 1s
      timeout: 3s
      retries: 30
  app:
    <<: *common
    networks: [frontend, backend]
    depends_on:
      backend:
        condition: service_healthy
    command: ["sh", "-ec", "curl --noproxy '*' --fail --silent --show-error --connect-timeout 1 --max-time 3 http://backend:80/ >/tmp/dependency.html; echo dependency-ready-at-start; exec sleep infinity"]
networks:
  frontend:
    labels:
      $OWNER_LABEL: "$RUN_TOKEN"
  backend:
    internal: true
    labels:
      $OWNER_LABEL: "$RUN_TOKEN"
YAML
compose config --quiet
compose config
read -r -p 'Press ENTER to continue...'
cleanup_add compose-project cleanup_project
# Run up in the background only so this host can observe its startup gate.
# Save/wait for its status; register client termination before it can fail.
cleanup_add compose-client stop_up_client
assert_empty_project
# Launch Docker directly here so UP_PID names the client, not a wrapper shell.
BUILDX_CONFIG="$SCRATCH/buildx" COMPOSE_REMOVE_ORPHANS=false COMPOSE_IGNORE_ORPHANS=true \
  docker compose --project-name "$PROJECT" --file "$FILE" \
  --project-directory "$SCRATCH" --env-file /dev/null \
  up --detach --no-build --pull never > "$SCRATCH/up.log" 2>&1 &
UP_PID=$!
GATED=no
READY=no
for ((ATTEMPT=1; ATTEMPT<=60; ATTEMPT++)); do
  BACKEND_ID=$(compose ps --all --quiet backend)
  APP_ID=$(compose ps --all --quiet app)
  HEALTH=absent APP_RUNNING=false
  if [[ -n $BACKEND_ID ]]; then
    owned_container "$BACKEND_ID" || die 'Unverified backend during startup.'
    # A created container can be visible before Docker installs Health.
    # Pending is not readiness; keep observing until the actual starting /
    # healthy states arrive. pipefail still propagates inspection failures.
    HEALTH=$(docker container inspect --format '{{json .State}}' "$BACKEND_ID" | jq -r '.Health.Status // "pending"')
  fi
  if [[ -n $APP_ID ]]; then
    owned_container "$APP_ID" || die 'Unverified app during startup.'
    APP_RUNNING=$(docker container inspect --format '{{.State.Running}}' "$APP_ID")
  fi
  if [[ $HEALTH == starting && $APP_RUNNING == false ]]; then
    if [[ $GATED == no ]]; then echo 'Observed health gate: backend starting; app has not started.'; fi
    GATED=yes
  fi
  if [[ $HEALTH == healthy && $APP_RUNNING == true ]]; then READY=yes; break; fi
  if [[ -n $UP_PID ]] && ! kill -0 "$UP_PID" 2>/dev/null; then
    if wait "$UP_PID"; then UP_PID=; else
      STATUS=$?; UP_PID=; cat "$SCRATCH/up.log" >&2; exit "$STATUS"
    fi
  fi
  [[ $HEALTH != unhealthy ]] || die 'Backend healthcheck exhausted its startup budget.'
  sleep 1
done
[[ $READY == yes && $GATED == yes ]] || { cat "$SCRATCH/up.log" >&2; die 'Did not observe bounded dependency readiness and gating.'; }
if [[ -n $UP_PID ]]; then wait "$UP_PID"; UP_PID=; fi
cleanup_cancel compose-client
cat "$SCRATCH/up.log"
record_ids frontend app backend
compose logs --no-color app
compose exec -T app cat /tmp/dependency.html | cmp website-test/index.html -
echo 'Verified service_healthy gate: app first-start request succeeded without retries.'
# Successful independent requests prove the backend and clients are ready.
host_request
request app http://frontend:80/
request app http://backend:80/
BACKEND_IP=$(docker container inspect --format "{{(index .NetworkSettings.Networks \"${PROJECT}_backend\").IPAddress}}" "${SERVICE_IDS[backend]}")
[[ -n $BACKEND_IP ]] || die 'Backend has no bridge address.'
request app "http://$BACKEND_IP:80/"
request frontend http://127.0.0.1:80/
echo 'Verified ready controls: app reaches frontend and backend by service name, and backend by IP.'
# DNS absence is checked separately: getent 2 means no matching record.
# RES_OPTIONS bounds resolver retries; timeout bounds the entire lookup.
# Missing names can make curl return 6 or time out during DNS (28), so curl
# alone is not our DNS proof. A known IP tests transport independently.
if compose exec -T frontend env RES_OPTIONS='timeout:1 attempts:1' timeout 5 getent ahostsv4 backend; then
  die 'Frontend unexpectedly resolved backend.'
else
  STATUS=$?
  [[ $STATUS == 2 ]] || die "Unexpected DNS lookup status: $STATUS"
fi
for ADDRESS in backend "$BACKEND_IP"; do
  if request frontend "http://$ADDRESS:80/"; then die "Frontend unexpectedly reached backend at $ADDRESS."; else
    STATUS=$?
    if [[ $ADDRESS == backend ]]; then
      [[ $STATUS == 6 || $STATUS == 28 ]] || die "Unexpected unresolved-host request status: $STATUS"
    else
      [[ $STATUS == 7 || $STATUS == 28 ]] || die "Unexpected IP isolation status: $STATUS"
    fi
  fi
done
request app http://backend:80/
request app "http://$BACKEND_IP:80/"
echo 'Verified isolation: frontend cannot resolve backend or reach its known IP; app still can.'
docker network inspect "${NETWORK_IDS[frontend]}" "${NETWORK_IDS[backend]}"
for NAME in frontend backend; do
  docker network inspect "${NETWORK_IDS[$NAME]}" | jq -e \
    --arg app "${SERVICE_IDS[app]}" --arg peer "${SERVICE_IDS[$NAME]}" \
    '.[0].Containers | keys == ([$app, $peer] | sort)' >/dev/null
done
docker container inspect "${SERVICE_IDS[app]}" "${SERVICE_IDS[backend]}" | jq -e \
  'all(.[]; (.HostConfig.PortBindings | length) == 0)' >/dev/null
docker container inspect "${SERVICE_IDS[frontend]}" | jq -e \
  --arg network "${PROJECT}_frontend" '.[0] | (.NetworkSettings.Networks | keys) == [$network] and
    (.HostConfig.PortBindings | keys) == ["80/tcp"]' >/dev/null
echo 'Verified topology by IDs: app joins both networks; only frontend publishes HTTP.'
# Startup ordering is not continuous dependency supervision. A later backend
# failure can break app connections; applications need bounded timeouts,
# retry/reconnection policy and useful errors. depends_on does not repair it.
read -r -p 'Press ENTER to continue...'
cleanup_project
cleanup_cancel compose-project
REMAINING=$(docker container ls --all --quiet --filter "label=com.docker.compose.project=$PROJECT")
[[ -z $REMAINING ]] || die 'Project containers survived cleanup.'
REMAINING=$(docker network ls --quiet --filter "label=com.docker.compose.project=$PROJECT")
[[ -z $REMAINING ]] || die 'Project networks survived cleanup.'
remove_image
cleanup_cancel compose-image
rm --recursive --force -- "$SCRATCH"
cleanup_cancel compose-files
echo 'Compose networking complete; owned containers, networks, image and temporary files removed.'
# SIGKILL cannot run traps. Inspect the printed project/file plus run labels,
# immutable IDs and endpoints before recovering leftovers. Never prune, use
# --remove-orphans/--rmi/--volumes blindly, or disconnect a foreign endpoint.
# Inspect before removing anything (substitute the printed PROJECT/FILE):
# docker container ls --all --filter label=com.docker.compose.project=PROJECT
# docker network ls --filter label=com.docker.compose.project=PROJECT
# docker container inspect CONTAINER_ID
# docker network inspect NETWORK_ID
# docker image inspect PROJECT-http:lesson
# After checking run labels, recorded IDs and the absence of foreign endpoints:
# docker compose --project-name PROJECT --file FILE --env-file /dev/null down
# docker image rm OWNED_IMAGE_ID
# If the temporary FILE is gone, remove only verified owned container IDs
# before verified network IDs; do not reconstruct cleanup from names alone.
# Build cache can remain; source fixtures and pre-existing images stay intact.
# Official references, checked with Compose 5.7.0:
# https://docs.docker.com/compose/how-tos/networking/
# https://docs.docker.com/compose/how-tos/startup-order/
