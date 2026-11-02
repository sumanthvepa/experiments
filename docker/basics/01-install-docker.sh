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
if [[ ! -r /etc/os-release ]]; then
  die "Cannot read /etc/os-release"
fi
source /etc/os-release

# The rest of the script uses distribution_id to identify the
# distribution. If os-release does not define ID, the value is linux
# (this is what the os-release specification says), which is not a
# supported distribution.
readonly distribution_id=${ID:-linux}

# Functions that find and remove the distribution's docker packages
# The functions distribution_packages, conflicting_packages,
# apt_uninstall_packages and dnf_uninstall_packages are defined in
# package-utilities.sh. They find the packages that come with the
# distribution and conflict with Docker's packages, and remove them.
# See the comments in that file. It is found in the directory of this
# script, so the script can be run from any directory.
source "$(dirname "${BASH_SOURCE[0]}")/package-utilities.sh"

# apt_install_docker: install Docker Engine from Docker's apt
# repository, on Ubuntu or Debian. The steps follow Docker's
# instructions for the apt repository:
#   https://docs.docker.com/engine/install/ubuntu/
#   https://docs.docker.com/engine/install/debian/
# The instructions for the two distributions are the same, except for
# the name of the distribution in the URLs of the key and the
# repository, and for the way the release codename is found.
#
# Usage: apt_install_docker dist_id
#   dist_id: ubuntu or debian. This is the value of distribution_id.
#
# It must be run as root. It does not remove the packages that
# conflict with Docker's packages: see conflicting_packages. If
# dist_id is neither ubuntu nor debian, it prints an error message on
# stderr and returns 1.
apt_install_docker() {
  local dist_id=${1:-}
  local keyring=/etc/apt/keyrings/docker.asc
  local repo_url arch codename
  local -a docker_packages=(
    docker-ce docker-ce-cli containerd.io
    docker-buildx-plugin docker-compose-plugin
  )

  case $dist_id in
    ubuntu | debian)
      ;;
    *)
      echo "ERROR: apt_install_docker: unsupported distribution:" \
        "'$dist_id'" >&2
      return 1
      ;;
  esac
  repo_url=https://download.docker.com/linux/$dist_id

  # ${dist_id^} makes the first letter a capital letter, e.g. Ubuntu
  echo "Installing docker for ${dist_id^}"

  # Add Docker's official GPG key. The key is what the packages from
  # Docker are signed with. It is made readable by everyone, because
  # apt reads it as an unprivileged user.
  apt-get update
  apt-get --yes install ca-certificates curl
  install --mode=0755 --directory /etc/apt/keyrings
  curl --fail --silent --show-error --location "$repo_url/gpg" \
    --output "$keyring"
  chmod a+r "$keyring"

  # Add the repository to Apt sources. The file is in the deb822
  # format, which has one field on each line. The architecture (for
  # example amd64) comes from dpkg. The codename of the release (for
  # example noble or trixie) comes from /etc/os-release. On a
  # distribution that is derived from Ubuntu (Linux Mint, for example)
  # VERSION_CODENAME is the codename of the derivative, so the codename
  # of the Ubuntu release it is based on, UBUNTU_CODENAME, is used when
  # it is defined. (Docker does not officially support the derivatives.)
  arch=$(dpkg --print-architecture)
  codename=$(
    . /etc/os-release
    echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  )
  printf '%s\n' \
    'Types: deb' \
    "URIs: $repo_url" \
    "Suites: $codename" \
    'Components: stable' \
    "Architectures: $arch" \
    "Signed-By: $keyring" |
    tee /etc/apt/sources.list.d/docker.sources > /dev/null

  # Read the package lists again, so that apt knows about the packages
  # in the repository that was just added
  apt-get update
  apt-get --yes install "${docker_packages[@]}"
}


# We can now install docker based on the distribution
if [[ $distribution_id == 'ubuntu' || $distribution_id == 'debian' ]]; then
  apt_install_docker "$distribution_id"
elif [[ $distribution_id == 'almalinux' ]]; then
  echo "Installing docker for AlmaLinux"
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
elif [[ $distribution_id == 'fedora' ]]; then
  echo "Installing docker for Fedora"
  dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  dnf -y install \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin
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
