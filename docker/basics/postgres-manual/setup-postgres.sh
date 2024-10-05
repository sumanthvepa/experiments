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

echo "Setting up Postgres..."
echo "TODO: Setup the environment needed for a postgres database"
echo "TODO: Create the database directories"
# Create the database data directory if it does not exist
PGDATA="/var/lib/pgsql/16/data/"
if [ ! -d $PGDATA ]; then
  echo "Creating the database data directory"
  mkdir -p $PGDATA
  if [ $? -ne 0 ]; then
    echo "Error creating the database data directory"
    exit 1
  fi
fi

# Initialize the database only if it is empty
if [ ! "$(ls -A $PGDATA)" ]; then
  gosu postgres initialize-postgres.sh
  if [ $? -ne 0 ]; then
    echo "Error initializing the database"
    exit 2
 fi
fi
echo "...finished setting up Postgres"

echo "Starting Postgres..."
# Start the postgres server
