# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# node-test2/Dockerfile: Exploratory Docker file to create a
# size optimized node installation running on almalinux:10-minimal
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

# Node.js from its binary distribution, built in two stages. The first
# stage unpacks the archive from nodejs.org. The second copies only
# the files that run Node.js, and only the second becomes the image.
# Lesson 11 compares its size with lesson 10's RPM installation.
# https://docs.docker.com/build/building/multi-stage/

# An ARG before the first FROM sets a default for every stage. A stage
# that uses the argument must declare it again, without a value.
# ARCH_SUFFIX has no default on purpose: lesson 11 passes x64 or arm64
# for the daemon's CPU, and a build without it must fail rather than
# pick a binary for the wrong CPU.
# https://docs.docker.com/reference/dockerfile/#arg
ARG NODEJS_VERSION=26.13.1
ARG ARCH_SUFFIX

# Stage 1: unpack the archive. ADD unpacks a local .tar.gz archive into
# the destination directory, where COPY would copy it as one file. The
# builder does the unpacking, so this stage needs no operating system
# and starts from scratch. It holds the whole distribution, including
# the C headers in include, the manual pages in share and the top-level
# documents. If ARCH_SUFFIX is missing, ADD fails: the archive name it
# makes, node-v26.13.1-linux-.tar.gz, does not exist.
# https://docs.docker.com/reference/dockerfile/#add
FROM scratch AS unpack
ARG NODEJS_VERSION
ARG ARCH_SUFFIX
ADD node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}.tar.gz /unpack/

# Stage 2: the image. node is dynamically linked: it needs the C++
# runtime libraries libstdc++ and libatomic, and AlmaLinux supplies
# glibc and the other system libraries.
FROM almalinux:10-minimal
ARG NODEJS_VERSION
ARG ARCH_SUFFIX
RUN microdnf -y install libstdc++ libatomic \
  && microdnf clean all \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/node /usr/local/bin/node \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/npm /usr/local/bin/npm \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/npx /usr/local/bin/npx

# COPY --from copies files from an earlier stage instead of from the
# build context. bin holds node and the npm and npx commands, lib holds
# npm itself, and LICENSE must stay with the binaries. Without headers,
# npm cannot compile native addons; that needs a compiler as well.
# ADD and COPY keep the owner recorded in the archive, user 1001 of the
# machine that built Node.js. --chown=0:0 makes root the owner, so that
# no user in the container can change the runtime.
COPY --from=unpack --chown=0:0 /unpack/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/bin /opt/node/${NODEJS_VERSION}/bin
COPY --from=unpack --chown=0:0 /unpack/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/lib /opt/node/${NODEJS_VERSION}/lib
COPY --from=unpack --chown=0:0 /unpack/node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX}/LICENSE /opt/node/${NODEJS_VERSION}/LICENSE
CMD ["/usr/local/bin/node"]
