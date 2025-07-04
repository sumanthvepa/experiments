#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# make_woff2.sh: Script to convert tiff files to woff2 format
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
  echo "Converting $file to WOFF2 format..."
  # Use the 'woff2' command to convert TTF to WOFF2
  # woff2_compress is installed in /opt/bin
  /opt/bin/woff2_compress "$file"
done
