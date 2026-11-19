#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 22-docker-rootless.sh: Explore Docker access and non-root
# container processes, and distinguish these from a rootless daemon
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
# die diagnoses failures; cleanup_add/cleanup_cancel retain owned-resource
# cleanup until removal succeeds, including Ctrl-C (130) and SIGTERM (143).
source ./bash-utilities.sh

echo '22-docker-rootless: Docker access, USER and gosu process identity'
# Host invocation: bash /path/to/22-docker-rootless.sh
# Requires Bash 4+, a Linux Docker daemon, Docker/Buildx, GNU timeout,
# coreutils and network access if the AlmaLinux base is absent. No sudo,
# mounts, ports or host account/daemon changes are needed. Native arm64 on
# rootful Docker was tested; amd64 and other daemon/OS modes are untested.
# Container-local numeric IDs avoid host user, UID mapping and SELinux
# bind-mount assumptions; lesson 06 owns the bind-mount examples.
for TOOL in docker timeout sha256sum cp mktemp rm dirname sleep; do
  command -v "$TOOL" >/dev/null || die "This lesson needs $TOOL before setup."
done
docker info >/dev/null
docker buildx version >/dev/null
DAEMON_OS=$(docker version --format '{{.Server.Os}}')
[[ $DAEMON_OS == linux ]] || die 'This lesson needs a Linux Docker daemon.'
NATIVE_ARCH=$(docker version --format '{{.Server.Arch}}')
case $NATIVE_ARCH in
  amd64) GOSU_SHA=bbc4136d03ab138b1ad66fa4fc051bafc6cc7ffae632b069a53657279a450de3;;
  arm64) GOSU_SHA=c3805a85d17f4454c23d7059bcb97e1ec1af272b90126e79ed002342de08389b;;
  *) die "Unsupported native daemon architecture: $NATIVE_ARCH (need amd64 or arm64).";;
esac
BASE=almalinux:10-minimal
USER_IMAGE='identity-user'
GOSU_IMAGE='identity-gosu'
OWNER_LABEL=io.github.svepa.docker-basics.identity-run
RUN_TOKEN="identity-$$-$RANDOM"
BASE_ID=
BASE_CREATED=no
declare -A CONTAINER_IDS=() IMAGE_IDS=()
for IMAGE in "$USER_IMAGE" "$GOSU_IMAGE"; do
  EXISTING=$(docker image ls --quiet "$IMAGE:latest")
  [[ -z $EXISTING ]] || die "Image name $IMAGE already exists." \
    "Inspect with docker image inspect $IMAGE before removing an unwanted tag."
  EXISTING=$(docker container ls --all --quiet --filter "name=^/$IMAGE$")
  [[ -z $EXISTING ]] || die "Container name $IMAGE already exists." \
    "Inspect with docker container inspect $IMAGE before removing it."
done

# Arguments: container name. Prefer the returned immutable ID, with exact
# name plus this run's label as a fallback during create/ID handoff.
remove_owned_container() {
  local name=$1 existing owner target=${CONTAINER_IDS[$1]:-}
  if [[ -n $target ]]; then
    existing=$(docker container ls --all --quiet --no-trunc --filter "id=$target") || return $?
  else
    existing=$(docker container ls --all --quiet --no-trunc --filter "name=^/$name$") || return $?
  fi
  [[ -n $existing ]] || return 0
  owner=$(docker container inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$existing") || return $?
  [[ $owner == "$RUN_TOKEN" ]] || { echo "Refusing to remove changed container $name." >&2; return 1; }
  docker container rm --force "$existing" || return $?
}
# Arguments: image tag. Labels protect lesson tags; the saved ID protects
# against replacing a tag after build. Pre-existing base images are exempt.
remove_owned_image() {
  local tag=$1 existing owner expected=${IMAGE_IDS[$1]:-}
  existing=$(docker image ls --quiet "$tag") || return $?
  [[ -n $existing ]] || return 0
  existing=$(docker image inspect --format '{{.Id}}' "$tag") || return $?
  if [[ $tag == "$BASE" ]]; then
    expected=$BASE_ID
  else
    owner=$(docker image inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$tag") || return $?
    [[ $owner == "$RUN_TOKEN" ]] || { echo "Refusing to remove changed image $tag." >&2; return 1; }
  fi
  [[ -z $expected || $existing == "$expected" ]] || { echo "Refusing to remove replaced image $tag." >&2; return 1; }
  docker image rm "$tag" || return $?
}
EXISTING=$(docker image ls --quiet "$BASE")
if [[ -z $EXISTING ]]; then
  cleanup_add identity-base remove_owned_image "$BASE"
  BASE_CREATED=yes
  timeout --foreground 300 docker image pull "$BASE"
fi
BASE_ID=$(docker image inspect --format '{{.Id}}' "$BASE")
BASE_ARCH=$(docker image inspect --format '{{.Architecture}}' "$BASE")
[[ $BASE_ARCH == "$NATIVE_ARCH" ]] || die "Base architecture $BASE_ARCH differs from daemon architecture $NATIVE_ARCH."
echo "Verified native base architecture: $BASE_ARCH"

# Access to a rootful Docker daemon

# On a Linux host with a rootful Docker daemon, the docker group
# normally grants access to the daemon's Unix socket. A member can
# run Docker commands without sudo, although the daemon still runs
# as root. This is not rootless Docker. Control of a rootful daemon
# grants root-level privileges on its host, so give this access only
# to trusted users.
#
# The following optional HOST administration command adds the current
# user to an existing docker group on a properly installed system.
# It stays commented out: this lesson does not change host accounts.
# -a appends to the supplementary groups; -G names those groups.
# Quoting "$USER" keeps the login name a single argument.
# sudo usermod -aG docker "$USER"
# Log out and log back in for the new group membership to take effect.
# This changes permission to use Docker, not the container's user.
# See https://docs.docker.com/engine/install/linux-postinstall/


# Successful CLI access alone cannot establish daemon identity. The following
# observation reports the daemon's security options without configuring it.
SECURITY_OPTIONS=$(docker info --format '{{json .SecurityOptions}}')
printf 'Observed daemon security options: %s\n' "$SECURITY_OPTIONS"
echo 'Docker access, container USER and rootless daemon mode are separate choices.'

# 1. USER chooses the build/runtime default identity.
# USER also affects following RUN instructions in that build stage. The
# direct-user target checks this at build time. Its CMD starts a non-root
# program; --user can override that default (see lesson 06).
# The demo has a build-prepared directory and a root-owned runtime directory.
# USER can write the first but cannot initialize the second. All paths are
# private container files, never host mounts.
# See https://docs.docker.com/reference/dockerfile/#user
# We reuse repository gosu 1.17 bytes, not another lesson's runtime state.
# A pinned SHA256 detects changed bytes; this is NOT GPG verification of
# the .asc signature. Upstream provenance/license are in rootless-test/README.md.
SCRATCH=$(mktemp --directory --tmpdir 'docker-basics-identity.XXXXXXXX')
cleanup_add identity-files rm --recursive --force -- "$SCRATCH"
cp --recursive rootless-test/. "$SCRATCH/"
GOSU_SOURCE="postgres-test/$NATIVE_ARCH/gosu-$NATIVE_ARCH"
printf '%s  %s\n' "$GOSU_SHA" "$GOSU_SOURCE" | sha256sum --check
cp -- "$GOSU_SOURCE" "$SCRATCH/gosu"
echo "Prepared private build context: $SCRATCH"
# --target selects a named Dockerfile stage; --label marks ownership.
# Each build is bounded to 900s. Build cache may remain after cleanup.
for TARGET in direct-user initialized-gosu; do
  if [[ $TARGET == direct-user ]]; then IMAGE=$USER_IMAGE; else IMAGE=$GOSU_IMAGE; fi
  cleanup_add "$IMAGE-image" remove_owned_image "$IMAGE:latest"
  echo "Building $IMAGE ($TARGET), timeout 900s..."
  timeout --foreground 900 docker image build --target "$TARGET" --tag "$IMAGE:latest" \
    --label "$OWNER_LABEL=$RUN_TOKEN" "$SCRATCH"
  IMAGE_IDS[$IMAGE:latest]=$(docker image inspect --format '{{.Id}}' "$IMAGE:latest")
done
read -r -p 'Press ENTER to compare USER and root-owned directory permissions...'

# Arguments: image/container name, mode (direct or gosu). Register before
# create, save its returned ID, start, then wait at most 30 one-second
# attempts for the actual application. Each exec probe is bounded to 5s.
start_application() {
  local name=$1 mode=$2 id running ready=no attempt status directory
  if [[ $mode == direct ]]; then directory=prepared; else directory=runtime; fi
  cleanup_add "$name-container" remove_owned_container "$name"
  CONTAINER_IDS[$name]=$(docker container create --name "$name" \
    --label "$OWNER_LABEL=$RUN_TOKEN" --network none "$name:latest")
  id=${CONTAINER_IDS[$name]}
  docker container start "$id"
  for ((attempt=1; attempt<=30; attempt++)); do
    running=$(docker container inspect --format '{{.State.Running}}' "$id")
    if [[ $running != true ]]; then
      docker container logs "$id" >&2
      die "Application $name stopped before readiness."
    fi
    if timeout --foreground 5 docker container exec --user 10001:10001 "$id" \
      test -f "/demo/$directory/ready"; then
      ready=yes
      break
    else
      status=$?
      [[ $status == 1 ]] || die "Application readiness probe failed: $status."
    fi
    if (( attempt < 30 )); then sleep 1; fi
  done
  [[ $ready == yes ]] || die "Application $name readiness timed out."
  docker container logs "$id"
}
# Arguments: container name. Config.User describes the default for NEW
# exec processes, not a process which already dropped privileges with gosu.
# Read /proc/1/status explicitly as root inside the container to inspect the
# primary process; all four real/effective/saved/filesystem IDs must match.
# A separate default exec id below intentionally demonstrates the difference.
verify_identity() {
  local name=$1 id config identity
  id=${CONTAINER_IDS[$name]}
  config=$(docker container inspect --format '{{.Config.User}}' "$id")
  printf '%s configured USER: %s\n' "$name" "$config"
  identity=$(docker container exec --user 0:0 "$id" bash -ec '
    while read -r key real effective saved filesystem rest; do
      case $key in
        Uid:|Gid:) printf "%s %s %s %s %s\n" "$key" "$real" "$effective" "$saved" "$filesystem";;
      esac
    done < /proc/1/status')
  [[ $identity == $'Uid: 10001 10001 10001 10001\nGid: 10001 10001 10001 10001' ]] || die "Unexpected PID 1 identity for $name: $identity"
  printf '%s PID 1 identity:\n%s\n' "$name" "$identity"
}
start_application "$USER_IMAGE" direct
verify_identity "$USER_IMAGE"
CONFIG=$(docker image inspect --format '{{.Config.User}}' "$USER_IMAGE:latest")
[[ $CONFIG == 10001:10001 ]] || die 'Unexpected USER image configuration.'
USER_ID=${CONTAINER_IDS[$USER_IMAGE]}
docker container exec "$USER_ID" bash -ec '
  test "$(id -u):$(id -g)" = 10001:10001
  test "$(cat /demo/prepared/message)" = "written by USER"
  test "$(stat --format=%u:%g:%a /demo/prepared)" = 10001:10001:700
  test "$(stat --format=%u:%g:%a /demo/runtime)" = 0:0:700'
echo 'Verified USER: non-root PID 1 writes prepared data and cannot initialize root-owned data.'
read -r -p 'Press ENTER to initialize as root and execute the application with gosu...'

# 2. Root initialization followed by exec gosu.
# The image defaults to 0:0 so its entrypoint can create a root-owned seed
# and transfer its private directory to 10001:10001. exec gosu changes user
# and group, then executes the application without a lingering root parent.
# The application validates the seed, writes as 10001 and still cannot
# write /root. This pattern needs trust in the root initialization code;
# it gives different startup permissions from USER alone.
# https://github.com/tianon/gosu/tree/1.17
start_application "$GOSU_IMAGE" gosu
verify_identity "$GOSU_IMAGE"
GOSU_ID=${CONTAINER_IDS[$GOSU_IMAGE]}
CONFIG=$(docker image inspect --format '{{.Config.User}}' "$GOSU_IMAGE:latest")
[[ $CONFIG == 0:0 ]] || die 'Unexpected gosu image configuration.'
DEFAULT_EXEC=$(docker container exec "$GOSU_ID" id -u)
[[ $DEFAULT_EXEC == 0 ]] || die 'Unexpected default exec identity.'
echo 'gosu default docker exec UID: 0; the existing PID 1 UID is 10001.'
# --user selects the identity of this new checking process explicitly.
docker container exec --user 10001:10001 "$GOSU_ID" bash -ec '
  test "$(cat /demo/runtime/seed)" = "initialized by root"
  test "$(cat /demo/runtime/message)" = "written after gosu"
  test "$(stat --format=%u:%g:%a /demo/runtime)" = 10001:10001:700
  test "$(stat --format=%u:%g /demo/runtime/seed)" = 10001:10001'
echo 'Verified gosu: root initialized data, then non-root PID 1 wrote it successfully.'
echo 'These container process demonstrations do not test or configure a rootless daemon.'
read -r -p 'Press ENTER to remove the identity examples...'

# 3. Visible cleanup. Fallbacks remain registered until each removal succeeds.
for IMAGE in "$GOSU_IMAGE" "$USER_IMAGE"; do
  docker container stop --timeout 2 "${CONTAINER_IDS[$IMAGE]}"
  remove_owned_container "$IMAGE"
  cleanup_cancel "$IMAGE-container"
done
for IMAGE in "$GOSU_IMAGE" "$USER_IMAGE"; do
  remove_owned_image "$IMAGE:latest"
  cleanup_cancel "$IMAGE-image"
done
rm --recursive --force -- "$SCRATCH"
cleanup_cancel identity-files
if [[ $BASE_CREATED == yes ]]; then
  remove_owned_image "$BASE"
  cleanup_cancel identity-base
fi
echo 'Identity lesson complete; owned resources removed.'
# SIGKILL cannot run traps. Inspect leftovers before removing confirmed
# owned IDs/tags: docker container inspect identity-user identity-gosu
# docker image inspect identity-user identity-gosu almalinux:10-minimal
# Check the identity-run label, then docker container rm --force ID and
# docker image rm TAG. Remove the base only if this run pulled it. Inspect
# the printed private context before removing it. Never prune other work.

# A rootless Docker daemon

# Docker's rootless mode runs the daemon and containers in a user
# namespace without root privileges on the host. A process can still
# be uid 0 (root) inside that namespace: with rootless Docker, this
# maps to the user running the daemon on the host. Other container
# ids map to subordinate host ids. See 06-docker-bind-mounts.sh for
# the resulting bind-mount ownership and --user caveats.
#
# userns-remap also maps container ids to different host ids, but
# leaves the daemon running as root. It is distinct from rootless
# mode. Neither docker group membership nor Dockerfile USER selects
# either daemon configuration.
#
# This lesson does not install or configure a rootless daemon. Its
# rootless and userns-remap explanations are documentation-based;
# those daemon modes have not been tested here.
# See https://docs.docker.com/engine/security/rootless/
# and https://docs.docker.com/engine/security/rootless/uid-gid-mapping/
# and https://docs.docker.com/engine/security/userns-remap/
