#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 00-docker-overview.sh: Print out an overview of docker
#
# Copyright (C) 2024-25 Sumanth Vepa.
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

echo "00 Docker Overview"
echo
echo "A container is an isolated environment for running one or more"
echo "processes on a host operating system. The host may be a physical"
echo "machine or a virtual machine."
echo
echo "A container is created from a container image. An image contains"
echo "the filesystem and configuration needed to start the container."
echo "The relationship between an image and a container is somewhat"
echo "like the relationship between an executable file and a running"
echo "process."
echo
echo "Containers share the host's operating system kernel. An image"
echo "can contain a different Linux distribution from the host. For"
echo "example, an AlmaLinux container can run on a Fedora host."
