# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# node-test2/Dockerfile: Exploratory Docker file to create a
# size optimized node installation running on almalinux:9-minimal
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

# This Dockerfile creates a size optimized  node installation running
# on almalinux:9-minimal

# Instead of installing nodejs from a package manager, we can create
# a smaller footprint by downloading the nodejs binaries and copying
# them to the image. This way we can have a smaller image size and
# have more control over the version of nodejs we are using.

FROM almalinux:9-minimal

# The ARG command a build-time variable that is used to pass
# variables from the docker build command to the Dockerfile.
# The = 20 specifes that the default value of NODEJS_MAJOR_VERSION
# is 20. This value can be overridden by passing the value
# to the docker build command. (In fact, it is overriddent in
# this case in 10-docker-build-node.sh)
# Detailed documentation on ARG can be found at
# https://docs.docker.com/reference/dockerfile/#arg
ARG NODEJS_VERSION='22.11.0'
ARG ARCH_SUFFIX='arm64'

# ENV PATH=$PATH:/opt/node/${NODEJS_VERSION}/bin

# Combine multiple RUN commands into one to reduce the number of layers
# created by the image. This will reduce the size of the image.

# We will create a directory to store the node binaries and then copy
# the node binaries to the image. We will also create symlinks to the
# node binaries from /usr/local/bin to the /opt/node/20.17.0/bin
# directory, so that we can run node, npm, npx, and corepack.

# Note that the symlinks are created before the binaries are copied
# to the image. This allows us to avoid creating a new layer for
# symlink creation. The symlinks will function once the binaries
# are copied to the image.
RUN mkdir -p /opt/node \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/node /usr/local/bin/node \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/npm /usr/local/bin/npm \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/npx /usr/local/bin/npx \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/corepack /usr/local/bin/corepack

# We copy only the bin and lib directories the nodejs binary
# distribution. This is accomplished by deleting all the other
# files. See 09-docker-build-optimzing1.sh for details on
# how this is done.
# This will reduce the size of the image.
COPY node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX} /opt/node/${NODEJS_VERSION}

# Finally run the node interpreter
CMD ["/usr/local/bin/node"]
