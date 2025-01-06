# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# curl-test/Dockerfile: Exploratory Docker file to create a
# curl installation running on almalinux:9-minimal
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

# Exploratory Dockerfile to create a curl installation running on
# almalinux:9-minimal
FROM almalinux:9-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs curl on almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:curl-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/curl-test"


# The workdir command sets the working directory for build
# commands that follow it. The CMD and ENTRYPOINT commands
# will also run their executables in this directory.
WORKDIR /opt/call-curl/bin

# COPY command, copies a file or directory from the host
# to the image. The first argument is the source and the
# second argument is the destination in the image.
# This is very usefull for copying the source or compiled
# executables of an application into the image.
COPY call-curl.sh .

CMD ["./call-curl.sh"]
