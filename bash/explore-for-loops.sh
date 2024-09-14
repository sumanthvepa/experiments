#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-for-loops.sh: Explore for loops
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

# You can iterate over a list of items as follows:

# This is a traditional for loop.
for ((i = 0; i < 10; ++i )); do
  echo "i = $i"
done

# You can also use the for in loop using the seq command
# see man 1 seq.
for i in $(seq 0 9); do
    echo "i = $i"
done

# You can iterate over an array
ARRAY=(0 2 4 6 8 10)
for i in ${ARRAY[@]}; do
  echo "i=$i"
done

# if you omit the in clause, the for loop will operate
# on the parameter list $@. Depending on whether the
# for loop is inside a function or at the top-level,
# $@ either represents the function parameters or
# the script parameters.

# In the code below the for loop is iterating
# over function parameters.
function foo() {
  local arg
  for arg; do
    echo "parameter: $arg"
  done
}

foo first second "the third one" 4

# At the top level omitting the in clause will cause
# for loop to iterate over the command line arguments
# starting with $1.

for arg; do
  echo "command line parameter: $arg"
done