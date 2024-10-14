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

# Initialization and startup script for Postgres within a container.
# This script is intended to be run within the container running
# the postgres-manual image.
# It needs to be run manually by a user logging into the container.

# Exit codes
EXIT_CODE_SUCCESS=0
EXIT_CODE_ERROR_COULD_NOT_INITIALIZE_DATABASE=1
EXIT_CODE_ERROR_POSTGRES_SERVER_ERROR=2
EXIT_CODE_ERROR_POSTGRES_PASSWORD_NOT_SET=3
EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY=4
EXIT_CODE_ERROR_COULD_NOT_CREATE_PGDATA=5
EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_OWNERSHIP=6
EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_PERMISSIONS=7
EXIT_CODE_ERROR_COULD_NOT_CREATE_POSTGRES_INITDB_WALDIR=8
EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_OWNERSHIP=9
EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_PERMISSIONS=10
EXIT_CODE_ERROR_GOSU_NOT_FOUND=11


# Checks if all required variables have been set correctly
#
# Currently, the only required variable is POSTGRES_PASSWORD.
# It should be set to a non-empty string.
#
# Arguments: None
#
# Returns:
#  0 EXIT_CODE_SUCCESS if all required variables are set correctly
#  1 EXIT_CODE_ERROR_POSTGRES_PASSWORD_NOT_SET if the POSTGRES_PASSWORD
#    environment variable is not set
#  2 EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY if the POSTGRES_PASSWORD
#    environment variable is set, but empty
function check_required_variables() {
  if [[ ! -v POSTGRES_PASSWORD ]]; then
    echo "[11] ERROR($EXIT_CODE_ERROR_POSTGRES_PASSWORD_NOT_SET): The POSTGRES_PASSWORD environment variable is must be set"
    return $EXIT_CODE_ERROR_POSTGRES_PASSWORD_NOT_SET
  else
    if [[ -z "${POSTGRES_PASSWORD}" ]]; then
      echo "[11] ERROR($EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY): The POSTGRES_PASSWORD environment variable must not be empty"
      return $EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY
    fi
  fi
  # TODO: Don't print the password
  echo "[11] POSTGRES_PASSWORD is set to $POSTGRES_PASSWORD"
  return $EXIT_CODE_SUCCESS
}

# Initializes optional variables to default values if not already set.
#
# Currently, the optional variables are:
#  - POSTGRES_USER: The user to run the postgres server as.
#      Defaults to 'postgres'
#  - POSTGRES_DB: The default database to create. Defaults to the
#     value of POSTGRES_USER
#  - POSTGRES_INITDB_ARGS: Additional arguments to pass to initdb
#  - POSTGRES_INITDB_WALDIR: The directory to store write-ahead
#     logs(WAL). Defaults to empty
#  - POSTGRES_HOST_AUTH_METHOD: The host-based authentication method.
#     Defaults to 'scram-sha-256'
#  - PGDATA: The directory to store the database data. Defaults to
#     '/var/lib/pgsql/16/data/'
#
# Arguments: None
#
# Returns:
# 0 EXIT_CODE_SUCCESS
function initialize_optional_variables() {
  echo "[12] Initializing optional variables..."
  # Set the variables needed for the script to default values
  # if they are not already set.
  POSTGRES_USER=${POSTGRES_USER:=postgres}
  echo "[12] POSTGRES_USER is set to $POSTGRES_USER"
  POSTGRES_DB=${POSTGRES_DB:=$POSTGRES_USER}
  echo "[12] POSTGRES_DB is set to $POSTGRES_DB"
  POSTGRES_INITDB_ARGS=${POSTGRES_INITDB_ARGS:=}
  echo "[12] POSTGRES_INITDB_ARGS is set to $POSTGRES_INITDB_ARGS"
  POSTGRES_INITDB_WALDIR=${POSTGRES_INITDB_WALDIR:=}
  echo "[12] POSTGRES_INITDB_WALDIR is set to $POSTGRES_INITDB_WALDIR"
  POSTGRES_HOST_AUTH_METHOD=${POSTGRES_HOST_AUTH_METHOD:="scram-sha-256"}
  echo "[12] POSTGRES_HOST_AUTH_METHOD is set to $POSTGRES_HOST_AUTH_METHOD"
  PGDATA=${PGDATA:=/var/lib/pgsql/16/data/}
  echo "[12] ...done."
  return $EXIT_CODE_SUCCESS
}

# Creates the data directory with proper ownership and permissions if
# it does not already exist.
#
# Arguments: None
#
# Returns:
# 0 EXIT_CODE_SUCCESS if the data directory is created successfully
# 3 EXIT_CODE_ERROR_COULD_NOT_CREATE_PGDATA if the data directory could not be created
# 4 EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_OWNERSHIP if the ownership of the data directory could not be changed
# 5 EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_PERMISSIONS if the permissions of the data directory could not be changed
function create_data_directory() {
  if [[ -d "$PGDATA" ]]; then
    echo "[13] Data directory '$PGDATA' already exists... skipping data directory creation"
    return $EXIT_CODE_SUCCESS
  else 
    echo "[13] Creating the data directory $PGDATA"
    mkdir -p "$PGDATA"
    if [ $? -ne 0 ]; then
      echo "[13] ERROR($EXIT_CODE_ERROR_COULD_NOT_CREATE_PGDATA) Could not create the data directory $PGDATA"
      return $EXIT_CODE_ERROR_COULD_NOT_CREATE_PGDATA
    fi
    # Change the ownership and permissions of the data directory
    # The directory should be owned by the postgres user and
    # accessible only to the owner $POSTGRES_USER for reading,
    # writing, and executing.
    chown $POSTGRES_USER:$POSTGRES_USER "$PGDATA"
    if [[ $? -ne 0 ]]; then
      echo "[13] ERROR($EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_OWNERSHIP): Could not change ownership of data directory $PGDATA to $POSTGRES_USER:$POSTGRES_USER"
      return $EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_OWNERSHIP
    fi
    chmod 00700 "$PGDATA"
    if [[ $? -ne 0 ]]; then
      echo "[13] ERROR($EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_PERMISSIONS): Could not change permissions of data directory $PGDATA to 00700"
      return $EXIT_CODE_ERROR_COULD_NOT_CHANGE_PGDATA_PERMISSIONS
    fi
  fi
  echo "[13] ...done."
  return $EXIT_CODE_SUCCESS
}

# Creates the write-ahead log directory with proper ownership and permissions
# if it does not already exist.
#
# Arguments: None
#
# Returns:
# 0 EXIT_CODE_SUCCESS if the write-ahead log directory is created successfully
# 6 EXIT_CODE_ERROR_COULD_NOT_CREATE_POSTGRES_INITDB_WALDIR if the
#   write-ahead log directory could not be created
# 7 EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_OWNERSHIP if the
#   ownership of the write-ahead log directory could not be changed
# 8 EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_PERMISSIONS if the
#   permissions of the write-ahead log directory could not be changed
function create_write_ahread_log_directory() {
  if [[ -z "$POSTGRES_INITDB_WALDIR" ]]; then
    echo "[14] Write-ahead log(WAL) directory not specified... skipping WAL directory creation"
    return $EXIT_CODE_SUCCESS
  fi
  if [[ -d "$POSTGRES_INITDB_WALDIR" ]]; then
    echo "[14] Write-ahead log(WAL) directory $POSTGRES_INITDB_WALDIR already exists... skipping WAL directory creation"
    return $EXIT_CODE_SUCCESS
  fi
  echo "[14] Creating the write-ahead log directory..."
  mkdir -p "$POSTGRES_INITDB_WALDIR"
  if [[ $? -ne 0 ]]; then
    echo "[14] ERROR($EXIT_CODE_ERROR_COULD_NOT_CREATE_POSTGRES_INITDB_WALDIR): Could not create the write-ahead log directory $POSTGRES_INITDB_WALDIR"
    return $EXIT_CODE_ERROR_COULD_NOT_CREATE_POSTGRES_INITDB_WALDIR
  fi
  chown -R $POSTGRES_USER:$POSTGRES_USER "$POSTGRES_INITDB_WALDIR"
  if [[ $? -ne 0 ]]; then
    echo "[14] ERROR($EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_OWNERSHIP): Could not change ownership of the write-ahead log directory $POSTGRES_INITDB_WALDIR to $POSTGRES_USER:$POSTGRES_USER"
    return $EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_OWNERSHIP
  fi

  chmod 00700 "$POSTGRES_INITDB_WALDIR"
  if [[ $? -ne 0 ]]; then
    echo "[14] ERROR($EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_PERMISSIONS): Could not change permissions of the write-ahead log directory $POSTGRES_INITDB_WALDIR to 00700"
    return $EXIT_CODE_ERROR_COULD_NOT_CHANGE_POSTGRES_INITDB_WALDIR_PERMISSIONS
  fi

  echo "[14] ...done."
  return $EXIT_CODE_SUCCESS
}

# Initializes the database if it is not already initialized.
#
# Arguments: None
#
# Returns:
# 0 EXIT_CODE_SUCCESS if the database is initialized successfully
# 9 EXIT_CODE_ERROR_COULD_NOT_INITIALIZE_DATABASE if the database could not be initialized
function initialize_database() {
  if [[ ! -z "$(ls -A $PGDATA)" ]]; then
    echo "[15] Data directory $PGDATA is not empty... skipping database initialization"
    return $EXIT_CODE_SUCCESS
  fi

  GOSU_BINARY=$(command -v gosu)
  if [[ $? -ne 0 ]]; then
    echo "[15] ERROR($EXIT_CODE_ERROR_GOSU_NOT_FOUND): Could not find the gosu command. Please install gosu."
    return $EXIT_CODE_ERROR_GOSU_NOT_FOUND
  fi
  echo "[15] Found gosu at $GOSU_BINARY"

  echo "[15] Initializing the database..."
  $GOSU_BINARY $POSTGRES_USER initialize-postgres.sh
  if [[ $? -ne 0 ]]; then
    SECONDARY_EXIT_CODE=$?
    RETURN_CODE="${EXIT_CODE_ERROR_COULD_NOT_INITIALIZE_DATABASE}${SECONDARY_EXIT_CODE}"
    echo "[15] ERROR($RETURN_CODE): Could not initialize the database"
    return $RETURN_CODE
  fi
  echo "[5] ...done."
  return $EXIT_CODE_SUCCESS
}

# Sets up Postgres by creating necessary directories, and initializing the database.
#
# Arguments: None
#
# Returns: Returns 0 if Postgres is set up successfully,
#          a non-zero an error code if an error occurs. See Error
#          codes above for the full list of possible exit codes.
function setup_postgres() {
  echo "[1] Setting up Postgres..."
  check_required_variables || return $? # [1] Check required variables
  initialize_optional_variables || return $? # [2] Initialize optional variables
  create_data_directory || return $? # [3] Create the data directory
  create_write_ahread_log_directory || return $? # [4] Create the WAL directory
  initialize_database || return $? # [5] Initialize the database
  echo "[1] ...finished setting up Postgres"
  return $EXIT_CODE_SUCCESS
}

# Run the Postgres server.
#
# Arguments: None
#
# Returns: 0 always (currently.) In future it will
#          return a modified version of the exit code of the
#          postgres server. It will be prepended with
#          EXIT_CODE_ERROR_POSTGRES_SERVER_ERROR.
#          For example, if the postgres server exits with
#          exit code 1, this function will return 21.
function run_postgres() {
  echo "[2] Running the postgres server..."
  # Start the postgres server. We do not use exec here,
  # so that the script can examine the the exit code of the
  # postgres server.
  # gosu $POSTGRES_USER postgres -D $PGDATA
  echo "[2] gosu $POSTGRES_USER postgres -D $PGDATA"
  # gosu $POSTGRES_USER postgres -D $PGDATA
  if [[ $? -ne 0 ]]; then
    POSTGRES_SERVER_ERROR=$?
    RETURN_CODE="${EXIT_CODE_ERROR_POSTGRES_SERVER_ERROR}$POSTGRES_SERVER_ERROR"
    echo "[2] ERROR($RETURN_CODE): Postgres server exited with a non-zero exit code. $POSTGRES_SERVER_ERROR"
    return $RETURN_CODE
  fi
  echo "[2] ...Postgres exited normally."
  return $EXIT_CODE_SUCCESS
}

function main() {
  setup_postgres || return $?
  run_postgres || return $?
}

main
