#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# psql_binary_path.sh: Determine the path to the psql client binary
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

# This file is intended to be sourced by other scripts that need to
# determine the path to the psql client binary. The function
# psql_binary_path is defined in this file and can be called by other
# scripts to determine the path to the psql client binary.

# This function checks if the user has defined PSQL_BINARY and if so
# checks if it is a valid path to a binary. If the path is set but does
# not point to a valid binary, it will return an error. Otherwise, it
# returns the value of PSQL_BINARY. If PSQL_BINARY is not set, it
# looks in some standard places: /usr/bin/psql and
# /usr/pgsql-16/bin/psql. If it finds the psql binary there, it
# returns that path otherwise it returns and error.
function psql_binary_path() {
  local psql_binary=${PSQL_BINARY:-$(which psql)}
  if [[ ! -x $psql_binary ]]; then
    PSQL_BINARY='/usr/bin/psql'
    if [[ ! -x $psql_binary ]]; then
      PSQL_BINARY='/usr/local/bin/psql'
      if [[ ! -x $psql_binary ]]; then
        PSQL_BINARY='/usr/pgsql-16/bin/psql'
        if [[ ! -x $psql_binary ]]; then
          return 1
        fi
      fi
    fi
  fi
  echo $psql_binary
  return 0
}
