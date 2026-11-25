#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# bash-utilities.sh: General purpose functions for bash scripts
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

# This file is intended to be sourced by other scripts, for example
# 01-install-docker.sh. Sourcing it defines these functions and
# initializes cleanup state once. No cleanup traps are installed until
# cleanup_add is called.
#
#   die message...
#     Print an error message on stderr and exit the script.
#   die_if_not_root [message...]
#     Exit the script with an error message unless it is run by root.
#   die_if_not_available command...
#     Exit the script with an error message unless every command can be
#     found.
#   die_if_not_docker_available
#     Exit the script with an error message unless the docker command
#     is installed and can reach the Docker daemon.
#   docker_daemon_cpu_architecture
#     Print the CPU architecture of the Docker daemon, for example
#     amd64 or arm64.
#   die_if_docker_image_exists name...
#     Exit the script with an error message if any of the names is
#     already used by an image.
#   die_if_docker_container_exists name...
#     Exit the script with an error message if any of the names is
#     already used by a container, running or stopped.
#   pull_image_if_absent image [pull-option...]
#     Pull an image unless it is already on this machine. An image
#     that this run pulls is removed when the script exits.
#   remove_pulled_image image
#     Remove an image now, if this run pulled it, and forget its
#     saved cleanup command. An image that was already here is kept.
#   die_if_image_not_native image
#     Exit the script with an error message if the image is on this
#     machine but not built for the CPU architecture of the Docker
#     daemon.
#   cleanup_add key command...
#     Save a command that undoes a step of the script. It runs when
#     the script exits, unless cleanup_cancel forgets it first.
#   cleanup_cancel key
#     Forget a command saved by cleanup_add, without running it.
#   die_container_failed name status
#     Stop the script after an interactive docker container run
#     returns a non-zero status, and explain what may have gone wrong.
#
# cleanup_on_exit is a helper for cleanup_add and cleanup_cancel.
# remove_pulled_image_if_unchanged is a helper for pull_image_if_absent
# and remove_pulled_image.

# Source this file only once per shell. Sourcing it again must not
# forget pending cleanup commands or replace function definitions.
if [[ ${_DOCKER_BASICS_BASH_UTILITIES_SOURCED:-} == yes ]]; then
  return 0
fi
_DOCKER_BASICS_BASH_UTILITIES_SOURCED='yes'

# die: print an error message on stderr and exit with a non-zero
# status. A non-zero exit status tells whoever ran the script that it
# failed.
#
# Usage: die message...
#   message: the words of the error message. They are joined with
#            spaces and "ERROR: " is put in front of them.
#
# die exits the shell that it runs in. If it is called in a subshell,
# for example in $(...), only the subshell exits. The caller can
# still stop the script by assigning the output of the $(...) to a
# variable with set -e on.
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# die_if_not_root: exit the script with an error message unless it is
# run by root. EUID is the effective user id of the running script;
# root has the id 0.
#
# Usage: die_if_not_root [message...]
#   message: the words of the error message, as for die. The default
#            is "This script must be run as root. Try: sudo $0", where
#            $0 is the name of the script. (Functions do not change
#            $0, so it is the name of the script that calls this
#            function.)
#
# It uses die, so it exits the shell that it runs in.
die_if_not_root() {
  if [[ $EUID -ne 0 ]]; then
    die "${@:-This script must be run as root. Try: sudo $0}"
  fi
}

# die_if_not_available: exit the script with an error message unless
# every given command can be found. Call it before the script creates
# anything, so that a missing command stops the script at the start,
# and not halfway through, with work left to clean up.
#
# Usage: die_if_not_available command...
#   command: the name of a command that the script runs, for example
#            curl. command -v looks it up as bash would run it: in the
#            directories on PATH, or as a shell builtin or function.
#
# Every command is checked, so the message lists all the missing ones.
# It uses die, so it exits the shell that it runs in.
die_if_not_available() {
  local command
  local -a missing=()
  if [[ $# -lt 1 ]]; then
    die 'Usage: die_if_not_available command...'
  fi
  for command in "$@"; do
    if ! command -v "$command" >/dev/null; then
      missing+=("$command")
    fi
  done
  if [[ ${#missing[@]} -ne 0 ]]; then
    die "Commands not found: ${missing[*]}." \
      'Install them with the package manager of your Linux distribution.'
  fi
}

# die_if_not_docker_available: exit the script with an error message
# unless Docker is usable. The docker command is only a client: every
# real operation is a request to the Docker daemon. So check both that
# the command is installed and that it can reach a running daemon that
# you have permission to use. Call this before the first docker command,
# so that a Docker problem is reported as such, and not in the middle
# of a lesson step.
#
# Usage: die_if_not_docker_available
#
# docker info changes nothing. Only its standard output is discarded,
# so if it fails, Docker's own explanation is printed before ours.
# It uses die, so it exits the shell that it runs in.
die_if_not_docker_available() {
  die_if_not_available docker
  docker info >/dev/null || die 'Docker cannot reach its daemon (see the' \
    'error above). Check that the daemon is running and that you may use it.'
}

# docker_daemon_cpu_architecture: print the CPU architecture of the
# Docker daemon, in Docker's names, for example amd64 or arm64. The
# daemon builds the images and runs the containers, so its CPU decides
# which binaries an image needs. That is not always the CPU of the
# machine that runs the docker command: docker can talk to a daemon on
# another machine, or in a virtual machine, as Docker Desktop does.
#
# Usage: architecture=$(docker_daemon_cpu_architecture)
#
# Docker's names are not the kernel's: uname -m prints x86_64 for
# amd64 and aarch64 for arm64. Software vendors may use other names
# again; Node.js, for example, names its amd64 binaries x64.
#
# It uses die, so it exits the shell that it runs in.
docker_daemon_cpu_architecture() {
  if [[ $# -ne 0 ]]; then
    die 'Usage: docker_daemon_cpu_architecture'
  fi
  docker version --format '{{.Server.Arch}}' ||
    die 'Could not read the CPU architecture of the Docker daemon.'
}

# die_if_docker_image_exists: exit the script with an error message if
# any of the given names is already used by an image. A name such as
# dig-cmd:latest is only a label that points at an image. Building with
# --tag moves the label to the new image, and removing the name later
# would remove someone else's image. So check the names that a script
# will build before it builds anything.
#
# Usage: die_if_docker_image_exists name...
#   name: an image name with a tag (dig-cmd:latest), or without one
#         (dig-cmd). Without a tag, an image with any tag is a conflict.
#
# Every name is checked, so the message lists all the conflicts. It
# uses die, so it exits the shell that it runs in.
die_if_docker_image_exists() {
  local name ids
  local -a existing=()
  for name in "$@"; do
    ids=$(docker image ls --quiet "$name") ||
      die "Could not list the images named $name."
    if [[ -n $ids ]]; then
      existing+=("$name")
    fi
  done
  if [[ ${#existing[@]} -ne 0 ]]; then
    die "Image names already in use: ${existing[*]}." \
      'Inspect them with docker image ls NAME before removing any.'
  fi
}

# die_if_docker_container_exists: exit the script with an error message
# if any of the given names is already used by a container, running or
# stopped. Container names are unique, and a stopped container keeps
# its name until it is removed.
#
# Usage: die_if_docker_container_exists name...
#   name: a container name, compared exactly with the names of all
#         containers. (docker container inspect is not used, because it
#         also matches a container whose id starts with the name.)
#
# Every name is checked, so the message lists all the conflicts. It
# uses die, so it exits the shell that it runs in.
die_if_docker_container_exists() {
  local all name
  local -a existing=()
  all=$(docker container ls --all --format '{{.Names}}') ||
    die 'Could not list the containers.'
  for name in "$@"; do
    if grep --quiet --line-regexp --fixed-strings -- "$name" <<<"$all"; then
      existing+=("$name")
    fi
  done
  if [[ ${#existing[@]} -ne 0 ]]; then
    die "Container names already in use: ${existing[*]}." \
      'Inspect them with docker container inspect NAME before removing any.'
  fi
}

# The images pulled by pull_image_if_absent. The key is the image name;
# the value is the id that the image had after the pull, or empty while
# the pull runs.
declare -gA PULLED_IMAGE_IDS=()

# pull_image_if_absent: pull an image unless it is already on this
# machine. A lesson that builds FROM a base image, or runs a container
# from an image, needs the image locally. If it was already here, it is
# yours, and the lesson must keep it. If the lesson pulls it, the
# lesson removes it again: when the script exits, or earlier with
# remove_pulled_image.
#
# Usage: pull_image_if_absent image [pull-option...]
#   image:       the image name and tag, for example almalinux:10-minimal.
#   pull-option: options for docker image pull, for example
#                --platform linux/arm64.
#
# The cleanup command is saved before the pull starts, because an
# interrupted pull may already have stored the image. The id of the
# pulled image is recorded, and an image whose id has changed by the
# time it is removed is kept: someone has replaced it with their own.
# It uses die, so it exits the shell that it runs in.
pull_image_if_absent() {
  local image=${1:-} ids
  if [[ $# -lt 1 ]]; then
    die 'Usage: pull_image_if_absent image [pull-option...]'
  fi
  shift
  ids=$(docker image ls --quiet "$image") ||
    die "Could not list the images named $image."
  if [[ -n $ids ]]; then
    return 0
  fi
  PULLED_IMAGE_IDS[$image]=''
  cleanup_add "pulled-image $image" remove_pulled_image_if_unchanged "$image"
  docker image pull "$@" "$image" || die "Could not pull $image."
  PULLED_IMAGE_IDS[$image]=$(docker image inspect --format '{{.Id}}' \
    "$image") || die "Could not inspect $image."
}

# remove_pulled_image: remove an image that pull_image_if_absent pulled,
# and forget its saved cleanup command. Lessons call it at the end, so
# that the removal is visible. It does nothing for an image that was
# already on this machine.
#
# Usage: remove_pulled_image image
#
# It uses die, so it exits the shell that it runs in.
remove_pulled_image() {
  local image=${1:-}
  if [[ $# -ne 1 ]]; then
    die 'Usage: remove_pulled_image image'
  fi
  if [[ ! -v PULLED_IMAGE_IDS[$image] ]]; then
    return 0
  fi
  echo "Removing $image, which this run pulled:"
  remove_pulled_image_if_unchanged "$image" ||
    die "Could not remove $image."
  cleanup_cancel "pulled-image $image"
  unset 'PULLED_IMAGE_IDS[$image]'
}

# remove_pulled_image_if_unchanged: a helper for pull_image_if_absent
# and remove_pulled_image. Remove the image if it is present and still
# has the id that it had after the pull. It runs as a cleanup command,
# so it returns instead of exiting (see cleanup_add).
remove_pulled_image_if_unchanged() {
  local image=$1 ids id expected=${PULLED_IMAGE_IDS[$1]:-}
  ids=$(docker image ls --quiet "$image") || return $?
  if [[ -z $ids ]]; then
    return 0
  fi
  if [[ -n $expected ]]; then
    id=$(docker image inspect --format '{{.Id}}' "$image") || return $?
    if [[ $id != "$expected" ]]; then
      echo "Keeping $image: it was replaced after this run pulled it." >&2
      return 1
    fi
  fi
  docker image rm "$image" || return $?
}

# die_if_image_not_native: exit the script with an error message unless
# an image is built for the CPU architecture of the Docker daemon, for
# example arm64 or amd64. An image tag can be published for several
# architectures, but this machine keeps only one of them under the
# name. A copy for another CPU runs only under emulation, slowly, or
# not at all. If the image was already here, it is yours, so the lesson
# stops rather than replace it.
#
# If the image is not on this machine, there is nothing to check, and
# it returns success: a build or a run fetches the copy for the
# daemon's CPU itself.
#
# Usage: die_if_image_not_native image
#   image: the image name and tag, for example almalinux:10-minimal.
#
# It uses die, so it exits the shell that it runs in.
die_if_image_not_native() {
  local image=${1:-} ids image_arch daemon_arch
  if [[ $# -ne 1 ]]; then
    die 'Usage: die_if_image_not_native image'
  fi
  ids=$(docker image ls --quiet "$image") ||
    die "Could not list the images named $image."
  if [[ -z $ids ]]; then
    return 0
  fi
  daemon_arch=$(docker_daemon_cpu_architecture) || exit $?
  image_arch=$(docker image inspect --format '{{.Architecture}}' \
    "$image") || die "Could not inspect $image."
  if [[ $image_arch != "$daemon_arch" ]]; then
    die "$image is built for $image_arch, but the Docker daemon runs on" \
      "$daemon_arch. Inspect it with docker image inspect $image."
  fi
}

# The commands saved by cleanup_add, and the keys that name them.
# CLEANUP_COMMANDS[i] is the command named CLEANUP_KEYS[i].
# cleanup_cancel unsets the same element of both arrays, so there can
# be gaps in the indexes, but the two arrays always have the same
# ones.
CLEANUP_KEYS=()
CLEANUP_COMMANDS=()

# cleanup_add: save a command that undoes a step of the script, for
# example one that removes a container that the script created. If
# the script exits before it undoes the step itself, because a command
# fails with set -e on, die is called, or Ctrl-C is pressed, the
# command runs when the script exits. The saved commands run newest
# first. So a step is undone before the steps that it depends on, for
# example a container is removed before the image that it was created
# from.
#
# Usage: cleanup_add key command...
#   key:     a name for the saved command, which cleanup_cancel uses.
#            No other saved command may have the same key.
#   command: the command and its arguments. Variables in them are
#            expanded when cleanup_add is called, not when the command
#            runs. So cleanup_add c docker container rm "$ID" saves
#            the id that ID holds now.
#
# Cleanup commands run in an if condition so a failure does not stop
# the remaining commands. This also disables set -e inside functions
# used as cleanup commands. Such functions must check failures and
# return a non-zero status explicitly, for example:
#   some_command "$@" || return $?
# They should return instead of exit, so the other cleanups still run.
#
# cleanup_add sets the EXIT trap to cleanup_on_exit. It also sets the
# INT trap, for Ctrl-C, and the TERM trap, for kill, to exit with 130
# or 143. These are 128 plus the numbers of the signals, the statuses
# that the shell reports for a program stopped by them. Without these
# two traps, bash still runs the EXIT trap when one of these signals
# stops the script, but $? is then 0, and cleanup_on_exit would exit
# with 0, as if the script had succeeded.
# A script that sets its own EXIT trap afterwards replaces the
# cleanup. A script that changes the INT or TERM trap must set it back
# to 'exit 130' or 'exit 143' afterwards.
#
# Do not call cleanup_add in a subshell, for example in $(...) or in a
# pipeline. The subshell has its own copy of the saved commands, and
# runs them as soon as the subshell exits.
cleanup_add() {
  local key=${1:-}
  local command
  local i
  if [[ $# -lt 2 ]]; then
    die 'Usage: cleanup_add key command...'
  fi
  shift
  for i in "${!CLEANUP_KEYS[@]}"; do
    if [[ ${CLEANUP_KEYS[i]} == "$key" ]]; then
      die "cleanup_add: a cleanup command already has the key $key"
    fi
  done
  # %q quotes each word, so that eval in cleanup_on_exit splits the
  # saved string back into exactly the same words. printf adds a space
  # after each word, and the last one is removed.
  printf -v command '%q ' "$@"
  CLEANUP_KEYS+=("$key")
  CLEANUP_COMMANDS+=("${command% }")
  trap cleanup_on_exit EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
}

# cleanup_cancel: forget a command saved by cleanup_add, without
# running it. Call it once the script has undone the step itself.
#
# Usage: cleanup_cancel key
#   key: the key that was given to cleanup_add.
#
# It dies if no saved command has the key, so that a misspelt key is
# noticed. die exits the script, and so runs the saved commands.
cleanup_cancel() {
  local i
  if [[ $# -ne 1 ]]; then
    die 'Usage: cleanup_cancel key'
  fi
  for i in "${!CLEANUP_KEYS[@]}"; do
    if [[ ${CLEANUP_KEYS[i]} == "$1" ]]; then
      unset 'CLEANUP_KEYS[i]' 'CLEANUP_COMMANDS[i]'
      return 0
    fi
  done
  die "cleanup_cancel: no cleanup command has the key $1"
}

# cleanup_on_exit: the EXIT trap that cleanup_add sets. It runs the
# saved commands, newest first, and prints each one before it runs it.
# It runs every command, even if one fails, and then exits with the
# status that the script was exiting with. If that status is 0 but a
# command failed, it exits with 1 instead, so that the script does not
# report success when its cleanup failed.
cleanup_on_exit() {
  local status=$?
  local indexes=("${!CLEANUP_COMMANDS[@]}")
  local command
  local n
  for ((n = ${#indexes[@]} - 1; n >= 0; n--)); do
    command=${CLEANUP_COMMANDS[indexes[n]]}
    echo "Cleaning up: $command" >&2
    if ! eval "$command"; then
      echo "ERROR: Cleanup failed: $command" >&2
      if [[ $status -eq 0 ]]; then
        status=1
      fi
    fi
  done
  exit "$status"
}

# die_container_failed: stop the script after an interactive
# docker container run returns a non-zero status, and explain
# what may have gone wrong.
#
# Usage: die_container_failed name status
#   name:   the name of the container.
#   status: the exit status of docker container run.
#
# The status alone does not say whether Docker or bash failed, so the
# message describes possible causes. Docker may fail before the
# container starts, for example because the name is already in use.
# If bash started, a common cause is a mistyped command followed by
# plain exit. For example, catt in place of cat followed by exit
# returns 127, which means "command not found". An explicit non-zero
# exit or termination by a signal can also produce a failure status.
#
# The status may not come from the container at all. If the Docker
# client itself is killed, for example with kill -KILL from another
# terminal, docker container run returns 137 (128 plus 9, the number
# of SIGKILL) without printing an error. The container may then still
# be running. The script that calls this function should explain how
# to find and remove such a container.
#
# It uses die, so it exits the shell that it runs in.
die_container_failed() {
  local name=$1
  local status=$2
  die "docker container run for $name returned status $status." \
    'If Docker printed no error above, the status usually describes' \
    'how bash in the container ended. A common cause is a mistyped' \
    'command followed by plain "exit". Run the script again and' \
    'use "exit 0". If Docker printed an error, deal with that first.' \
    'For example, if the name is already in use by a container' \
    'that you no longer need, remove it with:' \
    "docker container rm --force $name"
}
