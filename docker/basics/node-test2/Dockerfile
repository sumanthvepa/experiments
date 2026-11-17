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

# A Node.js binary distribution, prepared by lesson 11 in an owned context.
# Keep upstream LICENSE and all package notices. Copying selected runtime
# contents saves headers/manuals, but the actual image-size tradeoff against
# lesson 10's RPM baseline is measured there, not guaranteed by layer count.
FROM almalinux:10-minimal

# Version defaults to the saved release. ARCH_SUFFIX deliberately has no
# default: an omitted argument must fail rather than select arm64 under QEMU.
# The host passes x64 for amd64 or arm64 for arm64 explicitly.
# https://docs.docker.com/reference/dockerfile/#arg
ARG NODEJS_VERSION=22.11.0
ARG ARCH_SUFFIX
RUN case "$ARCH_SUFFIX" in x64|arm64) ;; *) echo 'Pass ARCH_SUFFIX=x64 or arm64' >&2; exit 1 ;; esac \
  && microdnf -y install libstdc++ \
  && microdnf clean all \
  && mkdir -p /opt/node \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/node /usr/local/bin/node \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/npm /usr/local/bin/npm \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/npx /usr/local/bin/npx \
  && ln -s /opt/node/${NODEJS_VERSION}/bin/corepack /usr/local/bin/corepack

# bin and lib plus LICENSE come from a complete archive in a temporary
# directory. libstdc++ supplies C++ runtime dependencies; AlmaLinux provides
# glibc and other system libraries. This is a dynamically linked runtime.
COPY node-v${NODEJS_VERSION}-linux-${ARCH_SUFFIX} /opt/node/${NODEJS_VERSION}
CMD ["/usr/local/bin/node"]
