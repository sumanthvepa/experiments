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

# AlmaLinux 10 supplies Python 3.12 as its default Python. Install the
# unversioned RPM names python3 and python3-pip; the patch release follows
# repository updates. This ARG is a version assertion, not a package
# selector. A different major.minor needs a reviewed package change too.
ARG PYTHON_VERSION=3.12

# RUN executes at build time. && stops on a failed install/check. Clean
# metadata in the same layer so it does not enlarge an earlier layer.
# Keep RPM-owned /usr/bin/python3 and /usr/bin/pip3 intact: linking over
# existing package paths would fail. /usr/local/bin comes first in PATH.
# The four aliases preserve the convenient python/python3/pip/pip3 names.
RUN microdnf install -y python3 python3-pip \
    && microdnf clean all \
    && mkdir -p /usr/local/bin \
    && ln -s /usr/bin/python3 /usr/local/bin/python3 \
    && ln -s /usr/bin/pip3 /usr/local/bin/pip3 \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && ln -s /usr/bin/pip3 /usr/local/bin/pip \
    && python -c "import sys; assert '.'.join(map(str, sys.version_info[:2])) == '${PYTHON_VERSION}'" \
    && python -m pip --version

# CMD sets the runtime default; it does not run during the build.
CMD ["python"]
