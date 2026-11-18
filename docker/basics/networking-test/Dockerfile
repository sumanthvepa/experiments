# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# networking-test/Dockerfile: Build the small HTTP networking fixture
#
# Copyright (C) 2026 Sumanth Vepa.
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

# Reuse lesson 15's independently built native PostgreSQL client/server.
FROM postgres-test
RUN microdnf -y --disablerepo='pgdg*' install socat curl-minimal && microdnf clean all
COPY --chmod=0755 response.sh /usr/local/bin/networking-response
# Replace the database entrypoint: these two containers are HTTP services.
ENTRYPOINT ["socat", "-T", "10", "TCP-LISTEN:8080,reuseaddr,fork", "EXEC:/usr/local/bin/networking-response"]
STOPSIGNAL SIGTERM
EXPOSE 8080/tcp
