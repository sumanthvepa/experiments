#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-funcname.sh: Explore the FUNCNAME bash variable
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

# FUNCNAME is an bash array that holds the function call stack.
# ${FUNCNAME[0]} is the currently executing function ${FUNCNAME[1]}
# is the function that called it and so on.

# The top of the function call stack can have one of the
# following value:
# 'source:   if the script is being sourced.
# 'main' :   if the script is being executed AND the test is
#            being done from within a function
# It does not print anything if the test done outside
# a fuction.

function print_call_stack() {
  for FUNC in ${FUNCNAME[@]}; do
    echo $FUNC
  done
}

# The following prints the call stack from within
# the print_call_stack function
print_call_stack

# This function can be used to check if a script has been
# sourced.
function is_sourced() {
  TOPCALL="none"
  for FUNC in ${FUNCNAME[@]}; do
    TOPCALL=$FUNC
  done
  test $TOPCALL = "source"
}

# You can use is_sourced to test if the script was
# sourced.
if is_sourced; then
  echo "Script was sourced"
else
  echo "Script was executed directly"
fi