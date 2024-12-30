#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 08-docker-build-basics.sh: Explore building Docker images
#
# Copyright (C) 2024 Sumanth Vepa.
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

echo '08-docker-build-basics'

# To build a custom Docker image, you can use the docker build command
# The build command expects two things: a Dockerfile and a build context
# The build context is the directory that contains the Dockerfile
# The Dockerfile contains the instructions to build the image
# The build context contains the files that are needed to build the
# image.

# In the following example, we will build a custom image that runs an
# an instance of the nginx web server on an AlmaLinux base image.
# The image will be tagged as nginx-test.

# The docker file will be in the nginx-test directory
# The build context will be that directory as well.
# The Dockerfile is extensively documented to explore the different
# instructions that can be used in a Dockerfile.
docker build --tag nginx-test ./nginx-test

# You can look at https://github.com/nginxinc/docker-nginx
# for a examples of production quality Dockerfiles.

# Make a note with firewall-cmd that the port is open. The port
# is actually opened by the docker --publish option, the call
# firewall-cmd command just records that fact and lets firewalld
# know that the port is accessible.
# Also if port was already open in firewalld, we don't want to
# close it after the script is done. The PORT_IS_ALREADY_ACCESSIBLE
# variable is used to keep track of this.

# See 09-docker-networking for how to run a container that is only
# accessible from the host.

# The following commands to query and manipulate the firewall require
# root privileges. We first need to check that we are running as root
# and if so, then we can run the commands.
# $EUID is the effective user id of the user running the script.
if [[ $EUID -eq 0 ]]; then
  PORT_IS_ALREADY_ACCESSIBLE=$(firewall-cmd --zone=public --query-port=9000/tcp)
  if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
    firewall-cmd --zone=public --add-port=9000/tcp
  fi
else
  echo "Querying the firewall and adding ports requires root privileges"
  echo "The following commands will be invoked with sudo"
  echo "firewall-cmd --zone=public --query-port=9000/tcp"
  PORT_IS_ALREADY_ACCESSIBLE=$(sudo firewall-cmd --zone=public --query-port=9000/tcp)
    if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
      echo "firewall-cmd --zone=public --add-port=9000/tcp"
      sudo firewall-cmd --zone=public --add-port=9000/tcp
  fi
fi

# You can start the custom container with run:
docker container run --name='nginx-test' --publish 9000:80 --detach nginx-test

echo "The container is running at http://$(hostname -f):9000/"
echo 'Notice that it is the almalinux version of the nginx web server'
echo 'The script will sleep for 30 seconds before stopping and removing the container'
sleep 30
# You can stop the container with stop:
docker container stop nginx-test
# and then remove it
docker container rm nginx-test

echo "Running a container with the custom nginx image and a bind mount"
# You can bind mount a directory with different html content. This is
# useful for development.
docker container run \
  --name='nginx-test' \
  --publish 9000:80 \
  --volume ./hello-world-nginx:/usr/share/nginx/html \
  --detach \
  nginx-test

echo "The container is running at http://$(hostname -f):9000/"
echo 'The script will sleep for 30 seconds before stopping and removing the container'
sleep 30
# Stop and remove the container
docker container stop nginx-test
docker container rm nginx-test

# Close the port 9000 on the firewall of the host
# only if it was not accessible before the script
# was run.
if [[ $EUID -eq 0 ]]; then
  if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
    firewall-cmd --zone=public --remove-port=9000/tcp
  fi
else
  # use sudo if not running as root
  if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
    echo "firewall-cmd --zone=public --remove-port=9000/tcp"
    sudo firewall-cmd --zone=public --remove-port=9000/tcp
  fi
fi

# Remove the custom image
docker image rm nginx-test
