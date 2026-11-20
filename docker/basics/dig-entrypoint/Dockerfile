# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# dig-entrypoint/Dockerfile: Exploratory Docker file to create a
# dig installation that is executed using ENTRYPOINT
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

# This Dockerfile builds an image whose fixed program is dig, set with
# ENTRYPOINT.

FROM almalinux:10-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa <svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs dig using the ENTRYPOINT instruction"

# RUN installs bind-utils (which supplies dig) while building the image.
# This filesystem change adds a layer. ENTRYPOINT changes startup
# configuration without adding filesystem contents. Clean package
# metadata in this layer.
RUN microdnf -y install bind-utils && microdnf clean all

# The ENTRYPOINT instruction specifies the fixed program of the image:
# the program that a container started from the image runs as PID 1,
# unless docker container run is given --entrypoint. Like CMD, it is
# run when the container starts, not when the image is built. Unlike
# CMD, it is not replaced by the words after the image name in docker
# container run. Those words are passed to the program as its
# arguments instead.

# To see an image's ENTRYPOINT without looking at its Dockerfile, look
# for Config.Entrypoint in the output of
# docker image inspect dig-entrypoint.

# ENTRYPOINT has the same two forms as CMD (see dig-cmd/Dockerfile):
#   ENTRYPOINT dig        (shell form)
#   ENTRYPOINT ["dig"]    (exec form)
# Here the difference matters even more. In shell form, Docker runs the
# string with /bin/sh -c, and passes neither CMD nor the words after
# the image name to the program. So ENTRYPOINT dig always runs dig with
# no arguments. Only the exec form lets those words reach dig.

# If an image contains multiple ENTRYPOINT entries, the last one
# overrides. A derived image inherits the ENTRYPOINT of its base image,
# unless it sets its own. Setting ENTRYPOINT also clears the CMD
# inherited from the base image. Otherwise the CMD of almalinux,
# /bin/bash, would become an argument to dig. So docker image inspect
# shows Config.Cmd as null for this image.

# Words after the image name are appended to the ENTRYPOINT:
#   docker container run --rm dig-entrypoint www.google.com
# starts dig www.google.com. So words meant to replace the program do
# not work:
#   docker container run --rm dig-entrypoint ls -l
# starts dig ls -l, and dig rejects -l. To replace the program itself,
# use the --entrypoint option. It is an option of docker container run,
# so it comes before the image name:
#   docker container run --rm --entrypoint ls dig-entrypoint -l
# starts ls -l.

# ENTRYPOINT and CMD can be used together. ENTRYPOINT then fixes the
# program, and CMD supplies its default arguments, which the words
# after the image name replace. For example, an image with
#   ENTRYPOINT ["dig"]
#   CMD ["www.google.com"]
# looks up www.google.com when it is run with no words after its name,
# and example.com when it is run with example.com after its name. This
# image sets no CMD, so dig runs with no arguments by default, and asks
# for the root name servers. The printf-defaults image in
# 09-docker-build-cmd-entrypoint.sh shows the combination.

# Here the exec form is required, not just preferred: in shell form,
# the words after the image name would never reach dig.
ENTRYPOINT ["dig"]
