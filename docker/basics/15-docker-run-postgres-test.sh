#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 15-docker-run-postgres-test.sh: Create and run a Postgres Docker
# image
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

echo '15-docker-run-postgres-test.sh'

# This script runs the postgres-test Docker image that was built
# using 14-docker-build-postgres-test.sh. (It will build the image
# if it does not exist.)

# The script relies on the variables and utility functions defined
# in docker-build-postgres-test-utilities.sh. We source that
# script to get access to those variables and functions.
source ./docker-build-postgres-test-utilities.sh
source ./psql-utilities.sh

# Call the function download_and_build_postgres_test_image to download
# the necessary files and build the image. If the return value of this
# function is non-zero, then the image build failed. Clean up and exit
# with the returned error code.
download_and_build_postgres_test_image
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
  clean_up_existing_container
  clean_up_existing_image
  exit $EXIT_CODE
fi

echo
echo "We can now run the image to start the Postgres service."
echo
echo "You need to define the POSTGRES_PASSWORD environment variable to"
echo "in order for the postgres service to start wihin the container"
echo "This an be done by passing the environment variable to the"
echo "docker container run command as shown below:"
echo
echo "docker container run --interactive --tty --rm --publish 5432:5432 --env POSTGRES_PASSWORD='postgres' postgres-test"
echo
echo "You can also set it within the container after you've been "
echo "dropped into the shell."
echo
echo "export POSTGRES_PASSWORD='postgres'"
echo
echo "or whatever password you want to set"
echo
echo "If you are trying to troubleshoot the container, you an run it"
echo "with the DOCKER_POSTGRES_DEBUG environment variable set to"
echo "1 as follows:"
echo
echo "docker container run --interactive --tty --rm --publish 5432:5432 --env POSTGRES_PASSWORD='postgres' --env DOCKER_POSTGRES_DEBUG=1 postgres-test"
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
echo "docker container stop postgres-test-test"
echo

# Start the container detached. This returns control to this shell
# script while the container start postgres in the background.
# The container will be automatically removed when it is stopped.
# (bacause we passed the --rm option to docker container run)
POSTGRES_PASSWORD='postgres'
docker container run --detach --rm --publish 5432:5432 --env POSTGRES_PASSWORD=$POSTGRES_PASSWORD --name='postgres-test-test' postgres-test
if [[ $? -ne 0 ]]; then
  echo "Failed to start the postgres-test-test container"
  exit 1
fi

# Wait for the container to start the postgres service

# The way we check to see if the postgres service has started is by
# running the pg_isready command in the container. You cannot use
# docker run, to run a command in a running container, since there
# already a command running in the container (the postgres service).
# Docker exec command allows you to another command in a running
# container. It seems to work by forking PID 1 in the container
# again to create a second process that runs the command you want.

# The pg_isready command returns 0 if the postgres service is ready
# to accept connections and non-zero otherwise. We can use this
# information to determine if the postgres service has started.

# The while loop below keeps checking if the postgres service has
# started by running the pg_isready command in the container every
# 2 seconds. The loop exits when the pg_isready command returns 0

echo "Waiting for the postgres service to start..."
IS_POSTGRES_SERVER_READY=1
while [[  $IS_POSTGRES_SERVER_READY -ne 0 ]]; do
  sleep 25
  docker container exec postgres-test-test /usr/pgsql-16/bin/pg_isready
  IS_POSTGRES_SERVER_READY=$?
done
echo "Postgres service has started successfully"

# The postgres service has started. We can now connect to the
# database using the psql client and create a test database
# and a test table in it.

# First check if the psql client is installed on the host machine
echo "Checking if the psql client is installed on the host machine"
PSQL_BINARY=$(psql_binary_path)
if [[ $? -ne 0 ]]; then
  echo "Could not find the psql client binary on this system."
  echo "Please install the psql client or set the environment variable"
  echo "PSQL_BINARY to the path of the psql client binary."
  exit 1
fi
echo "psql client found at $PSQL_BINARY"

# Now we can exercise the Postgres server
# We do a deep nested if-else block to create the database, create a table
# check if the table was created successfully, insert data into the table
# and finally select the data from the table.
# This is done so that if a prior step fails, then the next step
# is not executed, and the script goes to the end where clean up is done.

# Now create a test database on the Postgres server
echo "Creating a test database on the Postgres server"
PSQL_COMMAND="PGPASSWORD=$POSTGRES_PASSWORD  $PSQL_BINARY --host=$(hostname -f) --username=postgres "
CREATE_DATABASE_COMMAND="$PSQL_COMMAND --dbname=postgres --command=\"CREATE DATABASE testdb;\""
echo $CREATE_DATABASE_COMMAND
eval $CREATE_DATABASE_COMMAND
if [[ $? -eq 0 ]]; then
  echo "Test database created successfully"
  # Now create a test table in the test database
  echo "Creating a test table in the test database"
  CREATE_TABLE_COMMAND="$PSQL_COMMAND --dbname=testdb --command=\"CREATE TABLE testtable (id SERIAL PRIMARY KEY, name VARCHAR(255));\""
  echo $CREATE_TABLE_COMMAND
  eval $CREATE_TABLE_COMMAND
  if [[ $? -eq 0 ]]; then
    echo "Test table created successfully"
    # Now insert some data into the test table
    echo "Inserting data into the test table"
    INSERT_DATA_COMMAND="$PSQL_COMMAND --dbname=testdb --command=\"INSERT INTO testtable (name) VALUES ('test');\""
    echo $INSERT_DATA_COMMAND
    eval $INSERT_DATA_COMMAND
    if [[ $? -eq 0 ]]; then
      echo "Data inserted successfully"
      # Now select the data from the test table
      echo "Selecting data from the test table"
      SELECT_DATA_COMMAND="$PSQL_COMMAND --dbname=testdb --command=\"SELECT name FROM testtable;\""
      echo $SELECT_DATA_COMMAND
      eval $SELECT_DATA_COMMAND
      if [[ $? -eq 0 ]]; then
        echo "Data selected successfully"
      else
        echo "Failed to select data from the test table"
      fi
    else
      echo "Failed to insert data into the test table"
    fi
  else
    echo "Failed to create the test table"
  fi
else
  echo "Failed to create the test database"
fi

# Clean up the container and image
clean_up_existing_container
clean_up_existing_image
