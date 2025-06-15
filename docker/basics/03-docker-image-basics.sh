#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 03-docker-image-basics.sh: Explore docker image basics
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

echo "03-docker-image-basics"

# Let us create an image for use in this exploration.
# Docker build creates custom image. We will explore
# docker build and custom images in much more detail
# in 09-docker-build.sh
docker build --tag docker-basics-ping -<<EOF
FROM almalinux:9-minimal
RUN microdnf -y install iputils
EOF


# Docker container run downloads the container image
# specifed before running it. If the image has already
# been downloaded, then it simply creates an instance
# of that image.
# To see the list of images that have been dowloaded
# use docker image ls
docker image ls

# Notice that the container image that we created 'docker-basics-ping'
# is present in the list of images.

# Since this is just a test image, we will remove it so that
# if this exploration script is run again it can be recreated.
docker image rm 'docker-basics-ping'


# If you want to download a container image without running it use the
# docker pull command. For example you can pull the curl image without
# running it as follows:
docker image pull curlimages/curl

# You can see that the image has been downloaded using docker
# image ls
docker image ls

echo "Now with the --all option"
# Image ls also support the --all flag to show all images
# including intermediate images. Intermediate images are
# created during the build process and are not directly
# accessible.
docker image ls --all

# When you run the container, with that image, it does not need
# to be downloaded again.
docker container run --rm curlimages/curl curl --version

# Let's clean up by removing the curl image
docker image rm curlimages/curl
