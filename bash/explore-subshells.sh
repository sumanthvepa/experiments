#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-subshell.sh: Explore subshells in bash
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

# A subshell is a shell within a shell. It is a child process of the
# current shell process. A subshell is created using the parentheses

# When you run another shell script from within a shell script, the
# other script is run in a subshell.

# Variables defined in the parent shell are not available in the
# subshell.
VARIABLE_DEFINED_IN_PARENT="This variable is defined in the parent shell"
# E.g.
./called-from-explore-subshells.sh # Prints nothing

# If you want to pass variables to the subshell, you can redifine them
# in the call to the script:
# Prints: This variable is defined in the parent shell
VARIABLE_DEFINED_IN_PARENT=$VARIABLE_DEFINED_IN_PARENT ./called-from-explore-subshells.sh

# You can also use the export command to make the variable available in
# the subshell:
export VARIABLE_DEFINED_IN_PARENT
./called-from-explore-subshells.sh # Prints: This variable is defined in the parent shell

# But the variable will now leak outside the script into the
# calling environment of this script. This may not be desirable.
# You can unset the variable after the call to the script to prevent
# this.
unset VARIABLE_DEFINED_IN_PARENT