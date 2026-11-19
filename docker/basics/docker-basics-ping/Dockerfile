# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-basics-ping/Dockerfile: Build an image that runs ping on
# almalinux:10-minimal
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

# 08-docker-build-basics.sh builds this image as docker-basics-ping,
# with this directory as the build context. The image runs ping. The
# words that follow the image name on the docker container run
# command line become the arguments of ping.

# The FROM instruction names the base image that the build starts
# from. Each instruction after it adds to that image. In this case we
# are using almalinux:10-minimal.
#
# In general it is probably a good idea to be as specific as possible
# with the base image, to avoid any surprises. A tag such as
# 10-minimal moves: AlmaLinux points it to a new image each time it
# publishes one, so two builds of this file, weeks apart, may start
# from different base images. If you want total control, you can add
# the digest of the image to the name, for example
# almalinux:10-minimal@sha256:<digest>. Docker then uses exactly that
# image, whatever the tag points to now. docker image ls --digests
# shows the digests of the images on this machine. The downside is
# that you will need to update this file yourself when you want a
# newer version of the base image, for example to get security fixes.
#
# For milestone42's use case, I think it is good enough to match the
# major and minor version of the host. So 10.1-minimal should be good
# enough if the host is running AlmaLinux 10.1. The images in
# docker/basics use 10-minimal, which follows the newest minor
# version, so that the examples keep working as AlmaLinux 10 is
# updated.
FROM almalinux:10-minimal

# AlmaLinux minimal images use microdnf as the package manager. It is
# a stripped down version of dnf that is designed to be used in
# containers. For the most part it is a drop in replacement for dnf.
# The difference is that microdnf does not support all the features
# of dnf. In particular it does not support plugins or group
# installs. It also lacks python3 support. This is usually not a
# problem, since you won't be using these features in containers.
# Otherwise the package names are the same.
#
# microdnf clean all removes the package metadata and the downloaded
# packages that microdnf keeps in /var/cache. The image does not need
# them. The clean must be in the same RUN instruction as the install.
# Each RUN instruction adds a layer to the image, and a file that one
# layer adds stays stored in that layer, even if a later layer deletes
# it. So a separate RUN microdnf clean all would hide the files, but
# would not make the image any smaller. && runs the clean only if the
# install succeeds, so a failed install still fails the build.
# 08-docker-build-basics.sh shows the size of each layer with docker
# image history.
RUN microdnf -y install iputils && microdnf clean all

# Notice we use the ENTRYPOINT instruction instead of CMD. ENTRYPOINT
# specifies the program to run when the container starts. Any
# arguments given after the image name on the docker container run
# command line are passed to that program as its arguments. So
#   docker container run --rm docker-basics-ping -c 3 www.google.com
# runs /usr/bin/ping -c 3 www.google.com in the container.
#
# The brackets are the exec form: a JSON array, with one element for
# each word of the command. Docker runs the program directly, without
# a shell, so it runs as the first process of the container and
# receives the signals that Docker sends, for example the SIGINT of
# Ctrl-C. For details about the difference between CMD and ENTRYPOINT
# see 09-docker-build-cmd-entrypoint.sh.
ENTRYPOINT ["/usr/bin/ping"]
