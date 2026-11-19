#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# call-curl.sh: Fetch the page at the URL in the environment variable
# FETCH_URL, and print it
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

# This is the command of the image that the Dockerfile in this
# directory describes. 07-docker-envvars.sh builds the image, as
# docker-basics-curl, to show how environment variables are passed to
# a container.

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail

# The Dockerfile gives FETCH_URL a default value, but
# docker container run --env FETCH_URL removes it when FETCH_URL is
# not set on the host, and --env FETCH_URL= sets it to an empty value.
# ${FETCH_URL:-} is empty in both cases, without set -u stopping the
# script. Say what is wrong, rather than let curl fail with a vague
# error. Status 2 is the usual status for a command used wrongly.
if [[ -z ${FETCH_URL:-} ]]; then
  echo 'call-curl.sh: FETCH_URL is not set, or is empty. Give it a URL' \
    'with: docker container run --rm --init --env FETCH_URL=URL' \
    'docker-basics-curl' >&2
  exit 2
fi

# exec replaces bash with curl, without a bash process waiting for
# it. The container returns curl's exit status. Run the container with
# --init so curl is a child of the init process and can be stopped
# with Ctrl-C or docker container stop. Without --init, curl runs as
# PID 1 and ignores SIGINT and SIGTERM, because it has no handlers for
# them (see 02-docker-container-basics.sh). curl options:
#   --location: follow redirects.
#   --silent --show-error: print no progress meter, but still print
#     errors.
#   --fail: return a non-zero status if the server reports an error,
#     such as 404 Not Found, rather than print the error page.
#   --connect-timeout 10: allow at most 10 seconds to connect,
#     including looking up the host name and negotiating TLS.
#   --max-time 30: allow at most 30 seconds for the whole transfer,
#     including connecting and following redirects.
# The quotes pass the URL to curl as one word, even if it has spaces
# or characters such as * and ?, which bash would otherwise expand.
exec curl --location --silent --show-error --fail \
  --connect-timeout 10 --max-time 30 "$FETCH_URL"
