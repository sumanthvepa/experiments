#!/usr/bin/env bash
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


# Note the use of the env trampoline #!/usr/bin/env bash
# instead of a simple /bin/bash. This is to ensure that the
# version of bash used is taken from from the user's environment.
# This is to avoid picking up an ancient version bash that
# is the default bash environment on macOS.

# This function reads a file containing package names into an array
# passed to it as the second argument. The first argument is the
# name of the file to read.
function read_packages() {
  local filename="$1"
  if [[ ! -f "$filename" ]]; then
    echo "File not found: $filename"
    exit 1
  fi
  # Declare that the second argument is a nameref to an array
  # This allows the function to modify the array passed as the second
  # argument. We use this technique to return an array from the function.
  # Since in bash, functions cannot return arrays directly, we use
  # nameref to modify the array in the caller's scope.
  declare -n pkgs=$2

  # mapfile reads lines from a file specifed on the command line
  # and stores them in an array. We use process substitution to
  # generate temporary file that is fed to mapfile. The -t option
  # tells mapfile to strip the trailing newline from each line read.
  # the pkgs array will contain the words from the file, with
  # each word as a separate element in the array.

  # The `<(...)` syntax is called process substitution in Bash. It
  # runs the command inside the parentheses in a subshell and provides
  # its output as a temporary file or named pipe. In the code above,
  # `< <(tr -s '[:space:]' '\n' < "$1")` means the output of the
  # `tr` command is fed to `mapfile` as if it were a file.
  # This allows `mapfile` to read the processed words directly from
  # the command's output.

  # The `tr -s '[:space:]' '\n'` command replaces sequences of
  # whitespace characters with a single newline character, effectively
  # splitting the input into separate lines for each word. This is useful

  # The grep -v '^$' command filters out any empty lines from the input.

  mapfile -t pkgs < <(
    sed 's/#.*//' "$filename" | # Remove comments i.e. everything after a #
    tr -s '[:space:]' '\n' | # Replace whitespace with newlines
    grep -v '^$') # Remove empty lines
}

install_packages() {
  local pkgs=("$@")
  if [ ${#pkgs[@]} -eq 0 ]; then
    echo "No packages provided to install."
    return 1
  fi
  # echo "Installing packages: ${packages[*]}"
  python3 -m pip install "${packages[@]}"
}


# Get the absolute path to the real directory where
# this script is located. This allows us to source
# the virtual environment needed by this script from
# that location.
SCRIPT_PATH="$0"
echo "SCRIPT_PATH=$SCRIPT_PATH"
# Commented code below will give the actual location of the script,
# which is not what we need when we want the location of the symbolic link.
# SCRIPT_PATH=$(realpath "$BASH_SOURCE")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
SCRIPT_DIR=$(readlink -f "$SCRIPT_DIR")
echo "SCRIPT_DIR=$SCRIPT_DIR"

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

# Install additional package specified in packages.txt
read_packages "$SCRIPT_DIR/packages.txt" packages
echo "Installing additional packages: ${packages[*]}"
install_packages "${packages[@]}"

# Update requirements.txt
python3 -m pip freeze >requirements.txt
