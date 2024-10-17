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

echo "TODO: explore functions in bash"

# in particular explore how to use functions from within if statments.
# And how to use return etc. See explore-funcname and ChatGPT logs for
# issues # that I should explore.

# Explore variadic functions with $@, "$@" See
# explore-command-line-arguments.sh for an example. Elaborate on that
# example.

# There are two ways to define functions in bash:
# Standard function defintion
# This uses the function keyword and has no parentheses
# following it
function foo {
  echo "This is function foo"
}

# You can have a pair of parentheses following
# it. This is the form I prefer. It makes it look
# like a function.
function foo1() {
  echo "This is function foo1"
}

# Short form
# I prefer the standard form with parenthesis.
bar() {
  echo "This is function bar"
}

# You can invoke a function in the same way as you would
# a command:
foo
foo1
bar

# You can pass parameter to a function much the same
# way as you would pass command line arguments to
# a command

# within a function you can access the individual
# parameters as $1 $2 $3 upto $9.
function bat() {
  echo "$1 followed by $2, followed by $3"
}

bat first second third

# $0 however always represents the name of the
# script.
function bat1() {
  echo $0 # script name
  echo $1 # first parameter
}

bat1 first

# You can iterate over all the arguments using $@
function bat2() {
  local arg
  for arg in "$@"; do
    echo $arg
  done
}

bat2 'first' 'the second one' 'third' 'fourth'

# Functions in bash behave like commands. They have an exit
# status. You can use the return statement to set the exit
# status of a function. If not explicitly set the exit
# status of a function is the exit status of the last command
# executed in the function.

function foo2() {
  echo "This is function foo2"
  return 1
}

# You can get the return value of a function the same way
# you would get the return value of a command, using $?
foo2
echo "Exit status of foo2: $?"


# Functions can only return integers. If you want to
# return a string you can use echo to print the string
# and then capture the output of the function using
# command substitution.
function foo4() {
  echo "This is function foo4"
}
OUTPUT=$(foo4)
echo $OUTPUT

# Functions can have local variables. Local variables
# are only available within the function.
function foo5() {
  local local_var="This is a local variable"
  echo $local_var
}

foo5
echo $local_var # This will not work

# Using exit within a function will exit the script,
# expected, not just the function.
function terminate_script() {
  echo "This is function terminate_script"
  exit 1
}

terminate_script
# No code below this line will be executed, because foo3
# has exited the script.
echo "Exit status of foo3: $?"

