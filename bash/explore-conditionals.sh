#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-conditionals.sh: Explore bash scripting
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

# There are two conditional commands in bash test or [ (single square
# bracket) and [[ or double square bracket.

# The single square bracket is fully POSIX compitable, and should
# be used if cross-shell compatibility is desirable.

# Otherwise for linux only shell scripting prefer the bash [[
# conditional.

VAR=1
if [[ var -eq 1 ]]; then
  echo "VAR is 1"
else
  echo "VAR is not 1"
fi
