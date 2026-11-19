#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# psql_binary_path.sh: Determine the path to the psql client binary
#
# Copyright (C) 2024-26 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
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

# Print one executable path, or fail without changing the caller's state.
# An explicit override is authoritative: report invalid paths instead of
# silently selecting another client. Quoting preserves spaces in paths.
# Otherwise search PATH, then common Linux/macOS installation locations.
psql_binary_path() {
  local candidate
  if [[ -n ${PSQL_BINARY:-} ]]; then
    if [[ -f $PSQL_BINARY && -x $PSQL_BINARY ]]; then
      printf '%s\n' "$PSQL_BINARY"
      return 0
    fi
    printf 'PSQL_BINARY is not an executable file: %s\n' "$PSQL_BINARY" >&2
    return 1
  fi
  candidate=$(command -v psql) || candidate=
  if [[ -n $candidate && -f $candidate && -x $candidate ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi
  for candidate in /usr/bin/psql /usr/local/bin/psql /usr/pgsql-16/bin/psql /opt/homebrew/bin/psql; do
    if [[ -f $candidate && -x $candidate ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo 'No executable psql client found.' >&2
  return 1
}
