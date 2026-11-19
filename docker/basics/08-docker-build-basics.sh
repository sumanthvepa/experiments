#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 08-docker-build-basics.sh: Explore building Docker images
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

echo '08-docker-build-basics'

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail

# Change to the directory of this script, so that the relative paths
# used below, such as ./docker-basics-ping, work wherever the script
# is run from. With set -e on, the script stops if the cd fails.
cd "$(dirname "${BASH_SOURCE[0]}")"

# die, cleanup_add and cleanup_cancel come from bash-utilities.sh.
source ./bash-utilities.sh

# query_tcp_port, open_tcp_port and close_tcp_port come from
# firewall-utilities.sh. See 02-docker-container-basics.sh.
source ./firewall-utilities.sh

# The script uses curl on the host to find out when nginx is ready,
# and to check the page that it serves. Check for it before creating
# anything.
if ! command -v curl >/dev/null; then
  die 'This script needs curl. Install it with the package manager' \
    'of your Linux distribution.'
fi

# The script builds images with these names. Building gives the new
# image the name, and takes it away from any image that already has
# it. Check for them before building, so that an existing image keeps
# its name. 02-docker-container-basics.sh and 03-docker-image-basics.sh
# also build an image named docker-basics-ping, and remove it when they
# finish. See 03-docker-image-basics.sh for why the output of ls is
# saved in a variable before it is tested.
for IMAGE_NAME in docker-basics-ping docker-basics-context \
  docker-basics-arg docker-basics-nginx; do
  EXISTING_IMAGE_IDS=$(docker image ls --quiet "$IMAGE_NAME")
  if [[ -n $EXISTING_IMAGE_IDS ]]; then
    die "An image named $IMAGE_NAME already exists. Stopping. If it is" \
      'left over from an earlier run of this script, list the images' \
      "with docker image ls $IMAGE_NAME and remove each one with" \
      "docker image rm $IMAGE_NAME:TAG"
  fi
done

# The last example bind mounts ./hello-world-nginx into an nginx
# container. If Docker uses SELinux, nginx in the container cannot
# read the files, and the example would fail with "403 Forbidden".
# See the comments on SELinux in 06-docker-bind-mounts.sh. Only that
# example needs the bind mount, so it is skipped, rather than the
# whole script stopped. docker info --format prints the security
# options of the Docker daemon with a Go template.
SECURITY_OPTIONS=$(docker info --format='{{.SecurityOptions}}')
SELINUX_ENABLED='no'
if [[ $SECURITY_OPTIONS == *name=selinux* ]]; then
  SELINUX_ENABLED='yes'
fi


# What a build needs

# docker image build builds an image. docker build is an alias for it
# (see 03-docker-image-basics.sh). The build needs two things:
#
# - A Dockerfile: a text file of instructions, such as FROM, RUN,
#   COPY, ENV and CMD. The build runs them in order, starting from the
#   base image that FROM names. Each instruction is one step of the
#   build.
# - A build context: the files that the build may use. The last
#   argument of docker image build names it. It is usually a directory
#   on the host, but it can also be the URL of a Git repository or of
#   a tar archive. Giving - in place of the context reads stdin: a
#   plain Dockerfile gives an empty filesystem context, while a tar
#   archive supplies the context and its Dockerfile, for example
#   docker image build - < context.tar.
#
# Local source paths for COPY and ADD are relative to the root of the
# context. They cannot reach files in its parent directory on the
# host. BuildKit removes parent-directory navigation: COPY ../file
# /file reads file at the root of the context, and succeeds if it is
# there. ADD can also fetch remote sources, and COPY --from can read
# from another build stage, a named context or an image.
#
# The Dockerfile is looked for at the root of the context, under the
# name Dockerfile, unless --file names another one (see Choosing the
# Dockerfile with --file, below). The docker command sends the context
# to the builder, BuildKit, which runs in the Docker daemon and not in
# the docker command. BuildKit asks only for the files that the build
# uses, when it needs them. The old builder, which DOCKER_BUILDKIT=0
# selects, sent the whole context before the build started.


# Building and tagging an image

# Let's start with a very basic example. We will create a custom image
# based on almalinux:10-minimal that contains the ping command. The
# Dockerfile is in the docker-basics-ping directory, which is also the
# build context. Because this is such a simple example, the build
# context only contains the Dockerfile, and an empty .gitignore. The
# Dockerfile explains each of its instructions.
#
# --tag names the image. Without a tag after a colon, the name gets
# the tag latest, so the image is docker-basics-ping:latest. --tag can
# be given more than once, to give the image several names. Without
# --tag, the image has only an id, and docker image ls shows <none>
# for its name. If an image already has the name, building again moves
# the name to the new image. If the old image has no other tags, it is
# then left without a name, and is called dangling. So the examples
# below give each build a name of its own.
#
# The build downloads the base image, almalinux:10-minimal, if it is
# not already on this machine. It is kept when the script ends, as in
# 07-docker-envvars.sh.
echo 'Building docker-basics-ping from ./docker-basics-ping:'
docker image build --tag docker-basics-ping ./docker-basics-ping
cleanup_add ping-image docker image rm 'docker-basics-ping:latest'

# The TAG column shows latest.
docker image ls docker-basics-ping


# Layers and docker image history

# Each RUN, COPY and ADD instruction adds a layer to the image: the
# files that the step created, changed or deleted. Other instructions,
# such as ENTRYPOINT, only change the settings of the image, and add
# no files. docker image history lists the steps, newest first, with
# the size of each one. The top two rows come from
# ./docker-basics-ping/Dockerfile: ENTRYPOINT, with a size of 0B, and
# RUN, which installed iputils. The rows below them come from the base
# image. <missing> in the IMAGE column means that the step has no
# image of its own on this machine, which is normal for images built
# with BuildKit, and for steps of a downloaded image. See
# 03-docker-image-basics.sh for more about docker image history.
echo 'The steps of docker-basics-ping, newest first:'
docker image history docker-basics-ping


# How ENTRYPOINT receives arguments

# docker image inspect shows the settings that the image gives each
# of its containers. ./docker-basics-ping/Dockerfile sets ENTRYPOINT
# to ["/usr/bin/ping"]. It does not set CMD. The base image sets CMD
# to ["/bin/bash"], but a Dockerfile that sets ENTRYPOINT also clears
# the CMD of its base image, so Cmd is null.
echo 'The ENTRYPOINT and CMD of docker-basics-ping:'
docker image inspect \
  --format 'Entrypoint: {{json .Config.Entrypoint}}  Cmd: {{json .Config.Cmd}}' \
  docker-basics-ping

# The words that follow the image name on the docker container run
# command line are added to the ENTRYPOINT, so -V runs
# /usr/bin/ping -V, which prints the version of ping. Docker runs it
# directly, without a shell. Without any words, ping would get no
# arguments, and would fail with "usage error: Destination address
# required". 09-docker-build-cmd-entrypoint.sh compares this with CMD,
# whose words are replaced, rather than added to.
echo 'docker container run --rm docker-basics-ping -V runs ping -V:'
docker container run --rm docker-basics-ping -V

# This example pings www.google.com, so it needs the network. The
# options are short ones, because ping has no long options:
#   -c 3: send 3 packets, and then stop.
#   -w 10: stop after 10 seconds, even if fewer replies have arrived.
# ping returns 0 if a reply arrived, 1 if none did, and 2 for other
# errors, such as a host name that cannot be looked up. If ping fails,
# for example because there is no network, the script prints a
# warning and goes on. ICMP may be blocked even when downloads work.
# Later builds may still need the network to download base images or
# install packages, such as nginx, if those steps are not cached.
#
# As in 07-docker-envvars.sh, the container is made with docker
# container create, and a cleanup command that removes it by its id
# is saved before it is started, so that it is removed even if only
# the docker client is killed. start --attach then shows the output of
# ping, and passes signals on to it, as run does. Without --init, ping
# runs as the first process of the container. The kernel drops a
# signal sent to that process only if the process has no handler for
# it, and ping handles SIGINT, so Ctrl-C still stops it (see
# 02-docker-container-basics.sh). If a container with this name
# already exists, create fails, and the script stops without touching
# that container.
PING_CONTAINER='docker-basics-build-ping'
if ! PING_CONTAINER_ID=$(docker container create \
  --name "$PING_CONTAINER" docker-basics-ping -c 3 -w 10 www.google.com); then
  die 'Could not create the ping container. If the name' \
    "$PING_CONTAINER is already in use and you no longer need that" \
    'container, remove it with:' \
    "docker container rm --force $PING_CONTAINER"
fi
cleanup_add ping-container docker container rm --force "$PING_CONTAINER_ID"

# The || saves the status, so that set -e does not stop the script.
# Statuses of 128 or higher can mean that the container or Docker
# client was terminated by a signal. Stop with that same status, even
# if the script itself did not receive the signal. ping uses only 0, 1
# and 2, so stop for any other status as well.
echo 'docker-basics-ping -c 3 -w 10 www.google.com:'
PING_STATUS=0
docker container start --attach "$PING_CONTAINER_ID" || PING_STATUS=$?
if [[ $PING_STATUS -ge 128 ]]; then
  echo 'ERROR: docker container start ended with status' \
    "$PING_STATUS. The container or Docker client may have been" \
    'interrupted or killed.' >&2
  exit "$PING_STATUS"
elif [[ $PING_STATUS -gt 2 ]]; then
  die "docker container start returned $PING_STATUS, a status that" \
    'ping does not use. 126 or 127 usually means that the command in' \
    'the container could not be run.'
fi
# start returns 1 for its own errors, which ping also uses. So check
# that the container ran, and exited with the same status, before
# treating the status as the status of ping, as in 07-docker-envvars.sh.
PING_RESULT=$(docker container inspect \
  --format '{{.State.Status}} {{.State.ExitCode}}' "$PING_CONTAINER_ID")
if [[ $PING_RESULT != "exited $PING_STATUS" ]]; then
  die "docker container start returned $PING_STATUS, but the" \
    "container state and exit status are: $PING_RESULT"
fi
if [[ $PING_STATUS -ne 0 ]]; then
  echo "WARNING: ping could not reach www.google.com (status" \
    "$PING_STATUS). Continuing: ICMP may be blocked even when" \
    'downloads work. Later builds may still need network access.' >&2
fi
# Remove the container by id, then forget the saved cleanup command.
docker container rm "$PING_CONTAINER_ID" >/dev/null
cleanup_cancel ping-container

# The ping image is no longer needed. docker image rm prints the name
# that it removes, and the ids of the layers that it deletes.
docker image rm 'docker-basics-ping:latest'
cleanup_cancel ping-image


# The build context and .dockerignore

# The next examples need a build context whose files the script can
# change. mktemp --directory creates an empty directory that only you
# can use, in /tmp or in the directory that TMPDIR names, and prints
# its path. A cleanup command removes it, and everything in it, when
# the script exits. The directory holds:
#   Dockerfile:      the instructions, shown below.
#   message.txt:     a file that the image is meant to contain.
#   secret.txt:      a file that the image must not contain. It is a
#                    stand in for a password or a key.
#   notes/todo.txt:  a file that the image does not need.
CONTEXT_DIR=$(mktemp --directory)
cleanup_add context-dir rm --recursive --force -- "$CONTEXT_DIR"
mkdir "$CONTEXT_DIR/notes"
echo 'Version 1 of message.txt' >"$CONTEXT_DIR/message.txt"
echo 'not-a-real-password' >"$CONTEXT_DIR/secret.txt"
echo 'Notes that the image does not need' >"$CONTEXT_DIR/notes/todo.txt"

# The Dockerfile:
#   ENV sets DOCKER_BASICS_RUN to the name of the context directory,
#     which mktemp makes up anew for each run of the script. See the
#     note below.
#   RUN date saves the time, to the nanosecond, at which the RUN step
#     ran, in /built-at.txt. The cache examples below use it to tell
#     whether the step ran again.
#   COPY . /context/ copies the whole build context into /context in
#     the image.
#   CMD lists the files in /context, with ls.
# The shell replaces ${CONTEXT_DIR##*/} with the name of the
# directory, the part of its path after the last /. The text has no
# other $, so nothing else is changed.
#
# Why DOCKER_BASICS_RUN: the build cache, explained below, outlives
# the images, and the --no-cache example adds a second result for RUN
# date to it. On the next run of the script, the cache would then
# hold two results for the same step, and BuildKit could use either
# one, so the times that the examples compare would not always match.
# ENV changes the environment of the RUN step after it, which is an
# input of that step. A value that is new for each run means that
# only the results of this run match.
cat >"$CONTEXT_DIR/Dockerfile" <<EOF
FROM almalinux:10-minimal
ENV DOCKER_BASICS_RUN=${CONTEXT_DIR##*/}
RUN date --utc '+%T.%N' > /built-at.txt
COPY . /context/
CMD ["ls", "-l", "--almost-all", "--recursive", "/context"]
EOF

# The tags of docker-basics-context that the examples build, in the
# order that they are built.
CONTEXT_TAGS=()

# build_context_image: build the image in CONTEXT_DIR as
# docker-basics-context:TAG, and save a cleanup command that removes
# that name.
#
# Usage: build_context_image tag [option...]
#   tag:    the tag of the image.
#   option: more options for docker image build, for example --quiet,
#           which prints only the id of the image, in place of the
#           steps of the build.
build_context_image() {
  local tag=$1
  shift
  docker image build "$@" --tag "docker-basics-context:$tag" \
    "$CONTEXT_DIR"
  cleanup_add "context-$tag" docker image rm "docker-basics-context:$tag"
  CONTEXT_TAGS+=("$tag")
}

# built_at: print the time at which the RUN step of the image
# docker-basics-context:TAG ran.
#
# Usage: built_at tag
built_at() {
  docker container run --rm "docker-basics-context:$1" cat /built-at.txt
}

# COPY . copies everything in the context, including the Dockerfile
# itself, the notes and secret.txt.
echo 'Building docker-basics-context:all-files, without .dockerignore:'
build_context_image all-files --quiet
echo 'The files that COPY . copied into the image:'
docker container run --rm 'docker-basics-context:all-files'

# A file named .dockerignore, at the root of the context, lists the
# files that the build must leave out. COPY and ADD then do not see
# them. Its rules:
# - Each line is a pattern, for a path relative to the root of the
#   context. notes/ leaves out the directory notes, and everything in
#   it.
# - * matches any characters in a name, except /, and ** matches any
#   number of directories. So **/*.log leaves out every .log file.
# - A line that starts with ! keeps files that an earlier line leaves
#   out. For example *.txt followed by !message.txt.
# - Lines that start with # are comments.
# Listing Dockerfile and .dockerignore keeps them out of the image.
# The builder still reads them, because it needs them to run the
# build.
#
# Leaving files out keeps secrets out of the image, keeps the image
# small, and, as the cache examples below show, means that changing
# those files does not make the build run its steps again.
cat >"$CONTEXT_DIR/.dockerignore" <<'EOF'
# Files that the image does not need.
.dockerignore
Dockerfile
notes/
secret.txt
EOF

echo 'Building docker-basics-context:ignored, with .dockerignore:'
build_context_image ignored --quiet
echo 'The files that COPY . copied into the image:'
docker container run --rm 'docker-basics-context:ignored'

# Check that .dockerignore did what was expected. If it did not, the
# examples that follow would be misleading, so stop. ls prints one
# name on each line when its output is not a terminal. The message
# puts the names on one line, with each newline replaced by a space.
IGNORED_FILES=$(docker container run --rm 'docker-basics-context:ignored' \
  ls --almost-all /context)
if [[ $IGNORED_FILES != 'message.txt' ]]; then
  die 'Expected only message.txt in /context, but found:' \
    "${IGNORED_FILES//$'\n'/ }"
fi


# The build cache

# BuildKit keeps the result of each step in its build cache. Before it
# runs a step, it checks whether the cache already has the result of
# the same step, with the same inputs, after the same earlier steps.
# If it does, it uses that result in place of running the step again.
# The inputs are the text of the instruction, and, for COPY and ADD,
# the contents and relevant metadata, such as permissions, of the
# files that they copy. File modification times (mtime) are excluded:
# changing only mtime does not invalidate the cache. Once a step has
# to run again, every step after it runs again too, because its input,
# the result of the earlier step, has changed.
#
# The cache is kept when the images are removed. So if you have run
# this script before, the RUN step of docker-basics-ping, above, and
# of docker-basics-nginx, below, come from the cache, and show CACHED
# even on the first build of this run. (The DOCKER_BASICS_RUN variable
# keeps that from happening for docker-basics-context.) docker buildx
# du lists the entries in the build cache, and docker
# builder prune removes them (see 03-docker-image-basics.sh). The
# script does not prune, because that would also remove the cache of
# your other builds.
#
# --progress=plain prints every step of the build as plain text, in
# place of the display that BuildKit shows on a terminal, which hides
# the finished steps. Look for CACHED after the RUN and COPY steps.
echo 'Building docker-basics-context:rebuilt, with nothing changed:'
build_context_image rebuilt --progress=plain

# The build output shows whether RUN and COPY came from the cache.
# The timestamp comparison checks that RUN did not run again:
# /built-at.txt must hold the same time as in the ignored image. It
# does not check whether COPY was cached, because RUN precedes COPY.
BUILT_AT_IGNORED=$(built_at ignored)
BUILT_AT_REBUILT=$(built_at rebuilt)
echo "RUN date ran at $BUILT_AT_IGNORED for ignored, and at" \
  "$BUILT_AT_REBUILT for rebuilt."
if [[ $BUILT_AT_REBUILT != "$BUILT_AT_IGNORED" ]]; then
  die 'Expected the RUN step to come from the cache.'
fi

# notes/ is in .dockerignore, so COPY . does not see the notes, and a
# change to them does not change the input of COPY. The whole build
# still comes from the cache. Look for CACHED after COPY in the plain
# build output; the timestamp comparison below checks only RUN.
echo 'More notes' >>"$CONTEXT_DIR/notes/todo.txt"
echo 'Building docker-basics-context:notes-changed, after changing' \
  'notes/todo.txt, which .dockerignore leaves out:'
build_context_image notes-changed --progress=plain
if [[ $(built_at notes-changed) != "$BUILT_AT_IGNORED" ]]; then
  die 'Expected the RUN step to come from the cache.'
fi

# message.txt is copied by COPY ., so changing it changes the input of
# COPY, which runs again. RUN date comes before COPY, so its result
# still comes from the cache, and /built-at.txt is unchanged. The
# image has the new message.txt. The plain build output shows COPY
# running again, while RUN shows CACHED. Check the message as well as
# the timestamp, so the script stops if it copied the wrong contents.
# Each value is read from the image once, printed, and then checked.
echo 'Version 2 of message.txt' >"$CONTEXT_DIR/message.txt"
echo 'Building docker-basics-context:message-changed, after changing' \
  'message.txt:'
build_context_image message-changed --progress=plain
BUILT_AT_MESSAGE_CHANGED=$(built_at message-changed)
COPIED_MESSAGE=$(docker container run --rm \
  'docker-basics-context:message-changed' cat /context/message.txt)
echo "RUN date ran at $BUILT_AT_MESSAGE_CHANGED for message-changed."
echo "/context/message.txt in the image: $COPIED_MESSAGE"
if [[ $BUILT_AT_MESSAGE_CHANGED != "$BUILT_AT_IGNORED" ]]; then
  die 'Expected the RUN step to come from the cache.'
fi
if [[ $COPIED_MESSAGE != 'Version 2 of message.txt' ]]; then
  die 'Expected /context/message.txt to contain Version 2 of message.txt,' \
    "but found: $COPIED_MESSAGE"
fi

# --no-cache makes the build run every step again, without looking in
# the cache. So RUN date saves a new time. This is useful when a step
# depends on something outside the build, for example when RUN
# microdnf -y install should pick up newer packages from the
# repositories. Its text has not changed, so without --no-cache the
# build would keep using the old result.
echo 'Building docker-basics-context:no-cache, with --no-cache:'
build_context_image no-cache --quiet --no-cache
BUILT_AT_NO_CACHE=$(built_at no-cache)
echo "RUN date ran at $BUILT_AT_NO_CACHE for no-cache."
if [[ $BUILT_AT_NO_CACHE == "$BUILT_AT_IGNORED" ]]; then
  die 'Expected the RUN step to run again with --no-cache.'
fi

# Similarly, the build uses the base image that is already on this
# machine, even if a newer one has been published with the same tag.
# --pull makes it check the registry for a newer base image first.
# The script does not use it, because it needs the network, and could
# replace your almalinux:10-minimal.

# docker image ls shows the ids of the images. On the machine this
# script was written on, ignored, rebuilt and notes-changed have the
# same id: a build whose every step comes from the cache gives the
# same image, so the three tags name one image. all-files,
# message-changed and no-cache each have an id of their own.
docker image ls docker-basics-context

# The order of the instructions matters. Put the steps that rarely
# change, such as installing packages, before the steps that often
# change, such as copying the source code of an application. Then a
# change to the source code runs only the COPY, and the steps after
# it, again, and the package install comes from the cache.


# Choosing the Dockerfile with --file

# --file names a Dockerfile other than Dockerfile at the root of the
# context. A relative path is relative to the current directory, not
# to the context, and the Dockerfile does not even have to be in the
# context. --file - reads the Dockerfile from stdin, and still uses
# the context. docker image build - instead reads stdin as either a
# plain Dockerfile, with an empty filesystem context, or a tar archive
# containing the context and its Dockerfile. The examples in
# 03-docker-image-basics.sh and in the next section use the plain
# Dockerfile form.
#
# The context has a .dockerignore, but a Dockerfile can also have an
# ignore file of its own, named after it with .dockerignore added. For
# message.Dockerfile, below, it would be message.Dockerfile.dockerignore,
# next to it. If there is one, the build uses it in place of the
# .dockerignore at the root of the context.
cat >"$CONTEXT_DIR/message.Dockerfile" <<'EOF'
FROM almalinux:10-minimal
COPY message.txt /message.txt
CMD ["cat", "/message.txt"]
EOF
echo 'Building docker-basics-context:message, with' \
  '--file message.Dockerfile:'
build_context_image message --quiet \
  --file "$CONTEXT_DIR/message.Dockerfile"
echo 'docker-basics-context:message prints its copy of message.txt:'
docker container run --rm 'docker-basics-context:message'

# Remove the images, newest first, then the context directory, and
# forget the saved cleanup commands. Each docker image rm prints the
# name that it removes. A tag that names the same image as an earlier
# one only removes the name. The last name of an image also deletes
# the image.
for ((i = ${#CONTEXT_TAGS[@]} - 1; i >= 0; i--)); do
  docker image rm "docker-basics-context:${CONTEXT_TAGS[i]}"
  cleanup_cancel "context-${CONTEXT_TAGS[i]}"
done
rm --recursive --force -- "$CONTEXT_DIR"
cleanup_cancel context-dir


# Build arguments: ARG and --build-arg

# ARG declares a build argument: a variable that the instructions that
# follow it can use, during the build only. Its value comes from
# docker image build --build-arg NAME=VALUE, or else from the default
# value in the ARG instruction. ENV, which 07-docker-envvars.sh uses,
# sets a variable in the image instead, which every container of the
# image gets.
#
# This Dockerfile has no COPY, so it needs no context. It is given to
# docker image build on stdin, with - in place of the context, as in
# 03-docker-image-basics.sh. RUN writes the value of GREETING into
# /greeting.txt, and the container prints that file. The Dockerfile
# is kept in a variable, because it is built twice. <<< gives the
# value of the variable to the command on stdin.
ARG_DOCKERFILE=$(cat <<'EOF'
FROM almalinux:10-minimal
ARG GREETING=Hello
ENV FAREWELL=Goodbye
RUN echo "$GREETING, written by RUN during the build" > /greeting.txt
CMD ["cat", "/greeting.txt"]
EOF
)

echo 'Building docker-basics-arg:default, with the default GREETING:'
docker image build --quiet --tag 'docker-basics-arg:default' - \
  <<<"$ARG_DOCKERFILE"
cleanup_add arg-default docker image rm 'docker-basics-arg:default'

# A different value of a build argument is a different input to the
# steps that use it, so the RUN step runs again, rather than come from
# the cache.
echo 'Building docker-basics-arg:namaste, with' \
  '--build-arg GREETING=Namaste:'
docker image build --quiet --build-arg GREETING=Namaste \
  --tag 'docker-basics-arg:namaste' - <<<"$ARG_DOCKERFILE"
cleanup_add arg-namaste docker image rm 'docker-basics-arg:namaste'

echo 'docker-basics-arg:default prints:'
docker container run --rm 'docker-basics-arg:default'
echo 'docker-basics-arg:namaste prints:'
docker container run --rm 'docker-basics-arg:namaste'

# The value is in the file that RUN wrote, during the build. Changing
# a runtime value does not rerun the build or rewrite files generated
# by it. So --env GREETING=Hola, when the container runs, does not
# change what the container prints.
echo 'docker-basics-arg:default, run with --env GREETING=Hola, prints:'
docker container run --rm --env GREETING=Hola 'docker-basics-arg:default'

# The build argument is not in the environment of the container.
# printenv prints nothing, and returns 1, for a variable that is not
# set. The variable set with ENV is there.
GREETING_STATUS=0
docker container run --rm 'docker-basics-arg:namaste' \
  printenv GREETING || GREETING_STATUS=$?
if [[ $GREETING_STATUS -ne 1 ]]; then
  die 'Expected GREETING not to be set in the container, but' \
    "printenv returned $GREETING_STATUS."
fi
echo 'As expected, the container has no GREETING. It has FAREWELL,' \
  'from ENV:'
docker container run --rm 'docker-basics-arg:namaste' printenv FAREWELL

# A build argument is not secret. docker image history shows the
# value that each step used, to anyone who can run docker commands, or
# who gets a copy of the image. --no-trunc shows the whole of each
# step, and --format prints only the command of each step. Look for
# GREETING=Namaste in the RUN and ARG rows. To give a build a password
# or a key, use docker image build --secret, and
# RUN --mount=type=secret in the Dockerfile. The secret is then
# available to that one RUN step, as a file, and is not saved in the
# image.
echo 'The steps of docker-basics-arg:namaste:'
docker image history --no-trunc --format '{{.CreatedBy}}' \
  'docker-basics-arg:namaste'

# More about ARG:
# - An ARG before FROM can choose the base image, for example
#     ARG ALMALINUX_TAG=10-minimal
#     FROM almalinux:${ALMALINUX_TAG}
#   Such an ARG can only be used in FROM. To use its value after FROM,
#   repeat ARG ALMALINUX_TAG, without a value, after FROM.
# - A --build-arg that no ARG in the Dockerfile declares is not used.
#   BuildKit ignores it without a warning, so a misspelt name is easy
#   to miss. (The old builder printed a warning.)
# - To pass a build argument on to the containers, copy it into a
#   variable of the image with ENV, for example
#     ARG GREETING=Hello
#     ENV GREETING=$GREETING

docker image rm 'docker-basics-arg:namaste' 'docker-basics-arg:default'
cleanup_cancel arg-namaste
cleanup_cancel arg-default


# An nginx image

# In the following example, we will build a custom image that runs an
# instance of the nginx web server on an AlmaLinux base image. The
# image will be tagged as docker-basics-nginx. The Dockerfile is in
# the docker-basics-nginx directory, which is also the build context.
# The Dockerfile is extensively documented to explore the different
# instructions that can be used in a Dockerfile.
#
# You can look at https://github.com/nginxinc/docker-nginx for
# examples of production quality Dockerfiles. They build the nginx
# image that 02-docker-container-basics.sh uses.
echo 'Building docker-basics-nginx from ./docker-basics-nginx:'
docker image build --tag docker-basics-nginx ./docker-basics-nginx
cleanup_add nginx-image docker image rm 'docker-basics-nginx:latest'

# docker image inspect shows what the instructions of the Dockerfile
# saved in the image: the labels, the exposed port, the stop signal
# and the command. In the Go template, range goes through the labels,
# and prints each name and value on a line of its own.
# 17-docker-inspect.sh explores docker inspect in more detail.
echo 'The labels of docker-basics-nginx:'
docker image inspect \
  --format '{{range $name, $value := .Config.Labels}}{{$name}}={{$value}}{{"\n"}}{{end}}' \
  docker-basics-nginx
echo 'The exposed ports, stop signal and command of docker-basics-nginx:'
docker image inspect \
  --format 'ExposedPorts: {{json .Config.ExposedPorts}}  StopSignal: {{.Config.StopSignal}}  Cmd: {{json .Config.Cmd}}' \
  docker-basics-nginx

# EXPOSE only records the port. docker container run --publish
# 9000:80, below, publishes port 80 of the container on port 9000 of
# the host. Docker changes the firewall rules of the host to let
# traffic in, without going through firewalld or ufw. So, as in
# 02-docker-container-basics.sh, we also open the port in the firewall,
# to make it easier to remember that the container is running on an
# external port, and close it after the container is stopped. If the
# port was already open, the script leaves it open. query_tcp_port
# prints partial if only some of the firewall chains allow the port,
# and then the script leaves the firewall alone. See
# 21-docker-networking.sh for how to run a container that is only
# accessible from the host.
#
# A cleanup command closes the port if the script stops early. It is
# saved before the containers are created, so that on an early exit
# the containers are removed first.
if [[ $EUID -ne 0 ]]; then
  echo 'Querying the firewall and adding ports requires root privileges'
  echo 'The firewall commands will be invoked with sudo'
fi
PORT_IS_ALREADY_ACCESSIBLE=$(query_tcp_port 9000)
if [[ $PORT_IS_ALREADY_ACCESSIBLE == 'no' ]]; then
  open_tcp_port 9000
  cleanup_add firewall-port close_tcp_port 9000
elif [[ $PORT_IS_ALREADY_ACCESSIBLE == 'partial' ]]; then
  echo 'Port 9000 is open in only some of the firewall chains. The' \
    'script leaves the firewall alone.'
fi

# Both nginx examples use one container name, one at a time.
NGINX_CONTAINER='docker-basics-build-nginx'

# start_nginx_container: create and start a container of
# docker-basics-nginx, with port 80 published on port 9000 of the
# host, and wait until nginx answers. It sets NGINX_CONTAINER_ID to
# the id of the container, and NGINX_PAGE to the home page that nginx
# served. As in 04-docker-kill-top-stats.sh, the container is created
# first, and a cleanup command that removes it by its id is saved
# before it is started.
#
# Usage: start_nginx_container [option...]
#   option: more options for docker container create, for example a
#           bind mount.
start_nginx_container() {
  local attempt
  if ! NGINX_CONTAINER_ID=$(docker container create \
    --name "$NGINX_CONTAINER" --publish 9000:80 "$@" docker-basics-nginx); then
    die 'Could not create the nginx container. If the name' \
      "$NGINX_CONTAINER is already in use and you no longer need that" \
      'container, remove it with:' \
      "docker container rm --force $NGINX_CONTAINER"
  fi
  cleanup_add nginx-container docker container rm --force \
    "$NGINX_CONTAINER_ID"

  # Starting fails if another program or container already uses port
  # 9000 of the host. docker container ps shows the ports that
  # containers publish. start prints the id of the container, which is
  # thrown away.
  if ! docker container start "$NGINX_CONTAINER_ID" >/dev/null; then
    die 'Could not start the nginx container. If Docker reports that' \
      'port 9000 is already allocated, stop the program or container' \
      'that uses it, and run the script again.'
  fi

  # docker container start returns before nginx is ready. Ask for the
  # home page on the published port, up to 30 times, a second apart,
  # as in 04-docker-kill-top-stats.sh. 127.0.0.1 is the host itself,
  # where Docker publishes the port. --fail makes curl fail on an HTTP
  # error status, as well as when it cannot connect. --max-time gives
  # up on an attempt that takes longer than 2 seconds. --noproxy '*'
  # sends the request straight to nginx, even if the http_proxy
  # variable names a proxy.
  echo 'Waiting for nginx to answer at http://127.0.0.1:9000/...'
  for attempt in {1..30}; do
    if NGINX_PAGE=$(curl --silent --fail --max-time 2 --noproxy '*' \
      'http://127.0.0.1:9000/'); then
      return 0
    fi
    if [[ $attempt -lt 30 ]]; then
      sleep 1
    fi
  done
  die 'nginx did not answer at http://127.0.0.1:9000/ after 30' \
    'tries. Stopping.'
}

# stop_nginx_container: stop and remove the container that
# start_nginx_container started, and forget its cleanup command.
#
# docker container stop sends the stop signal of the image, SIGQUIT,
# which makes nginx finish its requests and exit. It waits for the
# container to stop, and sends SIGKILL if it has not stopped after 10
# seconds. nginx exits with 0 after a SIGQUIT. An exit code of 137
# would mean that it had to be killed, as in
# 04-docker-kill-top-stats.sh.
stop_nginx_container() {
  local exit_code
  docker container stop "$NGINX_CONTAINER_ID" >/dev/null
  exit_code=$(docker container inspect --format '{{.State.ExitCode}}' \
    "$NGINX_CONTAINER_ID")
  echo "nginx stopped, with exit code $exit_code."
  docker container rm "$NGINX_CONTAINER_ID" >/dev/null
  cleanup_cancel nginx-container
}

# You can start the custom container with docker container create and
# start, as start_nginx_container does, or with run.
start_nginx_container

# The nginx package of AlmaLinux serves a test page, whose title is
# "Test Page for the HTTP Server on AlmaLinux". Check that nginx
# served it, so that the bind mount example below can show the
# difference.
if ! grep --quiet --fixed-strings 'AlmaLinux' <<<"$NGINX_PAGE"; then
  die 'nginx did not serve the AlmaLinux test page of the image.'
fi
echo "The container is running at http://$(hostname --fqdn):9000/"
echo 'Notice that it is the AlmaLinux version of the nginx web server.'

# The -p option prints the prompt before read waits for input. The -r
# option stops read from treating a backslash as special. See
# 02-docker-container-basics.sh.
read -r -p 'Press ENTER when done...'
stop_nginx_container

# You can bind mount a directory with different HTML content. This is
# useful for development: nginx serves the files as you edit them on
# the host, without a new build. The ./ tells Docker that this is a
# bind mount, and not a named volume. :ro mounts it read only, because
# nginx only needs to read the files. The mount hides the files that
# the image has in /usr/share/nginx/html (see 06-docker-bind-mounts.sh).
if [[ $SELINUX_ENABLED == 'yes' ]]; then
  echo 'Docker uses SELinux, so the bind mount example is skipped.' \
    'See the comments on SELinux in 06-docker-bind-mounts.sh.'
else
  echo 'Running a container with the custom nginx image and a bind mount'
  start_nginx_container \
    --volume ./hello-world-nginx:/usr/share/nginx/html:ro

  # Check that nginx serves ./hello-world-nginx/index.html, and not the
  # page of the image. grep --quiet prints nothing, and only returns
  # whether it found the text.
  if ! grep --quiet --fixed-strings '<h1>docker-basics</h1>' \
    <<<"$NGINX_PAGE"; then
    die 'nginx did not serve ./hello-world-nginx/index.html.'
  fi
  echo "The container is running at http://$(hostname --fqdn):9000/"
  echo 'It serves ./hello-world-nginx/index.html.'
  read -r -p 'Press ENTER when done...'
  stop_nginx_container
fi

# Close port 9000 on the firewall of the host, only if it was not
# accessible before the script was run, and forget the saved cleanup
# command.
if [[ $PORT_IS_ALREADY_ACCESSIBLE == 'no' ]]; then
  close_tcp_port 9000
  cleanup_cancel firewall-port
fi

# Finally we remove the custom image, and forget the saved cleanup
# command. The base image, almalinux:10-minimal, is kept. The build
# cache is kept too.
docker image rm 'docker-basics-nginx:latest'
cleanup_cancel nginx-image
