#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-arrays.sh: Explore arrays in bash
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

# Bash supports arrays. You can declare an array on any
# on of the following two ways:
ARRAY1=("first", "second", "third")

# or using the declare builting command
declare -a ARRAY2=("one", "two", "three")

# You can access individual elements of the array
# follows (array indices are zero based)
SECOND_ELEMENT=${ARRAY1[1]}
echo "SECOND_ELEMENT=$SECOND_ELEMENT"

# You can print an entire array as follows:
echo ${ARRAY1[@]}

# You can get the length of an array using the following
# string
echo ${#ARRAY1[@]}

# You can loop through the elements of an array
# as follows:

for ELEMENT in ${ARRAY1[@]}; do
  echo $ELEMENT
done

# You can also iterate by index
for INDEX in $(seq 0 3); do
  echo ${ARRAY2[$INDEX]}
done

# Or you can use a traditional for loop to
# iterate over the array

for ((INDEX=0; INDEX < ${#ARRAY1[@]}; ++INDEX)); do
  echo ${ARRAY1[$INDEX]}
done
