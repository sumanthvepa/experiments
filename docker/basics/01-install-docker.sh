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

# os-release is a file that contains information about the distribution
# In particular it defines the environment variable ID, that can be used
# to determine the distribution, e.g. ubuntu, debian, fedora, almalinux
source /etc/os-release

# We can now install docker based on the distribution
if [[ $ID == 'ubuntu' ]]; then
  echo "Installing docker for Ubuntu"
  apt-get -y install ca-certificates
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get -y install docker-ce \
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
      usermod -aG docker $user
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
