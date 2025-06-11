#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# setup-postgres.sh: Initialization and startup script for Postgres
# within a container.
#
# Copyright (C) 2024-25 Sumanth Vepa.
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
# This script is intended to be run within the container running the
# postgres-manual image. It needs to be run manually by a user logging
# into the container.

# This script replicates most of the capabilities of the official
# postgres docker image. It is intended to be an intermediate
# experimental container to help me learn how to create a proper
# docker entrypoint file for an functional postgres container.

# Some things that are functionally different from the official
# postgres docker image:
#  - This script does not support _FILE environment variables for
#    setting the password and other environment variables. That
#    feature is not implemented here.

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
EXIT_CODE_ERROR_BASH_ERROR=12

# Prints a message to the console if the DOCKER_POSTGRES_DEBUG environment
# variable is set to 1.
#
# Arguments: $@ The message to print to the console
# Returns: None
function debug_echo() {
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    echo "$@"
  fi
}

# Checks if the user is asking for help
#
# Arguments: $@ The command line arguments passed to the script
# Returns:
#  0 if the user is not asking for help
#  1 if the user is asking for help
function is_asking_for_help() {
  if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "-?" ]]; then
    return 1
  fi
  return 0
}

# Checks if the user is asking for the version of the postgres server
#
# Arguments: $@ The command line arguments passed to the script
# Returns:
#  0 if the user is not asking for the version
#  1 if the user is asking for the version
function is_asking_for_version() {
 for arg; do
   if [[ "$arg" == "--version" ]]; then
     return 1
   fi
   if [[ "$arg" == "-V" ]]; then
     return 1
   fi
 done
 return 0
}

# Checks if the user is asking for the configuration of the postgres server
#
# Arguments: $@ The command line arguments passed to the script
# Returns:
#  0 if the user is not asking for the configuration
#  1 if the user is asking for the configuration
function is_asking_for_config() {
 for arg; do
   if [[ "$arg" == "--describe-config" ]]; then
     return 1
   fi
 done
 return 0
}


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
  debug_echo "[11] Checking required variables..."
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
  debug_echo "[11] POSTGRES_PASSWORD is set to $POSTGRES_PASSWORD"
  debug_echo "[11] ...done."
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
  debug_echo "[12] Initializing optional variables..."
  # Set the variables needed for the script to default values
  # if they are not already set.
  DOCKER_POSTGRES_DEBUG=${DOCKER_POSTGRES_DEBUG:=0}
  debug_echo "[12] DOCKER_POSTGRES_DEBUG is set to $DOCKER_POSTGRES_DEBUG"
  POSTGRES_DIST_DIR=${POSTGRES_DIST_DIR:="/usr/pgsql-16"}
  debug_echo "[12] POSTGRES_DIST_DIR is set to $POSTGRES_DIST_DIR"
  POSTGRES_USER=${POSTGRES_USER:=postgres}
  debug_echo "[12] POSTGRES_USER is set to $POSTGRES_USER"
  # Default name of db to postgres user
  POSTGRES_DB=${POSTGRES_DB:=$POSTGRES_USER}
  debug_echo "[12] POSTGRES_DB is set to $POSTGRES_DB"
  POSTGRES_INITDB_ARGS=${POSTGRES_INITDB_ARGS:=}
  debug_echo "[12] POSTGRES_INITDB_ARGS is set to $POSTGRES_INITDB_ARGS"
  POSTGRES_INITDB_WALDIR=${POSTGRES_INITDB_WALDIR:=}
  debug_echo "[12] POSTGRES_INITDB_WALDIR is set to $POSTGRES_INITDB_WALDIR"
  POSTGRES_HOST_AUTH_METHOD=${POSTGRES_HOST_AUTH_METHOD:="scram-sha-256"}
  debug_echo "[12] POSTGRES_HOST_AUTH_METHOD is set to $POSTGRES_HOST_AUTH_METHOD"
  PGDATA=${PGDATA:=/var/lib/pgsql/16/data/}
  debug_echo "[12] PGDATA is set to $PGDATA"
  debug_echo "[12] ...done."
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
    debug_echo "[13] Data directory '$PGDATA' already exists... skipping data directory creation"
    return $EXIT_CODE_SUCCESS
  else 
    debug_echo "[13] Creating the data directory $PGDATA"
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
  debug_echo "[13] ...done."
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
    debug_echo "[14] Write-ahead log(WAL) directory not specified... skipping WAL directory creation"
    return $EXIT_CODE_SUCCESS
  fi
  if [[ -d "$POSTGRES_INITDB_WALDIR" ]]; then
    debug_echo "[14] Write-ahead log(WAL) directory $POSTGRES_INITDB_WALDIR already exists... skipping WAL directory creation"
    return $EXIT_CODE_SUCCESS
  fi
  debug_echo "[14] Creating the write-ahead log directory..."
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

  debug_echo "[14] ...done."
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
  local postgres_flags="$@"

  if [[ ! -z "$(ls -A $PGDATA)" ]]; then
    debug_echo "[15] Data directory $PGDATA is not empty... skipping database initialization"
    return $EXIT_CODE_SUCCESS
  fi

  GOSU_BINARY=$(command -v gosu)
  if [[ $? -ne 0 ]]; then
    echo "[15] ERROR($EXIT_CODE_ERROR_GOSU_NOT_FOUND): Could not find the gosu command. Please install gosu."
    return $EXIT_CODE_ERROR_GOSU_NOT_FOUND
  fi
  debug_echo "[15] Found gosu at $GOSU_BINARY"

  debug_echo "[15] Initializing the database..."

  DOCKER_POSTGRES_DEBUG=$DOCKER_POSTGRES_DEBUG \
  POSTGRES_DIST_DIR=$POSTGRES_DIST_DIR \
  POSTGRES_USER=$POSTGRES_USER \
  POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  POSTGRES_DB=$POSTGRES_DB \
  POSTGRES_INITDB_ARGS=$POSTGRES_INITDB_ARGS \
  POSTGRES_INITDB_WALDIR=$POSTGRES_INITDB_WALDIR \
  POSTGRES_HOST_AUTH_METHOD=$POSTGRES_HOST_AUTH_METHOD \
  PGDATA=$PGDATA \
       $GOSU_BINARY $POSTGRES_USER initialize-postgres.sh $postgres_flags
  local secondary_exit_code=$?
  if [[ $secondary_exit_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_COULD_NOT_INITIALIZE_DATABASE}${secondary_exit_code}"
    echo "[15] ERROR($return_code): Could not initialize the database"
    return $return_code
  fi
  debug_echo "[15] ...done."
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
  local postgres_flags="$@"
  debug_echo "[1] Setting up Postgres..."
  debug_echo "[1] DEBUG: postgres_flags: $postgres_flags"

  # Initialize required and optional variables
  check_required_variables || return $?
  initialize_optional_variables || return $?
  
  # Only do setup if the user is not asking for the version,
  # otherwise, just return. No setup is needed.
  is_asking_for_version $postgres_flags
  local wants_version=$?
  debug_echo "[1] DEBUG: wants_version: $wants_version"
  if [[ $wants_version -eq 1 ]]; then
    return $EXIT_CODE_SUCCESS
  fi

  create_data_directory || return $? # [3] Create the data directory
  create_write_ahread_log_directory || return $? # [4] Create the WAL directory

  # If the user is asking for the configuration,
  # remove the --describe-config option before passing the rest of
  # the arguments to the postgres_config function. The describe-config
  # option will interfere with the initialization of the database.
  is_asking_for_config $postgres_flags
  local wants_config=$?
  debug_echo "[1] DEBUG: wants_config: $wants_config"
  if [[ $wants_config -eq 1 ]]; then
    local filtered_args=()
    for arg in $postgres_flags; do
      if [[ "$arg" != "--describe-config" ]]; then
        filtered_args+=("$arg")
      fi
    done
    postgres_flags="${filtered_args[@]}"
  fi
  initialize_database $postgres_flags || return $?
  debug_echo "[1] ...finished setting up Postgres"
  return $EXIT_CODE_SUCCESS
}

# Run bash
#
# Arguments: None
# Returns: If successful the function does not return. If an error
#          occurs, the function returns EXIT_CODE_ERROR_BASH_ERROR
function run_bash() {
  debug_echo "[2] Running bash..."
  /bin/bash
  if [[ $? -ne 0 ]]; then
    echo "[2] ERROR($EXIT_CODE_ERROR_BASH_ERROR): Could not run bash"
    return $EXIT_CODE_ERROR_BASH_ERROR
  fi
}

# Run the Postgres server.
#
# Arguments: None
#
# Returns: If successful the function does not return. If an error
#          occurs, the function returns an error code.
function run_postgres() {
  local postgres_flags="$@"
  local postgres_binary=$POSTGRES_DIST_DIR/bin/postgres
  local postgres_parameters=""
  debug_echo "[2] Running the postgres server..."

  # Only pass the -D flag if the user is not asking for the version
  # or the configuration.
  is_asking_for_version $postgres_flags
  local wants_version=$?
  debug_echo "[2] DEBUG: wants_version: $wants_version"
  is_asking_for_config $postgres_flags
  local wants_config=$?
  debug_echo "[2] DEBUG: wants_config: $wants_config"
  if [[ $wants_version -eq 1 || $wants_config -eq 1 ]]; then
    postgres_parameters="$postgres_flags"
  else
    postgres_parameters="-D $PGDATA $postgres_flags"
  fi

  # Start the postgres server. We do not use exec here,
  # so that the script can examine the the exit code of the
  # postgres server.  
  local postgres_command="gosu $POSTGRES_USER $postgres_binary $postgres_parameters"
  debug_echo "[2] postgres command: $postgres_command"
  eval $postgres_command
  local postgres_server_error=$?
  if [[ $postgres_server_error -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_POSTGRES_SERVER_ERROR}$postgres_server_error"
    echo "[2] ERROR($return_code): Postgres server exited with a non-zero exit code. $postgres_server_error"
    return $return_code
  fi
  #echo "[2] ...Postgres exited normally."
  #return $EXIT_CODE_SUCCESS
}

function print_usage() {
  echo "Usage: setup-postgres.sh [OPTIONS] [bash| postgres]"
  echo "Options:"
  echo "  -h, --help: Print this help message"
  echo "bash: Initialize postgres, but do not start the server. Instead, run bash"
  echo "postgres: Run the postgres server. This is the default if no arguments are passed"
}

function main() {
  debug_echo [0] "Starting the setup-postgres script..."
  # If the user is asking for help, print the usage message and exit
  is_asking_for_help $@
  if [[ $? -eq 1 ]]; then
    print_usage
    return $EXIT_CODE_SUCCESS
  fi

  # If the user specifies 'bash', then just setup the postgres
  # server and run bash. Do not pass any command line arguments
  # to the setup function.
  if [[ "$1" == "bash" ]]; then
    setup_postgres || return $?
    run_bash $@ || return $?
    return $EXIT_CODE_SUCCESS
  fi

  # If the first argument seems like an option, then set
  # the postgres_flags variable to the command line arguments.
  # These will be treated as flags to the postgres server.
  local postgres_flags=""
  if [[ ${1:0:1} == "-" ]]; then
    postgres_flags="$@"
  fi

  # Otherwise, just pass all the arguments to the setup function
  # and run the postgres server with the same arguments.
  setup_postgres $postgres_flags || return $?
  run_postgres $postgres_flags || return $?
  debug_echo "[0] ...finished running the setup-postgres script."
  return $EXIT_CODE_SUCCESS
}

main "$@"
