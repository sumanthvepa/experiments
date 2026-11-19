# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# postgres-test/Dockerfile: Build a PostgreSQL image with automatic
# initialization and startup through an entrypoint script.
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

# ENTRYPOINT initializes an empty cluster and execs PostgreSQL automatically.
# CMD supplies postgres; replacing CMD with bash initializes then opens a
# shell without leaving the server running. Informational flags skip init.
# This teaching image resembles selected official-image behaviors, but
# does not implement _FILE variables or arbitrary command dispatch.

# Use the almalinux:10-minimal image as the base image
FROM almalinux:10-minimal

# Require the caller to choose; never silently copy an amd64 executable.
LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image to show how to set up a PostgreSQL server on almalinux:10-minimal"

ARG ARCH_SUFFIX
RUN test "$ARCH_SUFFIX" = amd64 || test "$ARCH_SUFFIX" = arm64

# EL10 uses ordinary PostgreSQL packages, not EL8/9 module streams.
# We choose PGDG's versioned PG16 packages and /usr/pgsql-16 paths.
# The helper refreshes this EL10 RPM in a temporary context; both bundled
# architecture variants also configure EL10 for standalone builds.
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

COPY --chmod=0755 docker-entrypoint.sh initialize-postgres.sh /usr/local/bin/
RUN mkdir -p /docker-entrypoint-initdb.d
ENV PATH="/usr/pgsql-16/bin:${PATH}"
STOPSIGNAL SIGINT
EXPOSE 5432
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
