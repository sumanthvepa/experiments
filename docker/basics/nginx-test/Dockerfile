# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# nginx-test/Dockerfile: Exploratory Docker file to create a
# nginx installation running on almalinux:9-minimal
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

# This Dockerfile creates an nginx installation running on
# almalinux:9-minimal


# By convention commands in a Dockerfile are capitalized. They
# work even if not capitalized though.

# The from command tells docker which base image to use. For this
# example we've chosen a base image that can be changed at the source.
# This is not the best thing to do in practice, because, you baseline
# image could change, making the image this Dockerfile changable
# which is not what you want with a Docker image.

# Instead use a specfic non-changeable version for your base image.

# However, for testing and adhoc containers, doing this is okay.
FROM almalinux:9-minimal

# The MAINTAINER command is deprecated. It sets the author of
# field in image metadata. Instead use LABEL command to set
# metadata. The LABEL command is more flexible and can be used
# to set other metadata as well.
# MAINTAINER Sumanth Vepa <svepa@milestone42.com>

# The LABEL command is used to add metadata to the image.
# This metadata can be used to search for images in a registry.
# See 10-docker-inspect.sh for how view and use this metadata.
LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This a demo image to show how to setup an nginx server on almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:nginx-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/nginx-test"

# The RUN command runs specific command in the image.
# Each RUN command will result in a new layer in the
# union filesystem that comprises the image.
RUN microdnf -y install nginx

# This specifies what signal docker should send to the
# process running in the container when
# docker container stop is called from the host.
# This can be overridden on the command line with -s option
# passed to docker container stop.
# See 02-docker-container-basics.sh for examples of using
# -s
STOPSIGNAL SIGQUIT

# This is essentially a form of documentation for the reader of the
# Dockerfile telling them that the process in the container will
# listen on the given port, in this case port 80. You can be more
# general simply saying 80 instead of 80/tcp. Doing so will open the
# port for both TCP and UDP traffic.
EXPOSE 80/tcp

# The CMD command specifes what command to run when the image is
# started. Each element in the list should correspond to one argument
# typed on the command line. If a command line has multiple words that
# are quoted, then you should include those multple words in one
# element of # the list like with "daemon off;" below.
CMD ["nginx", "-g", "daemon off;"]
