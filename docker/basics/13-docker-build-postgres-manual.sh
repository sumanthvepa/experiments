#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 13-docker-build-postgres-manual.sh: Explore building a postgres
# Docker image, that required manual invocation of a setup script
# inside the image
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License a
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

echo '13-docker-build-postgres-manual.sh'

# This script creates a Postgres Docker image that has postgres
# installed, but not started. The user is expected to start the
# Postgres service manually by running the setup script inside
# the container.

# The setup script is copied to the image during the build process.

# See the instructions at the end of this script on how to use
# the Postgres Docker image that is created here.

# We need to know the architecture of the CPU that the script is
# running on so that we can download the appropriate Postgres
# RPM and gosu binary.
CPU_ARCHITECTURE=$(uname -m)

echo "CPU architecture as reported by 'uname -m' is $CPU_ARCHITECTURE"

# Determine the architecture suffix to be used to
# get the appropriate Postgres RPM and gosu binary distribution
if [[ "$CPU_ARCHITECTURE" == "x86_64" ]]; then
  ARCH_SUFFIX='amd64'
elif [[ "$CPU_ARCHITECTURE" == "aarch64" ]]; then
  ARCH_SUFFIX='arm64'
fi

# Download the postgres RPM from the postgres repository if it
# not present in the postgres-manual directory. Note that even
# though the rpm itself is not architecture-specific, the
# it's GPG signature is, and the downloaded file should be
# saved to an architecture-specific directory. Hence the ${ARCH_SUFFIX}
# in the path for POSTGRES_REPO_RPM.
POSTGRES_REPO_RPM="./postgres-manual/${ARCH_SUFFIX}/pgdg-redhat-repo-latest.noarch.rpm"
POSTGRES_REPO_RPM_URL="https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${CPU_ARCHITECTURE}/pgdg-redhat-repo-latest.noarch.rpm"
if [[ ! -f $POSTGRES_REPO_RPM ]]; then
  echo "${POSTGRES_REPO_RPM}  not found"
  # Create architecture-specific download directory
  mkdir -p ./postgres-manual/${ARCH_SUFFIX}
  echo "Downloading from postgres repository"
  echo "URL: $POSTGRES_REPO_RPM_URL"
  curl -fsSL $POSTGRES_REPO_RPM_URL -o $POSTGRES_REPO_RPM
  if [[ $? -ne 0 ]]; then
    echo "Failed to download the Postgres repository RPM"
    exit 1
  fi
fi

# Download gosu for the given architecture if it is not present in the
# postgres-manual directory.
GOSU_BINARY="./postgres-manual/${ARCH_SUFFIX}/gosu-${ARCH_SUFFIX}"
GOSU_BINARY_URL="https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH_SUFFIX}"
GOSU_SIGNATURE="./postgres-manual/${ARCH_SUFFIX}/gosu-${ARCH_SUFFIX}.asc"
GOSU_SIGNATURE_URL="https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH_SUFFIX}.asc"

if [[ ! -f $GOSU_BINARY ]]; then
  echo "${GOSU_BINARY} not found"
  # Create architecture-specific download directory
  mkdir -p ./postgres-manual/${ARCH_SUFFIX}
  echo "Downloading gosu from the official repository"
  echo "URL: $GOSU_BINARY_URL"
  curl -fsSL $GOSU_BINARY_URL -o $GOSU_BINARY
  if [[ $? -ne 0 ]]; then
    echo "Failed to download the gosu binary"
    exit 1
  fi
  curl -fsSL $GOSU_SIGNATURE_URL -o $GOSU_SIGNATURE
  if [[ $? -ne 0 ]]; then
    echo "Failed to download the gosu signature"
    exit 1
  fi
fi

# Remove any previous image if it exists
IMAGE_EXISTS=$(docker image ls --quiet postgres-manual)
if [[ ! -z $IMAGE_EXISTS ]]; then
  echo "Removing existing postgres-manual image"
  docker image rm postgres-manual
fi

# Now we can build the Postgres Docker image
docker build --tag postgres-manual --build-arg ARCH_SUFFIX=${ARCH_SUFFIX} ./postgres-manual

# Give the user instructions on how to use this postgres docker image
echo "Postgres Docker image built successfully"
echo
echo "We can now run the image and start the Postgres service manually"
echo "You need to define the POSTGRES_PASSWORD environment variable to"
echo "be able to start the postgres service manually within the"
echo "container. This an be done by passing the environment variable"
echo "to the docker container run command as shown below:"
echo
echo "docker container run --interactive --tty --rm --publish 5432:5432 --env POSTGRES_PASSWORD='postgres' postgres-manual"
echo
echo "You can also set it within the container after you've been "
echo "dropped into the shell."
echo
echo "export POSTGRES_PASSWORD='postgres'"
echo
echo "or whatever password you want to set"
echo
echo "Once you're inside the container, you can start the Postgres "
echo "service by running the following command:"
echo
echo "/usr/local/bin/setup-postgres.sh"
echo
echo "This script will properly initialize the Postgres database and"
echo "start the Postgres service. You can pass options to it that it"
echo "will in turn pass to the postgres command."
echo "If you are trying to troubleshoot the script, you an run it"
echo "with the DOCKER_POSTGRES_DEBUG environment variable set to"
echo "1 as follows:"
echo
echo "DOCKER_POSTGRES_DEBUG=1 /usr/local/bin/setup-postgres.sh"
echo
echo Alternatively, you can export the environment variable
echo
echo "export DOCKER_POSTGRES_DEBUG=1"
echo "/usr/local/bin/setup-postgres.sh"
echo
echo "Finally, you can set the POSTGRES_PASSWORD environment variable"
echo "when running the container as shown below:"
echo
echo "docker container run --interactive --tty --rm --publish 5432:5432 --env POSTGRES_PASSWORD='postgres' --env DOCKER_POSTGRES_DEBUG=1 postgres-manual"
echo
echo "Note, that to connect to the database, you will have to connect"
echo "to the container on port 5432. Since we're publishing the port"
echo "5432 of the container to the host, you can connect to the "
echo "database from the host machine using the IP address/name of the"
echo "host machine."
echo
echo "The password for the postgres user is the value of the"
echo "POSTGRES_PASSWORD environment variable that you set when"
echo "running the container."
echo
echo "You need to have the psql client installed on the machine from "
echo "which you want to connect to the Postgres database. See "
echo "databases/postgres/01-install-postgress-client.sh in this"
echo "repository for instructions on how to install the psql client."
echo
echo "The psql command to connect to the Postgres database is as"
echo "follows:"
echo
echo "psql --host=$(hostname -f) --username=postgres --password"
echo
echo "You will be prompted for the password that you set in the"
echo "POSTGRES_PASSWORD environment variable. If you want to connect "
echo "non-interactively, you can pass the password as an environment "
echo "variable PGPASSWORD to the psql command as follows:"
echo
echo "PGPASSWORD='postgres' psql --host=$(hostname -f) --username=postgres"
echo
echo "See https://stackoverflow.com/questions/6405127/how-do-i-specify-a-password-to-psql-non-interactively"
echo "for more information on how to connect to the Postgres database"
echo "non-interactively."
echo
echo "To stop the Postgres server, you'll have to issue a stop command"
echo "from outside the container from a different terminal on the host"
echo
echo "docker container stop postgres-manual-test"
echo

docker container run --interactive --tty --rm --publish 5432:5432 --env POSTGRES_PASSWORD='postgres' --name='postgres-manual-test' postgres-manual

# Clean up by removing the docker image
echo
echo "Cleaning up the postgres-manual image"
docker image rm postgres-manual
