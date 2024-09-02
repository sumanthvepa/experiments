# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# node-test/Dockerfile: Exploratory Docker file to create a
# python installation running on almalinux:9-minimal
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

# This Dockerfile creates a python installation running on
# almalinux:9-minimal. 

FROM almalinux:9-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This a demo image to show how to setup node almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:node-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/node-test"

# Most of the time want the latest available package version
# for python. The default version of python in almalinux:9-minimal
# is 3.9, which is quite old. However, later versions of python
# are available in the almalinux:9-minimal repositories with
# specific version numbers. For example, python3.12 is available
# in the almalinux:9-minimal repositories. So we will install
# that.

# Also note the clean up.

# Finally note that we are creating symbolic links to the python3.12
# and pip3.12 binaries as python3, python and pip3, pip respectively.
# This is to make it easier to use the python interpreter and the
# pip package manager.
RUN microdnf install -y python3.12 python3.12-pip \
    && microdnf clean all \
    && ln -s /usr/bin/python3.12 /usr/bin/python3 \
    && ln -s /usr/bin/pip3.12 /usr/bin/pip3 \
    && ln -s /usr/bin/python3.12 /usr/bin/python \
    && ln -s /usr/bin/pip3.12 /usr/bin/pip


CMD ["python"]
