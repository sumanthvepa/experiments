#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-variables.sh: Explore variables in bash
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

# A variable in bash is created by assigning a value to it.
# The value can be a string, a number, or a command output.
# The variable name must start with a letter or an underscore.
# The variable name can contain letters, numbers, and underscores.
# The variable name is case-sensitive.
# By convention, variable names are in uppercase.
# E.g.
NAME="Samwise Gamgee"
AGE=25
TODAY=$(date)

# Note that any text within $(...) is treated as a command and the
# output of the command is assigned to the variable.

# To access the value of a variable, use the $ symbol followed by the
# variable name. E.g.
echo "The name is: $NAME"
echo "The age is: $AGE"
echo "Today is: $TODAY"

# To unset a variable, use the unset command.
# E.g.
unset NAME
echo "The name is: $NAME"

# Parameter Expansion
# The ${...} syntax is used for parameter expansion.
# Parameter expansion allows you to manipulate the value of a variable
# in various ways during expansion.

# Fo a full discussion of parameter expansion in bash, see:
# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

# The simplest form of parameter expansion is to use the variable name
# inside curly braces. This simply expands to the value of the variable.
# E.g.
NAME="Samwise Gamgee"
echo "The name is ${NAME}"

# This is equivalent to using the $ symbol directly in most cases.
# The main difference is that the curly braces are required when you
# want to append text to the variable name. E.g.
POSITION=1
echo "You came ${POSITION}ST"

# If in the code above, if you had simply used $POSITIONST, bash would
# have tried to expand the variable $POSITIONST, which is not defined.
# The curly braces are used to delimit the variable name.

# ${VAR:-VALUE} syntax is used to give a default value for a variable
# that may not be set. E.g.
unset NAME
echo "The name is ${NAME:-"Frodo Baggins"}" # Prints "The name is: Frodo Baggins"
# Note that name is still unset.
echo "The name is: $NAME" # Prints "The name is: "

# Note that the value could be a variable itself. E.g.
DEFAULT_NAME="Frodo Baggins"
echo "The name is ${NAME:-$DEFAULT_NAME}" # Prints "The name is: Frodo Baggins"
# The value of NAME is still unset.
echo "The name is: $NAME" # Prints "The name is: "

# The VALUE field could also be a command. E.g.
echo "The name is ${NAME:-$(whoami)}" # Prints "The name is: <your username>"
# The value of NAME is still unset.
echo "The name is: $NAME" # Prints "The name is: "

# It could of course be the result of a parameter expansion. E.g.
unset NAME
unset DEFAULT_NAME
echo "The name is ${NAME:-${DEFAULT_NAME:-"Frodo Baggins"}}" # Prints "The name is: Frodo Baggins"

# In the code above, if the NAME variable is not set, the value of the
# DEFAULT_NAME variable is used. If the DEFAULT_NAME variable is also
# not set, the value "Frodo Baggins" is used.

# Both NAME and DEFAULT_NAME are still unset.
echo "The name is: $NAME" # Prints "The name is: "
echo "The default name is: $DEFAULT_NAME" # Prints "The default name is: "

# Note that VALUE need not be set. E.g.
unset NAME
echo "The name is ${NAME:-}" # Prints "The name is: "
# The value of NAME is still unset.
echo "The name is: $NAME" # Prints "The name is: "

# The above idiom is not very useful when used in the manner shown above.
# But it is useful when used in a conditional statement. E.g.
unset NAME
if [ -z "${NAME:-}" ]; then
    echo "The name is not set"
else
    echo "The name is: $NAME"
fi

# In the code above, if the NAME variable is not set, ${NAME:-}
# expands to an empty string, which is then tested by the -z operator.


# ${VAR:=VALUE} syntax is used to set the value of a variable if it is
# not already set. Unlike ${VAR:-VALUE}, which does not set the value
# of $VAR, ${VAR:=VALUE} sets the value of $VAR to VALUE if $VAR is not
# already set. E.g.
unset NAME
echo "The name is ${NAME:="Frodo Baggins"}" # Prints "The name is: Frodo Baggins"
# Notice that NAME changed to "Frodo Baggins"
echo $NAME


unset NAME
# VALUE could be a variable. E.g.
DEFAULT_NAME="Frodo Baggins"
echo "The name is ${NAME:=$DEFAULT_NAME}" # Prints "The name is: Frodo Baggins"
# Notice that NAME is now "Frodo Baggins"
echo $NAME

# VALUE could also be a command. E.g.
unset NAME
echo "The name is ${NAME:=$(whoami)}" # Prints "The name is: <your username>"
# Notice that NAME is now your username.
echo $NAME

# VALUE could also be the result of a parameter expansion. E.g.
unset NAME
unset DEFAULT_NAME
echo "The name is ${NAME:=${DEFAULT_NAME:="Frodo Baggins"}}" # Prints "The name is: Frodo Baggins"
# Notice that NAME is now "Frodo Baggins"
echo $NAME
# Also notice that DEFAULT_NAME is also set to "Frodo Baggins"
echo $DEFAULT_NAME

# Of course, VALUE could be empty. E.g.
unset NAME
echo "The name is ${NAME:=}" # Prints "The name is: "
# Notice that NAME is now an empty string.
# Note you can check if a variable is set using the -v operator.
# Notice that you have to check NAME not $NAME
# The else condition won't be executed since NAME is set to an
# empty string.
if [[ -v NAME ]]; then
    # Now the check for an empty string will be executed.
    # and the if conditional will trigger.
    if [[ -z $NAME ]]; then
        echo "The name is an empty string"
    else
        echo "The name is: $NAME"
    fi
else
    echo "The name is not set"
fi
unset NAME

# ${VAR:+VALUE} syntax is used to replace the value of a variable
# if it is already set. E.g.
NAME="Samwise Gamgee"
echo "The name is: ${NAME:+"Frodo Baggins"}" # Prints "The name is: Frodo Baggins"
# Notice that NAME is still "Samwise Gamgee"
echo $NAME

# ${VAR:offset}, ${VAR:offset:length} syntax is used to get a substring
# of a variable. E.g.
NAME="Samwise Gamgee"
echo "The first name is: ${NAME:0:7}" # Prints "The name is: Samwise"
echo "The last name is: ${NAME:8}" # Prints "The name is: Gamgee"

# Note that $1, $2, $3 etc. represent the command line arguments.
# The $0 variable represents the name of the script. 
# So, it might be confusing to see a number in the first postion
# but remember that in this case its the name of the variable not
# an offset or length.
# E.g.
set -- "first" "second" "third"
echo "The first argument is: $1" # Prints "The first argument is: first"
echo "The second argument is: $2" # Prints "The second argument is: second"
echo "The third argument is: $3" # Prints "The third argument is: third"
echo "The first 3 letters of the first argument are: ${1:0:3}" # Prints "The first 3 letters of the first argument are: fir"

# If the lenght is not specified, the substring will go to the end of the string.
# E.g.
echo "The letters following the first letter of the first argument are: ${1:1}" # Prints "The letters following the first letter of the first argument are: irst"


# TODO: explore the ${VAR:offset:length} syntax in more detail.
# In particular ${VAR:@:length} and ${VAR:offset:@} syntax.
# and the ${VAR:*:length} and ${VAR:offset:*} syntax.
# Offset and length can be zero or negative. The details of what happens
# in each case are explained in the bash manual linked above.

# TODO: Explore other parameter expansion syntaxes such as
# ${VAR#pattern}, ${VAR##pattern}, ${VAR%pattern}, ${VAR%%pattern},
# ${VAR/pattern/string}, ${VAR//pattern/string}, ${VAR/#pattern/string},
# ${VAR/%pattern/string}, ${VAR^pattern}, ${VAR^^pattern}, ${VAR,pattern},
# ${VAR,,pattern}, etc.