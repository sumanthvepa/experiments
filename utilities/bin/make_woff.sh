#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# make_woff.sh: Script to convert tiff files to woff format
#
# Copyright (C) 2024-25 Sumanth Vepa.
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

for file in "$@"; do

  woff_file="${file%.ttf}.woff"
  echo "Converting $file to $woff_file"
  # Use the 'ttx' command to convert TTF to WOFF
  # ttx is part of the fonttools dnf package
  # -f option overrites the output file if it exists.
  # It won't append the new output to an existing file.
  # -o option specifies the output file name
  /usr/bin/ttx -f -o "$woff_file" "$file"
done
