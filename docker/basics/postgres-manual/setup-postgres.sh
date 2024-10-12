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

function check_required_variables() {
  if [[ ! -v POSTGRES_PASSWORD ]]; then
    echo "[1] ERROR(1): The POSTGRES_PASSWORD environment variable is must be set"
    return 1
  else
    if [[ -z "${POSTGRES_PASSWORD}" ]]; then
      echo "[1] ERROR(2): The POSTGRES_PASSWORD environment variable must not be empty"
      return 2
    fi
  fi
  # TODO: Don't print the password
  echo "[1] POSTGRES_PASSWORD is set to $POSTGRES_PASSWORD"
  return 0
}

function initialize_optional_variables() {
  echo "[2] Initializing optional variables..."
  # Set the variables needed for the script to default values
  # if they are not already set.
  POSTGRES_USER=${POSTGRES_USER:=postgres}
  echo "[2] POSTGRES_USER is set to $POSTGRES_USER"
  POSTGRES_DB=${POSTGRES_DB:=$POSTGRES_USER}
  echo "[2] POSTGRES_DB is set to $POSTGRES_DB"
  POSTGRES_INITDB_ARGS=${POSTGRES_INITDB_ARGS:=}
  echo "[2] POSTGRES_INITDB_ARGS is set to $POSTGRES_INITDB_ARGS"
  POSTGRES_INITDB_WALDIR=${POSTGRES_INITDB_WALDIR:=}
  echo "[2] POSTGRES_INITDB_WALDIR is set to $POSTGRES_INITDB_WALDIR"
  POSTGRES_HOST_AUTH_METHOD=${POSTGRES_HOST_AUTH_METHOD:="scram-sha-256"}
  echo "[2] POSTGRES_HOST_AUTH_METHOD is set to $POSTGRES_HOST_AUTH_METHOD"
  PGDATA=${PGDATA:=/var/lib/pgsql/16/data/}
  echo "[2] ...done."
  return 0
}

function create_data_directory() {
  if [[ -d $PGDATA ]]; then
    echo "[3] Data directory $PGDATA already exists... skipping data directory creation"
    return 0
  else 
    echo -n "[3] Creating the data directory..." 
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
 fi
 echo " done."
  return 0  
}

function create_write_ahread_log_directory() {
  if [[ -z $POSTGRES_INITDB_WALDIR ]]; then
    echo "[4] Write-ahead log(WAL) directory not specified... skipping WAL directory creation"
    return 0
  fi
  if [[ -d $POSTGRES_INITDB_WALDIR ]]; then
    echo "[4] Write-ahead log(WAL) directory $POSTGRES_INITDB_WALDIR already exists... skipping WAL directory creation"
    return 0
  fi
  echo -n "[4] Creating the write-ahead log directory..."
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
  echo " done."
  return 0
}

function initialize_database() {
  if [[ ! -z "$(ls -A $PGDATA)" ]]; then
    echo "[5] Data directory $PGDATA is not empty"
    echo "[5] Skipping database initialization"
    return 0
  fi
  echo -n "[5] Initializing the database..."
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
  echo " done."
  return 0
}

# Initialization and startup script for Postgres within a container.
# This script is intended to be run within the container running
# the postgres-manual image.
# It needs to be run manually by a user logging into the container.

echo "Setting up Postgres..."
check_required_variables || exit $? # [1] Check required variables
initialize_optional_variables || exit $? # [2] Initialize optional variables
create_data_directory || exit $? # [3] Create the data directory
create_write_ahread_log_directory || exit $? # [4] Create the WAL directory
initialize_database || exit $? # [5] Initialize the database
echo "...finished setting up Postgres"

echo "Starting Postgres..."
# Start the postgres server
