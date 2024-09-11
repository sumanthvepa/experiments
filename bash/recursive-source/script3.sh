#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# recursive-source/script3.sh: Shell script that is sourced by script2.sh
# This is the last script in the recursive source chain.
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

echo "\${BASH_SOURCE[0]}: ${BASH_SOURCE[0]}"
echo "\${BASH_SOURCE[1]}: ${BASH_SOURCE[1]}"
echo "\${BASH_SOURCE[2]}: ${BASH_SOURCE[2]}"
echo "\${BASH_SOURCE[3]}: ${BASH_SOURCE[3]}"
