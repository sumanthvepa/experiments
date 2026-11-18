#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 22-docker-rootless.sh: Explore Docker access and non-root
# container processes, and distinguish these from a rootless daemon
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

echo '22-docker-rootless.sh'

# This lesson distinguishes who may control Docker, which user a
# container program runs as, and which user the Docker daemon runs
# as. These are separate choices. At present it is a reading lesson:
# running bash /path/to/22-docker-rootless.sh only prints its name.
# Reading and running this placeholder needs Bash, but no Docker
# access, root privileges or network connection. The USER and gosu
# demonstrations below are still TODO.

# Access to a rootful Docker daemon

# On a Linux host with a rootful Docker daemon, the docker group
# normally grants access to the daemon's Unix socket. A member can
# run Docker commands without sudo, although the daemon still runs
# as root. This is not rootless Docker. Control of a rootful daemon
# grants root-level privileges on its host, so give this access only
# to trusted users.
#
# The following optional HOST administration command adds the current
# user to an existing docker group on a properly installed system.
# It stays commented out: this lesson does not change host accounts.
# -a appends to the supplementary groups; -G names those groups.
# Quoting "$USER" keeps the login name a single argument.
# sudo usermod -aG docker "$USER"
# Log out and log back in for the new group membership to take effect.
# This changes permission to use Docker, not the container's user.
# See https://docs.docker.com/engine/install/linux-postinstall/


# A non-root process inside a container

# The container program's user is independent of access to Docker.
# Dockerfile USER sets the default user for subsequent RUN commands
# in that build stage and for ENTRYPOINT and CMD at runtime.
# docker container run --user can override the image's default user;
# see the existing --user example in 06-docker-bind-mounts.sh.
# Running a program as a non-root user inside a container does not
# make a rootful daemon rootless, or remove the privileges of the
# person who controls that daemon.
# See https://docs.docker.com/reference/dockerfile/#user

# TODO: explore the USER instruction in the Dockerfile, and
# how to use gosu to run a program as a non-root user


# A rootless Docker daemon

# Docker's rootless mode runs the daemon and containers in a user
# namespace without root privileges on the host. A process can still
# be uid 0 (root) inside that namespace: with rootless Docker, this
# maps to the user running the daemon on the host. Other container
# ids map to subordinate host ids. See 06-docker-bind-mounts.sh for
# the resulting bind-mount ownership and --user caveats.
#
# userns-remap also maps container ids to different host ids, but
# leaves the daemon running as root. It is distinct from rootless
# mode. Neither docker group membership nor Dockerfile USER selects
# either daemon configuration.
#
# This lesson does not install or configure a rootless daemon. Its
# rootless and userns-remap explanations are documentation-based;
# those daemon modes have not been tested here.
# See https://docs.docker.com/engine/security/rootless/
# and https://docs.docker.com/engine/security/rootless/uid-gid-mapping/
# and https://docs.docker.com/engine/security/userns-remap/
