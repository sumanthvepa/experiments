#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 20-docker-build-website.sh: Explore building a website served by
# nginx in a Docker container
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

# Stop on unexpected failures, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports errors; cleanup_add/cleanup_cancel remove owned resources on
# normal exit, errors, Ctrl-C (130) and SIGTERM (143).
source ./bash-utilities.sh

echo '20-docker-build-website: package and serve a static nginx website'
# Host: bash /path/to/20-docker-build-website.sh
# Needs Bash, Docker/Buildx, curl, cmp, Python 3 and network access to
# Docker Hub/AlmaLinux repositories, with a local Linux Docker daemon.
# No host packages, mounts or credentials are needed. Only native arm64
# on rootful Docker was tested; other OS/CPU/daemon modes are untested.
# COPY avoids host bind-mount ownership/SELinux relabelling concerns.
for TOOL in curl cmp python3 mktemp rm dirname sleep; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL before setup."
done
die_if_not_docker_available
docker buildx version >/dev/null
DAEMON_OS=$(docker version --format '{{.Server.Os}}')
[[ $DAEMON_OS == linux ]] || die 'This lesson needs a Linux Docker daemon.'
IMAGE=website-test
BASE=almalinux:10-minimal
WEBSITE_PORT=8080
OWNER_LABEL=io.github.svepa.docker-basics.website-run
RUN_TOKEN="website-$$-$RANDOM"
ID=
die_if_docker_image_exists "$IMAGE:latest"
die_if_docker_container_exists "$IMAGE"
# Check the chosen loopback port without touching a listener. Docker start
# also checks it, covering a listener appearing after this preflight.
if ! python3 - "$WEBSITE_PORT" <<'PYPORT'
import socket
import sys
with socket.socket() as listener:
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind(('127.0.0.1', int(sys.argv[1])))
PYPORT
then
  die "Loopback port $WEBSITE_PORT is unavailable; leave its owner alone."
fi

# Cleanup uses this run's label and returned ID; a changed same-name resource
# is never removed. Register before build/create to cover interrupted clients.
remove_owned_container() {
  local existing owner target=${ID:-}
  if [[ -n $target ]]; then
    existing=$(docker container ls --all --quiet --no-trunc --filter "id=$target") || return $?
  else
    existing=$(docker container ls --all --quiet --no-trunc --filter "name=^/$IMAGE$") || return $?
  fi
  [[ -n $existing ]] || return 0
  owner=$(docker container inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$existing") || return $?
  [[ $owner == "$RUN_TOKEN" ]] || { echo 'Refusing to remove changed website container.' >&2; return 1; }
  docker container rm --force "$existing" || return $?
}
remove_owned_image() {
  local tag=$1 existing owner
  existing=$(docker image ls --quiet "$tag") || return $?
  [[ -n $existing ]] || return 0
  if [[ $tag == "$IMAGE:latest" ]]; then
    owner=$(docker image inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$tag") || return $?
    [[ $owner == "$RUN_TOKEN" ]] || { echo "Refusing to remove changed image $tag." >&2; return 1; }
  fi
  docker image rm "$tag" || return $?
}
pull_image_if_absent "$BASE"
die_if_image_not_native "$BASE"

# 1. Package local content in an image (build basics are in lesson 08).
# The final argument is the build context. COPY reads paths relative to it,
# placing index.html and style.css under nginx's root, plus our nginx.conf
# at /etc/nginx/nginx.conf. These are image files, not a live host mount:
# changing a source file later requires rebuilding and a new container.
# The configuration's root/index directives map / to index.html; try_files
# returns 404 for missing paths. mime.types supplies text/css for the asset.
cleanup_add website-image remove_owned_image "$IMAGE:latest"
echo 'Building website-test from ./website-test...'
docker image build --tag "$IMAGE:latest" --label "$OWNER_LABEL=$RUN_TOKEN" ./website-test
read -r -p 'Press ENTER to continue...'

# 2. Run nginx as PID 1 in the foreground (CMD daemon off;). EXPOSE only
# documents port 80; --publish (-p) maps host 127.0.0.1:8080 to container 80.
# This loopback demonstration needs no firewall opening or sudo; Docker
# manages publication rules. Host firewall rule state is left unchanged.
# A remote Docker context would publish on the daemon host, so use a local
# daemon. The page is entirely static: no Flask service or reverse proxy.
cleanup_add website-container remove_owned_container
ID=$(docker container create --name "$IMAGE" --label "$OWNER_LABEL=$RUN_TOKEN" \
  --publish "127.0.0.1:$WEBSITE_PORT:80" "$IMAGE:latest")
docker container start "$ID"
docker container exec "$ID" nginx -t
# Store responses privately for exact comparisons; never overwrite fixtures.
SCRATCH=$(mktemp --directory --tmpdir 'docker-basics-website.XXXXXXXX')
cleanup_add website-files rm --recursive --force -- "$SCRATCH"
URL="http://127.0.0.1:$WEBSITE_PORT"
echo 'Waiting for nginx HTTP readiness (30 attempts, 3s requests, 1s delay)...'
READY=no
for ((ATTEMPT=1; ATTEMPT<=30; ATTEMPT++)); do
  RUNNING=$(docker container inspect --format '{{.State.Running}}' "$ID")
  if [[ $RUNNING != true ]]; then
    docker container logs "$ID" >&2
    die 'nginx container stopped before readiness.'
  fi
  # --noproxy keeps inherited proxy settings from redirecting loopback traffic.
  # --write-out returns status separately from the response body in --output.
  if HTTP_STATUS=$(curl --noproxy '*' --silent --show-error --connect-timeout 1 \
    --max-time 3 --output "$SCRATCH/index.html" --write-out '%{http_code}' "$URL/"); then
    [[ $HTTP_STATUS == 200 ]] || die "Unexpected website HTTP status: $HTTP_STATUS."
    READY=yes
    break
  else
    CURL_STATUS=$?
    # Docker publication may reset/close a connection before nginx listens.
    # Retry connection refusal, timeout, empty reply and receive failure.
    [[ $CURL_STATUS == 7 || $CURL_STATUS == 28 || $CURL_STATUS == 52 || $CURL_STATUS == 56 ]] || die "Website readiness curl failed: $CURL_STATUS."
  fi
  if (( ATTEMPT < 30 )); then sleep 1; fi
done
[[ $READY == yes ]] || die 'nginx HTTP readiness timed out.'
# HTTP 200 alone could be the distribution's welcome page. Compare the
# actual body, then fetch the stylesheet referenced by our page and compare
# its body too. cmp's nonzero status stops the lesson if bytes differ.
cmp website-test/index.html "$SCRATCH/index.html"
echo 'Verified website page: HTTP 200 and exact packaged index.html content.'
HTTP_STATUS=$(curl --noproxy '*' --silent --show-error --connect-timeout 1 \
  --max-time 3 --output "$SCRATCH/style.css" --write-out '%{http_code}' "$URL/style.css")
[[ $HTTP_STATUS == 200 ]] || die "Unexpected stylesheet HTTP status: $HTTP_STATUS."
cmp website-test/style.css "$SCRATCH/style.css"
echo 'Verified referenced stylesheet: HTTP 200 and exact packaged style.css content.'
printf 'Open %s/ in a browser on this host.\n' "$URL"
read -r -p 'Press ENTER to continue...'

# 3. Visible cleanup, with registered fallbacks until each step succeeds.
docker container stop "$ID"
remove_owned_container
cleanup_cancel website-container
remove_owned_image "$IMAGE:latest"
cleanup_cancel website-image
remove_pulled_image "$BASE"
rm --recursive --force -- "$SCRATCH"
cleanup_cancel website-files
echo 'Lesson complete; owned website resources removed.'
# SIGKILL cannot run traps. Inspect possible leftovers before removing only
# confirmed owned container IDs/image tags (check the website-run label):
# docker container inspect website-test
# docker image inspect website-test almalinux:10-minimal
# docker container rm --force CONTAINER_ID
# docker image rm website-test:latest  # and base only if this run pulled it
# Build cache may remain; do not prune unrelated resources.
# References:
# https://docs.docker.com/reference/dockerfile/#copy
# https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/
# https://docs.docker.com/engine/network/port-publishing/
