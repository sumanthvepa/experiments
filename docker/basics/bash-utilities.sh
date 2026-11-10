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
#   cleanup_add key command...
#     Save a command that undoes a step of the script. It runs when
#     the script exits, unless cleanup_cancel forgets it first.
#   cleanup_cancel key
#     Forget a command saved by cleanup_add, without running it.
#
# cleanup_on_exit is a helper for cleanup_add and cleanup_cancel.

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
