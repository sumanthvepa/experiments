#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 04-docker-kill-top-stats.sh: Explore the docker container kill, top
# and stats commands.
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

echo '04-docker-kill-top-stats'

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail

# Use the same error and cleanup helpers as 03-docker-image-basics.sh.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"

# The script uses curl on the host to find out when nginx is ready.
# Check for it before creating anything.
if ! command -v curl >/dev/null; then
  die 'This script needs curl. Install it with the package manager' \
    'of your Linux distribution.'
fi

# All the examples below use one nginx container, named
# docker-basics-nginx.

# Create an nginx container without publishing a port. The kill, top
# and stats commands talk to the container through the Docker daemon,
# and not over the network. Without --publish, it is still on the
# default bridge network. The host and containers on that bridge can
# reach it, and it can make outgoing connections. See
# 02-docker-container-basics.sh for what --publish does to the firewall.

# docker container create makes a new container from an image, but
# does not start it. It pulls the image first if it is not available
# locally. It sets the container up with the options it is given,
# such as --name, and gives it its own writable layer on top of the
# image. The container is then in the Created state, with nothing
# running in it, until docker container start starts it. docker
# container run does both steps at once: it creates a container and
# starts it. They are separate here, so that the cleanup below can be
# saved after the container is created but before it is started.

# docker container create prints the id of the new container, which
# is saved for the cleanup below. If a container named
# docker-basics-nginx already exists, for example one left over from
# a run that was killed, create fails. The script then stops, rather
# than remove a container that this run did not create.
if ! NGINX_CONTAINER_ID=$(docker container create \
  --name='docker-basics-nginx' nginx); then
  die 'Could not create the demonstration container. If the name' \
    'docker-basics-nginx is already in use and you no longer need' \
    'that container, remove it with:' \
    'docker container rm --force docker-basics-nginx'
fi

# Save a cleanup command before starting the container, so that the
# container is removed even if it fails to start, or the script stops
# part way through. The command uses the id of the container, so it
# can only remove the container that this run created. --force stops
# the container first if it is still running. The end of the script
# removes the container itself, to show how, and then cleanup_cancel
# forgets the saved command.
cleanup_add nginx-container docker container rm --force \
  "$NGINX_CONTAINER_ID"

# Start the container in the background, without attaching to it.
# From here on, the examples use the name of the container, which is
# easier to read than its id. It names the same container, because
# this run created it.
docker container start 'docker-basics-nginx'

# docker container start returns as soon as the container has
# started, before nginx is ready. Until then, the program running in
# the container is a shell script, /docker-entrypoint.sh, which sets
# up nginx and then starts it. The kernel drops a signal that is sent
# to the first process of a container, if the process has no handler
# for it. So a signal sent too soon would be lost without any message.
#
# nginx sets up its signal handlers before it starts its worker
# processes, and it is a worker that answers a request. So once nginx
# answers a request, it handles signals, and it has worker processes
# for docker container top to show.

# Ask nginx for its home page with curl on the host. The container is
# not published, but the host can reach it at its address on the
# default bridge network, which Docker gives it when it starts.
# docker container inspect prints the details of a container, and
# --format picks out the address with a Go template.
#
# This needs rootful Docker, where the daemon runs as root and the
# bridge network is on the host. With rootless Docker, the bridge is
# in a separate network namespace, which the host cannot reach, so
# curl would fail.
NGINX_IP=$(docker container inspect \
  --format='{{.NetworkSettings.Networks.bridge.IPAddress}}' \
  'docker-basics-nginx')
if [[ -z $NGINX_IP ]]; then
  die 'The container has no address on the default bridge network.'
fi

# Try up to 30 times, a second apart. --fail makes curl fail on an
# HTTP error status, as well as when it cannot connect. --max-time
# gives up on an attempt that takes longer than 2 seconds. --noproxy
# '*' sends the request straight to the container, even if the
# http_proxy variable names a proxy, which could not reach it. curl
# takes the value of an option as the next word, not after an =.
echo "Waiting for nginx to answer at http://$NGINX_IP/..."
NGINX_READY='no'
for _ in {1..30}; do
  if curl --silent --fail --output /dev/null --max-time 2 \
    --noproxy '*' "http://$NGINX_IP/"; then
    NGINX_READY='yes'
    break
  fi
  sleep 1
done
if [[ $NGINX_READY != 'yes' ]]; then
  die "nginx did not answer at http://$NGINX_IP/ after 30 tries." \
    'With rootless Docker, the host cannot reach the container.' \
    'Stopping.'
fi

# You can see what processes are running in a container using docker
# container top. Unlike the top shell command, docker container top is
# a one shot command. It won't keep running. Notice the PIDs of the
# nginx worker processes. They change in the next example.
docker container top 'docker-basics-nginx'

# You can send a signal to the program running in a container using
# docker container kill. The --signal option takes the name of the
# signal, with or without the SIG prefix, or its number. So
# --signal='SIGHUP', --signal='HUP' and --signal=1 are all the same.

# nginx reloads its configuration when it receives SIGHUP. It starts
# new worker processes, and tells the old ones to finish what they
# are doing and exit. The master process keeps running.
docker container kill --signal='SIGHUP' 'docker-basics-nginx'

# Give nginx a moment to replace its worker processes.
sleep 2

# The master process has the same PID as before, but the worker
# processes have new PIDs.
docker container top 'docker-basics-nginx'

# The logs of the container show that nginx received the signal. If
# they do not, the examples that follow would be misleading, so stop.
# nginx writes its log to stderr, hence the 2>&1. See 10-docker-logs.sh
# for more about docker container logs.
if ! docker container logs 'docker-basics-nginx' 2>&1 |
  grep 'SIGHUP'; then
  die 'The nginx logs do not show the SIGHUP. Stopping.'
fi

# docker container top passes any options after the container name
# to the ps command. The following shows only the PID, the parent
# PID, the user and the command line of each process. The workers run
# as user 101, which is the nginx user in the container.
docker container top 'docker-basics-nginx' -o pid,ppid,user,args

# You can see the stats of a container using docker container stats.
# The following prints the CPU, memory, network and disk usage of the
# container once and exits. See 18-docker-stats.sh for more about
# docker container stats.
docker container stats --no-stream 'docker-basics-nginx'

# If you want a top like experience, leave out the --no-stream
# option. The following updates the stats of the container every
# second, until you press Ctrl-C.

# Ctrl-C sends SIGINT to the script as well as to docker container
# stats. Bash normally carries on when the command stops, but the
# trap makes sure that the script is not stopped with it. The trap
# runs the : command, which does nothing. Afterwards, restore the
# cleanup helper's trap, which exits with status 130 on Ctrl-C.
# stats may return 0 or 130 after Ctrl-C. Accept either, but stop on
# other errors even though this command is exempt from set -e.
echo 'docker container stats will run until you press Ctrl-C.'
read -r -p 'Press ENTER to start it...'
trap ':' SIGINT
STATS_STATUS=0
docker container stats 'docker-basics-nginx' || STATS_STATUS=$?
trap 'exit 130' INT
if [[ $STATS_STATUS -ne 0 && $STATS_STATUS -ne 130 ]]; then
  echo 'ERROR: docker container stats failed with status' \
    "$STATS_STATUS." >&2
  exit "$STATS_STATUS"
fi

# docker container kill sends SIGKILL if --signal is not given.
# SIGKILL cannot be handled or ignored, so nginx stops at once,
# without finishing the requests it is working on. Compare this with
# docker container stop, which sends the image's configured stop
# signal (SIGQUIT for nginx, SIGTERM if none is configured). It waits
# for the program to exit, then sends SIGKILL if the timeout expires.
# The default timeout for Linux containers is 10 seconds.
echo 'Killing the container...'
docker container kill 'docker-basics-nginx'

# docker container kill returns once the signal is sent, possibly
# before the container has stopped. docker container wait waits for
# it to stop, and prints its exit code: 137. An exit code above 128
# means that the program was ended by a signal, and 137 - 128 = 9 is
# the number of SIGKILL.
docker container wait 'docker-basics-nginx'

# The container has stopped, but still exists, and its status shows
# Exited (137).
docker container ps --all --filter name='docker-basics-nginx'

# The container has already stopped, so it can be removed without
# stopping it first. docker container rm prints the name of the
# container that it removed.
echo 'Cleaning up...'
docker container rm 'docker-basics-nginx'
cleanup_cancel nginx-container
echo '...cleanup completed.'
