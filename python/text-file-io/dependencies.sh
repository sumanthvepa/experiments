#!/bin/bash
#--------------------------------------------------------------------
# dependencies.sh: A shell script to install all the packages
# this project depends on
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#--------------------------------------------------------------------

# CAUTION: ALWAYS RUN THIS SCRIPT INSIDE A virtualenv

# Requested is simple script that upgrades
# the top level installed packages in the project
# This is really a hack to keep the top-level
# projects up-to-date  avoid having weird issues
# when upgrading packages in requirements.txt

# To upgrade the required packages,
# Create a clean python venv (by removing
# the previous one, creating a new one and
# activating it, and then run this script
python -m pip install --upgrade pip
python -m pip install pylint
python -m pip install mypy

python -m pip freeze >requirements.txt
