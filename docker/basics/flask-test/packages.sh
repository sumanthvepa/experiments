#!/bin/bash
# -------------------------------------------------------------------
# packages.sh: Script to upgrade all python package dependencies
# for the flask-test project
#
# Copyright (C) 2023-25 Sumanth Vepa.
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

# Packages.sh is a shell script that should be run in a python
# a fresh virtual environment to install the latest versions
# of all packages required by flask-test.

# To run this script FIRST enable the virtual environment
# into which you want to install the packages
# Typically, this is done as follows:
# source ./venv/bin/activate

# This script should ONLY be run if you want to upgrade flask-tests's
# package dependencies to the latest versions.
# Otherwise the simply install requirements.txt once you've activated
# the virtual environment, as follows:
# python3 -m pip install -r requirements.txt

# Upgrade to the latest version of pip
python3 -m pip install --upgrade pip

# Install python development tools for
# non-production environments
if [[ "$1" != "production" ]]; then
  # Standard python tools
  python3 -m pip install pylint
  python3 -m pip install mypy
fi

# Install required application dependencies
# Flask support
python3 -m pip install Flask

# Update requirements.txt
if [[ "$1" != "production" ]]; then
  python3 -m pip freeze >requirements.txt
else
  python3 -m pip freeze >production-requirements.txt
fi


