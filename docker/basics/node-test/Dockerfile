# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# node-test/Dockerfile: Exploratory Docker file to create a
# node installation running on almalinux:10-minimal
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

# Install Node.js from NodeSource's RPM repository on AlmaLinux.
# RPM supplies the runtime's shared-library dependencies as well. This is
# an exploratory image, not a production hardening or minimal-size recipe.
#
# There are two stages. The final scratch stage copies the ENTIRE installed
# filesystem, including package tools and libraries, into one filesystem
# layer. It does not select only Node's binaries or prove a size saving.
# Production suitability also depends on updates, users and the application.
# See https://docs.docker.com/build/building/multi-stage/
FROM almalinux:10-minimal AS unoptimized

# ARG declares a build-time variable with default 22. The host tutorial
# passes --build-arg NODEJS_MAJOR_VERSION=22 explicitly. A matching saved
# installer must exist in the context; its filename uses this ARG too.
# This chooses a major release; NodeSource may update its patch version.
# https://docs.docker.com/reference/dockerfile/#arg
ARG NODEJS_MAJOR_VERSION=22

# Copy the script that installs the appropriate version of nodejs
COPY nodesource_setup_${NODEJS_MAJOR_VERSION}.sh .

# Install the nodejs repository and remove the setup file
# Once the setup is done, the setup file is not required
RUN ./nodesource_setup_${NODEJS_MAJOR_VERSION}.sh \
    && rm nodesource_setup_${NODEJS_MAJOR_VERSION}.sh

# Install nodejs and then clean all dnf cached data
# as it is not required in the final image
RUN microdnf -y install nodejs \
    && microdnf clean all

FROM scratch

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image to show how to set up Node.js on almalinux:10-minimal"

# Preserve the installed filesystem, including shared libraries and
# third-party license notices, rather than copying only the node executable.
COPY --from=unoptimized / /

CMD ["node"]
