#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# node-utilities.sh: Functions shared by the Node.js lessons
#
# Copyright (C) 2026 Sumanth Vepa.
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
# -------------------------------------------------------------------

# This file is intended to be sourced by 10-docker-build-node.sh and
# 11-docker-build-node-optimized.sh. It sources bash-utilities.sh and
# defines:
#
#   download_node_setup_script major-version
#     Make sure that the node-test build context holds NodeSource's
#     setup script for a Node.js major release, downloading the script
#     if it is missing.
#   arch_suffix native-arch
#     Print the name that Node.js gives a CPU architecture in the names
#     of its binary archives: x64 for amd64, arm64 for arm64.

# Source by path so callers can run from another working directory.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"
NODE_TEST_CONTEXT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/node-test"

# download_node_setup_script: make sure that the node-test build
# context holds NodeSource's setup script for a Node.js major release.
# The Dockerfile's COPY can read only files in the context, and the
# build runs the script, so it is downloaded once, kept in node-test,
# and reviewed before it is committed.
#
# Usage: download_node_setup_script major-version
#   major-version: the Node.js major release, for example 26. The
#                  script is node-test/nodesource_setup_26.sh.
#
# Call it before the script creates anything else. It exits the script
# with an error message if the file is not the setup script for that
# release.
download_node_setup_script() {
  local major script
  if [[ $# -ne 1 ]]; then
    die 'Usage: download_node_setup_script major-version'
  fi
  major=$1
  script="$NODE_TEST_CONTEXT/nodesource_setup_${major}.sh"
  die_if_not_available curl chmod mv rm grep
  if [[ ! -f $script ]]; then
    echo "Downloading $script; review it before you commit it."
    cleanup_add node-setup-script rm --force -- "$script.part"
    curl --fail --silent --show-error --location --output "$script.part" \
      "https://rpm.nodesource.com/setup_${major}.x"
    chmod a+x "$script.part"
    mv "$script.part" "$script"
    cleanup_cancel node-setup-script
  fi
  grep --quiet --fixed-strings "NODE_VERSION=\"${major}.x\"" "$script" ||
    die "$script is not the Node.js $major setup script."
}

# arch_suffix: print the name that Node.js gives a CPU architecture in
# the names of its binary archives, for example the x64 in
# node-v26.13.1-linux-x64.tar.gz. Docker and Node.js name CPUs
# differently: the kernel's x86_64 is amd64 to Docker and x64 to
# Node.js, and its aarch64 is arm64 to both.
#
# Usage: suffix=$(arch_suffix native-arch)
#   native-arch: a CPU architecture in Docker's names, for example the
#                output of docker_daemon_cpu_architecture. The daemon
#                runs the image, so its CPU decides which binary the
#                image needs.
#
# Only amd64 and arm64 are supported. It uses die, so it exits the
# shell that it runs in.
arch_suffix() {
  if [[ $# -ne 1 ]]; then
    die 'Usage: arch_suffix native-arch'
  fi
  case $1 in
    amd64) echo x64 ;;
    arm64) echo arm64 ;;
    *) die "The Docker daemon runs on $1, but this lesson supports only" \
         'amd64 and arm64.' ;;
  esac
}
