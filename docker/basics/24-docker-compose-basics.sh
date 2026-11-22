#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 24-docker-compose-basics.sh: Explore Docker Compose basics
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

# Strict Bash stops on failed commands/pipelines and unset variables.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cancel provide reverse-order cleanup on
# normal exit, errors, Ctrl-C (130) and TERM (143).
source ./bash-utilities.sh

echo '24-docker-compose-basics: configure and operate one HTTP application'
# Host: bash /path/to/24-docker-compose-basics.sh
# Needs Bash 4+, Docker with Buildx and Compose plugin 2.32.2+
# (run --pull was added in 2.32.2; other features here are older), Python 3, jq,
# curl and cmp. Network access supplies the native AlmaLinux/nginx build.
# Use a local Linux daemon: a published port belongs to the daemon host.
# No credentials, host installs, bind mounts or firewall changes are used.
# Tested on Fedora/aarch64 rootful Docker/classic overlay2. Other OS/CPU,
# rootless, userns-remap and SELinux-enabled daemons remain untested.
(( BASH_VERSINFO[0] >= 4 )) || die 'This lesson needs Bash 4 or later.'
die_if_not_available python3 jq curl cmp mktemp rm dirname sleep cat
die_if_not_docker_available
COMPOSE_VERSION=$(docker compose version --short)
if [[ $COMPOSE_VERSION =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  (( BASH_REMATCH[1] > 2 || (BASH_REMATCH[1] == 2 && (BASH_REMATCH[2] > 32 || (BASH_REMATCH[2] == 32 && BASH_REMATCH[3] >= 2))) )) || die 'Install Compose plugin 2.32.2+ before this lesson.'
else
  die "Cannot identify Compose plugin version: $COMPOSE_VERSION"
fi
printf 'Compose plugin version: %s (minimum 2.32.2).\n' "$COMPOSE_VERSION"
docker buildx version >/dev/null
BASE=almalinux:10-minimal
EXISTING=$(docker image ls --quiet "$BASE")
if [[ -n $EXISTING ]]; then
  die_if_image_not_native "$BASE"
fi
PORT=8084
if ! python3 - "$PORT" <<'PYPORT'
"""Check loopback availability without changing its current listener."""
import socket
import sys
with socket.socket() as listener:
  listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  listener.bind(('127.0.0.1', int(sys.argv[1])))
PYPORT
then
  die "Loopback port $PORT is unavailable; inspect its listener and leave its owner alone."
fi

PROJECT="compose24-$$-$RANDOM"
RUN_TOKEN="$PROJECT-$RANDOM"
OWNER_LABEL=io.github.svepa.docker-basics.compose-run
IMAGE="$PROJECT-web:lesson"
IMAGE_ID=
SERVICE_ID=
NETWORK_ID=
SCRATCH=$(mktemp --directory --tmpdir 'docker-basics-compose24.XXXXXXXX')
cleanup_add compose-files rm --recursive --force -- "$SCRATCH"
FILE="$SCRATCH/compose.yaml"
ENV_FILE="$SCRATCH/interpolation.env"
# These names belong to this exercise. Unset inherited values only in this
# lesson process; the reader's shell and configuration files are unchanged.
unset COMPOSE24_MESSAGE COMPOSE24_UNUSED
# The directory is private (mktemp's 0700); make its env file private too.
(umask 077; : > "$ENV_FILE")
printf 'Compose project: %s\nCompose file: %s\n' "$PROJECT" "$FILE"

# Every project command uses precisely this file/project, including cleanup.
# --env-file avoids discovering a reader's .env. The explicit flags override
# COMPOSE_FILE/COMPOSE_PROJECT_NAME; disable automatic orphan removal too.
# Private BUILDX_CONFIG prevents changing the reader's builder selection or
# activity files; the daemon's ordinary build cache may still grow.
compose() {
  BUILDX_CONFIG="$SCRATCH/buildx" COMPOSE_REMOVE_ORPHANS=false COMPOSE_IGNORE_ORPHANS=true \
    docker compose --project-name "$PROJECT" --file "$FILE" \
    --project-directory "$SCRATCH" --env-file "$ENV_FILE" "$@"
}

# Check both generated names and project-labelled resources before setup.
# A random project is isolation, not permission to overwrite a collision.
assert_empty_project() {
  local type ids data
  for type in container network volume; do
    if [[ $type == container ]]; then
      ids=$(docker container ls --all --quiet --filter "label=com.docker.compose.project=$PROJECT") || return $?
    else
      ids=$(docker "$type" ls --quiet --filter "label=com.docker.compose.project=$PROJECT") || return $?
    fi
    [[ -z $ids ]] || { echo "ERROR: Compose project $PROJECT already has $type resources; inspect them first." >&2; return 1; }
  done
  ids=$(docker image ls --quiet "$IMAGE") || return $?
  if [[ -n $ids ]]; then
    [[ -n $IMAGE_ID ]] || { echo "ERROR: Image name $IMAGE already exists; inspect it first." >&2; return 1; }
    data=$(docker image inspect "$IMAGE") || return $?
    jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg id "$IMAGE_ID" \
      '.[0] | .Id == $id and .Config.Labels[$key] == $token' <<<"$data" >/dev/null || {
      echo 'ERROR: Built image changed before setup; inspect it first.' >&2; return 1;
    }
  else
    [[ -z $IMAGE_ID ]] || { echo 'ERROR: Built image disappeared before setup.' >&2; return 1; }
  fi
  die_if_docker_container_exists "$PROJECT-web-1"
  ids=$(docker network ls --quiet --filter "name=^${PROJECT}_default$") || return $?
  [[ -z $ids ]] || { echo 'ERROR: Generated default network name already exists; inspect it first.' >&2; return 1; }
}

# Accept only our label, service, project and recorded immutable IDs. This
# also discovers partially-created resources if up/run never returns IDs.
owned_container() {
  local id=$1 data
  data=$(docker container inspect "$id") || return $?
  jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg project "$PROJECT" \
    '.[0].Config.Labels | .[$key] == $token and
      .["com.docker.compose.project"] == $project and .["com.docker.compose.service"] == "web"' \
    <<<"$data" >/dev/null || return 1
  if [[ -n $SERVICE_ID ]]; then
    # One-off containers have a true oneoff label; a replacement service
    # carrying copied labels still cannot replace the recorded service ID.
    jq -e --arg id "$SERVICE_ID" '.[0] | .Id == $id or .Config.Labels["com.docker.compose.oneoff"] == "True"' \
      <<<"$data" >/dev/null || return 1
  fi
  if [[ -n $IMAGE_ID ]]; then
    jq -e --arg id "$IMAGE_ID" '.[0].Image == $id' <<<"$data" >/dev/null || return 1
  fi
}
owned_network() {
  local id=$1 data endpoint endpoints
  data=$(docker network inspect "$id") || return $?
  jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" --arg project "$PROJECT" \
    '.[0] | .Labels[$key] == $token and .Labels["com.docker.compose.project"] == $project and
      .Labels["com.docker.compose.network"] == "default"' <<<"$data" >/dev/null || return 1
  [[ -z $NETWORK_ID || $id == "$NETWORK_ID" ]] || return 1
  endpoints=$(jq -r '.[0].Containers | keys[]' <<<"$data") || return $?
  while read -r endpoint; do
    [[ -z $endpoint ]] || owned_container "$endpoint" || return 1
  done <<<"$endpoints"
}

# Gate Compose down, which otherwise trusts project metadata. Never pass
# --remove-orphans, --volumes or --rmi: those could remove reader resources.
verify_project() {
  local ids id
  # A same-name replacement without project labels must also block down.
  ids=$(docker container ls --all --quiet --no-trunc --filter "name=^/$PROJECT-web-1$") || return $?
  [[ -z $ids ]] || owned_container "$ids" || return 1
  ids=$(docker network ls --quiet --no-trunc --filter "name=^${PROJECT}_default$") || return $?
  [[ -z $ids ]] || owned_network "$ids" || return 1
  ids=$(docker volume ls --quiet --filter "label=com.docker.compose.project=$PROJECT") || return $?
  [[ -z $ids ]] || { echo 'Refusing project cleanup: unexpected volume.' >&2; return 1; }
  ids=$(docker container ls --all --quiet --no-trunc --filter "label=com.docker.compose.project=$PROJECT") || return $?
  for id in $ids; do
    owned_container "$id" || { echo "Refusing project cleanup: foreign/replaced container $id." >&2; return 1; }
  done
  ids=$(docker network ls --quiet --no-trunc --filter "label=com.docker.compose.project=$PROJECT") || return $?
  for id in $ids; do
    owned_network "$id" || { echo "Refusing project cleanup: foreign/replaced network $id." >&2; return 1; }
  done
}

# If down fails, independently remove only confirmed owned resources. This
# covers partial up, a surviving run --rm client and a foreign orphan. A
# network with any foreign endpoint is retained and failure is reported.
cleanup_project() {
  local ids id status=0
  if verify_project; then
    compose down --timeout 10 || status=1
  else
    status=1
  fi
  ids=$(docker container ls --all --quiet --no-trunc --filter "label=$OWNER_LABEL=$RUN_TOKEN") || return $?
  for id in $ids; do
    if owned_container "$id"; then
      docker container rm --force "$id" || status=1
    else
      echo "Retaining unverified container $id." >&2
      status=1
    fi
  done
  ids=$(docker network ls --quiet --no-trunc --filter "label=$OWNER_LABEL=$RUN_TOKEN") || return $?
  for id in $ids; do
    if owned_network "$id"; then
      docker network rm "$id" || status=1
    else
      echo "Retaining unverified network $id." >&2
      status=1
    fi
  done
  return "$status"
}
remove_image() {
  local data
  data=$(docker image ls --quiet "$IMAGE") || return $?
  [[ -n $data ]] || return 0
  data=$(docker image inspect "$IMAGE") || return $?
  jq -e --arg key "$OWNER_LABEL" --arg token "$RUN_TOKEN" \
    '.[0].Config.Labels[$key] == $token' <<<"$data" >/dev/null || { echo 'Retaining changed image.' >&2; return 1; }
  if [[ -n $IMAGE_ID ]]; then
    jq -e --arg id "$IMAGE_ID" '.[0].Id == $id' <<<"$data" >/dev/null || return 1
  fi
  docker image rm "$IMAGE" || return $?
}

assert_empty_project
# Here-documents write YAML into our private directory. Unquoted YAML
# expands host Bash variables (image/port/ownership) now. Quoted 'YAML'
# preserves the dollar expression for Compose to resolve later. Python JSON
# string quoting is also valid YAML quoting, including spaces in the context.
CONTEXT=$(python3 -c 'import json, os; print(json.dumps(os.path.abspath("website-test")))')
{
cat <<YAML
services:
  web:
    image: "$IMAGE"
    build:
      context: $CONTEXT
      labels:
        $OWNER_LABEL: "$RUN_TOKEN"
    command: ["nginx", "-g", "daemon off;"]
YAML
cat <<'YAML'
    environment:
      LESSON: "${COMPOSE24_MESSAGE:-Compose basics}"
YAML
cat <<YAML
    ports:
      - "127.0.0.1:$PORT:80"
    labels:
      $OWNER_LABEL: "$RUN_TOKEN"
networks:
  default:
    labels:
      $OWNER_LABEL: "$RUN_TOKEN"
YAML
} > "$FILE"
# 1. An application is the whole configured workload; this one contains one
# service, web. A service is a repeatable container definition. A project
# is a particular named instance: -p/--project-name isolates its containers
# and default network. -f/--file selects configuration instead of searching
# the current directory. Avoid container_name and global resource names.
# services maps names to definitions. image names the built result; build
# selects the local context from lesson 20 (no earlier container required).
# command overrides image CMD with an exec-style argument list. environment
# supplies container variables (lesson 07), not host shell substitutions.
# ports maps host loopback 8084 to container 80; EXPOSE alone doesn't publish.
# labels mark ownership, including the default network. Build fundamentals
# belong to 08, static content to 20, and volumes/storage to 05 and 06.
# No version: field is needed by the current Compose Specification.
# Compose interpolation happens before containers exist. ${NAME:-default}
# uses the default when NAME is unset or empty. CLI --env-file supplies
# interpolation values; a shell value takes precedence. It does not inject
# every file entry into a container: environment above explicitly maps only
# COMPOSE24_MESSAGE to LESSON. Service env_file: instead supplies container
# variables; see lesson 07 for runtime environment values.
# config --format json displays the resolved model as JSON; jq -e checks
# the expected value and fails the lesson if the comparison is false.
echo 'Resolve config with no message: expect LESSON=Compose basics.'
compose config --quiet
CONFIG=$(compose config --format json)
printf '%s\n' "$CONFIG"
jq -e '.services.web.environment.LESSON == "Compose basics"' <<<"$CONFIG" >/dev/null
cat > "$ENV_FILE" <<'ENV'
COMPOSE24_MESSAGE=From the interpolation file
COMPOSE24_UNUSED=Interpolation only sentinel
ENV
echo 'Resolve config with the owned env file: expect LESSON=From the interpolation file.'
CONFIG=$(compose config --format json)
printf '%s\n' "$CONFIG"
jq -e '.services.web.environment == {"LESSON": "From the interpolation file"}' <<<"$CONFIG" >/dev/null
echo 'Resolve config with a command-scoped shell value: expect LESSON=Shell override.'
CONFIG=$(COMPOSE24_MESSAGE='Shell override' compose config --format json)
printf '%s\n' "$CONFIG"
jq -e '.services.web.environment == {"LESSON": "Shell override"}' <<<"$CONFIG" >/dev/null
echo 'Verified default < env file < shell precedence; service commands now use the file value.'
read -r -p 'Press ENTER to continue...'
assert_empty_project
# BuildKit resolves the native FROM into its cache. We do not explicitly
# pull/tag the shared base; existing base tags are checked and left alone.
# The only Docker image-store tag created is our run-labelled service image.
# Register image cleanup before build and project cleanup before first up:
# either operation can create resources and then fail or be interrupted.
cleanup_add compose-image remove_image
compose build web
IMAGE_ID=$(docker image inspect --format '{{.Id}}' "$IMAGE")
die_if_image_not_native "$IMAGE"
cleanup_add compose-project cleanup_project
# A build can take time. Recheck runtime names/project membership and the
# recorded built-image ID/owner immediately before up, without reusing any
# resource that appeared while building.
assert_empty_project
# Detached up returns while the application starts; it isn't an HTTP check.
compose up --detach --no-build --pull never
SERVICE_ID=$(compose ps --all --quiet web)
[[ -n $SERVICE_ID && $SERVICE_ID != *$'\n'* ]] || die 'Expected one web service container.'
NETWORK_ID=$(docker network ls --quiet --no-trunc --filter "label=com.docker.compose.project=$PROJECT")
[[ -n $NETWORK_ID && $NETWORK_ID != *$'\n'* ]] || die 'Expected one default network.'
verify_project
printf 'Service container ID: %s\nDefault network ID: %s\n' "$SERVICE_ID" "$NETWORK_ID"
compose ps --all

# Bounded actual HTTP readiness: up/ps are lifecycle state, not service proof.
verify_http() {
  local attempt status running ready=no curl_status
  echo 'Checking HTTP readiness (30 attempts, 3s requests, 1s delay)...'
  for ((attempt=1; attempt<=30; attempt++)); do
    running=$(docker container inspect --format '{{.State.Running}}' "$SERVICE_ID") || return $?
    [[ $running == true ]] || { compose logs --no-color web >&2; return 1; }
    if status=$(curl --noproxy '*' --silent --show-error --connect-timeout 1 --max-time 3 \
      --output "$SCRATCH/index.html" --write-out '%{http_code}' "http://127.0.0.1:$PORT/"); then
      [[ $status == 200 ]] || { echo "Unexpected HTTP status: $status" >&2; return 1; }
      cmp website-test/index.html "$SCRATCH/index.html" || return $?
      ready=yes
      break
    else
      curl_status=$?
      [[ $curl_status == 7 || $curl_status == 28 || $curl_status == 52 || $curl_status == 56 ]] || return "$curl_status"
    fi
    if (( attempt < 30 )); then sleep 1 || return $?; fi
  done
  [[ $ready == yes ]] || { echo 'HTTP readiness timed out.' >&2; return 1; }
  echo 'Verified HTTP 200 and exact packaged index.html content.'
}
verify_http
# Check the actual container, rather than assuming config proves runtime.
RUNTIME_ENV=$(docker container inspect --format '{{json .Config.Env}}' "$SERVICE_ID")
jq -e 'index("LESSON=From the interpolation file") != null and
  all(.[]; startswith("COMPOSE24_UNUSED=") | not)' <<<"$RUNTIME_ENV" >/dev/null
LESSON_VALUE=$(compose exec -T web printenv LESSON)
[[ $LESSON_VALUE == 'From the interpolation file' ]] || die 'Runtime LESSON differs from the selected file value.'
# printenv returns 1 for an absent key. Require an in-container marker too:
# a failed Docker client returning 1 must never count as expected absence.
# The single quotes defer status/$? expansion to the container shell.
# shellcheck disable=SC2016
if ABSENCE=$(compose exec -T web sh -c '
  if printenv COMPOSE24_UNUSED; then
    exit 42
  else
    status=$?
    test "$status" -eq 1 || exit "$status"
    printf "%s\n" "printenv confirmed COMPOSE24_UNUSED absent"
  fi'); then
  [[ $ABSENCE == 'printenv confirmed COMPOSE24_UNUSED absent' ]] || die 'Missing container absence confirmation.'
else
  die 'Could not confirm the sentinel is absent from the container.'
fi
echo 'Verified runtime LESSON=From the interpolation file; unreferenced sentinel absent.'
# 2. logs reads service stdout/stderr. exec uses the existing web container;
# -T disables an interactive terminal so the command is usable in a script.
compose logs --no-color --tail 5 web
# Container shell, rather than the host, expands LESSON.
# shellcheck disable=SC2016
compose exec -T web sh -ec 'printf "exec environment: %s\n" "$LESSON"; nginx -t; touch /tmp/exec-marker'
# run creates a NEW disposable container from the service definition and
# overrides command. It doesn't publish service ports unless --service-ports
# is requested, avoiding a conflict with live web. --rm removes it on exit;
# a killed client can still leave it alive, hence the labelled fallback.
# shellcheck disable=SC2016
compose run --rm --no-deps -T --pull never web sh -ec \
  'test ! -e /tmp/exec-marker; printf "run environment: %s; separate writable layer\n" "$LESSON"'
compose exec -T web test -e /tmp/exec-marker
ONEOFFS=$(docker container ls --all --quiet --filter "label=com.docker.compose.project=$PROJECT" --filter 'label=com.docker.compose.oneoff=True')
[[ -z $ONEOFFS ]] || die 'Disposable run container was not removed.'
echo 'Verified exec retained its marker; run --rm used a separate container and removed it.'
printf 'Inspect http://127.0.0.1:%s/ on this host.\n' "$PORT"
read -r -p 'Press ENTER to continue...'

# 3. stop halts the service but retains its container and default network.
verify_project
compose stop --timeout 10 web
compose ps --all
RUNNING=$(docker container inspect --format '{{.State.Running}}' "$SERVICE_ID")
[[ $RUNNING == false ]] || die 'stop left web running.'
owned_network "$NETWORK_ID"
echo 'Observed stop: same container retained (stopped); same default network retained.'
# start restarts the SAME container, preserving its writable-layer marker.
compose start web
SAME_ID=$(compose ps --all --quiet web)
[[ $SAME_ID == "$SERVICE_ID" ]] || die 'start replaced the service container.'
compose exec -T web test -e /tmp/exec-marker
verify_http
echo 'Observed start: same container and marker retained; HTTP service ready again.'
read -r -p 'Press ENTER to continue...'

# down removes service containers/default network, but not the built image.
# No volumes are used here. Normally named/anonymous volumes remain; down
# --volumes additionally removes declared named and attached anonymous
# volumes. External volumes/networks are never removed by down. Treat any
# volume removal as a separate data decision (lessons 05/06), not a default.
# --rmi is intentionally avoided; remove only our labelled built image.
verify_project
cleanup_project
cleanup_cancel compose-project
REMAINING=$(docker container ls --all --quiet --filter "label=com.docker.compose.project=$PROJECT")
[[ -z $REMAINING ]] || die 'down left project containers.'
REMAINING=$(docker network ls --quiet --filter "label=com.docker.compose.project=$PROJECT")
[[ -z $REMAINING ]] || die 'down left project networks.'
RETAINED_ID=$(docker image inspect --format '{{.Id}}' "$IMAGE")
[[ $RETAINED_ID == "$IMAGE_ID" ]] || die 'down changed the built image.'
echo 'Observed down: service/run containers and default network removed; built image retained.'
remove_image
cleanup_cancel compose-image
rm --recursive --force -- "$SCRATCH"
cleanup_cancel compose-files
echo 'Compose lesson complete; owned project, image and temporary files removed.'
# SIGKILL cannot run traps. Use the printed project/file and inspect labels,
# IDs and network membership before recovering confirmed owned leftovers:
# docker container ls --all --filter label=com.docker.compose.project=PROJECT
# docker network ls --filter label=com.docker.compose.project=PROJECT
# docker image inspect PROJECT-web:lesson
# docker compose --project-name PROJECT --file FILE --project-directory SCRATCH --env-file ENV_FILE down
# Never blindly remove orphans or reader volumes. Retain changed resources
# for inspection. Build cache may remain; do not prune unrelated resources.
# References (current plugin syntax; checked against Compose 5.7.0):
# https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/
# https://docs.docker.com/reference/compose-file/interpolation/
# https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/
# https://docs.docker.com/reference/compose-file/services/
# https://docs.docker.com/compose/how-tos/project-name/
# https://docs.docker.com/reference/cli/docker/compose/run/
# https://docs.docker.com/reference/cli/docker/compose/down/
# https://github.com/docker/compose/releases/tag/v2.32.2
