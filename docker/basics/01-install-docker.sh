#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 01-install-docker.sh: Explore docker installation
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

echo '01-install-docker'

# This script installs Docker Engine from Docker's own package
# repository. It is written for the current development environments:
# Fedora 44, AlmaLinux 10.2, Debian 13, Ubuntu 26.04
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

# die() A utility function that prints an error message on stderr
# and exit with a non-zero status. A non-zero exit status tells
# whoever ran the script that it failed.
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# Require root privileges
# Installing packages, adding repositories, changing groups and
# starting services all need root. EUID is the effective user id of
# the running script; root has the id 0.
if [[ $EUID -ne 0 ]]; then
  die "This script must be run as root. Try: sudo $0"
fi

# Identify the distribution
# os-release is a file that contains information about the distribution
# In particular it defines the environment variable ID, that can be used
# to determine the distribution, e.g. ubuntu, debian, fedora, almalinux
if [[ -r /etc/os-release ]]; then
  die "Cannot read /etc/os-release"
fi
source /etc/os-release

# Functions that remove packages
# apt_uninstall_packages and dnf_uninstall_packages are defined in
# uninstall_packages.sh. They remove the packages that are given as
# arguments, if they are installed, and know nothing about the
# distribution: the code that installs docker decides which packages to
# remove, by passing the list for the distribution (see the function
# conflicting_packages below). The file is found in the directory of
# this script, so the script can be run from any directory.
source "$(dirname "${BASH_SOURCE[0]}")/uninstall_packages.sh"


# conflicting_packages: print the names of the packages that come with
# a distribution and conflict with the packages from Docker's
# repository, one name on each line. They must be removed before
# Docker's packages are installed. Each distribution has its own list,
# because the names are different on each distribution.
#
# Usage: conflicting_packages os_id
#   os_id: the id of the distribution. This is the value of the ID
#          variable that /etc/os-release defines, e.g. ubuntu, debian,
#          almalinux or fedora.
#
# A function cannot return an array, so it prints the names. The caller
# reads them into an array, and passes the array to the function that
# removes the packages:
#   names=$(conflicting_packages "$ID")
#   mapfile -t packages <<< "$names"
#   apt_uninstall_packages "${packages[@]}"
# (Assigning the output to a variable, instead of reading it directly
# with mapfile, lets set -e stop the script if the function fails.)
#
# If the distribution is not supported, it prints an error message on
# stderr and returns 1. Nothing is removed by this function.
conflicting_packages() {
  local os_id=$1

  # Unwanted Ubuntu packages
  local -a ubuntu_distribution_docker_packages=(
    docker.io docker-compose docker-compose-v2 docker-doc docker-buildx
    podman-docker containerd containerd-stable runc runc-stable
  )

  # Unwanted Debian packages
  local -a debian_distribution_docker_packages=(
    docker.io docker-cli docker-compose docker-doc docker-buildx
    podman-docker containerd runc
  )

  # Unwanted AlmaLinux packages
  local -a almalinux_distribution_docker_packages=(
    podman-docker docker docker-client docker-client-latest
    docker-common docker-latest docker-latest-logrotate
    docker-logrotate docker-engine containerd runc
  )

  # Unwanted Fedora packages
  local -a fedora_distribution_docker_packages=(
    moby-engine docker-cli docker-compose docker-buildx podman-docker
    containerd runc docker docker-client docker-client-latest
    docker-common docker-latest docker-latest-logrotate
    docker-logrotate docker-selinux docker-engine-selinux docker-engine
  )

  case $os_id in
    ubuntu)
      printf '%s\n' "${ubuntu_distribution_docker_packages[@]}"
      ;;
    debian)
      printf '%s\n' "${debian_distribution_docker_packages[@]}"
      ;;
    almalinux)
      printf '%s\n' "${almalinux_distribution_docker_packages[@]}"
      ;;
    fedora)
      printf '%s\n' "${fedora_distribution_docker_packages[@]}"
      ;;
    *)
      echo "ERROR: unsupported distribution: '$os_id'" >&2
      return 1
      ;;
  esac
}


# We can now install docker based on the distribution
if [[ $ID == 'ubuntu' ]]; then
  echo "Installing docker for Ubuntu"
  apt-get --yes install ca-certificates
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get --yes install docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
elif [[ $ID == 'almalinux' ]]; then
  echo "Installing docker for AlmaLinux"
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
elif [[ $ID == 'fedora' ]]; then
  echo "Installing docker for Fedora"
  dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  dnf -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin
elif [[ $ID == 'debian' ]]; then
  echo "Installing docker for Debian"
else
  echo "Unsupported OS"
fi

# This code adds the current user or a list of users specified in the
# DOCKER_USERS environment variable to the docker group.

# Check if the DOCKER_USERS environment variable is set and not empty
if [ -z "$DOCKER_USERS" ]; then
  # If USERS is not set, get the username of the user invoking sudo
  # This user will be added to the group docker
  users=($(logname))
else
  # If USERS is set, split it into an array
  IFS=',' read -r -a users <<< "$DOCKER_USERS"
fi
# Now add all the users in the array to the docker group
for user in "${users[@]}"; do
  # Check that the user exists before adding them to the docker group
  getent passwd $user
  if [[ $? -eq 0 ]]; then
    # Check that the user is not already a member of the docker group
    getent group docker | grep $user
    if [[ $? -ne 0 ]]; then
      # Add the user to the docker group
      echo "Adding $user to docker group"
      usermod --append --groups docker $user
    else
      echo "$user is already a member of the docker group"
    fi
  else
    echo "User $user does not exist"
  fi
done

# Start and enable the docker service
systemctl start docker
systemctl enable docker

# Finally check the docker version and run a test container
docker --version
docker run hello-world
