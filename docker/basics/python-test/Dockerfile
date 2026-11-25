# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# python-test/Dockerfile: Exploratory Docker file to create a
# python installation running on almalinux:10-minimal
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

# This Dockerfile creates a python installation running on
# almalinux:10-minimal.

FROM almalinux:10-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs Python on almalinux:10-minimal"

# AlmaLinux 10 ships several Python versions side by side, in packages
# named after the version, such as python3.14 and python3.14-pip.
# PYTHON_VERSION chooses which one to install; the patch release
# follows repository updates.
ARG PYTHON_VERSION=3.14

# RUN executes at build time; && stops at the first failed command.
# Cleaning the package metadata in the same RUN keeps it out of every
# layer. The packages install only the versioned commands, such as
# python3.14 and pip3.14. Links in /usr/local/bin, which comes before
# /usr/bin in PATH, add the usual names python, python3, pip and pip3.
#
# No virtual environment is needed: the container's own filesystem
# already keeps an application apart from everything else. pip installs
# packages in /usr/local/lib, apart from the files that RPM packages
# own in /usr/lib.
RUN microdnf install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-pip \
    && microdnf clean all \
    && ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python \
    && ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python3 \
    && ln -s /usr/bin/pip${PYTHON_VERSION} /usr/local/bin/pip \
    && ln -s /usr/bin/pip${PYTHON_VERSION} /usr/local/bin/pip3

# CMD sets the runtime default; it does not run during the build.
CMD ["python"]
