#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# setup-postgres.sh: Initialization and startup script for Postgres
# within a container.
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

echo "Setting up Postgres..."

# Initialization and startup script for Postgres within a container.
# This script is intended to be run within the container running
# the postgres-manual image.
# It needs to be run manually by a user logging into the container.

# Set the variables needed for the script to default values
# if they are not already set.
POSTGRES_USER=${POSTGRES_USER:=postgres}
if [[ -v POSTGRES_PASSWORD ]]; then
  if [[ -z "${POSTGRES_PASSWORD}" ]]; then
    echo "ERROR: The POSTGRES_PASSWORD environment variable must not be empty"
    exit 1
  fi
else
  echo "ERROR: The POSTGRES_PASSWORD environment variable must be set"
  exit 1
fi
POSTGRES_DB=${POSTGRES_DB:=$POSTGRES_USER}
POSTGRES_INITDB_ARGS=${POSTGRES_INITDB_ARGS:=}
POSTGRES_INITDB_WALDIR=${POSTGRES_INITDB_WALDIR:=}
POSTGRES_HOST_AUTH_METHOD=${POSTGRES_HOST_AUTH_METHOD:="scram-sha-256"}
PGDATA=${PGDATA:=/var/lib/pgsql/16/data/}

echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_INITDB_ARGS: $POSTGRES_INITDB_ARGS"
echo "POSTGRES_INITDB_WALDIR: $POSTGRES_INITDB_WALDIR"
echo "POSTGRES_HOST_AUTH_METHOD: $POSTGRES_HOST_AUTH_METHOD"
echo "PGDATA: $PGDATA"

# if [ ! -d $PGDATA ]; then
#  echo "Creating the database data directory"
#  mkdir -p $PGDATA
#  if [ $? -ne 0 ]; then
#    echo "Error creating the database data directory"
#    exit 1
#  fi
#  # Change the ownership and permissions of the data directory
#  # The directory should be owned by the postgres user and
#  # accessible only to the owner (postgres) for reading, writing,
#  # and executing.
#  chown postgres:postgres $PGDATA
#  if [ $? -ne 0 ]; then
#    echo "Error changing the ownership of the database data directory"
#    exit 2
#  fi
#  chmod 00700 "$PGDATA"
#  if [ $? -ne 0 ]; then
#    echo "Error changing the permissions of the database data directory"
#    exit 3
#  fi
# fi

# TODO: Check if the POSTGRES_INITDB_WALDIR environment variable is set,
# if so, create the directory and set the appropriate permissions
# if [ -n "${POSTGRES_INITDB_WALDIR:-}" ]; then
#  echo "Creating the WAL directory"
#  mkdir -p "${POSTGRES_INITDB_WALDIR}"
#  if [ $? -ne 0 ]; then
#    echo "Error creating the WAL directory"
#    exit 4
#  fi
#  chown -R postgres:postgres "${POSTGRES_INITDB_WALDIR}"
#  if [ $? -ne 0 ]; then
#    echo "Error changing the ownership of the WAL directory"
#    exit 5
#  fi
#  chmod 00700 "${POSTGRES_INITDB_WALDIR}"
#  if [ $? -ne 0 ]; then
#    echo "Error changing the permissions of the WAL directory"
#    exit 6
#  fi
#fi

# Initialize the database only if it is empty
# if [ ! "$(ls -A $PGDATA)" ]; then
#  gosu postgres initialize-postgres.sh
#  if [ $? -ne 0 ]; then
#    echo "Error initializing the database"
#    # The error code from initialize-postgres.sh is appended to 4
#    # so that the exact cause of initialization failure can be
#    # identified.
#    exit "4$?"
# fi
#fi
echo "...finished setting up Postgres"

echo "Starting Postgres..."
# Start the postgres server
