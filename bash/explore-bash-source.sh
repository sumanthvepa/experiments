#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-bash-source.sh: Explore the $0 and $BASH_SOURCE variables
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

# $0 is the name of the script itself. This is similar to argv[0] in C
# However, $0 is not always the name of the script. This is the case
# when the script is sourced. In that case, $0 is the name of the
# shell that is running the script.
# To see this in action, run the following command:
# $ source explore-bash-source.sh
# Note $0 is now the name of the shell that is running the script.
echo "\$0: $0"


# $BASH_SOURCE is an array that contains as its first element the
# name of the script itself. This is similar to $0. However, unlike
# $0, $BASH_SOURCE is always the name of the script, even when the
# script is sourced. To see this in action, run the following command:
# $ source explore-bash-source.sh
# Note $BASH_SOURCE[0] is still the name of the script.
echo "\$BASH_SOURCE[0]: ${BASH_SOURCE[0]}"

# The bash source array represents the sequence of scripts that
# in the call stack. The first element of the array is the name of
# the script itself. The second element is the name of the script
# that sourced the script. The third element is the name of the
# script that sourced the script that sourced that script, and so on.
# See the scripts in the directory recursive-source for an example
# of this in action.
# main.sh sources script1.sh which sources script2.sh which sources
# script3.sh. The BASH_SOURCE array in script3.sh will be:
# BASH_SOURCE[0] = script3.sh
# BASH_SOURCE[1] = script2.sh
# BASH_SOURCE[2] = script1.sh
# BASH_SOURCE[3] = main.sh

# Bash has a feature where referring to an array without an index
# is equivalent to referring to the first element of the array.
# So to get the first element of BASH_SOURCE you can also use
# This is not recommended as it is not as clear as using an index.
echo "\$BASH_SOURCE: $BASH_SOURCE"

