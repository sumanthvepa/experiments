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

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs dig using the CMD directive"


# RUN installs bind-utils (which supplies dig) while building the image.
# This filesystem change adds a layer. CMD changes startup configuration
# without adding filesystem contents. Clean package metadata in this layer.
RUN microdnf -y install bind-utils && microdnf clean all

# Exec form is a JSON array: one string per argument, with no implicit
# shell expansion. Only the last CMD applies; it runs at container startup.
# With no ENTRYPOINT, words after the image replace this entire command:
# docker container run --rm dig-cmd ls -l starts ls -l, not dig ls -l.
CMD ["dig"]
