# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# node-test/Dockerfile: Exploratory Docker file to create a
# node installation running on almalinux:9-minimal
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

# This Dockerfile creates a node installation running on
# almalinux:9-minimal. It's not the smallest image size, but
# it's a good daily use development image. It's probably okay
# to use this image for production as well.

# This is a multi-stage build.
# The image is created in two stages. The first stage is
# unoptimized and the second stage is optimized. The unoptimized
# stage is used to install nodejs and the optimized stage is
# used to copy the nodejs binaries to the image.

# This is the first stage.
FROM almalinux:9-minimal AS unoptimized

# Copy the script that installs nodejs
COPY nodesource_setup_20.sh .

# Install the nodejs repository and remove the setup file
# Once the setup is done, the setup file is not required
RUN ./nodesource_setup_20.sh \
    && rm nodesource_setup_20.sh

# Install nodejs and then clean all dnf cached data
# as it is not required in the final image
RUN microdnf -y install nodejs \
    && microdnf clean all

FROM scratch

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This a demo image to show how to setup node almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:node-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/node-test"

# This copies the entire filesystem from the unoptimized stage
# to the optimized stage as a single layer. This will reduce
# the size of the image.
COPY --from=unoptimized / /

CMD ["node"]
