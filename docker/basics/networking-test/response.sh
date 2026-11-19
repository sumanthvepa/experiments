#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# networking-test/response.sh: Handle one disposable demo HTTP request
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

# socat gives each connection its own process. This deliberately tiny HTTP
# fixture supports GET / only; it is not a production web server.
set -euo pipefail
IFS= read -r -t 2 -n 4096 REQUEST
# At most 32 header lines, each bounded in size and read time.
COMPLETE=false
for ((LINE=0; LINE<32; LINE++)); do
  IFS= read -r -t 1 -n 4096 HEADER
  if [[ $HEADER == $'\r' || -z $HEADER ]]; then COMPLETE=true; break; fi
done
[[ $COMPLETE == true ]] || exit 1
STATUS='200 OK'
BODY=
if [[ $REQUEST != $'GET / HTTP/1.1\r' ]]; then
  STATUS='404 Not Found'
  BODY='Use GET /'
elif [[ ${ROLE:-} == backend ]]; then
  if RESULT=$(PGCONNECT_TIMEOUT=3 PGOPTIONS='-c statement_timeout=3000' \
    psql --no-psqlrc --no-password --set ON_ERROR_STOP=1 --host=database \
      --username=postgres --dbname=postgres --tuples-only --no-align \
      --command "SELECT 'database-ready';"); then
    BODY="backend -> $RESULT"
  else
    STATUS='503 Service Unavailable'
    BODY='Database request failed'
  fi
elif [[ ${ROLE:-} == frontend ]]; then
  if RESULT=$(curl --noproxy '*' --fail --silent --show-error \
    --connect-timeout 3 --max-time 5 http://backend:8080/); then
    BODY="frontend -> $RESULT"
  else
    STATUS='503 Service Unavailable'
    BODY='Backend request failed'
  fi
else
  STATUS='500 Internal Server Error'
  BODY='Unknown service role'
fi
printf 'HTTP/1.1 %s\r\nContent-Type: text/plain\r\n' "$STATUS"
printf 'Content-Length: %s\r\nConnection: close\r\n\r\n%s' "${#BODY}" "$BODY"
