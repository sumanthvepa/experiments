#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 19-docker-networking.sh: Explore networking in Docker
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

echo '19-docker-networking'

# In order to make containers work and communcate with the world and
# each other Docker provides a networking stack. You might have had
# glimpse of thise in previous explorations where you saw that Docker
# had modified iptables on the host to allow containers to communicate
# with the world.

# In this script we wille explore how to use docker's networking
# capabilities to create networks, place containers on those
# networks, and allow them to communicate with each other. And 
# isolate them from the world if needed.

echo 'Docker has a few built-in networks that it creates by default:'
# You can see the list of networks by running docker network ls
# In general docker network is the command to manage networks in Docker.
# Like container, and image, the network command has subcommands
# like ls, create, inspect, rm, etc.
docker network ls 
# Btw, ls is a synoynm for list so you can also run docker network list
echo

echo 'The default network is the bridge network. This is the network that'
echo 'containers are placed on by default when you run a container without'
echo 'specifying a network. You can see the details of the bridge network:'
# by running docker network inspect bridge
docker network inspect bridge
echo

echo 'Another network that is created by default is the host network.'
echo 'The host network is a special network that allows containers to'
echo 'share the host network stack. This means that containers on the host'
echo 'network can communicate with the host and with each other using the'
echo 'host network interfaces. You can see the details of the host network:'
# by running docker network inspect host
docker network inspect host
echo

echo 'The third network that is created by default is the none network.'
echo 'The none network is a special network that allows containers to'
echo 'have no network connectivity. This means that containers on the none'
echo 'network cannot communicate with the host or with each other. You can'
echo 'see the details of the none network:'
docker network inspect none
echo

echo 'You can create your own networks using the docker network create command.'
echo 'For example, let us say you want to create an isolated network for an'
echo 'application that you are developing. Suppose that application, we call'
echo 'sample, has three components: a frontend website, a backend web service,'
echo 'and a database.'

echo 'Let us create a network for this application that we will call'
echo 'sample. We will use the bridge driver for this network.'
echo 'The bridge driver is the default driver for Docker networks.'
echo 'The bridge driver creates a private internal network on your host'
echo 'that allows containers to communicate with each other.'
docker network create --driver bridge sample
echo

echo 'You can now see the details of the sample network'
docker network inspect sample
echo

echo 'You can also see the list of networks again to see that the sample'
echo 'network has been created.'
docker network ls
echo

# We will now create the database container image, if it does not
# already exist.
# The script relies on the variables and utility functions defined
# in docker-build-postgres-test-utilities.sh and psql-utilities.sh 
# We source those scripts to get access to those variables and functions.
source ./docker-build-postgres-test-utilities.sh
source ./psql-utilities.sh
POSTGRES_IMAGE_NAME="postgres-test"
POSTGRES_IMAGE_ID=$(docker image ls --quiet $POSTGRES_IMAGE_NAME)
if [[ -z "$POSTGRES_IMAGE_ID" ]]; then
  echo "Image does NOT exist"
  download_and_build_postgres_test_image $POSTGRES_IMAGE_NAME "${POSTGRES_IMAGE_NAME}-test"
  EXIT_CODE=$?
  if [[ $EXIT_CODE -ne 0 ]]; then
    echo "Failed to build the $POSTGRES_IMAGE_NAME image. Exiting."
    exit $EXIT_CODE
  fi
  echo "$POSTGRES_IMAGE_NAME image built successfully"
else
  echo "$POSTGRES_IMAGE_NAME image already exists with ID: $POSTGRES_IMAGE_ID"
fi

# Then, we create the backend container image, if it does not
# already exist.
PYTHON_FLASK_IMAGE_ID=$(docker image ls --quiet sample-flask)



echo 'Now, let us run a few containers on this network.'
echo 'We will run a frontend container, a backend container, and a database'
echo 'container. We will use the nginx image for the frontend, the'
echo 'flask image for the backend, and the postgres image for the database.'
echo 'We will also use the --network option to specify that these containers'
echo 'should be placed on the sample network that we just created.'
echo 'We will also use the --name option to give these containers'
echo 'names so that we can refer to them easily.'
docker run -d --name sample-db --network sample postgres:latest