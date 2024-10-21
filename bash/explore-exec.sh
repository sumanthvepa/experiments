#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-exec.sh: Explore exec command in bash
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

# The exec command in bash is used to replace the current shell process
# with a new process. This is useful when you want to run a command and
# replace the current shell process with the command process.

# Note once the exec command is executed, the current shell process is
# replaced and the shell script does not continue executing.

# The syntax of the exec command is:
# exec command [arguments]
# e.g.
exec ls -l

# In the above example, the exec command is used to replace the current
# shell process with the ls -l command. The ls -l command is executed
# and the output is displayed. Once the ls -l command is completed, the
# shell process is terminated.
# Control does not return to the shell script.
# So the following will not execute
echo "This will not be printed"