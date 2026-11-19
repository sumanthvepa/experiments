# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# website-test/Dockerfile: Exploratory Docker file to create a
# nginx server hosting a simple website running on almalinux:10-minimal
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

# Start with a native Linux base and install nginx in the image, not host.
FROM almalinux:10-minimal
LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="A packaged static website served by nginx."
RUN microdnf -y install nginx && microdnf clean all

# COPY source paths are relative to the website-test build context.
# /etc/nginx/nginx.conf replaces the distribution's configuration; the
# document root contains our page and its referenced stylesheet.
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html style.css /usr/share/nginx/html/
# Make read permissions explicit, independent of source checkout modes.
RUN chmod 644 /etc/nginx/nginx.conf /usr/share/nginx/html/index.html /usr/share/nginx/html/style.css \
    && nginx -t

# Docker stop sends SIGQUIT for graceful nginx shutdown. EXPOSE documents
# the listening TCP port; publication is chosen when creating a container.
STOPSIGNAL SIGQUIT
EXPOSE 80/tcp
# Exec form keeps nginx as PID 1. Foreground mode keeps the container alive.
CMD ["nginx", "-g", "daemon off;"]
