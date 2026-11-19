#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-entrypoint.sh: Automatic initialization and startup for Postgres
# within a container.
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

# ENTRYPOINT runs automatically. Defaults mirror the official image's useful
# initialization inputs, but _FILE variables are deliberately unsupported.
# Official image reference: https://github.com/docker-library/docs/tree/master/postgres
# POSTGRES_USER is a database role; the Linux account is always postgres.
set -euo pipefail

usage() {
  cat <<'HELP'
Usage: docker-entrypoint.sh [bash|postgres] [postgres options...]
Initialize once, then run postgres (default) or an interactive bash shell.
Inputs: POSTGRES_PASSWORD (required for setup), POSTGRES_USER, POSTGRES_DB,
POSTGRES_INITDB_ARGS, POSTGRES_INITDB_WALDIR, POSTGRES_HOST_AUTH_METHOD,
POSTGRES_DIST_DIR, PGDATA and DOCKER_POSTGRES_DEBUG=1 (no password logging).
POSTGRES_USER must satisfy PostgreSQL 16 initdb/extension-owner rules:
no quotes, $, backslash, newline/CR, --, /*, */, @extowner@, @extschema,
or MODULE_PATHNAME. Spaces and semicolons are supported.
Trusted initialization files in /docker-entrypoint-initdb.d run in name order:
executable .sh, sourced .sh, .sql, .sql.gz, .sql.xz and .sql.zst.
HELP
}

case ${1:-} in -h|--help|'-?') usage; exit 0;; esac
export POSTGRES_DIST_DIR=${POSTGRES_DIST_DIR:-/usr/pgsql-16}
export PGDATA=${PGDATA:-/var/lib/pgsql/16/data}
export DOCKER_POSTGRES_DEBUG=${DOCKER_POSTGRES_DEBUG:-0}
export POSTGRES_USER=${POSTGRES_USER:-postgres}
export POSTGRES_DB=${POSTGRES_DB:-$POSTGRES_USER}
export POSTGRES_INITDB_ARGS=${POSTGRES_INITDB_ARGS:-}
export POSTGRES_INITDB_WALDIR=${POSTGRES_INITDB_WALDIR:-}
export POSTGRES_HOST_AUTH_METHOD=${POSTGRES_HOST_AUTH_METHOD:-scram-sha-256}
mode=postgres
if [[ ${1:-} == bash || ${1:-} == postgres ]]; then mode=$1; shift; fi
# Informational postgres flags need neither a password nor an initialized DB.
for arg; do
  case $arg in --version|-V|--describe-config)
    exec gosu postgres "$POSTGRES_DIST_DIR/bin/postgres" "$@";;
  esac
done
if [[ ! -v POSTGRES_PASSWORD ]]; then
  echo 'POSTGRES_PASSWORD must be set (demonstration credentials only).' >&2
  exit 3
fi
[[ -n $POSTGRES_PASSWORD ]] || { echo 'POSTGRES_PASSWORD must not be empty.' >&2; exit 4; }
export POSTGRES_PASSWORD
command -v gosu >/dev/null
# Repair ownership even when the directory already exists. Preserve the
# initialized cluster mode (0700 or initdb --allow-group-access 0750).
# There are no host mounts here; mounted data needs suitable ownership.
for directory in "$PGDATA" "${POSTGRES_INITDB_WALDIR:-}"; do
  [[ -n $directory ]] || continue
  mkdir -p -- "$directory"
  if [[ $(id -u) == 0 ]]; then chown postgres:postgres -- "$directory"; fi
  if [[ ! -s $PGDATA/PG_VERSION ]]; then chmod 0700 -- "$directory"; fi
done
if [[ ! -s $PGDATA/PG_VERSION ]]; then
  if [[ $mode == bash ]]; then
    gosu postgres /usr/local/bin/initialize-postgres.sh
  else
    gosu postgres /usr/local/bin/initialize-postgres.sh "$@"
  fi
elif [[ ! -f $PGDATA/.docker-postgres-initialized ]]; then
  echo 'Database initialization is incomplete; inspect PGDATA before retrying.' >&2
  exit 1
fi
if [[ $mode == bash ]]; then
  # Preserve the invoking manual shell identity; only the database runs
  # as the Linux postgres account.
  exec /bin/bash "$@"
fi
# exec makes postgres receive signals and preserves its real exit status.
exec gosu postgres "$POSTGRES_DIST_DIR/bin/postgres" -D "$PGDATA" "$@"
