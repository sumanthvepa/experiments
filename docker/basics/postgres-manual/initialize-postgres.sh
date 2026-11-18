#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# initialize-postgres.sh: Initialize the Postgres database in a
# container
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

# Called by setup-postgres.sh as the Linux postgres account. Trusted init
# scripts may run arbitrary code; never use files from an untrusted source.
set -euo pipefail
for variable in DOCKER_POSTGRES_DEBUG POSTGRES_DIST_DIR POSTGRES_USER \
    POSTGRES_PASSWORD POSTGRES_DB POSTGRES_HOST_AUTH_METHOD PGDATA; do
  [[ -n ${!variable:-} ]] || { echo "$variable must be nonempty." >&2; exit 1; }
done
# PostgreSQL 16 initdb cannot quote double quotes in its password SQL and
# creates plpgsql, whose extension-owner substitutions reject these names.
# Mirror those upstream limits before initdb can emit password SQL.
case $POSTGRES_USER in
  *'"'*|*"'"*|*'$'*|*\\*|*$'\n'*|*$'\r'*|*'--'*|*'/*'*|*'*/'*|\
  *'@extowner@'*|*'@extschema'*|*MODULE_PATHNAME*)
    echo 'POSTGRES_USER violates PostgreSQL 16 initdb/extension-owner naming rules; see setup-postgres.sh --help.' >&2
    exit 1;;
esac
[[ -v POSTGRES_INITDB_ARGS && -v POSTGRES_INITDB_WALDIR ]] || exit 1
[[ $(id -un) == postgres && -d $PGDATA ]] || exit 1
export PGPASSWORD=$POSTGRES_PASSWORD
export PGUSER=$POSTGRES_USER
export PGHOST=$PGDATA PGPORT=5432
PSQL=("$POSTGRES_DIST_DIR/bin/psql" --no-psqlrc --set ON_ERROR_STOP=1 --username "$POSTGRES_USER")
TEMP_PID=

# Stop the temporary socket-only server after SQL/decompression/script
# failure, Ctrl-C or normal initialization; never leave a server on failure.
stop_temporary_server() {
  [[ -n $TEMP_PID ]] || return 0
  "$POSTGRES_DIST_DIR/bin/pg_ctl" -D "$PGDATA" -m fast -w -t 30 stop || return $?
  wait "$TEMP_PID" || return $?
  TEMP_PID=
}
finish() {
  local status=$?
  trap - EXIT
  if ! stop_temporary_server; then
    echo 'Could not stop the temporary PostgreSQL server.' >&2
    if [[ $status == 0 ]]; then status=1; fi
  fi
  exit "$status"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Tokenize the legacy text option without eval. Quotes and backslash group
# words; substitutions, globbing, shell operators and variable expansion
# are never evaluated. Prefer --option=value when possible.
INITDB_ARGS=()
parse_initdb_args() {
  local text=$1 char word='' quote='' escaped=0 started=0 i
  for ((i=0; i<${#text}; i++)); do
    char=${text:i:1}
    if [[ $escaped == 1 ]]; then
      # Inside double quotes, backslash is special only before the shell
      # quote/escape characters. Keep it before other literal characters.
      if [[ $quote == '"' && $char != "\\" && $char != '"' &&
          $char != '$' && $char != '`' && $char != $'\n' ]]; then
        word+="\\"
      fi
      if [[ $char != $'\n' ]]; then word+=$char; started=1; fi
      escaped=0
    elif [[ $quote == "'" ]]; then
      if [[ $char == "'" ]]; then quote=; else word+=$char; fi
    elif [[ $char == "\\" ]]; then
      escaped=1
    elif [[ -n $quote ]]; then
      if [[ $char == "$quote" ]]; then quote=; else word+=$char; fi
    elif [[ $char == '"' || $char == "'" ]]; then
      quote=$char; started=1
    elif [[ $char == ' ' || $char == $'\t' || $char == $'\n' ]]; then
      if [[ $started == 1 ]]; then INITDB_ARGS+=("$word"); word=; started=0; fi
    else
      word+=$char; started=1
    fi
  done
  [[ -z $quote && $escaped == 0 ]] || { echo 'Unclosed quote/backslash in POSTGRES_INITDB_ARGS.' >&2; return 1; }
  if [[ $started == 1 ]]; then INITDB_ARGS+=("$word"); fi
}
parse_initdb_args "$POSTGRES_INITDB_ARGS"
WAL_ARGS=()
if [[ -n $POSTGRES_INITDB_WALDIR ]]; then WAL_ARGS+=(--waldir "$POSTGRES_INITDB_WALDIR"); fi
# Password goes through a file descriptor, never through a constructed
# command, a debug line or a persistent password file.
echo 'Initializing database cluster as Linux user postgres...'
"$POSTGRES_DIST_DIR/bin/initdb" --username "$POSTGRES_USER" \
  --pwfile=<(printf '%s\n' "$POSTGRES_PASSWORD") \
  --auth "$POSTGRES_HOST_AUTH_METHOD" \
  -D "$PGDATA" "${WAL_ARGS[@]}" "${INITDB_ARGS[@]}"
printf "\nlisten_addresses = '*'\n" >> "$PGDATA/postgresql.conf"
cp -- "$PGDATA/pg_hba.conf" "$PGDATA/pg_hba.conf.bak"
printf '\nhost all all all %s\n' "$POSTGRES_HOST_AUTH_METHOD" >> "$PGDATA/pg_hba.conf"
# Direct argv preserves postgres options containing spaces. Final options
# keep this temporary server private regardless of the supplied flags.
"$POSTGRES_DIST_DIR/bin/postgres" -D "$PGDATA" "$@" \
  -c listen_addresses= -c "unix_socket_directories=$PGDATA" -p 5432 \
  > "$PGDATA/initialization.log" 2>&1 &
TEMP_PID=$!
ready=0
for ((attempt=0; attempt<30; attempt++)); do
  if "$POSTGRES_DIST_DIR/bin/pg_isready" --timeout=1 --quiet; then ready=1; break; fi
  if ! kill -0 "$TEMP_PID" 2>/dev/null; then break; fi
  sleep 1
done
if [[ $ready == 0 ]]; then
  cat "$PGDATA/initialization.log" >&2
  echo 'Temporary server did not become ready.' >&2
  exit 1
fi
# :'name' quotes an SQL literal; format(%I) quotes a database identifier.
# stdin allows psql variables and \gexec; --command does not expand them.
"${PSQL[@]}" --dbname postgres --set db="$POSTGRES_DB" <<'SQL'
SELECT format('CREATE DATABASE %I', :'db')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'db') \gexec
SQL
shopt -s nullglob
for filename in /docker-entrypoint-initdb.d/*; do
  if [[ $DOCKER_POSTGRES_DEBUG == 1 ]]; then printf 'Initialization file: %s\n' "$filename"; fi
  case $filename in
    *.sh)
      if [[ -x $filename ]]; then "$filename"; else
        # shellcheck disable=SC1090 # Intentionally source a trusted user file.
        source "$filename"
      fi;;
    *.sql) "${PSQL[@]}" --dbname "$POSTGRES_DB" --file "$filename";;
    *.sql.gz) gzip --decompress --stdout -- "$filename" | "${PSQL[@]}" --dbname "$POSTGRES_DB";;
    *.sql.xz) xz --decompress --stdout -- "$filename" | "${PSQL[@]}" --dbname "$POSTGRES_DB";;
    *.sql.zst) zstd --decompress --stdout -- "$filename" | "${PSQL[@]}" --dbname "$POSTGRES_DB";;
    *) printf 'Ignoring initialization file: %s\n' "$filename";;
  esac
done
stop_temporary_server
# A failed init must never be mistaken for a complete initialized cluster.
touch "$PGDATA/.docker-postgres-initialized"
echo 'Database initialization complete; temporary server stopped.'
