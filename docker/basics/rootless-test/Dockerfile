# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# rootless-test/Dockerfile: Compare USER and root initialization with gosu
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

FROM almalinux:10-minimal AS common
COPY --chmod=0755 gosu /usr/local/bin/gosu
COPY gosu-LICENSE /usr/share/licenses/gosu/LICENSE
COPY --chmod=0755 application.sh initialize.sh /usr/local/bin/
# Both paths start in the image; only one is prepared for USER at build time.
RUN mkdir -p /demo/prepared /demo/runtime \
    && chown 10001:10001 /demo/prepared \
    && chmod 0700 /demo/prepared /demo/runtime \
    && gosu 10001:10001 id

FROM common AS direct-user
USER 10001:10001
# This build instruction also runs with USER's non-root identity.
RUN test "$(id -u):$(id -g)" = 10001:10001
ENTRYPOINT ["/usr/local/bin/application.sh"]
CMD ["direct"]

FROM common AS initialized-gosu
USER 0:0
ENTRYPOINT ["/usr/local/bin/initialize.sh"]
CMD ["gosu"]
