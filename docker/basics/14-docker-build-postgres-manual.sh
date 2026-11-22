#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 14-docker-build-postgres-manual.sh: Explore building a postgres
# Docker image, that required manual invocation of a setup script
# inside the image
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

# Strict Bash stops failed commands, unset inputs and failed pipelines.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
# die reports fatal errors; cleanup_add/cancel restore owned resources.
source ./bash-utilities.sh

echo '14-docker-build-postgres-manual: initialize and start PostgreSQL manually'
# Host: Bash, Docker/Buildx, curl, sha256sum, ss and the core utilities below.
# Needs network access to Docker Hub, PGDG and AlmaLinux repositories;
# missing gosu assets also need GitHub. No host psql or package install.
# Run by path from any directory. Use a local Linux Docker daemon.
# Lessons 08/09 explain builds and CMD. Here CMD is bash, so installing
# database packages alone starts neither a cluster nor a database server.
# No bind mounts: host SELinux labels do not apply. Other distributions,
# CPUs, rootless/userns-remap and SELinux-enabled daemons are untested.
die_if_not_available cat curl sha256sum ss uname mktemp cp rm mkdir dirname sleep
die_if_not_docker_available
docker buildx version >/dev/null
CPU_ARCHITECTURE=$(uname -m)
case $CPU_ARCHITECTURE in
  x86_64) ARCH_SUFFIX=amd64; GOSU_SHA=bbc4136d03ab138b1ad66fa4fc051bafc6cc7ffae632b069a53657279a450de3;;
  aarch64|arm64) CPU_ARCHITECTURE=aarch64; ARCH_SUFFIX=arm64; GOSU_SHA=c3805a85d17f4454c23d7059bcb97e1ec1af272b90126e79ed002342de08389b;;
  *) die "Unsupported CPU architecture: $CPU_ARCHITECTURE (need x86_64 or aarch64).";;
esac
DAEMON_ARCH=$(docker version --format '{{.Server.Arch}}')
[[ $DAEMON_ARCH == "$ARCH_SUFFIX" ]] || die 'Use a local Linux daemon matching the host CPU.'
die_if_docker_image_exists postgres-manual
die_if_docker_container_exists postgres-manual-test
LISTENERS=$(ss --tcp --listening --no-header 'sport = :5432')
[[ -z $LISTENERS ]] || die 'Host port 5432 is occupied; inspect its owner without stopping it.'

# Cleanup helpers check their failures because cleanup runs in a conditional.
# Images are removed only when this run acquired their previously absent tag.
remove_owned_image() {
  local existing
  existing=$(docker image ls --quiet "$1") || return $?
  if [[ -n $existing ]]; then docker image rm "$1" || return $?; fi
}
# 1. Prepare downloads in an owned context; never modify repository fixtures.
CONTEXT=$(mktemp --directory --tmpdir docker-basics-postgres-manual.XXXXXXXX)
cleanup_add postgres-context rm -rf -- "$CONTEXT"
cp -a postgres-manual/. "$CONTEXT/"
mkdir -p "$CONTEXT/$ARCH_SUFFIX"
# The bundled RPMs configure EL10. Refresh configuration only in the
# temporary copy, preserving the standalone repository context. The RPM is
# noarch, but each URL configures repositories for the chosen CPU.
REPO_URL="https://download.postgresql.org/pub/repos/yum/reporpms/EL-10-$CPU_ARCHITECTURE/pgdg-redhat-repo-latest.noarch.rpm"
echo "Downloading EL10 PGDG repository RPM: $REPO_URL"
curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 \
  "$REPO_URL" --output "$CONTEXT/$ARCH_SUFFIX/pgdg-redhat-repo-latest.noarch.rpm"
GOSU="$CONTEXT/$ARCH_SUFFIX/gosu-$ARCH_SUFFIX"
if [[ ! -f $GOSU ]]; then
  curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 \
    "https://github.com/tianon/gosu/releases/download/1.17/gosu-$ARCH_SUFFIX" --output "$GOSU"
fi
if [[ ! -f $GOSU.asc ]]; then
  curl --fail --location --silent --show-error --connect-timeout 15 --max-time 120 \
    "https://github.com/tianon/gosu/releases/download/1.17/gosu-$ARCH_SUFFIX.asc" --output "$GOSU.asc"
fi
# Pin the binary to the bundled 1.17 checksum, including fallback downloads.
# Merely downloading .asc is not signature verification. For independent
# upstream authentication use the key/fingerprint and GPG instructions at
# https://github.com/tianon/gosu/blob/1.17/INSTALL.md in a private keyring.
printf '%s  %s\n' "$GOSU_SHA" "$GOSU" | sha256sum --check

# 2. Build PGDG's PG16 package layout, without obsolete EL9 module commands.
pull_image_if_absent almalinux:10-minimal
die_if_image_not_native almalinux:10-minimal
cleanup_add postgres-image remove_owned_image postgres-manual
docker image build --tag postgres-manual --build-arg "ARCH_SUFFIX=$ARCH_SUFFIX" "$CONTEXT"
echo 'PostgreSQL image built; CMD is a shell, no database server yet.'

# 3. Manually inspect, initialize and start the database in that shell image.
# Only host loopback is published; do not open a firewall port. PostgreSQL
# must listen on * inside the container for Docker forwarding to reach it.
# These are disposable demonstration credentials, never real passwords.
export POSTGRES_PASSWORD='postgres-demo-only'
CONTAINER_ID=$(docker container create --interactive --tty \
  --name postgres-manual-test --publish 127.0.0.1:5432:5432 \
  --env POSTGRES_PASSWORD --env DOCKER_POSTGRES_DEBUG=1 postgres-manual)
cleanup_add postgres-container docker container rm --force "$CONTAINER_ID"
docker container start "$CONTAINER_ID"
cat <<'INSTRUCTIONS'
The container is running bash, not PostgreSQL. Inspect it in a shell:
  postgres --version
  printf '%s\n' "${PGDATA:-not set until setup}"
Then type: exit 0
We will invoke setup-postgres.sh manually with docker exec next.
You may also set POSTGRES_PASSWORD inside the shell with export, or pass
--env POSTGRES_PASSWORD at creation. Use DOCKER_POSTGRES_DEBUG=1 to show
initialization stages; debug output never prints the password. For example:
  DOCKER_POSTGRES_DEBUG=1 /usr/local/bin/setup-postgres.sh
or export DOCKER_POSTGRES_DEBUG=1 before manually invoking setup-postgres.sh.
INSTRUCTIONS
read -r -p 'Press ENTER to continue...'
docker container exec --interactive --tty --env 'PS1=manual-postgres> ' "$CONTAINER_ID" /bin/bash --norc
read -r -p 'Press ENTER to continue...'
# bash mode initializes without leaving the server running. With stdin
# closed its inspection shell exits immediately; interactive callers can
# inspect the initialized files before starting the server themselves.
docker container exec "$CONTAINER_ID" /usr/local/bin/setup-postgres.sh bash < /dev/null
# pg_isready returns 2 for no response. Other statuses, including Docker
# errors, are failures rather than proof that initialization stopped it.
if docker container exec "$CONTAINER_ID" pg_isready --host=127.0.0.1 --timeout=1 --quiet; then
  die 'Initialization unexpectedly left a PostgreSQL server running.'
else
  STATUS=$?
  [[ $STATUS == 2 ]] || die "Post-initialization readiness check failed: $STATUS."
fi
echo 'Manual initialization finished; no server is running.'
# Default/postgres mode starts the actual server; flags are passed as argv.
# Detached exec lets this terminal perform the independent readiness check.
docker container exec --detach "$CONTAINER_ID" /usr/local/bin/setup-postgres.sh postgres -c 'log_min_messages=warning'
READY=0
for ((ATTEMPT=1; ATTEMPT<=30; ATTEMPT++)); do
  if docker container exec "$CONTAINER_ID" pg_isready --host=127.0.0.1 --timeout=1 --quiet; then
    READY=1; break
  else
    STATUS=$?
    [[ $STATUS == 1 || $STATUS == 2 ]] || die "PostgreSQL readiness command failed: $STATUS."
  fi
  sleep 1
done
[[ $READY == 1 ]] || die 'PostgreSQL readiness timed out (30 attempts, 1s timeout/delay).'
# TCP plus password verifies authentication as well as the initialized DB.
RESULT=$(docker container exec --env PGPASSWORD="$POSTGRES_PASSWORD" "$CONTAINER_ID" \
  psql --no-psqlrc --set ON_ERROR_STOP=1 --host=127.0.0.1 --username=postgres \
  --dbname=postgres --tuples-only --no-align --command 'SELECT current_user, current_database(), 6 * 7;')
[[ $RESULT == 'postgres|postgres|42' ]] || die "Unexpected manual database result: $RESULT"
echo "Verified manual PostgreSQL TCP query: $RESULT"
cat <<'CLIENT'
From a host with psql installed, use the published loopback port:
  psql --host=127.0.0.1 --port=5432 --username=postgres --password
The prompt asks for the demonstration password set above. For unattended
local tests PGPASSWORD can be set in the environment, for example:
  PGPASSWORD='postgres-demo-only' psql --host=127.0.0.1 --username=postgres
Prefer a protected
password file for real credentials (PostgreSQL libpq documentation).
setup-postgres.sh also accepts postgres flags, --version, --describe-config,
custom POSTGRES_USER/DB, PGDATA, POSTGRES_DIST_DIR, POSTGRES_INITDB_ARGS,
POSTGRES_INITDB_WALDIR and POSTGRES_HOST_AUTH_METHOD. See its help.
CLIENT
read -r -p 'Press ENTER to continue...'
# Stop the exec-started server explicitly before stopping PID1 (bash).
docker container exec "$CONTAINER_ID" gosu postgres pg_ctl -D /var/lib/pgsql/16/data -m fast -w -t 30 stop
docker container stop "$CONTAINER_ID"
docker container rm "$CONTAINER_ID"
cleanup_cancel postgres-container
remove_owned_image postgres-manual
cleanup_cancel postgres-image
echo 'Lesson complete; owned container, images and temporary context removed on exit.'
# EXIT also removes a newly pulled base and the context; build cache remains.
# SIGKILL cannot run traps. Inspect leftovers (docker container inspect
# postgres-manual-test; docker image ls postgres-manual) before removing
# only resources you can identify as this run's. Never prune other work.
