#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# bash-utilities.sh: General purpose functions for bash scripts
#
# Copyright (C) 2026 Sumanth Vepa.
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

# This file is intended to be sourced by other scripts, for example
# 01-install-docker.sh. It defines these functions. Nothing runs until
# they are called.
#
#   die message...
#     Print an error message on stderr and exit the script.
#   die_if_not_root [message...]
#     Exit the script with an error message unless it is run by root.

# die: print an error message on stderr and exit with a non-zero
# status. A non-zero exit status tells whoever ran the script that it
# failed.
#
# Usage: die message...
#   message: the words of the error message. They are joined with
#            spaces and "ERROR: " is put in front of them.
#
# die exits the shell that it runs in. If it is called in a subshell,
# for example in $(...), only the subshell exits. The caller can
# still stop the script by assigning the output of the $(...) to a
# variable with set -e on.
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# die_if_not_root: exit the script with an error message unless it is
# run by root. EUID is the effective user id of the running script;
# root has the id 0.
#
# Usage: die_if_not_root [message...]
#   message: the words of the error message, as for die. The default
#            is "This script must be run as root. Try: sudo $0", where
#            $0 is the name of the script. (Functions do not change
#            $0, so it is the name of the script that calls this
#            function.)
#
# It uses die, so it exits the shell that it runs in.
die_if_not_root() {
  if [[ $EUID -ne 0 ]]; then
    die "${@:-This script must be run as root. Try: sudo $0}"
  fi
}
