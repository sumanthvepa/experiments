# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# dig-cmd/Dockerfile: Exploratory Docker file to create a
# dig installation the is executed using CMD
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

# Exploratory Docker file to create a dig installation the is executed
# using CMD

FROM almalinux:9-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs dig using the CMD directive"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:dig-cmd"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/dig-cmd"


# The RUN command runs specific command in the image. Each RUN command
# will result in a new layer in the union filesystem that comprises
# the image.
RUN microdnf -y install bind-utils

# The CMD command specifes what command to run when the image is
# started. Each element in the list should correspond to one argument
# typed on the command line. If a command line has multiple words that
# are quoted, then you should include those multple words in one
# element surround by quotes: "hello world".

# If multiple CMD commands are present only the last one applies.

# The CMD command is not executed when the image is built. It is only
# executed when the container is started.

# The CMD command can be overridden by passing a command to the
# docker run command. For example, if the CMD command is ["dig"] and
# you run the container with the command docker run dig-cmd
# then the dig command will be executed. If you run the container with
# the command docker run dig-cmd ls -l then the ls -l command will be
# executed.
CMD ["dig"]
