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

echo '17-docker-inspect: inspect images, containers and networks'
# Host: bash /path/to/17-docker-inspect.sh
# Needs Bash, jq, Docker, a local Linux daemon and network access
# to Docker Hub/AlmaLinux repositories. No host packages are installed.
# No ports, host mounts or firewall changes are needed. Only native arm64
# on rootful Docker was tested; other architectures/daemon modes are untested.
# Check jq BEFORE pulling/building; install missing tools yourself first.
die_if_not_available jq dirname sleep timeout
die_if_not_docker_available
IMAGE=docker-basics-nginx
NETWORK=docker-basics-inspect-network
NETWORK_ID=
BASE=almalinux:10-minimal
RUN_TOKEN="inspect-$$-$RANDOM"
OWNER_LABEL=io.github.svepa.docker-basics.inspect-run
die_if_docker_image_exists "$IMAGE:latest"
# The second container deliberately shares the image's name for section 4.
die_if_docker_container_exists nginx-test-container "$IMAGE"

EXISTING=$(docker network ls --quiet --filter "name=^$NETWORK$")
[[ -z $EXISTING ]] || die "Network name $NETWORK already exists." \
  "Inspect it with docker network inspect $NETWORK before removing an unwanted network."

# Prefer the ID returned by create. Only before that assignment completes
# (including an interrupted create) discover the exact name and verify its label.
# A missing network is harmless (cleanup is registered before creation).
# Never disconnect unknown endpoints: Docker refuses removal while in use.
remove_owned_network() {
  local existing owner network_id=${NETWORK_ID:-} filter="name=^$NETWORK$"
  if [[ -n $network_id ]]; then filter="id=$network_id"; fi
  existing=$(docker network ls --quiet --no-trunc --filter "$filter") || return $?
  [[ -n $existing ]] || return 0
  [[ $existing != *$'\n'* ]] || {
    echo "Refusing ambiguous network name $NETWORK; inspect it manually." >&2
    return 1
  }
  network_id=$existing
  owner=$(docker network inspect --format "{{index .Labels \"$OWNER_LABEL\"}}" "$network_id") || return $?
  [[ $owner == "$RUN_TOKEN" ]] || {
    echo "Refusing to remove changed network $NETWORK; inspect it manually." >&2
    return 1
  }
  docker network rm "$network_id" || return $?
}

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
pull_image_if_absent "$BASE"
die_if_image_not_native "$BASE"

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
read -r -p 'Press ENTER to continue...'

# Register the future network before either container: reverse cleanup must
# remove their endpoints before the network, even if interrupted in section 5.
# The unique label prevents touching a same-name network owned by someone else.
cleanup_add inspect-network remove_owned_network

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
read -r -p 'Press ENTER to continue...'

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
read -r -p 'Press ENTER to continue...'

# 5. Inspect a network's configuration and its current endpoint membership
# Create our own bridge instead of changing the daemon's built-in bridge.
# --driver selects the network implementation; the ownership label is network
# metadata (.Labels), unlike an image/container's .Config.Labels. Let Docker
# allocate an available subnet: addresses and IDs are observations, not constants.
NETWORK_ID=$(docker network create --driver bridge --label "$OWNER_LABEL=$RUN_TOKEN" "$NETWORK")
echo "JSON metadata of the network $NETWORK (one-element array):"
docker inspect --type=network "$NETWORK" | jq .
# A network has .Driver, .Scope and .IPAM, rather than image process defaults
# or container .State. Explicit --type=network or network inspect avoids name
# ambiguity. The Go template's json function also works on nested network data.
echo 'Network address-management configuration (.IPAM):'
docker network inspect --format '{{json .IPAM}}' "$NETWORK_ID" | jq .
# Driver=bridge and Scope=local describe a single-daemon bridge. IPAM.Driver
# identifies address management; IPAM.Config lists allocated Subnet/Gateway.
# Internal restricts external access when true; it is false here by default.
# None of these fields alone proves HTTP readiness or connectivity; lesson 21
# owns network configuration/connectivity. Here we only observe membership.
docker network inspect "$NETWORK_ID" | jq -e --arg name "$NETWORK" \
  --arg id "$NETWORK_ID" --arg label "$OWNER_LABEL" --arg owner "$RUN_TOKEN" '
  length == 1 and .[0].Name == $name and .[0].Id == $id and
  .[0].Driver == "bridge" and .[0].Scope == "local" and
  (.[0].Internal | not) and .[0].Labels[$label] == $owner and
  .[0].IPAM.Driver == "default" and
  (.[0].IPAM.Config | any(.Subnet != null and .Gateway != null)) and
  (.[0].Containers | length) == 0
' >/dev/null
echo 'Verified local bridge configuration and initially empty membership.'
# Reuse the original container after its stopped-state inspection. Starting
# then connecting it gives this network one live endpoint without a new image
# or container. Its existing default-bridge attachment is left intact.
docker container start "$ID"
docker network connect "$NETWORK_ID" "$ID"
echo 'Live network endpoints (.Containers, keyed by container ID):'
docker network inspect --format '{{json .Containers}}' "$NETWORK_ID" | jq .
# EndpointID names this attachment, not the container or network. IPv4Address
# includes a prefix length. The container view stores IPAddress separately.
docker network inspect "$NETWORK_ID" | jq -e --arg id "$ID" '
  (.[0].Containers | length) == 1 and
  .[0].Containers[$id].Name == "nginx-test-container" and
  (.[0].Containers[$id].EndpointID | length) > 0 and
  (.[0].Containers[$id].IPv4Address | contains("/"))
' >/dev/null
echo 'The same attachment from the container (.NetworkSettings.Networks):'
docker container inspect --format '{{json .NetworkSettings.Networks}}' "$ID" | jq .
docker container inspect "$ID" | jq -e --arg network "$NETWORK" --arg id "$NETWORK_ID" '
  .[0].State.Running and .[0].NetworkSettings.Networks[$network].NetworkID == $id and
  (.[0].NetworkSettings.Networks[$network].IPAddress | length) > 0
' >/dev/null
echo 'Verified live endpoint membership in both network and container inspection.'
read -r -p 'Press ENTER to continue...'

# 6. Visible cleanup removes only this run's containers, network and image tags
# Remove containers before their network and image. Keep fallbacks until
# each removal succeeds; a base that existed at startup is left untouched.
docker container rm "$AMBIGUOUS_ID"
cleanup_cancel inspect-ambiguous
docker container stop "$ID"
docker container rm "$ID"
cleanup_cancel inspect-container
docker network inspect "$NETWORK_ID" | jq -e '.[0].Containers | length == 0' >/dev/null
remove_owned_network
cleanup_cancel inspect-network
echo 'Verified endpoints removed before owned network removal.'
remove_owned_image "$IMAGE:latest"
cleanup_cancel inspect-image
remove_pulled_image "$BASE"
echo 'Lesson complete; owned inspection resources removed.'
# SIGKILL cannot run traps; a killed Docker client can leave a container.
# Inspect suspected leftovers first:
# docker container inspect nginx-test-container docker-basics-nginx
# docker image inspect docker-basics-nginx almalinux:10-minimal
# docker network inspect docker-basics-inspect-network
# Then remove only confirmed lesson-owned containers/networks by ID and image tags:
# docker container rm --force ID
# docker image rm docker-basics-nginx:latest
# docker network rm NETWORK_ID  # only after its confirmed owned endpoints are removed
# References:
# https://docs.docker.com/reference/cli/docker/inspect/
# https://docs.docker.com/engine/containers/run/
# https://pkg.go.dev/text/template
# https://docs.docker.com/reference/cli/docker/network/inspect/
# https://docs.docker.com/reference/cli/docker/network/create/
# https://docs.docker.com/reference/cli/docker/network/rm/
