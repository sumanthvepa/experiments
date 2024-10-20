#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-user-whoami.sh: Explore ways to get the user name in bash
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

# There are several ways to get the user name in bash.
# The first way is to use $USER environment variable
echo "The user name is: $USER"

# The second way is to use the whoami command
echo "The user name is: $(whoami)"

# The third way is to use the id command
echo "The user name is: $(id -un)"

# The fourth way is to use the logname command
echo "The user name is: $(logname)"

# The whoami command is a better way to get the user name.
# It prints the user name of the user who is running the script.
