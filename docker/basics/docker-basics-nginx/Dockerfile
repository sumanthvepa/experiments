# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-basics-nginx/Dockerfile: Exploratory Docker file to create a
# nginx installation running on almalinux:10-minimal
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

# This Dockerfile creates an nginx installation running on
# almalinux:10-minimal. 08-docker-build-basics.sh and
# 17-docker-inspect.sh build it as docker-basics-nginx, with this
# directory as the build context.


# By convention instructions in a Dockerfile are capitalized. They
# work even if not capitalized though.

# The FROM instruction tells docker which base image to use. For this
# example we've chosen a tag that can be changed at the source:
# AlmaLinux points 10-minimal to a new image each time it publishes
# one. This is not the best thing to do in practice, because your
# base image could change, making the image built from this
# Dockerfile changeable, which is not what you want with a Docker
# image.

# Instead use a specific, non-changeable version for your base image,
# for example by adding its digest to the name, as explained in
# docker-basics-ping/Dockerfile.

# However, for testing and ad hoc containers, doing this is okay.
FROM almalinux:10-minimal

# The MAINTAINER instruction is deprecated. It sets the author field
# in the image metadata. Instead use the LABEL instruction to set
# metadata. LABEL is more flexible and can be used to set other
# metadata as well.
# MAINTAINER Sumanth Vepa <svepa@milestone42.com>

# The LABEL instruction is used to add metadata to the image.
# This metadata can be used to search for images in a registry.
# The org.opencontainers.image names are the standard ones, defined
# by the Open Container Initiative. See 17-docker-inspect.sh for how
# to view and use this metadata.
LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image to show how to set up an nginx server on almalinux:10-minimal"

# The RUN instruction runs a command in the image that is being built.
# Each RUN instruction results in a new layer in the union filesystem
# that comprises the image. microdnf clean all removes the package
# metadata and downloaded packages that the image does not need. It
# must be in the same RUN instruction as the install to make the image
# smaller. See docker-basics-ping/Dockerfile.
RUN microdnf -y install nginx && microdnf clean all

# This specifies what signal docker should send to the process running
# in the container when docker container stop is called from the host.
# nginx shuts down gracefully when it receives SIGQUIT: it finishes
# the requests it is working on, and then exits. SIGTERM, which docker
# sends by default, makes nginx exit at once. This can be overridden
# with the --signal option of docker container stop, or with the
# --stop-signal option of docker container run. See
# 02-docker-container-basics.sh for examples of using --signal.
STOPSIGNAL SIGQUIT

# This is essentially a form of documentation for the reader of the
# Dockerfile, telling them that the process in the container will
# listen on the given port, in this case port 80. It is saved in the
# metadata of the image. EXPOSE does not publish the port, and does
# not open it in any firewall. docker container run --publish does
# that. docker container run --publish-all publishes every exposed
# port, on a random port of the host. The protocol defaults to TCP, so
# 80 means the same as 80/tcp. Write 80/udp for UDP. To expose a port
# for both, use two EXPOSE instructions, 80/tcp and 80/udp.
EXPOSE 80/tcp

# The CMD instruction specifies what command to run when a container
# of the image is started. Each element in the list should correspond
# to one argument typed on the command line. If a command line has
# multiple words that are quoted, then you should include those
# multiple words in one element of the list, like with "daemon off;"
# below.
#
# nginx normally starts in the background and then exits, leaving its
# processes running. A container stops when its first process exits,
# so "daemon off;" keeps nginx in the foreground, as the first process
# of the container. It then also receives the stop signal.
CMD ["nginx", "-g", "daemon off;"]
