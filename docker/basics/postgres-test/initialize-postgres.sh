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

# Exit codes
EXIT_CODE_SUCCESS=0
EXIT_CODE_ERROR_INITDB_COMMAND_FAILED=1
EXIT_CODE_ERROR_PG_CTL_START_COMMAND_FAILED=2
EXIT_CODE_ERROR_PG_CTL_STOP_COMMAND_FAILED=3
EXIT_CODE_ERROR_DOCKER_POSTGRES_DEBUG_EMPTY=4
EXIT_CODE_ERROR_POSTGRES_DIST_DIR_EMPTY=5
EXIT_CODE_ERROR_POSTGRES_USER_EMPTY=6
EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY=7
EXIT_CODE_ERROR_POSTGRES_DB_EMPTY=8
EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY=9
EXIT_CODE_ERROR_PGDATA_EMPTY=10
EXIT_CODE_ERROR_NOT_POSTGRES_USER=11
EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY=12
EXIT_CODE_ERROR_POSTGRES_CONF_NOT_FOUND=13
EXIT_CODE_ERROR_COULD_NOT_UPDATE_POSTGRES_CONF=14
EXIT_CODE_ERROR_POSTGRES_INITDB_ARGS_NOT_SET=15
EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET=16
EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND=17
EXIT_CODE_ERROR_COULD_NOT_BACKUP_PG_HBA_CONF=18
EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF=19
EXIT_CODE_ERROR_DATABASE_ALREADY_EXISTS=20
EXIT_CODE_ERROR_COULD_NOT_CREATE_DATABASE=21
EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED=22

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

# Check if the required variables are set
# 
# This script expects the following environment variables to be set:
#  POSTGRES_DIST_DIR: The location of the postgres distribution
#  POSTGRES_USER: The user to run the Postgres server as
#  POSTGRES_PASSWORD: The password for the Postgres user
#  POSTGRES_DB: The name of the database to create
#  POSTGRES_HOST_AUTH_METHOD: The host-based authentication method
#  PGDATA: The directory to store the Postgres data
#  POSTGRES_INITDB_ARGS: The arguments to pass to the init or the empty string if no arguments are needed
#  POSTGRES_INITDB_WALDIR: The directory to store the write-ahead logs or the empty string if no directory is needed
#  These environment variables are expected to be set by the calling
#  script (setup-postgres.sh) before this script is called.
#  We use this technique to ensure that default values for these
#  variables are set on exactly one place.(i.e. in DRY fashion)
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if all required variables are set
#   EXIT_CODE_ERROR_POSTGRES_DIST_DIR_EMPTY if POSTGRES_DIST_DIR is not set
#   EXIT_CODE_ERROR_POSTGRES_USER_EMPTY if POSTGRES_USER is not set
#   EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY if POSTGRES_PASSWORD is not set
#   EXIT_CODE_ERROR_POSTGRES_DB_EMPTY if POSTGRES_DB is not set
#   EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY if POSTGRES_HOST_AUTH_METHOD is not set
#   EXIT_CODE_ERROR_PGDATA_EMPTY if PGDATA is not set
#   EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY if PGDATA is not a directory
#   EXIT_CODE_ERROR_POSTGRES_INITDB_ARGS_NOT_SET if POSTGRES_INITDB_ARGS is not set
#   EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET if POSTGRES_INITDB_WALDIR is not set
function check_required_variables() {
  debug_echo "[151] Checking required variables..."
  if [[ -z "DOCKER_POSTGRES_DEBUG" ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_DOCKER_POSTGRES_DEBUG_EMPTY): The DOCKER_POSTGRES_DEBUG environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_DOCKER_POSTGRES_DEBUG_EMPTY
  fi
  if [[ -z "POSTGRES_DIST_DIR" ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_DIST_DIR_EMPTY): The POSTGRES_DIST_DIR environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_DIST_DIR_EMPTY
  fi
  if [[ -z "$POSTGRES_USER" ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_USER_EMPTY): The POSTGRES_USER environment variable is must be set to a non-empty user"
    return $EXIT_CODE_ERROR_POSTGRES_USER_NOT_SET
  fi
  debug_echo "[151] POSTGRES_USER=$POSTGRES_USER"

  if [[ -z "$POSTGRES_PASSWORD" ]]; then
    debug_echo "[1511] ERROR($EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY): The POSTGRES_PASSWORD environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_PASSWORD_EMPTY
  fi
  # TODO: Do not print the password
  debug_echo "[151] POSTGRES_PASSWORD=$POSTGRES_PASSWORD"

  if [[ -z "$POSTGRES_DB" ]]; then
    debug_echo "[1] ERROR($EXIT_CODE_ERROR_POSTGRES_DB_EMPTY): The POSTGRES_DB environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_DB_EMPTY
  fi
  debug_echo "[151] POSTGRES_DB=$POSTGRES_DB"

  if [[ -z "$POSTGRES_HOST_AUTH_METHOD" ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY): The POSTGRES_HOST_AUTH_METHOD environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_POSTGRES_HOST_AUTH_METHOD_EMPTY
  fi
  debug_echo "[151] POSTGRES_HOST_AUTH_METHOD=$POSTGRES_HOST_AUTH_METHOD"

  if [[ -z "$PGDATA" ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_PGDATA_EMPTY): The PGDATA environment variable is must be set to a non-empty value"
    return $EXIT_CODE_ERROR_PGDATA_EMPTY
  fi

  if [[ ! -d "$PGDATA" ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY): The PGDATA environment variable is must be set to an existing directory"
    return $EXIT_CODE_ERROR_PGDATA_NOT_DIRECTORY
  fi
  debug_echo "[151] PGDATA=$PGDATA"

  if [[ ! -v POSTGRES_INITDB_ARGS ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_INITDB_ARGS_NOT_SET): The POSTGRES_INITDB_ARGS environment variable, if set, must set"
    return $EXIT_CODE_ERROR_POSTGRES_INITDB_ARS_NOT_SET
  fi
  debug_echo "[151] POSTGRES_INITDB_ARGS=$POSTGRES_INITDB_ARGS"

  if [[ ! -v POSTGRES_INITDB_WALDIR ]]; then
    debug_echo "[151] ERROR($EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET): The POSTGRES_INITDB_WALDIR environment variable is must be set"
    return $EXIT_CODE_ERROR_POSTGRES_INITDB_WALDIR_NOT_SET
  fi
  debug_echo "[151] POSTGRES_INITDB_WALDIR=$POSTGRES_INITDB_WALDIR"

  debug_echo "[151] ...done."
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
    debug_echo "[152] ERROR($EXIT_CODE_ERROR_NOT_POSTGRES_USER): This script must be run as user $POSTGRES_USER"
    return $EXIT_CODE_ERROR_NOT_POSTGRES_USER
  fi
  debug_echo "[152] Okay. Running as user $POSTGRES_USER"
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
  debug_echo "[154] Running initdb command... "
  debug_echo "[154] command: $initdb_command"
  # The use of eval is necessary to expand the command string twice
  # to get the correct command. This first expansion is done by the
  # this shell script, and the second expansion is done by eval.
  # This allows the phrase --pwfile=<(printf "%s\n" "$POSTGRES_PASSWORD")
  # to be expanded to --pwfile=<(printf "%s\n" "postgres") in the
  # first expansion and then in the second expansion, the redirection
  # from standard out is done.

  # Redirect the output of the initdb command to /dev/null if the
  # debug flag is not set. This is to prevent the output from being
  # displayed on the console under normal circumstances. (Normally
  # only the output of the final run of postgres server is displayed)
  # This allows the docker container to behave exactly as if it were
  # a postgres commmand issued from the command line of the host.

  local initdb_error_code=0
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval "$initdb_command"
    initdb_error_code=$?
  else
    eval "$initdb_command" > /dev/null
    initdb_error_code=$?
  fi
  if [[ $initdb_error_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_INITDB_COMMAND_FAILED}$initdb_error_code"
    debug_echo "[154] ERROR($return_code): Initdb command failed: $initdb_error_code"
    return $return_code
  fi
  debug_echo "[154] ...done."
}

# Configure listen addresses in the postgres configuration file
#
# Arguments: None
# Returns:
#  EXIT_CODE_SUCCESS(0) if the listen addresses are configured
#  EXIT_CODE_ERROR_POSTGRES_CONF_NOT_FOUND(12) if the postgres
#  configuration file is not found.
#  EXIT_CODE_ERROR_COULD_NOT_UPDATE_POSTGRES_CONF(13) if the
#  postgres configuration file could not be updated.
function configure_listen_addresses() {
  local postgres_conf_file="${PGDATA}postgresql.conf"
  local postgres_conf_file_backup="${PGDATA}postgresql.conf.bak"
  debug_echo "[155] Configuring listen addresses..."
  if [[ ! -f "$postgres_conf_file" ]]; then
    debug_echo "[155] ERROR($EXIT_CODE_ERROR_POSTGRES_CONF_NOT_FOUND): Postgres configuration file $postgres_conf_file does not exist or is not a file"
    return $EXIT_CODE_ERROR_POSTGRES_CONF_NOT_FOUND
  fi

  # Edit the postgres configuration file to uncomment
  # listen_addresses = 'localhost' and change it to
  # listen_addresses = '*'. We use sed for this.
  sed --in-place=".bak" "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$postgres_conf_file"
  if [[ $? -ne 0 ]]; then
    debug_echo "[155] ERROR($EXIT_CODE_ERROR_COULD_NOT_UPDATE_POSTGRES_CONF): Could not update the postgres configuration file $postgres_conf_file"
    return $EXIT_CODE_ERROR_COULD_NOT_UPDATE_POSTGRES_CONF
  fi
  debug_echo "[155] ...done."
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
  debug_echo "[156] Configuring host-based authentication..."
  if [[ ! -f "$hba_file" ]]; then
    debug_echo "[156] ERROR($EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND): Host-based authentication file $hba_file does not exist or is not a file"
    return $EXIT_CODE_ERROR_PG_HBA_CONF_NOT_FOUND
  fi
  # Make a backup of the host-based authentication file
  cp "$hba_file" "$hba_file_backup"
  if [[ $? -ne 0 ]]; then
    debug_echo "[156] ERROR($EXIT_CODE_ERROR_COULD_NOT_BACKUP_PG_HBA_CONF): Could not backup the host-based authentication file $hba_file"
    return $EXIT_CODE_ERROR_COULD_NOT_BACKUP_PG_HBA_CONF
  fi

  # Add the following line to the host-based authentication file
  # host all all all $POSTGRES_HOST_AUTH_METHOD
  echo "host all all all $POSTGRES_HOST_AUTH_METHOD" >> "$hba_file"
  if [[ $? -ne 0 ]]; then
    debug_echo "[156] ERROR($EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF): Could not update the host-based authentication file $hba_file"
    return $EXIT_CODE_ERROR_COULD_NOT_UPDATE_PG_HBA_CONF
  fi
  debug_echo "[156] ...done."
}

# Start a temporary server
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the temporary server is started successfully
#   TBD: if the temporary server fails to start
function start_temporary_server() {
  debug_echo "[1571] Starting a temporary server..."
  local postgres_flags="$@"
  # Start the temporary server
  # Specify the data directory
  local pg_ctl_parameters="-D $PGDATA"
  # Do not listen on any IP addresses, only on the local socket
  pg_ctl_parameters="$pg_ctl_parameters --options \"-c listen_addresses='' -p 5432\""
  # Append user specified postgres flags to the pg_ctl command if any
  if [[ ! -z "$postgres_flags" ]]; then
    pg_ctl_parameters="$pg_ctl_parameters --options \"$postgres_flags\""
  fi
  # Write the activity to the log file
  pg_ctl_parameters="$pg_ctl_parameters --log \"${PGDATA}logfile\""
  # Wait for the server to start before returning control to the shell
  pg_ctl_parameters="$pg_ctl_parameters --wait"
  local pg_ctl_binary="$POSTGRES_DIST_DIR/bin/pg_ctl"
  local pg_ctl_command="PGUSER=\"$POSTGRES_USER\" $pg_ctl_binary $pg_ctl_parameters start"
  debug_echo "[1571] Running pg_ctl command..."
  debug_echo "[1571] command: $pg_ctl_command"
  local pg_ctl_error_code=0
  # Redirect the output of the pg_ctl command to /dev/null if the
  # debug flag is not set. This is to prevent the output from being
  # displayed on the console under normal circumstances. (Normally
  # only the output of the final run of postgres server is displayed)
  # This allows the docker container to behave exactly as if it were
  # a postgres commmand issued from the command line of the host.
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $pg_ctl_command
    pg_ctl_error_code=$?
  else
    eval $pg_ctl_command > /dev/null
    pg_ctl_error_code=$?
  fi
  if [[ $pg_ctl_error_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_PG_CTL_START_COMMAND_FAILED}$pg_ctl_error_code"
    debug_echo "[1571] ERROR($return_code): Failed to start the temporary server"
    return $return_code
  fi
  debug_echo "[1571] ...done."
  return $EXIT_CODE_SUCCESS
}

# Check if a database exists
#
# Arguments: $1: The name of the database to check
# Returns:
#   EXIT_CODE_SUCCESS(0) if database does not exist
#   EXIT_CODE_ERROR_DATABASE_ALREADY_EXISTS(1) if the database already exists
function database_exists() {
  # [NOTE REFERENCE A] Note that the way quotes, single and double are used to
  # construct the final psql command is important. This is because the command
  # is a combination of shell input and SQL input. They have slightly
  # different quoting rules. In particular care must be taken to ensure that
  # the --command="sql" is encased in double quotes and column names in the SQL
  # are encased in single quotes. Care should be taken to ensure that the
  # interpolation process strips just the right amout of escaping.
  local dbname=$1
  local psql_binary="$POSTGRES_DIST_DIR/bin/psql"
  local psql_parameters="-v ON_ERROR_STOP=1 --no-psqlrc --username $POSTGRES_USER --dbname postgres --tuples-only"
  local sql="SELECT 1 FROM pg_database WHERE datname='$dbname'"
  local psql_command="PGUSER=\"$POSTGRES_USER\" PGPASSWORD=\"$POSTGRES_PASSWORD\" $psql_binary $psql_parameters --command \"$sql\""
  debug_echo "psql_command: $psql_command"
  local dbexists=$(eval $psql_command)
  if [[ $dbexists -eq 1 ]]; then
    return $EXIT_CODE_ERROR_DATABASE_ALREADY_EXISTS
  else
    return $EXIT_CODE_SUCCESS
  fi
}

# Create a database
#
# Arguments: $1: The name of the database to create
# Returns:
#  EXIT_CODE_SUCCESS(0) if the database is created successfully
#  EXIT_CODE_ERROR_COULD_NOT_CREATE_DATABASE if the database creation fails
function create_database() {
  # See [NOTE REFERENCE A] for the explanation of the quoting technique
  # used in to generate the psql command.
  local dbname=$1
  local psql_binary="$POSTGRES_DIST_DIR/bin/psql"
  local psql_parameters="-v ON_ERROR_STOP=1 --no-psqlrc --username $POSTGRES_USER --dbname postgres --tuples-only"
  local sql="CREATE DATABASE $dbname;"
  local psql_command="PGUSER=\"$POSTGRES_USER\" PGPASSWORD=\"$POSTGRES_PASSWORD\" $psql_binary $psql_parameters --command \"$sql\""
  debug_echo "psql_command: $psql_command"
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $psql_command
  else
    eval $psql_command > /dev/null
  fi
  return $?
}

# Create the initial database
#
# Arguments: None
# Returns:
#  EXIT_CODE_SUCCESS(0) if the initial database is created successfully
#  TBD: if the initial database creation fails
function create_initial_database() {
  debug_echo "[1572] Creating the initial database $POSTGRES_DB..."
  # Create the initial database
  # Check if the database already exists
  debug_echo "[15721] Checking if the database $POSTGRES_DB already exists..."
  database_exists $POSTGRES_DB
  if [[ $? -eq $EXIT_CODE_ERROR_DATABASE_ALREADY_EXISTS ]]; then
    debug_echo "[15721] The database $POSTGRES_DB already exists"
    return $EXIT_CODE_SUCCESS
  fi
  debug_echo "[15721] The database $POSTGRES_DB does not exist"
  debug_echo "[15722] Creating the database $POSTGRES_DB..."
  create_database $POSTGRES_DB
  if [[ $? -ne 0 ]]; then
    debug_echo "[15722] ERROR($EXIT_CODE_ERROR_COULD_NOT_CREATE_DATABASE): Failed to create database $POSTGRES_DB"
    return $EXIT_CODE_ERROR_COULD_NOT_CREATE_DATABASE
  fi
  debug_echo "[15722] ...done."
  debug_echo "[1572] ...done."
  return $EXIT_CODE_SUCCESS
}

function execute_script() {
  local script=$1
  debug_echo "[15731] Executing script $script"
  "$script"
  local script_error_code=$?
  if [[ $script_error_code -ne 0 ]]; then
    debug_echo "[15731] ERROR($EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED): $script failed with error code $script_error_code"
    return $EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED
  fi
  debug_echo "[15731] ...done."
}

function source_script() {
  local script=$1
  debug_echo "[15732] Sourcing script $script"
  source "$script"
  local script_error_code=$?
  if [[ $script_error_code -ne 0 ]]; then
    debug_echo "[15732] ERROR($EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED): $script failed with error code $script_error_code"
    return $EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED
  fi
  debug_echo "[15732] ...done."
}

function execute_sql() {
  local sql_script=$1
  debug_echo "[15733] Executing SQL $sql_script"
  local psql_binary="$POSTGRES_DIST_DIR/bin/psql"
  local psql_parameters="-v ON_ERROR_STOP=1 --no-psqlrc --username $POSTGRES_USER --dbname $POSTGRES_DB"
  local psql_command="PGUSER=\"$POSTGRES_USER\" PGPASSWORD=\"$POSTGRES_PASSWORD\" $psql_binary $psql_parameters --file $sql_script"
  debug_echo "psql_command: $psql_command"
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $psql_command
  else
    eval $psql_command > /dev/null
  fi
  local sql_error_code=$?
  if [[ $sql_error_code -ne 0 ]]; then
    debug_echo "[15733] ERROR($EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED): $sql_script failed with error code $sql_error_code"
    return $EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED
  fi
  debug_echo "[15733] ...done."
}

function execute_gzipped_sql() {
  local sql_script=$1
  debug_echo "[15734] Executing gzipped SQL $sql_script"
  local psql_binary="$POSTGRES_DIST_DIR/bin/psql"
  local psql_parameters="-v ON_ERROR_STOP=1 --no-psqlrc --username $POSTGRES_USER --dbname $POSTGRES_DB"
  local psql_command="PGUSER=\"$POSTGRES_USER\" PGPASSWORD=\"$POSTGRES_PASSWORD\" $psql_binary $psql_parameters --file <(gunzip -c $sql_script)"
  debug_echo "psql_command: $psql_command"
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $psql_command
  else
    eval $psql_command > /dev/null
  fi
  local sql_error_code=$?
  if [[ $sql_error_code -ne 0 ]]; then
    debug_echo "[15734] ERROR($EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED): $sql_script failed with error code $sql_error_code"
    return $EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED
  fi
  debug_echo "[15734] ...done."
}

function execute_xzipped_sql() {
  local sql_script=$1
  debug_echo "[15735] Executing xzipped SQL $sql_script"
  local psql_binary="$POSTGRES_DIST_DIR/bin/psql"
  local psql_parameters="-v ON_ERROR_STOP=1 --no-psqlrc --username $POSTGRES_USER --dbname $POSTGRES_DB"
  local psql_command="PGUSER=\"$POSTGRES_USER\" PGPASSWORD=\"$POSTGRES_PASSWORD\" $psql_binary $psql_parameters --file <(xzcat $sql_script)"
  debug_echo "psql_command: $psql_command"
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $psql_command
  else
    eval $psql_command > /dev/null
  fi
  local sql_error_code=$?
  if [[ $sql_error_code -ne 0 ]]; then
    debug_echo "[15735] ERROR($EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED): $sql_script failed with error code $sql_error_code"
    return $EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED
  fi
  debug_echo "[15735] ...done."
}

function execute_zstd_sql() {
  local sql_script=$1
  debug_echo "[15736] Executing zstd SQL $sql_script"
  local psql_binary="$POSTGRES_DIST_DIR/bin/psql"
  local psql_parameters="-v ON_ERROR_STOP=1 --no-psqlrc --username $POSTGRES_USER --dbname $POSTGRES_DB"
  local psql_command="PGUSER=\"$POSTGRES_USER\" PGPASSWORD=\"$POSTGRES_PASSWORD\" $psql_binary $psql_parameters --file <(zstd --decompress --compress $sql_script)"
  debug_echo "psql_command: $psql_command"
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $psql_command
  else
    eval $psql_command > /dev/null
  fi
  local sql_error_code=$?
  if [[ $sql_error_code -ne 0 ]]; then
    debug_echo "[15736] ERROR($EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED): $sql_script failed with error code $sql_error_code"
    return $EXIT_CODE_ERROR_CUSTOM_INITIALIZATION_SCRIPT_FAILED
  fi
  debug_echo "[15736] ...done."
}

# Run the initial SQL scripts
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the initial SQL scripts are run successfully
#   TBD: if the initial SQL scripts fail to run
function run_initial_sql_scripts() {
  debug_echo "[1573] Running initial SQL scripts..."
  for filename; do
    case $filename in
      *.sh)
        if [[ -x "$filename" ]]; then
          execute_script "$filename" || return $?
        else
          source_script "$filename" || return $?
        fi
        ;;
      *.sql)
        execute_sql $filename || return $?
        ;;
      *.sql.gz)
        execute_gzipped_sql $filename || return $?
        ;;
      *.sql.xz)
        execute_xzipped_sql $filename || return $?
        ;;
      *.sql.zst)
        execute_zstd_sql $filename || return $?
        ;;
      *)
        debug_echo "[1573] Ignoring $filename"
        ;;
    esac
  done
  debug_echo "[1573] ...done."
  return $EXIT_CODE_SUCCESS
}

# Stop the temporary server
#
# Arguments: None
# Returns:
#   EXIT_CODE_SUCCESS(0) if the temporary server is stopped successfully
#   TBD: if the temporary server fails to stop
function stop_temporary_server() {
  debug_echo "[1574] Stopping the temporary server..."
  # Specify the data directory, the shutdown mode (fast is the default,
  # but we specify it anyway), and wait for the server to stop before
  # returning control to the shell
  local pg_ctl_parameters="-D "$PGDATA" -m fast --wait"
  local pg_ctl_binary="$POSTGRES_DIST_DIR/bin/pg_ctl"
  local pg_ctl_command="PGUSER=\"$POSTGRES_USER\" $pg_ctl_binary $pg_ctl_parameters stop"
  debug_echo "[1574] Running pg_ctl command..."
  debug_echo "[1575] command: $pg_ctl_command"

  # Redirect the output of the pg_ctl command to /dev/null if the
  # debug flag is not set. This is to prevent the output from being
  # displayed on the console under normal circumstances. (Normally
  # only the output of the final run of postgres server is displayed)
  # This allows the docker container to behave exactly as if it were
  # a postgres commmand issued from the command line of the host.
  if [[ $DOCKER_POSTGRES_DEBUG -eq 1 ]]; then
    eval $pg_ctl_command
  else
    eval $pg_ctl_command > /dev/null
  fi
  local pg_ctl_error_code=$?
  if [[ $pg_ctl_error_code -ne 0 ]]; then
    local return_code="${EXIT_CODE_ERROR_PG_CTL_STOP_COMMAND_FAILED}$pg_ctl_error_code"
    debug_echo "[1574] ERROR($return_code): Failed to stop the temporary server"
    return $return_code
  fi
  debug_echo "[1574] ...done."
  return $EXIT_CODE_SUCCESS
}

function configure_database() {
  debug_echo "[157] Configuring the database..."
  local postgres_flags="$@"
  start_temporary_server $postgres_flags || return $? # Exit if error starting temporary server
  create_initial_database || return $? # Exit if error creating initial database
  run_initial_sql_scripts || return $? # Exit if error running initial SQL scripts
  stop_temporary_server || return $? # Exit if error stopping temporary server
  debug_echo "[157] ...done."
  return $EXIT_CODE_SUCCESS
}

function initialize_database() {
  local postgres_flags="$@"
  check_required_variables || return $? # Exit if required variables are not set
  verify_postgres_user || return $? # Exit if not postgres user
  debug_echo -n "[153] Generating initdb command..."
  local initdb_command=$(generate_initdb_command)
  debug_echo "...done."
  run_initdb_command "$initdb_command" || return $? # Exit if error running initdb command  
  configure_listen_addresses || return $? # Exit if error configuring listen addresses
  configure_host_based_authentication || return $? # Exit if error configuring host-based authentication
  configure_database $postgres_flags || return $? # Exit if error configuring database
}

function main() {
  local postgres_flags="$@"
  debug_echo "[150] initialize-postgres.sh: main()"
  initialize_database $postgres_flags || return $? # Exit if error initializing database
  debug_echo "[150] ...done."
  return $EXIT_CODE_SUCCESS
}

main "$@"
