#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-printf.sh: Explore the printf command in bash
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

# The %q format specifier in printf is used to print a string in a format
# that can be reused as input to the shell. This is useful when you want
# to print a string that contains special characters and you want to
# reuse the string as input to the shell.
# E.g.
printf "%q\n" "Hello, World!" # prints Hello,\ World\!