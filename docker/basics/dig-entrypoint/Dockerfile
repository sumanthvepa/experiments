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

# This Dockerfile creates a dig command and executes it with
# ENTRYPOINT

FROM almalinux:10-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs dig using the ENTRYPOINT directive"

# RUN installs dig at build time; ENTRYPOINT configures container startup.
RUN microdnf -y install bind-utils && microdnf clean all

# Exec form passes each JSON string as one argument, without a shell.
# Only the last ENTRYPOINT applies. Setting it also clears an inherited
# CMD, so the base image's bash command does not become an argument to dig.
# docker container run --rm dig-entrypoint example.com starts dig example.com.
# With CMD ["example.com"] here, that would be the default argument, and
# words after the image would replace CMD's defaults while retaining dig.
# --entrypoint CAN replace the executable, before the image name:
# docker container run --rm --entrypoint ls dig-entrypoint -l starts ls -l.
# Shell form ENTRYPOINT dig instead uses /bin/sh -c and does not pass CMD
# or run-time words as arguments to dig. See lesson 09 for checked examples.
ENTRYPOINT ["dig"]
