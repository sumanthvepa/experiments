#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 12-docker-logs.sh: Explore Docker container logs
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

# Stop on unexpected failures, unset variables and failed pipelines.
set -euo pipefail
# die reports errors; cleanup_add/cleanup_cancel undo only resources this
# run owns, including on unexpected failure, Ctrl-C (130) or TERM (143).
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"

echo '12-docker-logs: retrieve, filter and follow container output'
# Run on the host: bash /path/to/12-docker-logs.sh
# Needs Bash, GNU date/coreutils and access to a Linux Docker daemon.
# Network access to the registry is needed only if the base is absent.
# Docker access may require sudo. No ports, host mounts or host settings
# change; rootless Docker needs no bridge-network or mount workaround.
# All commands run on the host; bash -c below runs INSIDE the container.
die_if_not_available date mktemp rm cat sleep
die_if_not_docker_available
date --date='2000-01-01T00:00:00.000000001Z' +%s%N >/dev/null
die_if_docker_container_exists docker-basics-logs

# 1. Output and logging drivers
# docker container logs (short alias: docker logs) retrieves captured
# stdout/stderr from the container command and children that inherit
# those streams. It does not discover arbitrary application log files.
# Retrieval depends on the logging driver or its local dual-logging cache.
# Remote drivers with caching disabled, the none driver, retention limits
# and lost log writes can prevent retrieval. Full retrieval means the
# records still retained, not an unlimited historical archive.
# https://docs.docker.com/reference/cli/docker/container/logs/
# https://docs.docker.com/engine/logging/
# https://docs.docker.com/engine/logging/dual-logging/
DEFAULT_DRIVER=$(docker info --format '{{.LoggingDriver}}')
echo "Daemon default logging driver: $DEFAULT_DRIVER"
# Use a known readable driver for this small container only; this does
# not change the daemon default. Inspect the effective choice below.
# Driver selection/rotation administration and external collection are
# further study: do not edit daemon.json or Docker-managed log files here.
BASE='almalinux:10-minimal'
pull_image_if_absent "$BASE"
die_if_image_not_native "$BASE"
SCRATCH=$(mktemp --directory --tmpdir docker-basics-logs.XXXXXX)
cleanup_add scratch rm -r -- "$SCRATCH"
echo "Temporary capture directory: $SCRATCH"

# Single quotes pass this program literally: $n expands in the container,
# not on the host. printf writes stdout by default; >&2 selects stderr.
# No --tty (-t) is used: a TTY would merge the two streams. Control files
# let exec request events, while the MAIN process prints every log marker.
# The sleep calls only bound polling/production rate; no filter boundary
# depends on assuming that a sleep establishes timestamp ordering.
ID=$(docker container create --name docker-basics-logs \
  --network none --log-driver json-file "$BASE" bash -c '
  set -euo pipefail
  stop_main() { printf "STOPPED_MAIN\n"; exit 0; }
  trap stop_main TERM
  printf "APP_FILE_ONLY\n" > /tmp/application.log
  printf "EARLY_STDOUT\n"
  printf "EARLY_STDERR\n" >&2
  until [[ -f /tmp/late ]]; do sleep 0.1; done
  printf "LATE_STDOUT\n"
  printf "LATE_STDERR\n" >&2
  until [[ -f /tmp/follow ]]; do sleep 0.1; done
  n=0
  until [[ -f /tmp/after-follow ]]; do
    n=$((n + 1))
    printf "LIVE_STDOUT_%03d\n" "$n"
    printf "LIVE_STDERR_%03d\n" "$n" >&2
    sleep 1
  done
  printf "AFTER_FOLLOW_MAIN\n"
  while :; do sleep 0.1; done
')
cleanup_add logs-container docker container rm --force "$ID"
echo "Owned logs container: $ID"
docker container start "$ID"
DRIVER=$(docker container inspect --format '{{.HostConfig.LogConfig.Type}}' "$ID")
TTY=$(docker container inspect --format '{{.Config.Tty}}' "$ID")
[[ $DRIVER == json-file && $TTY == false ]] || die 'Expected json-file logging without a TTY.'
echo "Container logging driver: $DRIVER; TTY: $TTY"

# wait_for_marker marker: bound readiness by 100 attempts. A failed logs
# request is fatal, rather than being mistaken for a not-yet-ready app.
# 2>&1 combines the client streams ONLY for searches, after capture.
wait_for_marker() {
  local marker=$1 output attempt
  for attempt in {1..100}; do
    output=$(docker container logs "$ID" 2>&1)
    [[ $output == *"$marker"* ]] && return 0
    sleep 0.1
  done
  die "Main process did not produce $marker within $attempt attempts."
}
wait_for_marker EARLY_STDOUT
wait_for_marker EARLY_STDERR
read -r -p 'Press ENTER to continue...'

# 2. Full retrieval and what is absent
# Without --follow, logs prints the retained records and returns. On a
# non-TTY container, the client writes each stream to its corresponding
# host descriptor. > captures stdout; 2> captures stderr separately.
echo 'Retrieving all current logs into separate host captures...'
docker container logs "$ID" > "$SCRATCH/stdout" 2> "$SCRATCH/stderr"
STDOUT=$(<"$SCRATCH/stdout")
STDERR=$(<"$SCRATCH/stderr")
[[ $STDOUT == EARLY_STDOUT && $STDERR == EARLY_STDERR ]] || \
  die 'Expected exactly one main-process marker on each separate stream.'
echo 'stdout:'; cat "$SCRATCH/stdout"
echo 'stderr:'; cat "$SCRATCH/stderr"
# exec starts a separate attachment. Its printed output is visible here,
# but is absent from logs. cat reads an application file explicitly; the
# file itself was not automatically captured by Docker either.
echo 'Reading the application file and separate exec output:'
FILE_TEXT=$(docker container exec "$ID" cat /tmp/application.log)
[[ $FILE_TEXT == APP_FILE_ONLY ]] || die 'Application file content differs.'
printf '%s\n' "$FILE_TEXT"
EXEC_TEXT=$(docker container exec "$ID" printf 'EXEC_ATTACHMENT_ONLY\n')
[[ $EXEC_TEXT == EXEC_ATTACHMENT_ONLY ]] || die 'Exec attachment content differs.'
printf '%s\n' "$EXEC_TEXT"
ALL=$(docker container logs "$ID" 2>&1)
[[ $ALL != *APP_FILE_ONLY* && $ALL != *EXEC_ATTACHMENT_ONLY* ]] || \
  die 'File/exec output unexpectedly appeared in the main process logs.'
echo 'Verified separate stdout/stderr and absence of file/exec-only output.'

# 3. Timestamps, tail and since
# --timestamps (-t for this command) adds Docker RFC3339Nano timestamps.
# The same short -t means --tty on create/run: options belong to commands.
# Save the latest observed EARLY timestamp, then add one nanosecond to
# form a boundary strictly after both early records. GNU date converts
# the timestamp to integer epoch nanoseconds; Bash integer arithmetic
# computes seconds and the nine-digit fractional part for --since.
TIMESTAMPED=$(docker container logs --timestamps "$ID" 2>&1)
echo 'Timestamped early records:'
printf '%s\n' "$TIMESTAMPED"
LATEST_EARLY=0
COUNT=0
while read -r STAMP MARKER; do
  [[ $STAMP =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\.[0-9]{9}Z$ ]] || die 'Missing RFC3339Nano timestamp.'
  [[ $MARKER == EARLY_STDOUT || $MARKER == EARLY_STDERR ]] || die 'Unexpected timestamped marker.'
  NS=$(date --date="$STAMP" +%s%N)
  ((NS > LATEST_EARLY)) && LATEST_EARLY=$NS
  COUNT=$((COUNT + 1))
done <<< "$TIMESTAMPED"
[[ $COUNT -eq 2 ]] || die 'Expected two timestamped early records.'
BOUNDARY_NS=$((LATEST_EARLY + 1))
printf -v SINCE '%d.%09d' "$((BOUNDARY_NS / 1000000000))" "$((BOUNDARY_NS % 1000000000))"
# exec only creates the request file. The main process emits late logs.
docker container exec "$ID" touch /tmp/late
wait_for_marker LATE_STDOUT
wait_for_marker LATE_STDERR
# Check observed late timestamps really fall beyond the selected boundary;
# this catches a clock anomaly rather than claiming that elapsed sleep did.
TIMESTAMPED=$(docker container logs --timestamps "$ID" 2>&1)
LATE_COUNT=0
while read -r STAMP MARKER; do
  if [[ $MARKER == LATE_STDOUT || $MARKER == LATE_STDERR ]]; then
    NS=$(date --date="$STAMP" +%s%N)
    [[ $NS -gt $BOUNDARY_NS ]] || die 'Late record does not follow the observed time boundary.'
    LATE_COUNT=$((LATE_COUNT + 1))
  fi
done <<< "$TIMESTAMPED"
[[ $LATE_COUNT -eq 2 ]] || die 'Expected two timestamped late records.'
# --tail (-n) limits the last retained lines. After both late markers are
# observed, the last two records must contain those markers and no early
# ones. 2>&1 is deliberate here because this example compares both streams.
TAIL=$(docker container logs --tail 2 "$ID" 2>&1)
echo 'Last two retained records (--tail 2):'
printf '%s\n' "$TAIL"
[[ $TAIL == *LATE_STDOUT* && $TAIL == *LATE_STDERR* && $TAIL != *EARLY_* ]] || die 'Tail included/excluded the wrong markers.'
# Absolute epoch seconds.nanoseconds avoids a relative duration moving
# between requests or a client-local timezone assumption. RFC3339 dates
# with Z/offset and relative durations such as 10m are also accepted.
FILTERED=$(docker container logs --since "$SINCE" "$ID" 2>&1)
echo "Records since observed boundary $SINCE:"
printf '%s\n' "$FILTERED"
[[ $FILTERED == *LATE_STDOUT* && $FILTERED == *LATE_STDERR* && $FILTERED != *EARLY_* ]] || die 'Since included/excluded the wrong markers.'
echo 'Verified timestamps, tail and since include late markers and exclude early markers.'

# 4. Follow new output; interrupt only the client
# --follow (-f) stays attached as new records arrive. --tail 0 omits old
# records, so the LIVE markers below prove new output, rather than replay.
# The main process produces a pair each second after this control request.
# Press Ctrl-C after seeing LIVE_STDOUT and LIVE_STDERR. As in lesson 04,
# temporarily ignore the script's INT while the foreground client handles
# it, then restore the cleanup helper's normal Ctrl-C behavior immediately.
echo 'Follow fresh LIVE markers, then press Ctrl-C to continue the lesson.'
read -r -p 'Press ENTER to continue...'
docker container exec "$ID" touch /tmp/follow
trap ':' INT
FOLLOW_STATUS=0
docker container logs --follow --tail 0 "$ID" || FOLLOW_STATUS=$?
trap 'exit 130' INT
[[ $FOLLOW_STATUS -eq 0 || $FOLLOW_STATUS -eq 130 ]] || die "Follow failed with status $FOLLOW_STATUS."
STATE=$(docker container inspect --format '{{.State.Running}}' "$ID")
[[ $STATE == true ]] || die 'Interrupting the logs client stopped the container.'
docker container exec "$ID" touch /tmp/after-follow
wait_for_marker AFTER_FOLLOW_MAIN
echo 'Verified container still running and main process produced AFTER_FOLLOW_MAIN.'
read -r -p 'Press ENTER to continue...'

# stop asks the main process to exit (TERM here), then kills it if its
# timeout expires. Our trap prints a final marker and exits normally.
# No --rm was used: the stopped container remains available for logs.
docker container stop --timeout 5 "$ID"
STATE=$(docker container inspect --format '{{.State.Status}} {{.State.ExitCode}}' "$ID")
[[ $STATE == 'exited 0' ]] || die "Expected a clean stop; got $STATE."
echo 'Retained logs after container stop, before removal:'
STOPPED=$(docker container logs "$ID" 2>&1)
printf '%s\n' "$STOPPED"
for MARKER in EARLY_STDOUT EARLY_STDERR LATE_STDOUT LATE_STDERR LIVE_STDOUT_ LIVE_STDERR_ AFTER_FOLLOW_MAIN STOPPED_MAIN; do
  [[ $STOPPED == *"$MARKER"* ]] || die "Stopped-container logs lack $MARKER."
done
[[ $STOPPED != *APP_FILE_ONLY* && $STOPPED != *EXEC_ATTACHMENT_ONLY* ]] || die 'File/exec output entered retained logs.'
echo 'Verified retained logs remain readable after a clean container stop.'
read -r -p 'Press ENTER to continue...'

# 5. Visible cleanup
# Remove only the id this run owns; then its captures and an added base.
# An existing base remains untouched. There is no build in this lesson.
echo 'Removing the stopped demonstration container...'
docker container rm "$ID"
cleanup_cancel logs-container
echo 'Removing temporary host captures...'
rm -r -- "$SCRATCH"
cleanup_cancel scratch
remove_pulled_image "$BASE"
echo 'Lesson complete; owned container, added base and temporary captures removed.'
# A killed client can leave its container alive. EXIT cleanup handles
# ordinary errors/signals, but cannot handle SIGKILL or power loss.
# Inspect leftovers before removing any resource you still need:
#   docker container inspect docker-basics-logs
#   docker container logs docker-basics-logs
#   docker container rm --force docker-basics-logs
#   docker image inspect almalinux:10-minimal
# Remove that base only if you know the interrupted run added it.
