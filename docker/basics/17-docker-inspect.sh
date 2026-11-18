#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 17-docker-inspect.sh: Explore the docker inspect command
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

# Stop on unexpected errors, unset variables and failed pipelines. In
# particular, pipefail stops a failed inspect hidden by a successful jq.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cleanup_cancel undo owned resources on
# normal exit, errors, Ctrl-C (130) and SIGTERM (143).
source ./bash-utilities.sh

echo '17-docker-inspect: inspect image configuration and container state'
# Host: bash /path/to/17-docker-inspect.sh
# Needs Bash, jq, Docker/Buildx, a local Linux daemon and network access
# to Docker Hub/AlmaLinux repositories. No host packages are installed.
# No ports, host mounts or firewall changes are needed. Only native arm64
# on rootful Docker was tested; other architectures/daemon modes are untested.
# Check jq BEFORE pulling/building; install missing tools yourself first.
for TOOL in docker jq dirname sleep timeout; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL before setup."
done
docker info >/dev/null
docker buildx version >/dev/null
DAEMON_OS=$(docker version --format '{{.Server.Os}}')
[[ $DAEMON_OS == linux ]] || die 'This lesson needs a Linux Docker daemon.'
NATIVE_ARCH=$(docker version --format '{{.Server.Arch}}')
IMAGE=docker-basics-nginx
BASE=almalinux:10-minimal
RUN_TOKEN="inspect-$$-$RANDOM"
OWNER_LABEL=io.github.svepa.docker-basics.inspect-run
EXISTING=$(docker image ls --quiet "$IMAGE:latest")
[[ -z $EXISTING ]] || die "Image name $IMAGE already exists." \
  "Inspect it with docker image inspect $IMAGE before removing an unwanted tag."
# The second container deliberately shares the image's name for section 4.
for NAME in nginx-test-container "$IMAGE"; do
  EXISTING=$(docker container ls --all --quiet --filter "name=^/$NAME$")
  [[ -z $EXISTING ]] || die "Container name $NAME already exists." \
    "Inspect it with docker container inspect $NAME before removing it."
done

# Remove a tag acquired only after the absence check above. Register before
# pull/build so a client interrupted just after acquiring the tag is covered.
# For the built image, verify our unique label before touching the tag.
# A cleanup function must return failures explicitly (see bash-utilities.sh).
remove_owned_image() {
  local tag=$1 owner existing
  existing=$(docker image ls --quiet "$tag") || return $?
  [[ -n $existing ]] || return 0
  if [[ $tag == "$IMAGE:latest" ]]; then
    owner=$(docker image inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$tag") || return $?
    [[ $owner == "$RUN_TOKEN" ]] || {
      echo "Refusing to remove changed image tag $tag; inspect it manually." >&2
      return 1
    }
  fi
  docker image rm "$tag" || return $?
}
BASE_CREATED=no
EXISTING=$(docker image ls --quiet "$BASE")
if [[ -z $EXISTING ]]; then
  cleanup_add inspect-base remove_owned_image "$BASE"
  BASE_CREATED=yes
  docker image pull "$BASE"
fi
BASE_ARCH=$(docker image inspect --format '{{.Architecture}}' "$BASE")
[[ $BASE_ARCH == "$NATIVE_ARCH" ]] || die "Base architecture $BASE_ARCH differs from daemon architecture $NATIVE_ARCH."
echo "Verified native base architecture: $BASE_ARCH"

# 1. Build an image with labels, then inspect its complete JSON metadata
# --tag assigns a local name (latest is the default tag). The last argument
# is the build context; lesson 08 explains the unchanged shared Dockerfile.
# The extra label identifies this run for safe cleanup. Build cache may remain.
cleanup_add inspect-image remove_owned_image "$IMAGE:latest"
echo "Building $IMAGE from ./docker-basics-nginx..."
docker image build --tag "$IMAGE:latest" --label "$OWNER_LABEL=$RUN_TOKEN" ./docker-basics-nginx
# Unformatted inspect returns a JSON ARRAY, even for one object. Without
# --type it searches resource types; here no container has this image name yet.
echo "JSON metadata of the image $IMAGE (one-element array):"
docker inspect "$IMAGE"
# --format (-f) executes a Go template for each result. Single quotes keep
# braces/dollar signs literal in the host shell. . is the current object;
# .Id selects its content-addressed image ID, which varies between builds.
echo 'ID of the image (.Id):'
IMAGE_ID=$(docker inspect --type=image --format '{{.Id}}' "$IMAGE")
printf '%s\n' "$IMAGE_ID"
# .Config is the image's default process configuration: command, labels,
# environment, exposed ports and stop signal. It has no running process/PID.
# json is Docker's template FUNCTION, serializing the selected value as JSON.
echo 'Config section of the image (compact JSON):'
IMAGE_CONFIG=$(docker inspect --type=image --format '{{json .Config}}' "$IMAGE")
printf '%s\n' "$IMAGE_CONFIG"
# A pipe sends inspect's stdout to jq, the host JSON processor. jq . pretty
# prints the same object. This does not change the image or its configuration.
echo 'Config section of the image (formatted):'
docker inspect --type=image --format '{{json .Config}}' "$IMAGE" | jq .
# .Config.Labels selects a string map inside Config. OCI metadata describes
# the image; labels do not control nginx. Bracket syntax in jq handles keys
# containing dots. jq -e makes a false/missing assertion return nonzero.
echo 'Labels of the image (.Config.Labels):'
docker inspect --type=image --format '{{json .Config.Labels}}' "$IMAGE" | jq .
docker image inspect "$IMAGE" | jq -e '
  length == 1 and
  .[0].Config.Cmd == ["nginx", "-g", "daemon off;"] and
  .[0].Config.StopSignal == "SIGQUIT" and
  (.[0].Config.ExposedPorts | has("80/tcp")) and
  (.[0].Config.Labels["org.opencontainers.image.description"] | contains("nginx"))
' >/dev/null
echo 'Verified image command, exposed port, stop signal and description label.'
read -r -p 'Press ENTER to start nginx and inspect its runtime state...'

# 2. A running container has its own identity and mutable runtime state
# Separate create/start lets cleanup register the returned container ID
# before nginx starts. --label adds a container-only label to demonstrate an
# override/addition; image metadata stays unchanged. No port is published.
ID=$(docker container create --name nginx-test-container \
  --label inspection.example=container-only "$IMAGE")
cleanup_add inspect-container docker container rm --force "$ID"
docker container start "$ID"
# Bounded readiness: inspect Docker state separately from a failed HTTP probe.
# timeout bounds each exec to 3 seconds; at most 30 probes and 29 sleeps.
# bash's /dev/tcp opens a TCP connection INSIDE the container. A real HTTP
# response proves nginx is serving, rather than merely that PID1 exists.
echo 'Waiting for nginx HTTP readiness inside the container...'
READY=no
for ((ATTEMPT=1; ATTEMPT<=30; ATTEMPT++)); do
  RUNNING=$(docker container inspect --format '{{.State.Running}}' "$ID")
  if [[ $RUNNING != true ]]; then
    docker container logs "$ID" >&2
    die 'nginx container stopped before readiness.'
  fi
  # The single-quoted command expands $response inside the container.
  # shellcheck disable=SC2016
  if RESPONSE=$(timeout 3 docker container exec "$ID" bash -ec \
    'exec 3<>/dev/tcp/127.0.0.1/80; printf "GET / HTTP/1.0\r\nHost: localhost\r\n\r\n" >&3; IFS= read -r response <&3; printf "%s" "$response"'); then
    [[ $RESPONSE == 'HTTP/1.1 200 OK'* ]] || die "Unexpected nginx HTTP response: $RESPONSE"
    READY=yes
    break
  else
    PROBE_STATUS=$?
    [[ $PROBE_STATUS == 1 || $PROBE_STATUS == 124 ]] || die "nginx readiness command failed: $PROBE_STATUS."
  fi
  if (( ATTEMPT < 30 )); then sleep 1; fi
done
[[ $READY == yes ]] || die 'nginx readiness timed out (30 attempts, 3s timeout, 1s delay).'
echo 'Verified nginx HTTP readiness: HTTP/1.1 200 OK'
echo 'JSON metadata of the container nginx-test-container:'
docker inspect "$ID" | jq .
# .Image is the immutable image ID used to create this container; .Config.Image
# is the supplied image reference. .Config copies defaults plus create-time
# overrides, whereas .State holds running status, exit code and current PID.
# A running state alone is not an HTTP health check. PIDs/times vary by run.
echo 'Container runtime state (.State):'
docker container inspect --format '{{json .State}}' "$ID" | jq .
docker container inspect "$ID" | jq -e --arg image "$IMAGE_ID" '
  .[0].Image == $image and .[0].State.Running and .[0].State.Pid > 0 and
  .[0].Config.Labels["inspection.example"] == "container-only"
' >/dev/null
# Container labels inherit image labels and may be extended at creation.
echo 'Labels of the container, using the explicit subcommand:'
docker container inspect --format '{{json .Config.Labels}}' "$ID" | jq .
docker image inspect "$IMAGE" | jq -e '.[0].Config.Labels | has("inspection.example") | not' >/dev/null
CURRENT_IMAGE_CONFIG=$(docker image inspect --format '{{json .Config}}' "$IMAGE")
[[ $CURRENT_IMAGE_CONFIG == "$IMAGE_CONFIG" ]] || die 'Image configuration changed unexpectedly.'
echo 'Verified container-only label; image configuration is unchanged.'
read -r -p 'Press ENTER to stop nginx and compare its runtime state...'

# 3. Stop the same container and compare the runtime fields
# stop uses the image's SIGQUIT. wait returns the process exit status; the
# inspect command itself can succeed even when that process exited nonzero.
docker container stop "$ID"
EXIT_CODE=$(docker container wait "$ID")
[[ $EXIT_CODE == 0 ]] || die "nginx shutdown failed: $EXIT_CODE."
echo 'Stopped container runtime state (.State):'
docker container inspect --format '{{json .State}}' "$ID" | jq .
docker container inspect "$ID" | jq -e --arg image "$IMAGE_ID" '
  .[0].Image == $image and .[0].State.Status == "exited" and
  (.[0].State.Running | not) and .[0].State.Pid == 0 and .[0].State.ExitCode == 0
' >/dev/null
echo 'Verified stopped state; image ID and configuration still describe the same image.'

# 4. Deliberate name ambiguity: two resource types share one name
# Create a second, unstarted container named docker-basics-nginx. Its name is
# intentionally identical to the image reference (which defaults to :latest).
# Generic inspect can resolve a different type than intended. Do not depend
# on its lookup order: --type=image/container selects the type explicitly.
AMBIGUOUS_ID=$(docker container create --name "$IMAGE" "$IMAGE")
cleanup_add inspect-ambiguous docker container rm --force "$AMBIGUOUS_ID"
echo 'Deliberate image/container name match: docker-basics-nginx'
echo 'JSON metadata using --type=image:'
docker inspect --type=image "$IMAGE" | jq .
echo 'JSON metadata using the image subcommand:'
docker image inspect "$IMAGE" | jq .
SELECTED_IMAGE=$(docker inspect --type=image --format '{{.Id}}' "$IMAGE")
SELECTED_CONTAINER=$(docker inspect --type=container --format '{{.Id}}' "$IMAGE")
[[ $SELECTED_IMAGE == "$IMAGE_ID" && $SELECTED_CONTAINER == "$AMBIGUOUS_ID" &&
   $SELECTED_IMAGE != "$SELECTED_CONTAINER" ]] || die 'Resource-type disambiguation did not select the expected IDs.'
printf 'Explicit image ID: %s\nExplicit container ID: %s\n' "$SELECTED_IMAGE" "$SELECTED_CONTAINER"
echo 'Verified --type disambiguation and explicit subcommand selection.'
read -r -p 'Press ENTER to remove the inspection examples...'

# To inspect a network
# TODO: Create a network for inspection
# docker inspect --type=network bridge

# 5. Visible cleanup removes only this run's containers and image tags
# Remove containers before the image they reference. Keep fallbacks until
# each removal succeeds; a base that existed at startup is left untouched.
docker container rm "$AMBIGUOUS_ID"
cleanup_cancel inspect-ambiguous
docker container rm "$ID"
cleanup_cancel inspect-container
remove_owned_image "$IMAGE:latest"
cleanup_cancel inspect-image
if [[ $BASE_CREATED == yes ]]; then
  remove_owned_image "$BASE"
  cleanup_cancel inspect-base
fi
echo 'Lesson complete; owned inspection resources removed.'
# SIGKILL cannot run traps; a killed Docker client can leave a container.
# Inspect suspected leftovers first:
# docker container inspect nginx-test-container docker-basics-nginx
# docker image inspect docker-basics-nginx almalinux:10-minimal
# Then remove only confirmed lesson-owned containers by ID and tags by name:
# docker container rm --force ID
# docker image rm docker-basics-nginx:latest
# References:
# https://docs.docker.com/reference/cli/docker/inspect/
# https://docs.docker.com/engine/containers/run/
# https://pkg.go.dev/text/template
