#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 01-install-docker.sh: Explore docker installation
#
# Copyright (C) 2024-25 Sumanth Vepa.
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

echo '01-install-docker'

# This script installs Docker Engine from Docker's own package
# repository. It is written for the current development environments:
# Fedora 44, AlmaLinux 10.2, CentOS Stream 10, Debian 13, Ubuntu 26.04
#
# Run it as root, for example:
#
#   sudo ./01-install-docker.sh
#
# To also give other users access to docker, list them (separated by
# commas) in the DOCKER_USERS environment variable. Note that sudo
# resets the environment, so pass the variable through sudo itself:
#
#   sudo DOCKER_USERS=alice,bob ./01-install-docker.sh
#
# The script can be run again safely. A repository that has already
# been added is not added a second time, and packages and users that
# are already installed or configured are left alone.

# Stop on errors
# -e: Exit as soon as a command fails
# -u: Treat the use of an unset variable as an error
# -o pipefail: A pipeline fails if any command in it fails (and not
#              just the last one)
# Without these options a script carries on after an error, which is
# dangerous for a script that changes the system.
set -euo pipefail

# bash-utilities.sh has the function die, which prints an error
# message on stderr and exits with a non-zero status. A non-zero exit
# status tells whoever ran the script that it failed. It also has
# die_if_not_root, which uses die. The file is found in the directory
# of this script, so the script can be run from any directory.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"

# Require root privileges
# Installing packages, adding repositories, changing groups and
# starting services all need root. die_if_not_root stops the script
# with an error message, that tells the user to use sudo, unless it is
# run by root.
die_if_not_root

# Identify the distribution
# os-release is a file that contains information about the distribution
# In particular it defines the environment variable ID, that can be used
# to determine the distribution, e.g. ubuntu, debian, fedora, almalinux
# or centos
if [[ ! -r /etc/os-release ]]; then
  die "Cannot read /etc/os-release"
fi
source /etc/os-release

# The rest of the script uses distribution_id to identify the
# distribution. If os-release does not define ID, the value is linux
# (this is what the os-release specification says), which is not a
# supported distribution.
readonly distribution_id=${ID:-linux}

# package-utilities.sh has the functions apt_uninstall_packages and
# dnf_uninstall_packages, which remove the packages that are given to
# them, if they are installed. See the comments in that file. It is
# found in the directory of this script, so the script can be run from
# any directory.
source "$(dirname "${BASH_SOURCE[0]}")/package-utilities.sh"

# docker-install-utilities.sh has the functions that find the packages
# that come with the distribution and conflict with Docker's packages
# (distribution_packages and conflicting_packages), the functions that
# install Docker (apt_install_docker and dnf_install_docker) and the
# functions that choose the users and add them to the docker group
# (users_for_docker_group and add_users_to_docker_group). See the
# comments in that file. It is found in the directory of this script,
# so the script can be run from any directory.
source "$(dirname "${BASH_SOURCE[0]}")/docker-install-utilities.sh"

# Decide which users will be added to the docker group. This is done
# before installing anything, so that a mistake stops the script before
# the system has been changed.
names=$(users_for_docker_group)
mapfile -t docker_users < <(printf '%s' "$names")

# Stop if any of the packages that come with the distribution and
# conflict with Docker's packages is installed. This script does NOT
# remove them. Removing a package can remove other packages that depend
# on it, and the person running the script should decide whether that
# is acceptable. This is also done before installing anything. If the
# distribution is not supported, conflicting_packages prints an error
# message and stops the script.
names=$(conflicting_packages "$distribution_id")
mapfile -t conflicts < <(printf '%s' "$names")
if [[ ${#conflicts[@]} -gt 0 ]]; then
  case $distribution_id in
    ubuntu | debian)
      remove_command='apt-get remove'
      ;;
    *)
      remove_command='dnf remove'
      ;;
  esac
  echo "These installed packages conflict with Docker's packages:" >&2
  printf '  %s\n' "${conflicts[@]}" >&2
  echo >&2
  echo 'If you do not need them, remove them yourself and run this' >&2
  echo 'script again, for example:' >&2
  echo "  $remove_command ${conflicts[*]}" >&2
  echo >&2
  echo 'Images, containers, volumes and networks in /var/lib/docker' >&2
  echo 'are not removed when the packages are removed.' >&2
  die "Conflicting packages are installed; nothing has been changed"
fi


# We can now install docker based on the distribution
if [[ $distribution_id == 'ubuntu' || $distribution_id == 'debian' ]]; then
  apt_install_docker "$distribution_id"
elif [[ $distribution_id == 'almalinux' || $distribution_id == 'centos' ||
        $distribution_id == 'fedora' ]]; then
  dnf_install_docker "$distribution_id"
else
  die "Unsupported distribution: $distribution_id"
fi

# Add the users to the docker group. This is done after the docker
# packages have been installed, because they create the group.
add_users_to_docker_group "${docker_users[@]}"

# Start and enable the docker service
systemctl start docker
systemctl enable docker

# Finally check the docker version and run a test container
docker --version
docker run hello-world
