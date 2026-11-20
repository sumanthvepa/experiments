#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 03-docker-image-basics.sh: Explore docker image basics
#
# Copyright (C) 2024-26 Sumanth Vepa.
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

echo '03-docker-image-basics'

# Stop on unexpected errors, unset variables and failed pipelines.
# The image removal that is meant to fail is checked explicitly below.
set -euo pipefail

# die, cleanup_add and cleanup_cancel come from bash-utilities.sh,
# which is in the same directory as this script.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"
die_if_not_docker_available

# Building and tagging replace any image with the same name. Check
# the image name, with any tag, and the container name before changing
# anything, so existing images and containers are kept.
die_if_docker_image_exists docker-basics-ping
die_if_docker_container_exists docker-basics-ping-container

# The script removes the images and the container that it creates at
# the end of each part. If it stops early, because a command fails or
# Ctrl-C is pressed, those steps never run. cleanup_add saves commands
# that remove what the script created, usually after creation succeeds.
# The saved commands run when the script exits. cleanup_cancel forgets
# a command once the script has run it itself. Images and containers
# that were already on this machine are kept. See bash-utilities.sh
# for the details.

# Let us create an image for use in this exploration.
# Docker image build creates a custom image. docker build is an alias
# for docker image build, and you will often see the shorter form.
# docker builder build is another alias. When the buildx plugin is
# installed, as it is by 01-install-docker.sh, all of these actually
# run docker buildx build, which builds the image with BuildKit.
# The exception is when the environment variable
# DOCKER_BUILDKIT is set to 0. Then docker uses the old builder
# instead, and prints a warning that it is deprecated and will be
# removed in a future release. You can see the list of aliases with
# docker image build --help. We will explore docker build and custom
# images in much more detail in 08-docker-build-basics.sh

# The image is built FROM almalinux:10-minimal. Keep it if you already
# have it; if the lesson pulls it, remove it again at the end of this
# part.
pull_image_if_absent almalinux:10-minimal
docker image build --tag docker-basics-ping -<<EOF
FROM almalinux:10-minimal
RUN microdnf -y install iputils
EOF
cleanup_add ping-latest docker image rm 'docker-basics-ping:latest'


# docker image ls lists the images stored on this machine, both the
# ones that were downloaded and the ones that were built here. Its
# aliases are docker image list and docker images.
docker image ls

# Notice that the container image that we created 'docker-basics-ping'
# is present in the list of images.

# The columns in the output are:
# IMAGE: The name of the image.
# ID: The start of the image id. --no-trunc shows the whole id.
# DISK USAGE: The space that the image takes on disk.
# CONTENT SIZE: On the machine this script was written on, which uses
#   the overlay2 storage driver, this is always 0B.
# EXTRA: U when a container uses the image.
# Older versions of docker, and docker image ls --digests, show
# different columns: REPOSITORY, TAG, IMAGE ID, CREATED and SIZE.


# An image can have more than one name. docker image tag gives an
# existing image another name. A name is made of a repository and a
# tag, separated by a colon. When no tag is given, as when we built
# docker-basics-ping, docker uses the tag latest. So the image is
# already called docker-basics-ping:latest, and here we also call it
# docker-basics-ping:v1.
docker image tag 'docker-basics-ping' 'docker-basics-ping:v1'
cleanup_add ping-v1 docker image rm 'docker-basics-ping:v1'

# Giving a repository name to image ls lists only the images in that
# repository. Notice that both names have the same id. They are two
# names for one image, and the image is stored only once.
docker image ls 'docker-basics-ping'

# The --quiet option prints only the ids, which is useful in scripts.
# The id is printed twice, once for each name.
docker image ls --quiet 'docker-basics-ping'

# The --filter option selects images in other ways. The reference
# filter matches the names against a pattern, in which * matches any
# characters.
docker image ls --filter reference='docker-basics-*'


# docker image history shows how the image was made, newest step
# first. Each instruction in the Dockerfile adds a row. Instructions
# that change files, such as RUN, add a layer with a size. Others,
# such as CMD, only change the settings of the image, and have a size
# of 0B. The top row is the RUN that installed iputils, and the rows
# below it come from the base image, almalinux:10-minimal. <missing>
# in the IMAGE column means that there is no separate image for that
# step. This is normal with BuildKit, and for steps of a downloaded
# image. The CREATED BY column is cut short. --no-trunc shows it in
# full.
docker image history 'docker-basics-ping'


# docker image rm removes a name from an image. When the last name is
# removed, docker deletes the image itself. Removing the v1 name only
# untags the image, because the name docker-basics-ping still refers
# to it.
docker image rm 'docker-basics-ping:v1'
cleanup_cancel ping-v1

# Docker will not remove an image that a container uses. To see this,
# create a container from the image. container create makes the
# container without starting it, and prints its id.
# Save the id, so that cleanup removes the container we created, and
# not another container that is later given the same name. If creation
# fails, for example because the name is already in use, stop.
if ! PING_CONTAINER_ID=$(docker container create \
  --name 'docker-basics-ping-container' \
  docker-basics-ping); then
  die 'Could not create the demonstration container. Stopping.'
fi
cleanup_add ping-container docker container rm "$PING_CONTAINER_ID"
echo "$PING_CONTAINER_ID"

# The EXTRA column now shows U, because the image is in use.
docker image ls 'docker-basics-ping'

# This fails with an error that says that a container is using the
# image, and that the removal must be forced:
# conflict: unable to remove repository reference "docker-basics-ping"
# (must force) - container ... is using its referenced image ...
# Checking the result lets the script continue after this expected
# failure, while an unexpected success stops the demonstration.
if docker image rm 'docker-basics-ping'; then
  cleanup_cancel ping-latest
  die 'Image removal unexpectedly succeeded. Stopping.'
fi

# docker image rm --force would delete the image anyway. The container
# keeps working, because docker keeps the files that it needs. But
# docker container ls --all then shows only an image id for the
# container, and not a name, so it is hard to tell what the container
# runs. It is better to remove the container first, and then the
# image.
docker container rm "$PING_CONTAINER_ID"
cleanup_cancel ping-container

# Since this is just a test image, we will remove it so that if this
# exploration script is run again it can be recreated. This time the
# last name is removed, so docker deletes the image. The output shows
# both the untagging and the deletion.
docker image rm 'docker-basics-ping'
cleanup_cancel ping-latest

# Remove the base image too, if this lesson pulled it.
remove_pulled_image almalinux:10-minimal


# If you want to download a container image without running it, use
# the docker image pull command. docker pull is an alias for it.
# For example you can pull the curl image without running it as
# follows:
#   docker image pull curlimages/curl

# An image name has the form registry/namespace/repository:tag. The
# parts that are left out get default values. The default registry
# is docker.io, which is Docker Hub, and the default tag is latest. So
# curlimages/curl is short for docker.io/curlimages/curl:latest.
# Official images on Docker Hub, such as nginx and almalinux, have no
# namespace in their short names. Their namespace is library, so
# nginx is short for docker.io/library/nginx:latest.

# latest is just a tag name. It does not mean the newest version. It
# is whatever image the publisher last gave that tag, and it can
# change at any time. So it is better to name a specific tag, such as
# almalinux:10-minimal used above, which says which version you want.
# Even such a tag can be moved by its publisher to a newer build. To
# get exactly the same image every time, use its digest, as in
# curlimages/curl@sha256:... docker image ls --digests shows the
# digests of the images.

# Pulling an image that is already present checks the registry, and
# downloads the image again if a newer one has been published under
# the same tag. The old copy then loses its name and is left behind as
# a dangling image. If the image is up to date, docker prints:
# Status: Image is up to date for curlimages/curl:latest
# So the lesson pulls the curl image only if it is not already on this
# machine, and removes it at the end only if it pulled it.
pull_image_if_absent curlimages/curl

# You can see that the image is present with docker image ls.
docker image ls

# Image ls also supports the --all option to show all images. Without
# it, image ls hides two kinds of images that have no name.
# The first kind is intermediate images. The old builder created an
# intermediate image for each instruction in the Dockerfile, and used
# these images as a cache to speed up later builds. BuildKit does not
# create intermediate images. It keeps its build cache separately. You
# can see the build cache with docker buildx du, and remove it with
# docker builder prune.
# The second kind is dangling images. A dangling image is one that has
# lost its name, usually because a newer build was given the same
# name. --all shows them as <untagged>, and
# docker image ls --filter dangling=true shows only them. Older
# versions of docker showed dangling images without --all, as <none>.
# So on a machine where only BuildKit has been used, and there are no
# dangling images, image ls --all shows the same images as image ls.
echo 'Now with the --all option'
docker image ls --all

# Running a container from the image does not download it again.
# The --pull option of container run controls when docker downloads
# the image. The default, missing, downloads it only if it is not
# already present. always checks the registry every time, and
# downloads the image if it has changed, so that the latest version is
# used. never does not download it at all, and the run fails if the
# image is not present. Here, never proves that the local image is
# used without downloading it again. If the image were missing,
# docker would fail with the error:
# No such image: curlimages/curl:latest
docker container run --rm --pull=never curlimages/curl curl --version

# Let's clean up by removing the curl image, but only if this lesson
# pulled it.
remove_pulled_image curlimages/curl


# Images that are no longer needed pile up over time. docker image
# prune removes dangling images. docker image prune --all removes
# every image that no container uses, including images that you
# pulled or built and still want. Both ask for confirmation unless
# --force is given. They act on all the images on this machine, and
# not just the ones from this script, so this script does not run
# them. docker system df shows how much space the images, containers,
# volumes and build cache take.
#
# The build at the start of this script is the one thing that it
# leaves behind. Its steps stay in BuildKit's build cache, which is
# what makes a second run of the build fast. docker builder prune
# removes the build cache, but the cache of every build on this
# machine, and not just this script's, so this script does not run it
# either. docker buildx du lists the entries in the build cache.
docker system df
