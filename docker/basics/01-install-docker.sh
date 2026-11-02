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

# A more robust implementation of an install docker script is
# can be found at https://www.smushd.in/devops/
# (Subscription required)

# This script installs Docker Engine from Docker's own package
# repository. It is written for the current development environments:
#
#   Fedora 44
#   AlmaLinux 10.2
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
#
# There is one function for each package manager. Each one removes the
# packages that are given as arguments, if they are installed. A
# function knows about the package manager, but not about the
# distribution: the code that installs docker decides which packages to
# remove, by passing it the list for the distribution (see the
# *_DISTRIBUTION_DOCKER_PACKAGES lists below). The functions are defined
# here but nothing runs until they are called.

apt_uninstall_packages() {
  # Remove packages with apt, the package manager of Ubuntu and Debian.
  # Usage: apt_uninstall_packages package...
  #   package: the name of a package to remove, if it is installed.
  #            Names of packages that are not installed are ignored.
  local -a installed=()
  local package

  # dpkg-query reports the status of a package. It fails for a package
  # that dpkg has never heard of (for example a package that only
  # exists in newer releases), so the output (not the exit status) is
  # compared, with the whole word 'installed'.
  for package in "$@"; do
    if [[ $(dpkg-query --show --showformat='${db:Status-Status}' "$package" \
      2> /dev/null) == 'installed' ]]; then
      installed+=("$package")
    fi
  done

  if [[ ${#installed[@]} -eq 0 ]]; then
    echo 'No distribution docker packages are installed'
    return 0
  fi

  echo 'Removing these distribution docker packages:'
  printf '  %s\n' "${installed[@]}"

  # Removing a package also removes the packages that depend on it.
  # --simulate shows everything apt is going to remove, without
  # removing anything.
  echo 'apt will remove (this includes packages that depend on them):'
  apt-get --simulate remove "${installed[@]}"

  # remove (as opposed to purge) leaves the packages' configuration
  # files behind. Images, containers, volumes and networks in
  # /var/lib/docker are not removed either.
  apt-get --yes remove "${installed[@]}"
}

dnf_uninstall_packages() {
  # Remove packages with dnf, the package manager of AlmaLinux and Fedora.
  # Usage: dnf_uninstall_packages package...
  #   package: the name of a package to remove, if it is installed.
  #            Names of packages that are not installed are ignored.
  local -a installed=()
  local package

  # rpm --query --quiet succeeds only if a package with exactly this
  # name is installed. (It does not match other packages that merely
  # provide the name.)
  for package in "$@"; do
    if rpm --query --quiet "$package"; then
      installed+=("$package")
    fi
  done

  if [[ ${#installed[@]} -eq 0 ]]; then
    echo 'No distribution docker packages are installed'
    return 0
  fi

  echo 'Removing these distribution docker packages:'
  printf '  %s\n' "${installed[@]}"

  # Removing a package also removes the packages that depend on it, and
  # the dependencies that nothing else needs any more. DNF has no
  # option that only shows what would be removed, so ask for the
  # removal and answer no (--assumeno). DNF then shows everything it
  # would remove and stops. Answering no makes DNF exit with a non-zero
  # status, so ignore that status here.
  echo 'dnf will remove (this includes packages that depend on them):'
  dnf --assumeno remove "${installed[@]}" || true

  # Images, containers, volumes and networks in /var/lib/docker are
  # not removed either.
  dnf --assumeyes remove "${installed[@]}"
}


# Docker packages that come with each distribution
#
# Each distribution has its own list of the packages that conflict with
# the packages from Docker's repository, because the names are
# different on each distribution. They must be removed before Docker's
# packages are installed. The lists are only data: nothing is removed
# until the code that installs docker passes the list for the
# distribution to apt_uninstall_packages or dnf_uninstall_packages.

# Ubuntu
# The list is the one in Docker's installation instructions for Ubuntu
# (https://docs.docker.com/engine/install/ubuntu/), plus the
# containerd-stable and runc-stable packages that Ubuntu 26.04 and later
# provide in place of containerd and runc.
#
# None of these packages is installed on a stock Ubuntu Server, so
# normally there is nothing to remove. They are only present if someone
# installed them. (The docker snap, which the Ubuntu Server installer
# can install, is a snap and not an apt package. It is not in the list.)
readonly -a UBUNTU_DISTRIBUTION_DOCKER_PACKAGES=(
  docker.io
  docker-compose
  docker-compose-v2
  docker-doc
  docker-buildx
  podman-docker
  containerd
  containerd-stable
  runc
  runc-stable
)

# Debian
# The list is the one in Docker's installation instructions for Debian
# (https://docs.docker.com/engine/install/debian/), plus docker-cli.
# Debian 13 (trixie) and later split the docker command line client out
# of docker.io into the docker-cli package, which conflicts with
# Docker's docker-ce-cli package.
#
# Notes on the Debian packages:
#   - docker-compose is Compose version 1 in Debian 12 (bookworm), but
#     Compose version 2 in Debian 13 and later. The newer one conflicts
#     with Docker's docker-compose-plugin package.
#   - Debian does not have a docker-compose-v2 package, or the
#     containerd-stable and runc-stable packages that Ubuntu has.
#   - The docker package in Debian 12 is unrelated to Docker. It is a
#     transitional package for a window manager dock (wmdocker), so it
#     is not in the list.
#
# These packages are normally only present if someone installed them.
readonly -a DEBIAN_DISTRIBUTION_DOCKER_PACKAGES=(
  docker.io
  docker-cli
  docker-compose
  docker-doc
  docker-buildx
  podman-docker
  containerd
  runc
)

# AlmaLinux
# The names come from two places:
#   - Docker's installation instructions for CentOS
#     (https://docs.docker.com/engine/install/centos/) list the
#     unofficial docker packages to remove.
#   - Docker's packages declare what they conflict with. In particular
#     containerd.io conflicts with containerd and runc.
#
# Of these only podman-docker is part of AlmaLinux 10 (it is in the
# AppStream repository). It provides a docker command that runs podman,
# and it conflicts with docker-ce. The other packages are not in the
# AlmaLinux 10 repositories. They are only present if they were
# installed from somewhere else. (AlmaLinux 10 has crun, not runc, as
# its container runtime. crun does not conflict with Docker's packages.)
#
# Not in the list:
#   - podman: only its docker wrapper (podman-docker) conflicts.
#   - container-selinux: it provides the name docker-selinux, but
#     Docker's packages need it.
readonly -a ALMALINUX_DISTRIBUTION_DOCKER_PACKAGES=(
  podman-docker
  docker
  docker-client
  docker-client-latest
  docker-common
  docker-latest
  docker-latest-logrotate
  docker-logrotate
  docker-engine
  containerd
  runc
)

# Fedora
# The names come from two places:
#   - The packages in the Fedora repositories (Fedora 44). Fedora
#     provides its own build of Docker, called Moby (moby-engine).
#   - Docker's installation instructions for Fedora
#     (https://docs.docker.com/engine/install/fedora/), which list the
#     unofficial docker packages to remove.
#
# Fedora packages that conflict with Docker's packages:
#   - moby-engine: provides the name docker, and conflicts with
#     docker-ce
#   - docker-cli: conflicts with docker-ce-cli
#   - docker-compose: conflicts with docker-compose-plugin
#   - docker-buildx: installs the same file as docker-buildx-plugin
#   - podman-docker: a docker command that runs podman. Conflicts with
#     docker-ce
#   - containerd and runc: containerd.io (from Docker) conflicts with
#     both
#
# The other names are the ones in Docker's instructions. They are not
# in the Fedora 44 repositories. They are only present if they were
# installed from somewhere else, or are left from an older release.
#
# Some packages are removed along with these because they need them,
# for example moby-engine-rootless-extras (needs moby-engine),
# docker-compose-switch (needs docker-compose) and docker-buildkit
# (needs containerd and runc). Removing runc also removes the cri-o
# packages (the Kubernetes container runtime) if they are installed.
# The list that dnf shows before the removal has all of them.
#
# Not in the list:
#   - podman: only its docker wrapper (podman-docker) conflicts.
#   - container-selinux: it provides the name docker-selinux, but
#     Docker's packages need it. It is not found by the name
#     docker-selinux, because only package names are matched.
readonly -a FEDORA_DISTRIBUTION_DOCKER_PACKAGES=(
  moby-engine
  docker-cli
  docker-compose
  docker-buildx
  podman-docker
  containerd
  runc
  docker
  docker-client
  docker-client-latest
  docker-common
  docker-latest
  docker-latest-logrotate
  docker-logrotate
  docker-selinux
  docker-engine-selinux
  docker-engine
)


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
