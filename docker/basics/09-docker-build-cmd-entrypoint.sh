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

# What this lesson teaches
# ------------------------
# This lesson teaches you how a container decides which program to run
# at startup. In particular, it explores the two Dockerfile instructions
# that control this: CMD and ENTRYPOINT.
#
# The two react differently to the words typed after the image name in
# docker run IMAGE WORDS...:
#
#   CMD ["dig"]         A replaceable default. Any words REPLACE the whole
#                       command: docker run dig-cmd ls -l runs ls -l.
#   ENTRYPOINT ["dig"]  The image's fixed program. Words are APPENDED as
#                       its arguments: docker run dig-entrypoint
#                       www.google.com runs dig www.google.com.
#
# The lesson builds two otherwise identical images, dig-cmd and
# dig-entrypoint, and runs them side by side:
#
#   1. No words: both images run dig.
#   2. dig-cmd ls -l: the words replace CMD, so ls -l runs.
#   3. dig-entrypoint www.google.com: the words become dig's arguments.
#   4. dig-entrypoint ls -l fails: dig receives ls -l and rejects -l.
#   5. dig-cmd www.google.com fails: Docker looks for a program named
#      www.google.com.
#   6. --entrypoint ls, placed before the image name, replaces ENTRYPOINT.
#   7. ENTRYPOINT and CMD together, the common real-world pattern:
#      ENTRYPOINT fixes the program and CMD supplies default arguments,
#      which runtime words replace. A quoted word containing a space
#      stays one argument.
#
# Each example inspects the container's actual startup command before
# starting it, then checks for the exit status the lesson predicts. Most
# of the remaining code is safety scaffolding: it refuses to touch
# existing images or containers, removes everything it creates, and
# keeps a base image that was already present.
#
# Reference: https://docs.docker.com/reference/dockerfile/#entrypoint

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# Import utility functions
# die reports fatal errors; cleanup_add/cleanup_cancel undo owned resources
# on normal completion, errors, Ctrl-C (130), and SIGTERM (143).
source ./bash-utilities.sh

echo '09-docker-build-cmd-entrypoint: default commands and arguments'
die_if_not_docker_available

# This lesson creates images and a container with these names. Stop if
# any name is already in use, so that the lesson never accidentally
# replaces or removes something of yours.
die_if_docker_image_exists dig-cmd dig-entrypoint printf-defaults
die_if_docker_container_exists docker-basics-dig

# Both Dockerfiles build FROM this base image. Keep it if you already
# have it; if the lesson pulls it, remove it again at the end.
BASE='almalinux:10-minimal'
pull_image_if_absent "$BASE"
die_if_image_not_native "$BASE"

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
CMD_CONFIG=$(docker image inspect --format \
  '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' dig-cmd)
ENTRYPOINT_CONFIG=$(docker image inspect --format \
  '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' dig-entrypoint)
echo 'Image settings (Entrypoint, then Cmd):'
echo "  dig-cmd:        $CMD_CONFIG"
echo "  dig-entrypoint: $ENTRYPOINT_CONFIG"
read -r -p 'Press ENTER to continue...'

# demonstrate: run one example of the lesson. It creates a container
# from an image, and shows the startup command that Docker made from
# the image's ENTRYPOINT and CMD and the words after the image name.
# It then starts the container, checks that the result is the one the
# lesson expects, and removes the container.
#
# Usage: demonstrate kind expected-path expected-args [expected-output]
#                    create-arg...
#   kind:            the expected result:
#                      ok               the command succeeds (status 0)
#                      dns              dig makes a DNS query; it succeeds,
#                                       or warns if no DNS server answers
#                      dig-error        dig rejects its arguments (1)
#                      missing-command  Docker cannot find the program
#                      printf           the command succeeds, and prints
#                                       exactly expected-output
#   expected-path:   the program that Docker should run, for example dig.
#                    docker container inspect shows it as .Path.
#   expected-args:   its arguments, as a JSON array, for example
#                    '["ls","-l"]', or '[]' for none. docker container
#                    inspect shows them as .Args.
#   expected-output: only for printf: the exact text, including the
#                    final newline, that the command should print.
#   create-arg:      the arguments for docker container create: any
#                    options, the image name, and the words after it.
#
# Examples. Each call runs the docker container create command shown,
# then docker container start --attach with the new container's id.
# Together, the two commands do what docker container run does.
#   demonstrate ok ls '["-l"]' dig-cmd ls -l
#     docker container create --name docker-basics-dig dig-cmd ls -l
#     The words replace CMD, so the container runs ls -l.
#   demonstrate dig-error dig '["ls","-l"]' dig-entrypoint ls -l
#     docker container create --name docker-basics-dig dig-entrypoint \
#       ls -l
#     The words are appended to ENTRYPOINT, so the container runs
#     dig ls -l.
#   demonstrate ok ls '["-l"]' --entrypoint ls dig-entrypoint -l
#     docker container create --name docker-basics-dig \
#       --entrypoint ls dig-entrypoint -l
#     --entrypoint replaces dig, so the container runs ls -l.
#
# Every example follows the same steps. Showing the command that Docker
# will run, before it runs, makes the CMD and ENTRYPOINT rules visible,
# instead of leaving them to be guessed from the program's output.
demonstrate() {
  local kind=$1 expected_path=$2 expected_args=$3
  local id actual status state error output expected_output=''
  shift 3
  if [[ $kind == printf ]]; then
    expected_output=$1
    shift
  fi
  printf 'Creating: docker container create --name docker-basics-dig'
  printf ' %q' "$@"
  printf '\n'
  if ! id=$(docker container create --name docker-basics-dig "$@"); then
    die 'Could not create demonstration container. Inspect' \
      'docker-basics-dig for a name conflict.'
  fi
  cleanup_add demo-container docker container rm --force "$id"
  actual=$(docker container inspect --format '{{.Path}} {{json .Args}}' "$id")
  echo "Actual command: $actual"
  [[ $actual == "$expected_path $expected_args" ]] || \
    die 'Unexpected startup command.'
  status=0
  if [[ $kind == printf ]]; then
    # Command substitution removes trailing newlines. Append a marker only
    # after start succeeds, so the comparison retains every output byte
    # without hiding a Docker failure. Remove the marker for display.
    output=$(docker container start --attach "$id" && printf '.') || status=$?
    printf '%s' "${output%.}"
  else
    docker container start --attach "$id" || status=$?
  fi
  # A signal is never a harmless DNS failure or an expected negative example.
  if [[ $status -ge 128 ]]; then
    exit "$status"
  fi
  state=$(docker container inspect \
    --format '{{.State.Status}} {{.State.ExitCode}}' "$id")
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
        die "Expected start error (1), created state (127) and" \
          "missing executable; got $status, $state, $error"
      echo 'Verified expected failure: start returned 1;' \
        'missing executable recorded as 127.'
      ;;
    *)
      [[ $state == "exited $status" && -z $error ]] || \
        die "Docker did not complete the command: $status, $state, $error"
      case $kind in
        ok) [[ $status -eq 0 ]] || die "Expected success; got $status." ;;
        printf)
          [[ $status -eq 0 ]] || die "Expected printf success; got $status."
          [[ $output == "$expected_output." ]] || \
            die 'Unexpected printf output.'
          echo 'Verified exact printf output and exit 0.'
          ;;
        dig-error)
          [[ $status -eq 1 ]] || \
            die "Expected dig usage error (1); got $status."
          echo 'Verified expected failure: dig rejects -l (1).'
          ;;
        dns)
          case $status in
            0)
              echo 'DNS command completed (records vary with the resolver).'
              ;;
            9)
              echo 'WARNING: dig could not reach a DNS server (9);' \
                'continuing.' >&2
              ;;
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
# Runs: docker container create --name docker-basics-dig dig-cmd
demonstrate dns dig '[]' dig-cmd
# Runs: docker container create --name docker-basics-dig dig-entrypoint
demonstrate dns dig '[]' dig-entrypoint

# Words after a CMD-only image replace the WHOLE CMD, including dig.
# ls -l lists the container working directory; -l requests a long listing.
echo '2. CMD replacement: ls -l runs instead of dig.'
# Runs: docker container create --name docker-basics-dig dig-cmd ls -l
demonstrate ok ls '["-l"]' dig-cmd ls -l

# Exec-form ENTRYPOINT keeps dig and appends words after the image name.
# +time=2 and +tries=1 bound this optional DNS request; no public record is
# required for the startup-command comparison to succeed.
echo '3. ENTRYPOINT arguments: dig looks up www.google.com.'
# Runs: docker container create --name docker-basics-dig dig-entrypoint \
#         www.google.com +time=2 +tries=1
demonstrate dns dig '["www.google.com","+time=2","+tries=1"]' \
  dig-entrypoint www.google.com +time=2 +tries=1

# This is an application error, not execution of ls: -l is not a dig option.
echo '4. Expected failure: ENTRYPOINT makes ls -l arguments to dig.'
# Runs: docker container create --name docker-basics-dig dig-entrypoint ls -l
demonstrate dig-error dig '["ls","-l"]' dig-entrypoint ls -l

# This is a startup error: Docker tries to execute a program named after
# the hostname, because the words replaced CMD's ["dig"].
echo '5. Expected failure: CMD replacement tries to execute www.google.com.'
# Runs: docker container create --name docker-basics-dig dig-cmd www.google.com
demonstrate missing-command www.google.com '[]' dig-cmd www.google.com

# --entrypoint is a Docker option, so it comes BEFORE the image name.
# It selects a different executable; the words after the image are its args.
# Our ENTRYPOINT-only Dockerfile deliberately leaves CMD empty. The next
# example adds CMD defaults to an exec-form ENTRYPOINT.
echo '6. Override ENTRYPOINT explicitly: ls -l runs instead of dig.'
# Runs: docker container create --name docker-basics-dig \
#         --entrypoint ls dig-entrypoint -l
demonstrate ok ls '["-l"]' --entrypoint ls dig-entrypoint -l

# Observe how CMD supplies defaults to ENTRYPOINT, and how runtime words
# REPLACE those defaults. Reuse this run's image: printf is already in its
# filesystem, so this adds no package installation or DNS request.
# A quoted here-document sends a Dockerfile on standard input (-), without
# host expansion or a temporary build context. JSON doubles the backslash
# so printf receives \n in its fixed format and prints a newline.
# Reserve cleanup before building: a failed/interrupted build client might
# already have published the tag. Remove it only if it actually exists.
remove_defaults_image() {
  local image_id
  image_id=$(docker image ls --quiet printf-defaults:latest) || return $?
  if [[ -n $image_id ]]; then
    docker image rm printf-defaults:latest || return $?
  fi
}
echo '7. Combined ENTRYPOINT and CMD: defaults versus replacement arguments.'
cleanup_add defaults-image remove_defaults_image
docker image build --tag printf-defaults - <<'DOCKERFILE'
FROM dig-entrypoint:latest
ENTRYPOINT ["/usr/bin/printf", "value=<%s>\\n"]
CMD ["default argument"]
DOCKERFILE
DEFAULTS_CONFIG=$(docker image inspect --format \
  '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' printf-defaults)
echo 'Image settings (Entrypoint, then Cmd):'
echo "  printf-defaults: $DEFAULTS_CONFIG"
read -r -p 'Press ENTER to continue...'

# printf-defaults runs printf with a fixed format from ENTRYPOINT,
# value=<%s>\n. printf repeats that format for every argument after it,
# so it prints one line per argument.
#
# With no words after the image name, CMD supplies the argument:
# "default argument", a single argument that contains a space. Exec form
# keeps it whole, so printf prints one line: value=<default argument>.
#
# Words after the image name replace CMD; they are not added to it. The
# quotes around 'replacement argument' make it one word for Bash, so
# Docker receives one argument and printf again prints one line.
#
# One line of output therefore shows both rules. Had the words been
# appended to CMD, or had the space split an argument, printf would have
# printed two lines.
echo 'No runtime arguments: CMD supplies one default argument with a space.'
# Runs: docker container create --name docker-basics-dig printf-defaults
demonstrate printf /usr/bin/printf '["value=<%s>\\n","default argument"]' \
  $'value=<default argument>\n' printf-defaults
echo 'One quoted runtime argument replaces CMD; the ENTRYPOINT format stays.'
# Runs: docker container create --name docker-basics-dig \
#         printf-defaults 'replacement argument'
demonstrate printf /usr/bin/printf '["value=<%s>\\n","replacement argument"]' \
  $'value=<replacement argument>\n' printf-defaults 'replacement argument'
read -r -p 'Press ENTER to continue...'

# Remove the images this lesson built, starting with printf-defaults,
# which was built FROM dig-entrypoint. docker image rm removes a tag;
# Docker deletes the image's layers once no other tag or image uses them.
# The base image is removed only if this lesson pulled it.
echo 'Removing demonstration images...'
docker image rm printf-defaults:latest
cleanup_cancel defaults-image
docker image rm dig-entrypoint:latest
cleanup_cancel entrypoint-image
docker image rm dig-cmd:latest
cleanup_cancel cmd-image
remove_pulled_image "$BASE"
echo 'Lesson complete; owned containers and images removed.'

# If this script is stopped with kill -9, or the computer loses power,
# it gets no chance to clean up, and the container and images it created
# can be left behind. To check for them:
#   docker container ls --all --filter name=docker-basics-dig
#   docker image ls dig-cmd
#   docker image ls dig-entrypoint
#   docker image ls printf-defaults
#   docker image ls almalinux
# Remove only what you are sure that run created:
#   docker container rm --force docker-basics-dig
#   docker image rm printf-defaults dig-entrypoint dig-cmd
# Remove the base image only if you did not have it before the run:
#   docker image rm almalinux:10-minimal
