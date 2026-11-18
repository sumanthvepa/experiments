#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 19-docker-login-logout.sh: Explore the docker login and logout commands
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

# Disable tracing before generating credentials, even under bash -x.
set +x
# Stop on unexpected failures, unset variables and failed pipelines.
set -euo pipefail
# Imports die and cleanup_add/cleanup_cancel. The helper removes owned
# resources on exit, errors, Ctrl-C (130) and TERM (143); see lesson 03.
# shellcheck source=bash-utilities.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"

echo '19-docker-login-logout: authenticate to our disposable local registry'
# Run on the HOST: bash /path/to/19-docker-login-logout.sh
# Needs Bash, Docker, curl, htpasswd (Apache utilities), jq, Python 3, tar
# and a local Linux Docker daemon. Docker access may require sudo. Pulling
# registry:3 needs network access, but no Docker Hub account or credentials.
# All commands run on the host; only the registry runs in a container.
# Nothing logs in or pushes to a remote registry. No firewall changes.
# Docker's 127.0.0.0/8 HTTP exception normally permits this loopback demo;
# it is not a production registry recipe. Basic auth over HTTP is visible
# on the wire: use TLS and proper secret storage for real deployments.
# If your daemon rejects HTTP, stop without changing daemon/trust settings.
# Other distributions, architectures, rootless, userns-remap, SELinux-enabled
# daemons and containerd image stores have not been tested. We copy the
# private auth file into the owned container: no host bind-mount relabeling
# or container writes to a reader directory are needed.

for TOOL in docker curl htpasswd jq python3 tar mktemp mkdir rm sleep; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL."
done
DOCKER_EXECUTABLE=$(command -v docker)
# A private directory (0700) and umask protect every generated file (0600).
# No reader config is opened, even by preliminary Docker commands. An
# explicitly selected non-default context would require reading its files,
# so report it before invoking Docker. DOCKER_HOST can select a local socket.
[[ ${DOCKER_CONTEXT:-default} == default ]] ||
  die 'This isolated lesson needs the default context and a local socket.'
[[ ${DOCKER_HOST:-unix:///var/run/docker.sock} == unix://* ]] ||
  die 'This loopback lesson needs a local Unix-socket Docker daemon.'
umask 077
WORK=$(mktemp --directory --tmpdir docker-basics-login.XXXXXX)
cleanup_add files rm --recursive --force -- "$WORK"
echo "Owned temporary directory: $WORK"
mkdir "$WORK/config" "$WORK/no-helpers" "$WORK/payload"
export DOCKER_CONFIG="$WORK/config"
printf '{"auths":{}}\n' > "$DOCKER_CONFIG/config.json"
# DOCKER_CONFIG alone is insufficient: the Linux CLI can automatically
# discover pass/secretservice helpers on PATH. Only Docker gets this empty
# PATH, preventing both discovery and execution of reader helpers. Use the
# previously resolved absolute Docker executable; other host tools retain
# their normal PATH. No CLI plugin or builder is needed by this lesson.
# The Unix socket needs no TLS material: also mask inherited certificate
# paths/TLS flags for this command, so personal client keys are never read.
docker() {
  DOCKER_TLS='' DOCKER_TLS_VERIFY='' DOCKER_CERT_PATH="$DOCKER_CONFIG" \
    PATH="$WORK/no-helpers" "$DOCKER_EXECUTABLE" --config "$DOCKER_CONFIG" "$@"
}
OS=$(docker version --format '{{.Server.Os}}')
ARCH=$(docker version --format '{{.Server.Arch}}')
[[ $OS == linux ]] || die 'This lesson requires a Linux Docker daemon.'

# 1. Guard names and port before creating anything in Docker.
REGISTRY_IMAGE='registry:3'
REGISTRY_NAME='docker-basics-login-registry'
PORT=5500
REGISTRY="127.0.0.1:$PORT"
PAYLOAD_IMAGE='docker-basics-login-payload:demo'
PUSH_IMAGE="$REGISTRY/demo/payload:demo"
EXISTING=$(docker container ls --all --quiet --filter "name=^/$REGISTRY_NAME$")
[[ -z $EXISTING ]] || die "Container name $REGISTRY_NAME already exists." \
  "Inspect it with docker container inspect $REGISTRY_NAME."
for IMAGE in "$PAYLOAD_IMAGE" "$PUSH_IMAGE"; do
  EXISTING=$(docker image ls --quiet "$IMAGE")
  [[ -z $EXISTING ]] || die "Image name $IMAGE already exists." \
    "Inspect it with docker image inspect $IMAGE."
done
# bind() checks the exact host address, without opening a firewall port.
# Docker's publish is the final authority if another process races this.
python3 - "$PORT" <<'PYPORT' || die "Host port 127.0.0.1:$PORT is busy."
import socket, sys
with socket.socket() as listener:
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind(('127.0.0.1', int(sys.argv[1])))
PYPORT
EXISTING=$(docker image ls --quiet "$REGISTRY_IMAGE")
if [[ -z $EXISTING ]]; then
  # Register first: a cancelled pull may still have installed the tag.
  cleanup_add registry-image docker image rm "$REGISTRY_IMAGE"
  docker image pull "$REGISTRY_IMAGE"
fi
IMAGE_ARCH=$(docker image inspect --format '{{.Architecture}}' "$REGISTRY_IMAGE")
[[ $IMAGE_ARCH == "$ARCH" ]] || die "Registry image architecture $IMAGE_ARCH differs from $ARCH."

# 2. Basic auth backed by a private bcrypt htpasswd file.
# These are generated DEMONSTRATION credentials, never a reader password.
# printf is a shell builtin: the password passes through stdin, never a
# process argument or terminal output. -i reads stdin; -B selects bcrypt;
# -c creates the private file. Do not use htpasswd -b (password argument).
DEMO_USER='tutorial'
DEMO_PASSWORD=$(python3 -c 'import secrets; print(secrets.token_hex(24))')
printf '%s\n' "$DEMO_PASSWORD" | htpasswd -i -B -c "$WORK/htpasswd" "$DEMO_USER"
read -r -p 'Press ENTER to create the authenticated loopback registry...'
# --publish maps HOST-IP:HOST-PORT:CONTAINER-PORT. Only 127.0.0.1:5500
# is exposed; 5000 belongs to the Flask lesson. --env sets registry options,
# containing no passwords. Registry creates an anonymous data volume;
# rm --volumes removes it along with the owned container, even on failure.
ID=$(docker container create --name "$REGISTRY_NAME" \
  --publish "127.0.0.1:$PORT:5000" \
  --env REGISTRY_AUTH=htpasswd \
  --env REGISTRY_AUTH_HTPASSWD_REALM='Local tutorial' \
  --env REGISTRY_AUTH_HTPASSWD_PATH=/htpasswd \
  "$REGISTRY_IMAGE")
cleanup_add registry docker container rm --force --volumes "$ID"
echo "Owned registry container: $ID"
docker container cp "$WORK/htpasswd" "$ID:/htpasswd"
docker container start "$ID" >/dev/null

# registry_request: authenticated HTTP GET, body to a private file and
# status to stdout. The curl configuration, including auth, uses stdin.
# --disable ignores ~/.curlrc; --noproxy avoids sending loopback credentials
# through a proxy. Bound each request to two seconds. Never use curl -v.
# Usage: registry_request API-path output-file
registry_request() {
  printf 'user = "%s:%s"\n' "$DEMO_USER" "$DEMO_PASSWORD" |
    curl --disable --config - --noproxy '*' --silent --show-error \
      --connect-timeout 1 --max-time 2 --output "$2" \
      --write-out '%{http_code}' "http://$REGISTRY$1"
}
# require_registry: an anonymous 401 plus an authenticated 200 verifies
# real auth, not merely a listening port. 30 attempts, 1s between attempts.
require_registry() {
  local attempt code authorized
  echo 'Waiting for registry HTTP authentication (30 attempts, 2s/request)...'
  for attempt in {1..30}; do
    if code=$(curl --disable --noproxy '*' --silent --show-error \
        --connect-timeout 1 --max-time 2 --output "$WORK/anonymous.json" \
        --write-out '%{http_code}' "http://$REGISTRY/v2/") && \
        [[ $code == 401 ]]; then
      if authorized=$(registry_request /v2/ "$WORK/authorized.json") && \
          [[ $authorized == 200 ]]; then
        jq --exit-status '.errors | any(.code == "UNAUTHORIZED")' \
          "$WORK/anonymous.json" >/dev/null || die 'Missing registry auth error.'
        echo 'Verified anonymous HTTP 401 and authenticated HTTP 200.'
        return 0
      fi
    fi
    [[ $attempt == 30 ]] || sleep 1
  done
  die 'Registry readiness/authentication failed; inspect local daemon support.'
}
require_registry

# 3. Own a tiny image, rather than retagging a reader's image (which would
# alter its metadata). tar streams one text file to image import; import
# creates a filesystem image without a build context, base or build plugin.
printf 'Disposable registry authentication payload.\n' > "$WORK/payload/lesson.txt"
PAYLOAD_ID=$(tar --create --directory "$WORK/payload" --file - lesson.txt |
  docker image import - "$PAYLOAD_IMAGE")
cleanup_add payload docker image rm "$PAYLOAD_ID"
# Register removal before tagging so errors after tag still clean it.
cleanup_add push-tag docker image rm "$PUSH_IMAGE"
docker image tag "$PAYLOAD_ID" "$PUSH_IMAGE"

# expect_denied_push: require an authentication denial, not any nonzero
# exit (a broken connection is not proof of access control). Redirection
# captures version-dependent Docker output, then prints only the result.
# Usage: expect_denied_push before-login|after-logout
expect_denied_push() {
  local status=0 output
  docker image push "$PUSH_IMAGE" > "$WORK/push-$1.log" 2>&1 || status=$?
  [[ $status -ne 0 ]] || die "Push unexpectedly succeeded $1."
  output=$(<"$WORK/push-$1.log")
  [[ $output == *'unauthorized'* || $output == *'no basic auth credentials'* ]] ||
    die "Push failed without an authentication denial $1 (status $status)."
  echo "Verified push denied $1 (status $status)."
}
read -r -p 'Press ENTER to push before login (expect authentication denial)...'
expect_denied_push before-login
CODE=$(registry_request /v2/demo/payload/tags/list "$WORK/tags.json")
[[ $CODE == 404 ]] || die 'The unauthenticated push created an unexpected repository.'
echo 'Verified repository absent before login (HTTP 404).'

# 4. login authenticates this registry host:port and stores client credentials.
# --username (-u) supplies a name; --password-stdin avoids history/process
# argument exposure. All credentials belong to this disposable demo only.
read -r -p 'Press ENTER to login using the demonstration password on stdin...'
if ! printf '%s\n' "$DEMO_PASSWORD" |
    docker login "$REGISTRY" --username "$DEMO_USER" --password-stdin; then
  die 'Local HTTP login failed: external validation blocker; do not change daemon or certificate trust settings.'
fi
# Show ONLY the isolated entry; it contains a reversible base64 auth value.
# jq --arg supplies the host:port as a literal key, avoiding shell expansion
# inside the single-quoted jq program. Decode in memory, verify the exact
# username/password pair, then redact the password before printing.
echo 'Temporary config entry (base64 is encoding, NOT encryption):'
jq --arg registry "$REGISTRY" '{auths: {($registry): .auths[$registry]}}' \
  "$DOCKER_CONFIG/config.json"
ENCODED=$(jq --exit-status --raw-output --arg registry "$REGISTRY" \
  '.auths[$registry].auth' "$DOCKER_CONFIG/config.json")
DECODED=$(printf '%s' "$ENCODED" | python3 -c \
  'import base64,sys; sys.stdout.write(base64.b64decode(sys.stdin.read(), validate=True).decode())')
[[ $DECODED == "$DEMO_USER:$DEMO_PASSWORD" ]] || die 'Stored credential did not decode to the demonstration credentials.'
unset DECODED
echo "Decoded username: $DEMO_USER; password: [REDACTED]; exact match verified."
read -r -p 'Press ENTER to push after login...'
docker image push "$PUSH_IMAGE" || die 'Authenticated push failed.'
CODE=$(registry_request /v2/demo/payload/tags/list "$WORK/tags.json")
[[ $CODE == 200 ]] || die 'Pushed repository is not observable.'
jq --exit-status '.name == "demo/payload" and .tags == ["demo"]' \
  "$WORK/tags.json" >/dev/null || die 'Registry tags do not match the pushed image.'
echo 'Verified registry now contains demo/payload:demo (HTTP 200).'

# 5. logout removes this registry's CLIENT credential, not the server image
# or account. Supply the registry explicitly; logout accepts a SERVER.
read -r -p 'Press ENTER to logout and push again (expect authentication denial)...'
docker logout "$REGISTRY" || die 'Logout failed.'
jq --exit-status --arg registry "$REGISTRY" \
  '(.auths[$registry].auth // "") == ""' "$DOCKER_CONFIG/config.json" \
  >/dev/null || die 'Logout left an auth entry.'
expect_denied_push after-logout
CODE=$(registry_request /v2/demo/payload/tags/list "$WORK/tags-after.json")
[[ $CODE == 200 ]] || die 'Logout unexpectedly removed the server repository.'
[[ $(<"$WORK/tags-after.json") == "$(<"$WORK/tags.json")" ]] ||
  die 'Registry content changed during the denied push.'
echo 'Verified logout removed local auth; registry content is unchanged.'

# Credential helpers for real work (COMMENTS ONLY; never read user config):
# credsStore names a default docker-credential-<name> program; credHelpers
# maps individual registry names to helpers, overriding the default store.
# Docker Desktop normally uses its native credential store; Linux can
# discover pass or secretservice automatically. Helpers store credentials
# outside config.json; base64 auth in config.json is not encryption.
# To inspect ONLY helper names yourself, without displaying auth entries:
# jq '{credsStore, credHelpers}' "${DOCKER_CONFIG:-$HOME/.docker}/config.json"
# This prints configuration names only; it does not invoke any helper.
# The temporary helper-free PATH above is a teaching isolation measure,
# not a recommendation to bypass your normal credential store.
#
# Docker Hub (COMMENTS ONLY; no real login is performed):
# docker login --username YOUR_DOCKERHUB_USERNAME
# This prompts for a password or personal access token. Without --username,
# Docker Hub login normally starts a browser/device-code flow. Omit SERVER
# for Docker Hub; use HOST[:PORT] for another registry, without URL paths.
# docker logout                 # default registry
# docker logout registry.example.com:5000
# Official references:
# https://docs.docker.com/reference/cli/docker/login/
# https://docs.docker.com/reference/cli/docker/logout/
# https://docs.docker.com/reference/cli/docker/#configuration-files
# https://docs.docker.com/reference/cli/dockerd/#insecure-registries
# https://distribution.github.io/distribution/about/deploying/#native-basic-auth
# https://distribution.github.io/distribution/spec/api/

# 6. Visible cleanup, in reverse dependency order. No global prune.
read -r -p 'Press ENTER to remove our registry, data, images and private files...'
docker image rm "$PUSH_IMAGE"
cleanup_cancel push-tag
docker image rm "$PAYLOAD_ID"
cleanup_cancel payload
docker container rm --force --volumes "$ID"
cleanup_cancel registry
if [[ -z $EXISTING ]]; then
  docker image rm "$REGISTRY_IMAGE"
  cleanup_cancel registry-image
fi
unset DEMO_PASSWORD ENCODED
rm --recursive --force -- "$WORK"
cleanup_cancel files
echo 'Lesson complete; owned registry, data, images and private files removed.'
# SIGKILL/power loss cannot run traps. Inspect before removing leftovers:
# docker container inspect docker-basics-login-registry
# docker image inspect docker-basics-login-payload:demo
# docker image inspect 127.0.0.1:5500/demo/payload:demo
# docker container rm --force --volumes CONTAINER_ID  # only your owned ID
# Remove only the owned demo tags and printed temporary directory after
# inspection. Preserve any registry:3 image that existed before the run.
