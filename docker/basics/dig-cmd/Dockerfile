# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# dig-cmd/Dockerfile: Exploratory Docker file to create a
# dig installation that is executed using CMD
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

# Exploratory Docker file to create a dig installation that is executed
# using CMD

FROM almalinux:10-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa <svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs dig using the CMD instruction"


# RUN installs bind-utils (which supplies dig) while building the image.
# This filesystem change adds a layer. CMD changes startup configuration
# without adding filesystem contents. Clean package metadata in this layer.
RUN microdnf -y install bind-utils && microdnf clean all

# Every Docker container must run one main program as PID 1 when
# the container starts. The CMD instruction specifies the default
# program (unless the image has an ENTRYPOINT). The program is run
# at that point, not when the image is built.

# To see an image's CMD without looking at its Dockerfile, look for
# Config.Cmd in the output of docker image inspect dig-cmd.

# CMD can be specified in two forms:
#   CMD dig        (shell form)
#   CMD ["dig"]    (exec form)
# Both forms can include arguments, for example CMD dig www.google.com
# or CMD ["dig", "www.google.com"]. The difference is in how Docker
# starts the program. In shell form, Docker runs the string with
# /bin/sh -c, so the shell splits it into words and expands variables
# such as $HOME. For a single command, such as CMD dig, the shell
# usually replaces itself with the program. For several commands, such
# as CMD cd /app && ./server, the shell stays as PID 1, and it does not
# pass on signals such as the SIGTERM sent by docker stop. Putting exec
# before the last command, as in CMD cd /app && exec ./server, makes
# the program replace the shell. The exec form specifies the command
# as a JSON array, similar to the argv array passed to a program.
# Docker starts the program directly: each string is exactly one
# argument, nothing is expanded, and the program itself is PID 1. The
# exec form is also required when CMD supplies default arguments to an
# ENTRYPOINT. Shell form also needs /bin/sh in the image; exec form
# works in minimal images that have no shell.

# If an image contains multiple CMD entries, the last one overrides.
# This also works across images. If the base image of an image has a
# CMD entry, then that entry is overridden by a CMD in the derived
# image. Conversely, if a derived image is missing a CMD entry, the
# CMD entry of the base image is used at startup, unless the derived
# image sets an ENTRYPOINT. In general it makes sense to have every
# image have a CMD or ENTRYPOINT entry (or both).

# The interaction between CMD and ENTRYPOINT is explored in
# dig-entrypoint/Dockerfile and 09-docker-build-cmd-entrypoint.sh.

# One thing to note is that the CMD entry can be overridden entirely
# by command line arguments. For example, with no ENTRYPOINT, words
# after the image name replace this entire command:
#   docker container run --rm dig-cmd ls -l
# starts ls -l, not dig ls -l.
# See 09-docker-build-cmd-entrypoint.sh for details on how that
# works.

# For this image just the plain dig command is good enough. We follow
# our preferred practice of using the JSON (i.e exec) form of the
# command, so no shell is involved. dig exits on its own after one
# query; for a long-running program that does not handle signals as
# PID 1, add --init to docker container run (see
# 02-docker-container-basics.sh).
CMD ["dig"]
