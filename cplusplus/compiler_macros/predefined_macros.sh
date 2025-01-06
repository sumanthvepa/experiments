#!/bin/bash
# -*- coding: utf-8 -*-
#####################################################################
# predefined_macros.sh: Shell script to dump all pre-defined
# compiler macros
#
# To choose a specific compiler set the CXX environment variable
# before invoking this script, as follows:
# CXX=/opt/local/bin/clang++-mp-19 ./predefined_macros.sh
#
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
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
#####################################################################

OS_NAME=$(uname -s)
if [[ $OS_NAME == 'Darwin' ]]; then
  echo "You are on a mac"
  DEFAULT_CXX=$(which clang++)
elif [[ $OS_NAME == 'Linux' ]]; then
  echo "You are on a linux machine"
  DEFAULT_CXX=$(which g++)
else
  DEFAULT_CXX=$(which c++)
fi

CXX=${CXX:-$DEFAULT_CXX}
echo "Using $CXX as the C++ compiler"

# This techinique of dumping all predefined macros is described
# in the following stack overflow post:
# https://stackoverflow.com/questions/2658461/what-predefined-macro-can-i-use-to-detect-clang
# Invokes the C++ to dump all pre-defined macro definitions
# -E only runs the preprocessor
# -dM prints all macro definitions in -E mode
# -x c++ treat the input file as C++ source
# /dev/null An empty input file. 
$CXX -E -dM -x c++ /dev/null
