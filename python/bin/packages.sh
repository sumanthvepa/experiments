#!/bin/bash
# -------------------------------------------------------------------
# packages.sh: Script to create/upgrade all python package
# dependencies for a project.
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

# Packages.sh is a shell script that should be run in a fresh
# python virtual environment to install the latest versions
# of all packages required by 01-remote-idea-python

# Get the absolute path to the real directory where
# this script is located. This allows us to source
# the virtual environment needed by this script from
# that location.
SCRIPT_PATH=$(realpath "$BASH_SOURCE")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

# Source the virtual environment from the correct
# location. This will allow python to access all
# the dependencies needed for this project
if [[ ! -v VIRTUAL_ENV ]]; then
  source "$SCRIPT_DIR"/venv/bin/activate
else
  if [[ $VIRTUAL_ENV != "$SCRIPT_DIR/venv" ]]; then
    echo "Incorrect virtual environment. Deactivate this environment before running this script."
    exit 1
  fi
  # No need to do anything. The correct virtual environment has
  # already been activated.
fi

# This script should ONLY be run if you want to upgrade command_lines's
# package dependencies to the latest versions.
# Otherwise the simply install requirements.txt once you've activated
# the virtual environment, as follows:
# python3 -m pip install -r requirements.txt

# Standard python tools
python3 -m pip install --upgrade pip
python3 -m pip install pylint
python3 -m pip install mypy

# Testing support
python3 -m pip install parameterized

# Update requirements.txt
python3 -m pip freeze >requirements.txt

