#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 09-docker-build-cmd-entrypoint.sh: Explore CMD and ENTRYPOINT
# commands in the Dockerfile
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

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports fatal errors; cleanup_add/cleanup_cancel undo owned resources
# on normal completion, errors, Ctrl-C (130), and SIGTERM (143).
source ./bash-utilities.sh

echo '09-docker-build-cmd-entrypoint: default commands and arguments'
# Run on the host: bash /path/to/09-docker-build-cmd-entrypoint.sh
# Needs Bash, Docker with a Linux daemon, access to that daemon, and network
# access to pull AlmaLinux and install bind-utils. Docker access may require
# running this script with sudo. No published ports or host mounts are used.
# The builds select the daemon's native platform; no architecture-specific
# binary is downloaded. Other architectures/rootless daemons are not tested.
# DNS examples additionally need an accessible resolver; failed DNS queries
# are warnings, while a failed build or Docker command stops the lesson.
# All commands below run on the host; dig and ls execute in containers.
command -v docker >/dev/null || die 'This lesson needs docker.'
docker info >/dev/null

# Protect names before pulling or building anything. A tag is a reference
# to an image; building with an existing tag would move that reference.
for IMAGE in dig-cmd dig-entrypoint; do
  EXISTING=$(docker image ls --quiet "$IMAGE")
  [[ -z $EXISTING ]] || die "Image name $IMAGE already exists. Inspect it with" \
    "docker image ls $IMAGE; remove unwanted tags with docker image rm $IMAGE:TAG."
done
EXISTING=$(docker container ls --all --quiet \
  --filter 'name=^/docker-basics-dig$')
[[ -z $EXISTING ]] || die 'Container name docker-basics-dig already exists.' \
  'Inspect it with docker container inspect docker-basics-dig before removing it.'

# Keep a base image that was already present. Explicitly pulling an absent
# base lets us register its removal before a build can fail. Build cache may
# remain; no prune command runs. Images are removed after their containers.
BASE='almalinux:10-minimal'
BASE_CREATED=no
EXISTING=$(docker image ls --quiet "$BASE")
if [[ -z $EXISTING ]]; then
  docker image pull "$BASE"
  cleanup_add base-image docker image rm "$BASE"
  BASE_CREATED=yes
fi

# A mismatched local base would make the builds use emulation. Refuse it
# rather than replacing an existing image or selecting another platform.
NATIVE_ARCH=$(docker version --format '{{.Server.Arch}}')
BASE_ARCH=$(docker image inspect --format '{{.Architecture}}' "$BASE")
[[ $BASE_ARCH == "$NATIVE_ARCH" ]] || \
  die "Base architecture $BASE_ARCH differs from daemon architecture $NATIVE_ARCH."
echo "Verified native base architecture: $BASE_ARCH"

echo 'Building dig-cmd and dig-entrypoint (bind-utils supplies dig)...'
docker image build --tag dig-cmd ./dig-cmd
cleanup_add cmd-image docker image rm dig-cmd:latest
docker image build --tag dig-entrypoint ./dig-entrypoint
cleanup_add entrypoint-image docker image rm dig-entrypoint:latest

# CMD and ENTRYPOINT configure startup; neither executes during a build.
# Both Dockerfiles use exec form: a JSON array, one string per argument.
# Docker executes these words directly, without /bin/sh -c. Shell expansion
# such as $HOME, pipes and redirects therefore does not happen implicitly.
# Shell form (for example CMD dig) runs through /bin/sh -c on Linux; shell
# form ENTRYPOINT does not forward CMD/run arguments to dig as exec form
# does. For signal handling and PID 1, see 02-docker-container-basics.sh.
# When several CMD or ENTRYPOINT instructions appear, only the last of
# each applies. Setting ENTRYPOINT clears an inherited CMD, so this image's
# Cmd is null, even though AlmaLinux supplies a default bash command.
echo 'Image settings: CMD-only versus exec-form ENTRYPOINT:'
for IMAGE in dig-cmd dig-entrypoint; do
  docker image inspect --format \
    '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' "$IMAGE"
done
CMD_CONFIG=$(docker image inspect --format \
  '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' dig-cmd)
ENTRYPOINT_CONFIG=$(docker image inspect --format \
  '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' dig-entrypoint)
[[ $CMD_CONFIG == 'null ["dig"]' ]] || die "Unexpected CMD settings: $CMD_CONFIG"
[[ $ENTRYPOINT_CONFIG == '["dig"] null' ]] || \
  die "Unexpected ENTRYPOINT settings: $ENTRYPOINT_CONFIG"
echo 'Verified settings: CMD-only runs dig; ENTRYPOINT runs dig with no default arguments.'
read -r -p 'Press ENTER to compare the commands...'

# demonstrate expected-kind expected-path expected-args docker-create-args...
# Create separately from start so cleanup can remove the container by id
# even if the Docker client is killed. Inspect Path/Args before starting:
# these describe the actual command, rather than just its printed output.
# A single name is reused only after this run's prior container is removed.
# expected-kind: ok, dns (optional resolver), dig-error, or missing-command.
demonstrate() {
  local kind=$1 expected_path=$2 expected_args=$3
  local id actual status state error
  shift 3
  printf 'Creating: docker container create --name docker-basics-dig'
  printf ' %q' "$@"
  printf '\n'
  if ! id=$(docker container create --name docker-basics-dig "$@"); then
    die 'Could not create demonstration container. Inspect docker-basics-dig for a name conflict.'
  fi
  cleanup_add demo-container docker container rm --force "$id"
  actual=$(docker container inspect --format '{{.Path}} {{json .Args}}' "$id")
  echo "Actual command: $actual"
  [[ $actual == "$expected_path $expected_args" ]] || die 'Unexpected startup command.'
  status=0
  docker container start --attach "$id" || status=$?
  # A signal is never a harmless DNS failure or an expected negative example.
  if [[ $status -ge 128 ]]; then
    exit "$status"
  fi
  state=$(docker container inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$id")
  error=$(docker container inspect --format '{{.State.Error}}' "$id")
  case $kind in
    missing-command)
      # run reports 127 for an executable that cannot be found, whereas
      # create + start --attach reports a client error (1) and records 127
      # in State.ExitCode. Require that state and the specific runtime error
      # as well: an unrelated daemon error is not the expected failure.
      [[ $status -eq 1 && $state == 'created 127' &&
        $error == *www.google.com* &&
        $error == *'executable file not found'* ]] || \
        die "Expected start error (1), created state (127) and missing executable; got $status, $state, $error"
      echo 'Verified expected failure: start returned 1; missing executable recorded as 127.'
      ;;
    *)
      [[ $state == "exited $status" && -z $error ]] || \
        die "Docker did not complete the command: $status, $state, $error"
      case $kind in
        ok) [[ $status -eq 0 ]] || die "Expected success; got $status." ;;
        dig-error)
          [[ $status -eq 1 ]] || die "Expected dig usage error (1); got $status."
          echo 'Verified expected failure: dig rejects -l (1).'
          ;;
        dns)
          case $status in
            0) echo 'DNS command completed (records vary with the resolver).' ;;
            9) echo 'WARNING: dig could not reach a DNS server (9); continuing.' >&2 ;;
            *) die "Unexpected dig/Docker status: $status" ;;
          esac
          ;;
      esac
      ;;
  esac
  docker container rm "$id" >/dev/null
  cleanup_cancel demo-container
}

# No arguments: each image starts dig. Its default query is for root name
# servers, so records and even success depend on DNS. Do not compare text
# byte-for-byte: timestamps, query ids, servers and timing can differ.
# Default dig retries are finite; later explicit queries use a 2-second
# timeout and one attempt. The inspection proves identical startup words.
echo '1. No arguments: both images start dig.'
demonstrate dns dig '[]' dig-cmd
demonstrate dns dig '[]' dig-entrypoint

# Words after a CMD-only image replace the WHOLE CMD, including dig.
# ls -l lists the container working directory; -l requests a long listing.
echo '2. CMD replacement: ls -l runs instead of dig.'
demonstrate ok ls '["-l"]' dig-cmd ls -l

# Exec-form ENTRYPOINT keeps dig and appends words after the image name.
# +time=2 and +tries=1 bound this optional DNS request; no public record is
# required for the startup-command comparison to succeed.
echo '3. ENTRYPOINT arguments: dig looks up www.google.com.'
demonstrate dns dig '["www.google.com","+time=2","+tries=1"]' \
  dig-entrypoint www.google.com +time=2 +tries=1

# This is an application error, not execution of ls: -l is not a dig option.
echo '4. Expected failure: ENTRYPOINT makes ls -l arguments to dig.'
demonstrate dig-error dig '["ls","-l"]' dig-entrypoint ls -l

# This is a startup error: Docker tries to execute a program named after
# the hostname, because the words replaced CMD's ["dig"].
echo '5. Expected failure: CMD replacement tries to execute www.google.com.'
demonstrate missing-command www.google.com '[]' dig-cmd www.google.com

# --entrypoint is a Docker option, so it comes BEFORE the image name.
# It selects a different executable; the words after the image are its args.
# With both ENTRYPOINT ["dig"] and CMD ["example.com"], CMD would supply
# default arguments; run-time words would replace those defaults. Our
# ENTRYPOINT-only Dockerfile deliberately leaves CMD empty.
echo '6. Override ENTRYPOINT explicitly: ls -l runs instead of dig.'
demonstrate ok ls '["-l"]' --entrypoint ls dig-entrypoint -l
read -r -p 'Press ENTER to remove the demonstration images...'

# Visible normal cleanup teaches removal; the EXIT cleanup remains armed
# until each removal succeeds. A pre-existing base image is never removed.
echo 'Removing demonstration images...'
docker image rm dig-entrypoint:latest
cleanup_cancel entrypoint-image
docker image rm dig-cmd:latest
cleanup_cancel cmd-image
if [[ $BASE_CREATED == yes ]]; then
  docker image rm "$BASE"
  cleanup_cancel base-image
fi
echo 'Lesson complete; owned containers and images removed.'

# SIGKILL cannot run traps. If a run is killed, inspect leftovers first:
# docker container inspect docker-basics-dig
# docker image ls dig-cmd
# docker image ls dig-entrypoint
# Then remove only resources you have confirmed belong to that run, using
# docker container rm --force ID and docker image rm NAME:TAG. A killed
# Docker client can leave a container running; cleanup by id handles this
# when the script itself can still exit. No existing workload is stopped.
# Reference: https://docs.docker.com/reference/dockerfile/#entrypoint
