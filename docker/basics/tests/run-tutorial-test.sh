#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# run-tutorial-test.sh: Run a docker/basics tutorial under its Expect
# driver, and check what the run left behind
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

# The tutorials wait for a reader: they pause for ENTER, start shells
# in containers, and stop streams when Ctrl-C is pressed. A driver,
# written in Expect, gives the tutorial a real terminal and answers it
# the way a reader would. The tutorial itself is not changed, and runs
# exactly as it does for a reader. See tutorial-test.tcl for the
# procedures that drivers use.
#
# For each scenario, this script:
#   1. records the containers, images, volumes, networks and buildx
#      builders that exist, and the firewall state of the ports that
#      the driver names
#   2. runs the driver, from a new, empty working directory, so that
#      the tutorial must work when it is started from another
#      directory
#   3. records the same things again, and fails if the run left
#      something behind, or changed or removed something that was
#      there before. Images that the driver says the tutorial keeps
#      may be left behind.
#   4. fails if the tutorial left files in the working directory
#
# Usage: run-tutorial-test.sh [option...] tutorial [scenario | all]
#   tutorial: the name of a tutorial in docker/basics, for example
#             04-docker-kill-top-stats.sh, or the path of one
#   scenario: normal (the default), interrupt, continue or conflict.
#             all runs every scenario that the driver lists, and then
#             normal again, to check that a successful run can be
#             repeated.
#
# Options:
#   --driver file        use this driver, in place of
#                        tests/<tutorial name without .sh>.exp
#   --time-limit seconds stop a scenario that runs longer than this.
#                        The default comes from the driver, or is 1800.
#   --verbose            show the output of the terminals as well as
#                        saving it in the log
#   --help               print this text and exit
#
# A driver starts with comment lines that tell this script about it:
#   # scenarios: normal interrupt continue conflict
#       The scenarios that the driver supports. normal is required.
#   # keeps-image: name[:tag]
#       An image that the tutorial may leave behind, such as an image
#       a later tutorial uses, or a base image that it pulls. A name
#       without a tag means name:latest. One line per image.
#   # firewall-port: port
#       A TCP port that the tutorial may open in the firewall. Its
#       state must be the same after the run. Checking it needs sudo
#       without a password. One line per port.
#   # time-limit: seconds
#       The time limit for each scenario.
#
# Exit status:
#   0  every scenario that ran passed
#   1  a scenario failed, or the test could not be run
#   2  the command line was wrong
#   77 no scenario could run here, for example because sudo needs a
#      password. A driver also exits with 77 when it skips a scenario.
#
# Run one test at a time. Two tests would see each other's resources,
# so this script stops if another one is running.

set -euo pipefail

TESTS_DIRECTORY=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASICS_DIRECTORY=$(dirname "$TESTS_DIRECTORY")

# die, cleanup_add and cleanup_cancel come from bash-utilities.sh.
# query_tcp_port comes from firewall-utilities.sh.
# shellcheck source=../bash-utilities.sh
source "$BASICS_DIRECTORY/bash-utilities.sh"
# shellcheck source=../firewall-utilities.sh
source "$BASICS_DIRECTORY/firewall-utilities.sh"

KNOWN_SCENARIOS=(normal interrupt continue conflict)

# usage: print the usage text, which is the block of comments at the
# top of this file, from the line that starts with
# "Usage: run-tutorial-test.sh" to the next empty line. sed stops (q)
# at that empty line, so it does not print the other Usage: comments.
usage() {
  sed --quiet '/^# Usage: run-tutorial-test.sh/,/^$/{/^$/q;p}' \
    "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# usage_error: print an error and where to find the usage text, and
# exit with 2.
usage_error() {
  echo "ERROR: $*" >&2
  echo "Run $(basename -- "${BASH_SOURCE[0]}") --help for the usage." >&2
  exit 2
}

# header_values: print the values of a comment line in the driver,
# one per line.
#
# Usage: header_values driver key
#   driver: the driver file
#   key:    the word before the colon, for example keeps-image
header_values() {
  sed --quiet "s/^#[[:space:]]*$2:[[:space:]]*//p" "$1" |
    sed 's/[[:space:]]*$//'
}

# is_known_scenario: succeed if $1 is the name of a scenario.
is_known_scenario() {
  local name
  for name in "${KNOWN_SCENARIOS[@]}"; do
    [[ $name == "$1" ]] && return 0
  done
  return 1
}

# take_snapshot: print one line for each container, image, volume,
# network and buildx builder, and for the firewall state of each port
# in FIREWALL_PORTS, sorted. Uses ids where Docker has them, so that a
# resource that is removed and created again with the same name shows
# up as a change.
#
# Returns 1 if Docker or the firewall cannot be read.
take_snapshot() {
  local port state
  {
    docker container ls --all --no-trunc \
      --format 'container {{.ID}} {{.Names}}' || return 1
    docker image ls --all --no-trunc \
      --format 'image {{.ID}} {{.Repository}}:{{.Tag}}' || return 1
    docker volume ls --format 'volume {{.Name}}' || return 1
    docker network ls --no-trunc \
      --format 'network {{.ID}} {{.Name}}' || return 1
    docker buildx ls --format 'builder {{.Name}}' || return 1
    for port in "${FIREWALL_PORTS[@]}"; do
      state=$(query_tcp_port "$port") || return 1
      echo "firewall-port $port $state"
    done
  } | LC_ALL=C sort --unique
}

# is_kept_image: succeed if a snapshot line is an image that the
# driver says the tutorial may leave behind.
is_kept_image() {
  local line=$1
  local name kept
  [[ $line == image\ * ]] || return 1
  name=${line##* }
  for kept in "${KEPT_IMAGES[@]}"; do
    # A tag follows the last colon after the last slash. A colon
    # before a slash belongs to a registry address, as in
    # localhost:5000/name.
    if [[ ${kept##*/} != *:* ]]; then
      kept="$kept:latest"
    fi
    [[ $name == "$kept" ]] && return 0
  done
  return 1
}

# compare_snapshots: print the differences between two snapshots that
# count as failures, one per line, with "left behind: " or "changed or
# removed: " in front. Prints nothing if there are none.
#
# Usage: compare_snapshots before after
compare_snapshots() {
  local line
  # comm compares two sorted files. -13 prints the lines only in the
  # second file, and -23 the lines only in the first.
  while IFS= read -r line; do
    if ! is_kept_image "$line"; then
      echo "left behind: $line"
    fi
  done < <(LC_ALL=C comm -13 "$1" "$2")
  while IFS= read -r line; do
    echo "changed or removed: $line"
  done < <(LC_ALL=C comm -23 "$1" "$2")
}

# show_log_tail: print the end of a log, without the terminal control
# sequences that programs such as docker container stats print.
show_log_tail() {
  tail --lines=40 "$1" | tr --delete '\r' |
    sed 's/\x1b\[[0-9;?]*[A-Za-z]//g; s/^/  | /'
}

# run_scenario: run one scenario and print its result.
#
# Usage: run_scenario scenario number
#   scenario: the name of the scenario
#   number:   the position of the scenario in this run, used to name
#             its files in LOG_DIRECTORY
#
# Returns 0 if it passed, 1 if it failed and 77 if it was skipped.
# Saves the log and the two snapshots in LOG_DIRECTORY.
run_scenario() {
  local scenario=$1 number=$2
  local prefix="$LOG_DIRECTORY/$number-$scenario"
  local log="$prefix.log"
  local working_directory differences leftover_files attempt
  local status=0

  if ! take_snapshot > "$prefix.before"; then
    echo "FAIL $TUTORIAL_NAME $scenario: could not record the" \
      'resources before the run'
    return 1
  fi

  working_directory=$(mktemp --directory --tmpdir \
    'tutorial-test-work.XXXXXX') || return 1
  cleanup_add "working-directory-$number" \
    rm --recursive --force -- "$working_directory"

  # env --chdir starts the driver in the new working directory.
  # timeout stops the driver after the time limit; the driver then
  # stops the tutorial with Ctrl-C, so that its cleanup runs.
  # --foreground keeps the driver in this script's process group, so
  # that Ctrl-C on this terminal reaches it too. --kill-after kills
  # the driver if it has not stopped 60 seconds later.
  env --chdir="$working_directory" \
    TUTORIAL_TEST_TUTORIAL="$TUTORIAL" \
    TUTORIAL_TEST_SCENARIO="$scenario" \
    TUTORIAL_TEST_LOG="$log" \
    TUTORIAL_TEST_VERBOSE="$VERBOSE" \
    timeout --foreground --kill-after=60 "$TIME_LIMIT" \
    expect -f "$DRIVER" || status=$?

  leftover_files=$(find "$working_directory" -mindepth 1 -print)
  rm --recursive --force -- "$working_directory"
  cleanup_cancel "working-directory-$number"

  if [[ $status -eq 77 ]]; then
    echo "SKIP $TUTORIAL_NAME $scenario (log: $log)"
    return 77
  fi

  # A container started with --rm, or removed in the background, can
  # take a moment to go. Look again, up to 10 times a second apart,
  # before reporting it.
  differences=''
  for attempt in {1..10}; do
    if ! take_snapshot > "$prefix.after"; then
      echo "FAIL $TUTORIAL_NAME $scenario: could not record the" \
        'resources after the run'
      return 1
    fi
    differences=$(compare_snapshots "$prefix.before" "$prefix.after")
    [[ -z $differences ]] && break
    [[ $attempt -lt 10 ]] && sleep 1
  done

  if [[ $status -eq 0 && -z $differences && -z $leftover_files ]]; then
    echo "PASS $TUTORIAL_NAME $scenario (log: $log)"
    return 0
  fi

  echo "FAIL $TUTORIAL_NAME $scenario (log: $log)"
  if [[ $status -eq 124 || $status -eq 137 ]]; then
    echo "  The scenario ran longer than $TIME_LIMIT seconds."
  elif [[ $status -ne 0 ]]; then
    echo "  The driver exited with status $status."
  fi
  if [[ -n $differences ]]; then
    echo '  Resources that differ after the run:'
    printf '%s\n' "$differences" | sed 's/^/    /'
  fi
  if [[ -n $leftover_files ]]; then
    echo '  Files the tutorial left in its working directory:'
    printf '%s\n' "$leftover_files" | sed 's/^/    /'
  fi
  echo '  The end of the log:'
  show_log_tail "$log"
  return 1
}

# Read the command line.
VERBOSE=0
DRIVER=''
TIME_LIMIT=''
while [[ $# -gt 0 ]]; do
  case $1 in
    --help)
      usage
      exit 0
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --driver)
      [[ $# -ge 2 ]] || usage_error '--driver needs a file name'
      DRIVER=$2
      shift 2
      ;;
    --driver=*)
      DRIVER=${1#*=}
      shift
      ;;
    --time-limit)
      [[ $# -ge 2 ]] || usage_error '--time-limit needs a number'
      TIME_LIMIT=$2
      shift 2
      ;;
    --time-limit=*)
      TIME_LIMIT=${1#*=}
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      usage_error "unknown option $1"
      ;;
    *)
      break
      ;;
  esac
done
if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage_error 'give a tutorial, and optionally a scenario'
fi

# A name without a slash is a tutorial in docker/basics.
if [[ $1 == */* ]]; then
  TUTORIAL=$1
else
  TUTORIAL="$BASICS_DIRECTORY/$1"
fi
[[ -f $TUTORIAL ]] || usage_error "there is no tutorial $TUTORIAL"
TUTORIAL=$(realpath -- "$TUTORIAL")
TUTORIAL_NAME=$(basename -- "$TUTORIAL" .sh)

DRIVER=${DRIVER:-$TESTS_DIRECTORY/$TUTORIAL_NAME.exp}
[[ -f $DRIVER ]] || usage_error "there is no driver $DRIVER"
DRIVER=$(realpath -- "$DRIVER")

# Read the comment lines at the top of the driver.
DRIVER_SCENARIOS_LINE=$(header_values "$DRIVER" scenarios)
read -r -a DRIVER_SCENARIOS <<< "${DRIVER_SCENARIOS_LINE//$'\n'/ }"
mapfile -t KEPT_IMAGES < <(header_values "$DRIVER" keeps-image)
mapfile -t FIREWALL_PORTS < <(header_values "$DRIVER" firewall-port)
DRIVER_TIME_LIMIT=$(header_values "$DRIVER" time-limit)

if [[ ${#DRIVER_SCENARIOS[@]} -eq 0 ]]; then
  die "$DRIVER has no '# scenarios:' line."
fi
HAS_NORMAL='no'
for SCENARIO in "${DRIVER_SCENARIOS[@]}"; do
  is_known_scenario "$SCENARIO" ||
    die "$DRIVER lists an unknown scenario: $SCENARIO"
  [[ $SCENARIO == normal ]] && HAS_NORMAL='yes'
done
[[ $HAS_NORMAL == yes ]] ||
  die "$DRIVER must list the normal scenario."
for PORT in "${FIREWALL_PORTS[@]}"; do
  tcp_port_number run-tutorial-test.sh "$PORT" > /dev/null ||
    die "$DRIVER names a firewall port that is not valid: $PORT"
done

TIME_LIMIT=${TIME_LIMIT:-${DRIVER_TIME_LIMIT:-1800}}
if [[ ! $TIME_LIMIT =~ ^[1-9][0-9]*$ ]]; then
  usage_error "the time limit must be a whole number of seconds," \
    "not $TIME_LIMIT"
fi

# Choose the scenarios to run.
REQUESTED=${2:-normal}
if [[ $REQUESTED == all ]]; then
  SCENARIOS=("${DRIVER_SCENARIOS[@]}" normal)
else
  is_known_scenario "$REQUESTED" ||
    usage_error "unknown scenario $REQUESTED"
  LISTED='no'
  for SCENARIO in "${DRIVER_SCENARIOS[@]}"; do
    [[ $SCENARIO == "$REQUESTED" ]] && LISTED='yes'
  done
  [[ $LISTED == yes ]] ||
    die "$DRIVER does not support the scenario $REQUESTED."
  SCENARIOS=("$REQUESTED")
fi

# Check the tools before running anything.
for TOOL in expect docker timeout flock realpath comm; do
  command -v "$TOOL" > /dev/null ||
    die "This test needs $TOOL. Install it with the package manager" \
      'of your Linux distribution.'
done
docker buildx version > /dev/null 2>&1 ||
  die 'This test needs the docker buildx plugin.'

# Run one test at a time. flock holds a lock on the file as long as
# this script keeps it open. The file itself is left in place; it is
# empty.
LOCK_FILE="${TMPDIR:-/tmp}/docker-basics-tutorial-test.lock"
exec {LOCK_DESCRIPTOR}>> "$LOCK_FILE"
if ! flock --nonblock "$LOCK_DESCRIPTOR"; then
  die "Another tutorial test is running. Wait for it to finish."
fi

# Checking a firewall port needs sudo, and no one is there to type a
# password. Skip the test, rather than wait for one.
if [[ ${#FIREWALL_PORTS[@]} -gt 0 ]] &&
  ! sudo --non-interactive true 2> /dev/null; then
  echo "SKIP $TUTORIAL_NAME: checking firewall ports" \
    "${FIREWALL_PORTS[*]} needs sudo without a password."
  exit 77
fi

# The logs are kept after the test, so that they can be read. They
# are in a new directory under TMPDIR, or /tmp.
LOG_DIRECTORY=$(mktemp --directory --tmpdir \
  "tutorial-test-$TUTORIAL_NAME.XXXXXX")
echo "Testing $TUTORIAL_NAME: ${SCENARIOS[*]}"
echo "Logs: $LOG_DIRECTORY"

PASSED=0
FAILED=0
SKIPPED=0
NUMBER=0
for SCENARIO in "${SCENARIOS[@]}"; do
  NUMBER=$((NUMBER + 1))
  RESULT=0
  run_scenario "$SCENARIO" "$NUMBER" || RESULT=$?
  case $RESULT in
    0)
      PASSED=$((PASSED + 1))
      ;;
    77)
      SKIPPED=$((SKIPPED + 1))
      ;;
    *)
      FAILED=$((FAILED + 1))
      ;;
  esac
done

echo "$TUTORIAL_NAME: $PASSED passed, $FAILED failed, $SKIPPED skipped"
if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
if [[ $PASSED -eq 0 ]]; then
  exit 77
fi
exit 0
