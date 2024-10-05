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

# Check that the script is being run as the postgres user
if [ "$(whoami)" != "postgres" ]; then
  echo "This script must be run as the postgres user"
  exit 1
fi

echo "[as user postgres] Initializing the database"
echo "[as user postgres] Setting up host-based authentication"
echo "OPTIONAL [as user postgres] Starting a temporary server"
echo "  OPTIONAL [as user postgres] Creating an initial database"
echo "  OPTIONAL [as user postgres] Run initial SQL scripts"
echo "OPTIONAL [as user postgres] Stopping the temporary server"


