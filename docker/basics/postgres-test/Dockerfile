# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# postgres-test/Dockerfile: Creates an unoptimized Docker image
# that runs a postgres database server.
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

# This Dockerfile comes with postgres installed and a shell script
# to initialize and start the postgres database server within
# the container. However, this script is not run as an entrypoint
# script or a command script. Instead the user is dropped into
# a bash shell and can run the script manually.

# The purpose of this Docker image is to explore the initialization
# and startup of a postgres database server.

# Use the almalinux:9-minimal image as the base image
FROM almalinux:9-minimal

ARG ARCH_SUFFIX='amd64'

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This a demo image to show how to setup a postgres server on almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:postgres-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/postgres-test"


# Install basic editing tools to help with debugging
RUN microdnf -y install vim zstd procps-ng iproute

# Disable the version of postgres that comes bundled with the OS
RUN microdnf -y module disable postgresql

# Copy the latest postgres repository rpm to the root directory
COPY  ${ARCH_SUFFIX}/pgdg-redhat-repo-latest.noarch.rpm /

# Copy gosu to /usr/local/bin.
# This will be needed by the setup-postgres.sh script
COPY  ${ARCH_SUFFIX}/gosu-${ARCH_SUFFIX} /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

# Install the postgres repository
RUN rpm -i pgdg-redhat-repo-latest.noarch.rpm

# Install the postgresql16-server package
RUN microdnf -y install postgresql16-server

# Copy the experimental setup and initialization scripts
# for the postgres database server to the /usr/local/bin directory
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY initialize-postgres.sh /usr/local/bin/initialize-postgres.sh

STOPSIGNAL SIGINT
EXPOSE 5432

ENTRYPOINT [ "docker-entrypoint.sh" ]

# Set the default command to start postgres
CMD ["postgres"]
