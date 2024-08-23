#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 08-docker-build.sh: Explore building Docker images
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

echo '08-docker-build'

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


# You can start the custom container with run:
docker container run --name='nginx-test' --publish 9000:80 --detach nginx-test

echo 'The container is running at http://darkness2.milestone42.com:9000/'
