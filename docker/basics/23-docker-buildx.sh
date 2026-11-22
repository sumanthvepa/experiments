#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 23-docker-buildx.sh: Explore Docker Buildx
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

# Run on the HOST: bash /path/to/23-docker-buildx.sh (no arguments).
# Requires Bash 4+, a local Linux Docker daemon, Buildx, jq, tar, timeout
# and network access to public Docker Hub images. No login, push, sudo,
# package installation or daemon/emulation configuration is performed.
# Tested on Fedora 44 arm64, rootful Docker 29.9.3/classic overlay2,
# Buildx 0.38.1. Other hosts, architectures and daemon modes are untested.
# set -e stops on errors, -u rejects unset variables, pipefail checks pipes.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
# die reports fatal errors; cleanup_add/cleanup_cancel manage EXIT/INT/TERM
# fallbacks in reverse dependency order. Normal cleanup remains visible.
source ./bash-utilities.sh
(( BASH_VERSINFO[0] >= 4 )) || die 'This lesson requires Bash 4 or newer.'
[[ $# == 0 ]] || die 'Usage: 23-docker-buildx.sh (no arguments).'
die_if_not_available jq tar timeout sha256sum mktemp mkdir cat sort rm
die_if_not_docker_available
docker buildx version || die 'Install Buildx before running this lesson.'
DAEMON_ARCH=$(docker info --format '{{.Architecture}}')
case $DAEMON_ARCH in
  aarch64|arm64) NATIVE_ARCH=arm64; FOREIGN_ARCH=amd64; NATIVE_UNAME=aarch64; FOREIGN_UNAME=x86_64;;
  x86_64|amd64) NATIVE_ARCH=amd64; FOREIGN_ARCH=arm64; NATIVE_UNAME=x86_64; FOREIGN_UNAME=aarch64;;
  *) die "Unsupported daemon architecture: $DAEMON_ARCH";;
esac
# Do not depend on a preceding lesson's runtime resources. If AlmaLinux
# happens to be present, guard against the wrong-platform tag used elsewhere.
if docker image inspect almalinux:10-minimal >/dev/null 2>&1; then
  ALMA_ARCH=$(docker image inspect --format '{{.Architecture}}' almalinux:10-minimal)
  [[ $ALMA_ARCH == "$NATIVE_ARCH" ]] || die "Existing AlmaLinux architecture is $ALMA_ARCH, expected $NATIVE_ARCH."
fi
NATIVE_IMAGE=sample-buildx-native
FOREIGN_IMAGE=sample-buildx-foreign
OWNER_LABEL=org.docker-basics.buildx-run
die_if_docker_image_exists "$NATIVE_IMAGE:latest" "$FOREIGN_IMAGE:latest"
die_if_docker_container_exists "$NATIVE_IMAGE" "$FOREIGN_IMAGE"

# 1. A builder chooses a BuildKit backend; its driver determines where
# BuildKit runs; an exporter determines where the RESULT goes. Lesson 08
# owns Dockerfile instructions and ordinary builds/cache. Here we explicitly
# choose a docker-container driver, then compare --load with an OCI file.
# The docker driver uses the daemon's BuildKit; docker-container runs a
# separate BuildKit container with its own cache volume. Without an output,
# this driver normally keeps a result only in that cache, not docker image ls.
# https://docs.docker.com/build/builders/drivers/
echo 'Existing builders (the asterisk marks the current selection):'
docker buildx ls
ORIGINAL_BUILDER=$(docker buildx ls --format '{{json .}}' | jq --exit-status --slurp --raw-output '[.[] | select(.Current) | .Name] | unique | select(length == 1) | .[0]')
ORIGINAL_CONTEXT=$(docker context show)
ORIGINAL_BUILDERS=$(docker buildx ls --format '{{json .}}' | sort)
SCRATCH=$(mktemp --directory --tmpdir 'docker-basics-buildx.XXXXXXXX')
cleanup_add buildx-files rm --recursive --force -- "$SCRATCH"
RUN_TOKEN=${SCRATCH##*.}
BUILDER="basics-buildx-${RUN_TOKEN,,}"
NODE="${BUILDER}0"
BUILDKIT_CONTAINER="buildx_buildkit_$NODE"
BUILDKIT_VOLUME="${BUILDKIT_CONTAINER}_state"
BUILDKIT_IMAGE=moby/buildkit:buildx-stable-1
BUILDKIT_ID=
BUILDKIT_CREATED=no
BUILDER_CONFIG=
BUILDKIT_CONTAINER_ID=
VOLUME_STATE=
declare -A IMAGE_IDS=() CONTAINER_IDS=()
printf 'Private Buildx workspace: %s\n' "$SCRATCH"
# A private BUILDX_CONFIG keeps original configuration, selection, activity
# and caches untouched, including on failure. It does not change DOCKER_CONFIG,
# contexts or the daemon. Every lesson operation passes --builder explicitly.
# No --use: this builder is never selected as the reader's default.
mkdir "$SCRATCH/buildx"
bx() { BUILDX_CONFIG="$SCRATCH/buildx" docker buildx --builder "$BUILDER" "$@"; }

# Arguments: image tag, optional expected ID. Never remove a replaced tag.
# Label checks also cover a successful build interrupted before saving its ID.
remove_image() {
  local tag=$1 expected=${2:-} id owner
  if ! id=$(docker image inspect --format '{{.Id}}' "$tag" 2>/dev/null); then return 0; fi
  if [[ $tag != "$BUILDKIT_IMAGE" ]]; then
    owner=$(docker image inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$tag") || return $?
    [[ $owner == "$RUN_TOKEN" ]] || { echo "Refusing changed image $tag." >&2; return 1; }
    expected=${IMAGE_IDS[$tag]:-}
  fi
  [[ -z $expected || $id == "$expected" ]] || { echo "Refusing replaced image $tag." >&2; return 1; }
  docker image rm "$tag" || return $?
}
# Argument: name. The fallback is registered before create, so a signal
# between creation and receiving the returned ID still finds labelled ownership.
remove_container() {
  local name=$1 id owner
  if ! id=$(docker container inspect --format '{{.Id}}' "$name" 2>/dev/null); then return 0; fi
  owner=$(docker container inspect --format "{{index .Config.Labels \"$OWNER_LABEL\"}}" "$id") || return $?
  [[ $owner == "$RUN_TOKEN" && ( -z ${CONTAINER_IDS[$name]:-} || $id == "${CONTAINER_IDS[$name]}" ) ]] || {
    echo "Refusing changed container $name." >&2; return 1;
  }
  docker container rm --force "$id" || return $?
}
# Buildx has no volume ID. A run label plus its full creation metadata
# protects the owned cache volume; a changed/replaced resource is left alone.
remove_volume() {
  local state owner
  if ! state=$(docker volume inspect "$BUILDKIT_VOLUME" 2>/dev/null); then return 0; fi
  owner=$(jq --raw-output --arg label "$OWNER_LABEL" '.[0].Labels[$label]' <<< "$state") || return $?
  [[ $owner == "$RUN_TOKEN" && ( -z $VOLUME_STATE || $state == "$VOLUME_STATE" ) ]] || {
    echo 'Refusing changed BuildKit cache volume.' >&2; return 1;
  }
  docker volume rm "$BUILDKIT_VOLUME" || return $?
}
# No pre-existing builder/container/volume is reused. Check private instance
# bytes, container image/owner environment/ID and volume ownership BEFORE rm,
# because Buildx also removes the cache volume. Fall back before bootstrap.
remove_builder() {
  local config="$SCRATCH/buildx/instances/$BUILDER" id owner image state
  if [[ -f $config ]]; then
    if [[ -n $BUILDER_CONFIG && $(cat "$config") != "$BUILDER_CONFIG" ]]; then
      echo 'Refusing replaced builder configuration.' >&2; return 1
    fi
    if id=$(docker container inspect --format '{{.Id}}' "$BUILDKIT_CONTAINER" 2>/dev/null); then
      owner=$(docker container inspect --format '{{json .Config.Env}}' "$id") || return $?
      image=$(docker container inspect --format '{{.Image}}' "$id") || return $?
      [[ $image == "$BUILDKIT_ID" && ( -z $BUILDKIT_CONTAINER_ID || $id == "$BUILDKIT_CONTAINER_ID" ) ]] || {
        echo 'Refusing replaced BuildKit container.' >&2; return 1;
      }
      jq --exit-status --arg owner "DOCKER_BASICS_OWNER=$RUN_TOKEN" 'index($owner) != null' <<< "$owner" >/dev/null || {
        echo 'Refusing changed BuildKit container ownership.' >&2; return 1;
      }
    fi
    if state=$(docker volume inspect "$BUILDKIT_VOLUME" 2>/dev/null); then
      owner=$(jq --raw-output --arg label "$OWNER_LABEL" '.[0].Labels[$label]' <<< "$state") || return $?
      [[ $owner == "$RUN_TOKEN" && $state == "$VOLUME_STATE" ]] || {
        echo 'Refusing replaced BuildKit cache volume.' >&2; return 1;
      }
    fi
    bx rm "$BUILDER" || return $?
  fi
}
# The host only pulls the BuildKit image. Dockerfile base layers live inside
# our disposable builder, so removing its cache volume removes those too.
EXISTING=$(docker image ls --quiet "$BUILDKIT_IMAGE")
if [[ -z $EXISTING ]]; then
  cleanup_add buildkit-image remove_image "$BUILDKIT_IMAGE"
  BUILDKIT_CREATED=yes
  timeout --foreground 300 docker image pull --platform "linux/$NATIVE_ARCH" "$BUILDKIT_IMAGE"
fi
BUILDKIT_ID=$(docker image inspect --format '{{.Id}}' "$BUILDKIT_IMAGE")
# Pin the driver to the already inspected content, so bootstrap cannot
# refresh a pre-existing mutable tag. Official images have a repository digest;
# a local-only image can instead be addressed by its immutable image ID.
BUILDKIT_REF=$(docker image inspect --format '{{json .RepoDigests}}' "$BUILDKIT_IMAGE" | \
  jq --raw-output 'map(select(startswith("moby/buildkit@sha256:"))) | first // empty')
BUILDKIT_REF=${BUILDKIT_REF:-$BUILDKIT_ID}
die_if_image_not_native "$BUILDKIT_IMAGE"
# Update the callback with the immutable ID after pull; fallback above covers
# a signal before this assignment. No force removal or daemon-wide prune.
if [[ $BUILDKIT_CREATED == yes ]]; then
  cleanup_cancel buildkit-image
  cleanup_add buildkit-image remove_image "$BUILDKIT_IMAGE" "$BUILDKIT_ID"
fi
[[ ! -e $SCRATCH/buildx/instances/$BUILDER ]] || die 'Builder configuration already exists.'
EXISTING=$(docker buildx ls --format '{{.Name}}')
while IFS= read -r NAME; do [[ $NAME != "$BUILDER" ]] || die "Builder name $BUILDER already exists."; done <<< "$EXISTING"
die_if_docker_container_exists "$BUILDKIT_CONTAINER"
EXISTING=$(docker volume ls --quiet --filter "name=^$BUILDKIT_VOLUME$")
[[ -z $EXISTING ]] || die "BuildKit volume $BUILDKIT_VOLUME already exists."
# Pre-create our labelled volume before Buildx uses it; this also makes
# partial-bootstrap cleanup verifiable before a container ID is returned.
cleanup_add buildx-volume remove_volume
docker volume create --label "$OWNER_LABEL=$RUN_TOKEN" "$BUILDKIT_VOLUME"
VOLUME_STATE=$(docker volume inspect "$BUILDKIT_VOLUME")
cleanup_add buildx-builder remove_builder
bx create --name "$BUILDER" --node "$NODE" --driver docker-container --driver-opt "image=$BUILDKIT_REF" \
  --driver-opt "env.DOCKER_BASICS_OWNER=$RUN_TOKEN"
BUILDER_CONFIG=$(cat "$SCRATCH/buildx/instances/$BUILDER")
echo "Bootstrapping disposable builder: $BUILDER"
BUILDX_CONFIG="$SCRATCH/buildx" timeout --foreground 300 docker buildx --builder "$BUILDER" inspect --bootstrap
BUILDKIT_CONTAINER_ID=$(docker container inspect --format '{{.Id}}' "$BUILDKIT_CONTAINER")
echo "Builder ready: $BUILDER (docker-container); selection remains $ORIGINAL_BUILDER."
read -r -p 'Press ENTER to continue...'

# 2. --platform chooses the TARGET output. --load is shorthand for a Docker
# exporter loaded into the local image store; this single-platform result is
# runnable by docker container create. --tag alone does not imply --load here.
# --provenance=false omits extra attestation manifests to keep this small index
# easy to inspect. It does not alter the platform payloads.
cleanup_add "$NATIVE_IMAGE-image" remove_image "$NATIVE_IMAGE:latest"
BUILDX_CONFIG="$SCRATCH/buildx" timeout --foreground 600 docker buildx --builder "$BUILDER" build \
  --platform "linux/$NATIVE_ARCH" --load --provenance=false --progress plain \
  --label "$OWNER_LABEL=$RUN_TOKEN" --tag "$NATIVE_IMAGE:latest" buildx-test
IMAGE_IDS[$NATIVE_IMAGE:latest]=$(docker image inspect --format '{{.Id}}' "$NATIVE_IMAGE:latest")
PLATFORM=$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$NATIVE_IMAGE:latest")
[[ $PLATFORM == "linux/$NATIVE_ARCH" ]] || die "Unexpected loaded platform: $PLATFORM"
# Arguments: image/container name, expected uname. A stopped container retains
# actual output and exit state until checked, then cleanup removes its ID.
run_example() {
  local name=$1 expected=$2 id status output arch
  if [[ $name == "$NATIVE_IMAGE" ]]; then arch=$NATIVE_ARCH; else arch=$FOREIGN_ARCH; fi
  cleanup_add "$name-container" remove_container "$name"
  CONTAINER_IDS[$name]=$(docker container create --name "$name" --platform "linux/$arch" --network none \
    --label "$OWNER_LABEL=$RUN_TOKEN" "$name:latest")
  id=${CONTAINER_IDS[$name]}
  if timeout --foreground 30 docker container start --attach "$id"; then status=0; else status=$?; fi
  output=$(docker container logs "$id")
  if [[ $status != 0 ]]; then
    # Only a foreign executable-format error is an optional emulation limit.
    # Daemon/network/timeouts and application failures are essential failures.
    local error
    error=$(docker container inspect --format '{{.State.Error}}' "$id")
    if [[ $name == "$FOREIGN_IMAGE" && $error == *'exec format error'* ]]; then
      printf 'Foreign runtime unavailable (no working emulation): %s\n' "$error"
      return 0
    fi
    die "Runtime failed for $name (client $status): $error"
  fi
  status=$(docker container inspect --format '{{.State.ExitCode}}' "$id")
  [[ $status == 0 && $output == "buildx-demo:$expected" ]] || die "Unexpected runtime output/status for $name: $output / $status"
  printf 'Verified runtime %s: %s (exit %s)\n' "$name" "$output" "$status"
}
run_example "$NATIVE_IMAGE" "$NATIVE_UNAME"
echo "Verified native loaded platform: $PLATFORM"
read -r -p 'Press ENTER to continue...'

# 3. --output type=oci,dest=... writes an OCI-layout tar archive on the HOST.
# It is separate from the loaded image and requires no registry or push.
# TARGETOS/TARGETARCH are BuildKit automatic build arguments, redeclared in
# the stage to label each output. BUILDPLATFORM identifies the builder's
# platform (not necessarily the target); FROM --platform=$BUILDPLATFORM is
# useful for native cross-compilers. We do not use that override: FROM selects
# BusyBox for each target. There are NO RUN instructions, so foreign code is
# never executed during these builds. Copying/selecting layers is not emulation.
# https://docs.docker.com/build/building/multi-platform/
# https://docs.docker.com/build/exporters/oci-docker/
ARCHIVE="$SCRATCH/multi-platform.tar"
BUILDX_CONFIG="$SCRATCH/buildx" timeout --foreground 600 docker buildx --builder "$BUILDER" build \
  --platform linux/arm64,linux/amd64 --provenance=false --progress plain \
  --output "type=oci,dest=$ARCHIVE" buildx-test
mkdir "$SCRATCH/oci"
tar --extract --file "$ARCHIVE" --directory "$SCRATCH/oci"
# index.json points to an image index, whose per-platform descriptors each
# reference a manifest. A manifest references a config and filesystem layers.
# Validate digest bytes as well as platform descriptors and actual configs.
blob_path() {
  local digest=$1 path
  [[ $digest =~ ^sha256:[0-9a-f]{64}$ ]] || {
    printf 'Invalid OCI digest: %s\n' "$digest" >&2
    return 1
  }
  path="$SCRATCH/oci/blobs/sha256/${digest#sha256:}"
  # Command substitution clears errexit by default; explicitly propagate
  # checksum failures even when this function is called in an if condition.
  printf '%s  %s\n' "${digest#sha256:}" "$path" | sha256sum --check >&2 || return $?
  printf '%s\n' "$path"
}
INDEX_DIGEST=$(jq --exit-status --raw-output '.manifests | select(length == 1) | .[0].digest' "$SCRATCH/oci/index.json")
INDEX=$(blob_path "$INDEX_DIGEST")
jq --exit-status '.mediaType == "application/vnd.oci.image.index.v1+json" and (.manifests | length == 2)' "$INDEX"
for ARCH in arm64 amd64; do
  MANIFEST_DIGEST=$(jq --exit-status --raw-output --arg arch "$ARCH" \
    '[.manifests[] | select(.platform.os == "linux" and .platform.architecture == $arch)] | select(length == 1) | .[0].digest' "$INDEX")
  MANIFEST=$(blob_path "$MANIFEST_DIGEST")
  jq --exit-status '.mediaType == "application/vnd.oci.image.manifest.v1+json" and (.layers | length > 0)' "$MANIFEST"
  CONFIG_DIGEST=$(jq --exit-status --raw-output '.config.digest' "$MANIFEST")
  CONFIG=$(blob_path "$CONFIG_DIGEST")
  jq --exit-status --arg arch "$ARCH" '.os == "linux" and .architecture == $arch and .config.Labels["org.docker-basics.target"] == ("linux/" + $arch)' "$CONFIG"
  printf 'Verified OCI platform linux/%s: manifest %s config %s\n' "$ARCH" "$MANIFEST_DIGEST" "$CONFIG_DIGEST"
done
printf 'Verified two-platform OCI artifact: %s\n' "$ARCHIVE"
# Classic overlay2 stores single-platform images; it cannot load an index
# with both variants. Engine version alone does not establish image-store mode.
# A containerd image store can support indexes, but we do not change stores or
# claim docker load can load this OCI artifact on every host. Keep the archive
# for an OCI-aware consumer; a real distribution workflow could use --push to
# a registry you control, after authentication. No such push is run here.
read -r -p 'Press ENTER to continue...'

# 4. Native CPUs execute their own ISA. A foreign binary needs working QEMU/
# binfmt runtime support and may run more slowly. Builder-advertised platforms
# do not prove daemon runtime support; test it separately. The existing host
# supports this; elsewhere an exec-format error is reported precisely above.
cleanup_add "$FOREIGN_IMAGE-image" remove_image "$FOREIGN_IMAGE:latest"
BUILDX_CONFIG="$SCRATCH/buildx" timeout --foreground 600 docker buildx --builder "$BUILDER" build \
  --platform "linux/$FOREIGN_ARCH" --load --provenance=false --progress plain \
  --label "$OWNER_LABEL=$RUN_TOKEN" --tag "$FOREIGN_IMAGE:latest" buildx-test
IMAGE_IDS[$FOREIGN_IMAGE:latest]=$(docker image inspect --format '{{.Id}}' "$FOREIGN_IMAGE:latest")
PLATFORM=$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$FOREIGN_IMAGE:latest")
[[ $PLATFORM == "linux/$FOREIGN_ARCH" ]] || die "Unexpected foreign loaded platform: $PLATFORM"
run_example "$FOREIGN_IMAGE" "$FOREIGN_UNAME"
read -r -p 'Press ENTER to continue...'

# 5. Visible cleanup. rm removes our builder and its cache volume, not the
# pre-existing builders or their caches. Keep fallbacks until removal succeeds.
for NAME in "$FOREIGN_IMAGE" "$NATIVE_IMAGE"; do
  remove_container "$NAME"
  cleanup_cancel "$NAME-container"
  remove_image "$NAME:latest"
  cleanup_cancel "$NAME-image"
done
remove_builder
cleanup_cancel buildx-builder
remove_volume
cleanup_cancel buildx-volume
if [[ $BUILDKIT_CREATED == yes ]]; then
  remove_image "$BUILDKIT_IMAGE" "$BUILDKIT_ID"
  cleanup_cancel buildkit-image
fi
[[ $(docker buildx ls --format '{{json .}}' | jq --exit-status --slurp --raw-output '[.[] | select(.Current) | .Name] | unique | select(length == 1) | .[0]') == "$ORIGINAL_BUILDER" ]] || die 'Original builder selection changed.'
[[ $(docker context show) == "$ORIGINAL_CONTEXT" ]] || die 'Original Docker context changed.'
[[ $(docker buildx ls --format '{{json .}}' | sort) == "$ORIGINAL_BUILDERS" ]] || die 'Original builder inventory changed.'
rm --recursive --force -- "$SCRATCH"
cleanup_cancel buildx-files
echo 'Buildx lesson complete; original builder selection preserved and owned resources removed.'
# SIGKILL cannot run traps. Inspect the printed workspace/private BUILDX_CONFIG,
# builder/container/volume and ownership labels before manual removal. Remove
# only confirmed owned resources, never global prune or another builder's cache.
