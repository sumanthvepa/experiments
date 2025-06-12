#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 22-docker-rootless.sh: Explore using docker as a not root user 
# and as a non-root program within the container
#
# Copyright (C) 2024-25 Sumanth Vepa.
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

echo '22-docker-rootless.sh'

# Rootless means to different things in the context of these
# tutorials. First, it means the ability of a user managed docker
# containers without being root or invoking sudo.

# This is quite easily accomplished by adding the user to the group
# docker (docker must already have been properly installed.)
# sudo usermod -aG docker "$USER"
# You might need to log out and log back in for this to take effect.
# Then you can run docker commands without sudo.


# The second meaning of rootless is to run a program within the
# container as a non-root user.

# TODO: explore the USER instruction in the Dockerfile, and
# how to use gosu to run a program as a non-root user
