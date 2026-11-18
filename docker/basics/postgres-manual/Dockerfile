# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# postgres-manual/Dockerfile: Exploratory Dockerfile to explore
# creation of a postgres container. This one requires manual
# invocation of a setup script inside the container.
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

# This Dockerfile comes with postgres installed and a shell script
# to initialize and start the postgres database server within
# the container. However, this script is not run as an entrypoint
# script or a command script. Instead the user is dropped into
# a bash shell and can run the script manually.

# The purpose of this Docker image is to explore the initialization
# and startup of a postgres database server.

# Use the almalinux:10-minimal image as the base image
FROM almalinux:10-minimal

# Require the caller to choose; never silently copy an amd64 executable.
ARG ARCH_SUFFIX
RUN test "$ARCH_SUFFIX" = amd64 || test "$ARCH_SUFFIX" = arm64

# EL10 uses ordinary PostgreSQL packages, not EL8/9 module streams.
# We choose PGDG's versioned PG16 packages and /usr/pgsql-16 paths.
# The tutorial supplies a fresh EL10 repository RPM in a temporary context.
COPY ${ARCH_SUFFIX}/pgdg-redhat-repo-latest.noarch.rpm /tmp/pgdg.rpm
COPY ${ARCH_SUFFIX}/gosu-${ARCH_SUFFIX} /usr/local/bin/gosu
RUN chmod 0755 /usr/local/bin/gosu \
    && rpm -i /tmp/pgdg.rpm \
    && microdnf -y --disablerepo='pgdg*' --enablerepo=pgdg-common --enablerepo=pgdg16 install \
         postgresql16-server tzdata vim zstd gzip xz procps-ng iproute \
    && microdnf clean all \
    && rm /tmp/pgdg.rpm \
    && test -f /usr/share/zoneinfo/Asia/Kolkata \
    && /usr/local/bin/gosu postgres /usr/pgsql-16/bin/postgres --version

COPY --chmod=0755 setup-postgres.sh initialize-postgres.sh /usr/local/bin/
RUN mkdir -p /docker-entrypoint-initdb.d
ENV PATH="/usr/pgsql-16/bin:${PATH}"
STOPSIGNAL SIGINT
EXPOSE 5432
# No entrypoint: the reader explicitly invokes setup-postgres.sh.
CMD ["/bin/bash"]
