#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-functions.sh: Explore functions in bash
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

echo 'TODO: explore command line arguments.'

# In particular explore $@ "$@" and $* and "$*"
# Also explore $0 $1 etc.

# Within a function $@ represents the arguments passed
# to the function. So you cannot access command line
# arguments from with a function using $@
function print_arguments() {
  for param in "$@"; do
    echo $param
  done
}

print_arguments 3 4 'c'

# If you want to the function to have access to the
# command line arguments you have pass them to it
# explcitly

# This will print its command line arguments, using
# quotes preserves space in the arguments
print_arguments "$@"

# This will also print the command line arguments
# but spaces within arguments will be ignored
# and each space separated word will be treated
# as an argument.
print_arguments $@

# set -- will change the command line arguments to the
# specified values. For example the code below will
# discard the current command line arguments and
# replace them with "overide" "command" "line"
set -- 'override' 'command' 'line'
echo $@ # prints overide command line

# You can modify the command line by appending or
# prepending arguments as follows
set -- 'postgres' "$@"

# The word 'postgres' has been appended to 
echo $@
