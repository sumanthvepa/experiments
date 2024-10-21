#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-exit-vs-return.sh: Explore exit vs return in bash
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

# Exit vs Return
# The exit command is used to exit the shell script with a status code.
# The return command is used to return from a function with a status code.

function foo {
  echo "This is function foo"
  return 1
}

foo
echo $? # prints 1

# This function will cause the script to exit with status code 2
function bar {
    echo "This is function bar"
    exit 2
}

# Note that return value of the function will become the exit value of
# the script if the function call is the last command in the script.
foo

# This script will exit with code 1