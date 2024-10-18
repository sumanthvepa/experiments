#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# initialize-postgres.sh: Initialize the Postgres database in a
# container
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

# Initialize the Postgres database in a container
# This script is intended to be called from setup-postgres.sh and
# should be run as the postgres user.

# Set the location of the Postgres distribution directory
POSTGRES_DIST_DIR="/usr/pgsql-16"

# Exit codes
EXIT_CODE_SUCCESS=0
EXIT_CODE_ERROR_INITDB_COMMAND_FAILED=1
EXIT_CODE_ERROR_PG_CTL_START_COMMAND_FAILED=2
EXIT_CODE_ERROR_PG_CTL_STOP_COMMAND_FAILED=3
EXIT_CODE_ERROR_POSTGRES_USER_EMPTY=4
EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY=5
EXIT_CODE_ERROR_POSTGRES_DB_EMPTY=6
EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY=7
EXIT_CODE_ERROR_PGDATA_EMPTY=8
EXIT_CODE_ERROR_NOT_POSTGRES_USER=9
EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY=10
EXIT_CODE_ERROR_POSTGRES_INITDB_ARGS_NOT_SET=11
EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET=12
EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND=13
EXIT_CODE_ERROR_COULD_NOT_BACKUP_PG_HBA_CONF=14
EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF=15

# Check if the required variables are set
# 
# This script expect the following environment variables to be set:
#  POSTGRES_USER: The user to run the Postgres server as
#  POSTGRES_PASSWORD: The password for the Postgres user
#  POSTGRES_DB: The name of the database to create
#  POSTGRES_HOST_AUTH_METHOD: The host-based authentication method
#  PGDATA: The directory to store the Postgres data
#  POSTGRES_INITDB_ARGS: The arguments to pass to the init or the empty string if no arguments are needed
#  POSTGRES_INITDB_WALDIR: The directory to store the write-ahead logs or the empty string if no directory is needed
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if all required variables are set
#   EXIT_CODE_ERROR_POSTGRES_USER_EMPTY(2) if POSTGRES_USER is not set
#   EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY(3) if POSTGRES_PASSWORD is not set
#   EXIT_CODE_ERROR_POSTGRES_DB_EMPTY(4) if POSTGRES_DB is not set
#   EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY(5) if POSTGRES_HOST_AUTH_METHOD is not set
#   EXIT_CODE_ERROR_PGDATA_EMPTY(6) if PGDATA is not set
#   EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY(8) if PGDATA is not a directory
#   EXIT_CODE_ERROR_POSTGRES_INITDB_ARGS_NOT_SET(9) if POSTGRES_INITDB_ARGS is not set
#   EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET(10) if POSTGRES_INITDB_WALDIR is not set
function check_required_variables() {
  echo "[151] Checking required variables..."
  if [[ -z "$POSTGRES_USER" ]]; then
    echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_USER_EMPTY): The POSTGRES_USER environment variable is must be set to a non-empty user"
    return $EXIT_CODE_ERROR_POSTGRES_USER_NOT_SET
  fi
  echo "[151] POSTGRES_USER=$POSTGRES_USER"

  if [[ -z "$POSTGRES_PASSWORD" ]]; then
    echo "[1511] ERROR($EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY): The POSTGRES_PASSWORD environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY
  fi
  # TODO: Do not print the password
  echo "[151] POSTGRES_PASSWORD=$POSTGRES_PASSWORD"

  if [[ -z "$POSTGRES_DB" ]]; then
    echo "[1] ERROR($EXIT_CODE_ERROR_POSTGRES_DB_EMPTY): The POSTGRES_DB environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_DB_EMPTY
  fi
  echo "[151] POSTGRES_DB=$POSTGRES_DB"

  if [[ -z "$POSTGRES_HOST_AUTH_METHOD" ]]; then
    echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY): The POSTGRES_HOST_AUTH_METHOD environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY
  fi
  echo "[151] POSTGRES_HOST_AUTH_METHOD=$POSTGRES_HOST_AUTH_METHOD"

  if [[ -z "$PGDATA" ]]; then
    echo "[151] ERROR($EXIT_CODE_ERROR_PGDATA_EMPTY): The PGDATA environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_PGDATA_EMPTY
  fi

  if [[ ! -d "$PGDATA" ]]; then
    echo "[151] ERROR($EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY): The PGDATA environment variable is must be set to an existing directory"
    return $EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY
  fi
  echo "[151] PGDATA=$PGDATA"

  if [[ ! -v POSTGRES_INITDB_ARGS ]]; then
    echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_INITDB_ARGS_NOT_SET): The POSTGRES_INITDB_ARGS environment variable, if set, must set"
    return $EXIT_CODE_ERROR_POSTGRES_INITDB_ARS_NOT_SET
  fi
  echo "[151] POSTGRES_INITDB_ARGS=$POSTGRES_INITDB_ARGS"

  if [[ ! -v POSTGRES_INITDB_WALDIR ]]; then
    echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET): The POSTGRES_INITDB_WALDIR environment variable is must be set"
    return $EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET
  fi
  echo "[151] POSTGRES_INITDB_WALDIR=$POSTGRES_INITDB_WALDIR"

  echo "[151] ...done."
  return $EXIT_CODE_SUCCESS
}

# Verify that the script is being run as the postgres user
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the script is being run as the postgres user
#   EXIT_CODE_ERROR_NOT_POSTGRES_USER(7) if the script is not being run as the postgres user
function verify_postgres_user() {
  # Check that the script is being run as the postgres user
  if [[ "$(whoami)" != "$POSTGRES_USER" ]]; then
    echo "[152] ERROR($EXIT_CODE_ERROR_NOT_POSTGRES_USER): This script must be run as user $POSTGRES_USER"
    return $EXIT_CODE_ERROR_NOT_POSTGRES_USER
  fi
  echo "[152] Okay. Running as user $POSTGRES_USER"
}

# Generate the initdb command to initialize the database
#
# Use this function as follows:
# local initdb_command=$(generate_initdb_command)
# eval "$initdb_command"
# The command string should be passed to eval rather than run directly,
# as shown above.
#
# Arguments: None
# Returns: EXIT_CODE_SUCCESS(0)
#          The initdb command to initialize the database is generated
#          and printed to standard output which can be captured by the
#          caller.
function generate_initdb_command() {
  local initdb_dir="$POSTGRES_DIST_DIR/bin"
  local initdb_command="initdb "
  local initdb_parameters="--username=$POSTGRES_USER"
  initdb_parameters="$initdb_parameters --pwfile=<(printf \"%s\\n\" \"$POSTGRES_PASSWORD\")" 
  initdb_parameters="$initdb_parameters --auth=$POSTGRES_HOST_AUTH_METHOD"
  if [[ ! -z "$POSTGRES_WALDIR" ]]; then
    initdb_parameters="$initdb_parameters --waldir=$POSTGRES_WALDIR"
  fi
  initdb_parameters="$initdb_parameters -D $PGDATA"
  initdb_parameters="$initdb_parameters $POSTGRES_INITDB_ARGS"
  echo "${initdb_dir}/$initdb_command $initdb_parameters"
}

# Run the initdb command to initialize the database
#
# Arguments: $1: The initdb command string to run
# Returns:
#   EXIT_CODE_SUCCESS(0) if the initdb command is run successfully
#   EXIT_CODE_ERROR_INITDB_COMMAND_FAILED(1) if the initdb command fails
#   with the error code returned by initdb appended to the return code.
#   For example, if the initdb command fails with error code 1, the
#   return code will be 11.
function run_initdb_command() {
  local initdb_command=$1
  echo "[154] Running initdb command... "
  echo "[154] command: $initdb_command"
  # The use of eval is necessary to expand the command string twice
  # to get the correct command. This first expansion is done by the
  # this shell script, and the second expansion is done by eval.
  # This allows the phrase --pwfile=<(printf "%s\n" "$POSTGRES_PASSWORD")
  # to be expanded to --pwfile=<(printf "%s\n" "postgres") in the
  # first expansion and then in the second expansion, the redirection
  # from standard out is done.
  eval "$initdb_command"
  local initdb_error_code=$?
  if [[ $initdb_error_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_INITDB_COMMAND_FAILED}$initdb_error_code"
    echo "[154] ERROR($return_code): Initdb command failed: $initdb_error_code"
    return $return_code
  fi
  echo "[154] ...done."
}

# Configure host-based authentication
#
# Adds the following line to the host-based authentication file:
# host all all all $POSTGRES_HOST_AUTH_METHOD
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the host-based authentication is configured
#   EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND(11) if the host-based
#   authentication file is not found
#   EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF(12) if the host-based
#   authentication file could not be updated
function configure_host_based_authentication() {
  local hba_file="${PGDATA}pg_hba.conf"
  local hba_file_backup="$PGDATA/pg_hba.conf.bak"
  echo "[155] Configuring host-based authentication..."
  if [[ ! -f "$hba_file" ]]; then
    echo "[155] ERROR($EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND): Host-based authentication file $hba_file does not exist or is not a file"
    return $EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND
  fi
  # Make a backup of the host-based authentication file
  cp "$hba_file" "$hba_file_backup"
  if [[ $? -ne 0 ]]; then
    echo "[155] ERROR($EXIT_CODE_ERROR_COULD_NOT_BACKUP_PG_HBA_CONF): Could not backup the host-based authentication file $hba_file"
    return $EXIT_CODE_ERROR_COULD_NOT_BACKUP_PG_HBA_CONF
  fi

  # Add the following line to the host-based authentication file
  # host all all all $POSTGRES_HOST_AUTH_METHOD
  echo "host all all all $POSTGRES_HOST_AUTH_METHOD" >> "$hba_file"
  if [[ $? -ne 0 ]]; then
    echo "[155] ERROR($EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF): Could not update the host-based authentication file $hba_file"
    return $EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF
  fi
  echo "[155] ...done."
}

# Start a temporary server
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the temporary server is started successfully
#   TBD: if the temporary server fails to start
function start_temporary_server() {
  echo "[1561] Starting a temporary server..."
  # Start the temporary server
  # Specify the data directory
  local pg_ctl_parameters="-D $PGDATA"
  # Do not listen on any IP addresses, only on the local socket
  pg_ctl_parameters="$pg_ctl_parameters --options \"-c listen_addresses='' -p 5432\""
  # Write the activity to the log file
  pg_ctl_parameters="$pg_ctl_parameters --log \"${PGDATA}logfile\""
  # Wait for the server to start before returning control to the shell
  pg_ctl_parameters="$pg_ctl_parameters --wait"
  local pg_ctl_binary="$POSTGRES_DIST_DIR/bin/pg_ctl"
  local pg_ctl_command="PGUSER=\"$POSTGRES_USER\" $pg_ctl_binary $pg_ctl_parameters start"
  echo "[1561] Running pg_ctl command..."
  echo "[1561] command: $pg_ctl_command"
  eval $pg_ctl_command
  local pg_ctl_error_code=$?
  if [[ $pg_ctl_error_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_PG_CTL_START_COMMAND_FAILED}$pg_ctl_error_code"
    echo "[1561] ERROR($return_code): Failed to start the temporary server"
    return $return_code
  fi
  echo "[1561] ...done."
  return $EXIT_CODE_SUCCESS
}

# Create the initial database
#
# Arguments: None
# Returns:
#  EXIT_CODE_SUCCESS(0) if the initial database is created successfully
#  TBD: if the initial database creation fails
function create_initial_database() {
  echo "[1562] Creating an initial database..."
  # Create the initial database
  #psql -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $POSTGRES_DB"
  #if [[ $? -ne 0 ]]; then
  #  echo "[154] ERROR: Failed to create the initial database"
  #  return $?
  #fi
  echo "[1562] ...done."
  return $EXIT_CODE_SUCCESS
}

# Run the initial SQL scripts
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the initial SQL scripts are run successfully
#   TBD: if the initial SQL scripts fail to run
function run_initial_sql_scripts() {
  echo "[1563] Running initial SQL scripts..."
  # Run the initial SQL scripts
  #psql -U $POSTGRES_USER -d $POSTGRES_DB -f /path/to/initial.sql
  #if [[ $? -ne 0 ]]; then
  #  echo "[154] ERROR: Failed to run the initial SQL scripts"
  #  return $?
  #fi
  echo "[1563] ...done."
  return $EXIT_CODE_SUCCESS
}

# Stop the temporary server
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the temporary server is stopped successfully
#   TBD: if the temporary server fails to stop
function stop_temporary_server() {
  echo "[1564] Stopping the temporary server..."
  # Specify the data directory, the shutdown mode (fast is the default,
  # but we specify it anyway), and wait for the server to stop before
  # returning control to the shell
  local pg_ctl_parameters="-D "$PGDATA" -m fast --wait"
  local pg_ctl_binary="$POSTGRES_DIST_DIR/bin/pg_ctl"
  local pg_ctl_command="PGUSER=\"$POSTGRES_USER\" $pg_ctl_binary $pg_ctl_parameters stop"
  echo "[1564] Running pg_ctl command..."
  echo "[1565] command: $pg_ctl_command"
  eval $pg_ctl_command
  local pg_ctl_error_code=$?
  if [[ $pg_ctl_error_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_PG_CTL_STOP_COMMAND_FAILED}$pg_ctl_error_code"
    echo "[1564] ERROR($return_code): Failed to stop the temporary server"
    return $return_code
  fi
  echo "[1564] ...done."
  return $EXIT_CODE_SUCCESS
}

function configure_database() {
  echo "[156] Configuring the database..."
  start_temporary_server || return $? # Exit if error starting temporary server
  create_initial_database || return $? # Exit if error creating initial database
  run_initial_sql_scripts || return $? # Exit if error running initial SQL scripts
  stop_temporary_server || return $? # Exit if error stopping temporary server
  echo "[156] ...done."
  return $EXIT_CODE_SUCCESS
}

function initialize_database() {
  check_required_variables || return $? # Exit if required variables are not set
  verify_postgres_user || return $? # Exit if not postgres user
  local initdb_command=$(generate_initdb_command)
  run_initdb_command "$initdb_command" || return $? # Exit if error running initdb command  
  configure_host_based_authentication || return $? # Exit if error configuring host-based authentication
  configure_database || return $? # Exit if error configuring database
}

function main() {
  initialize_database || return $? # Exit if error initializing database
  return $EXIT_CODE_SUCCESS
}

main
