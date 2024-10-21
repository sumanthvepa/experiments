#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-nss-wrapper.sh: Explore the use of nss_wrapper to 
# simulate users and groups
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

# nss_wrapper is  shared libary that intercepts calls to the user
# groups and hosts NSS API.

# This is very useful when you need a specific user name to exist on a
# system, and do not have the priviliges needed to create such a user.

# This is particularly useful in a docker container which needs to run
# a process as a user that is not known at the time the image was
# created. For example if a postgres container is required to run as a
# username local to the container host, then nss_wrapper is a useful
# tool to simulate the existence of the user for the duration of the
# container's existence.

# This is achieved by using Linux's LD_PRELOAD feature. This feature
# allows a set of shared libraries to be loaded prior to any of an
# executable own shared libraries.  This allows them to provide
# replacements for function calls provided by system libraries. In
# this case linss_wrapper.so intercepts calls to getpwent in the libc
# directory to read from the group and password files specified by the
# NSS_WRAPPER_PASSWD and NSS_WRAPPER_GROUP environment variables. And
# get user and group information from there. This allows a user of
# the nss_wrapper library to provide a temporary user and group for
# the proccess to use.
#
# One consequence of the way NSS_WRAPPER works is that it is entirely
# language agnostic. Whether your program is written in C/C++ Java,
# Python or Bash, you can have it use special user ids and groups.


# To use nss_wrapper install the nss_wrapper package
# dnf -y install nss_wrapper

# Then specify specify the following environment variable.
# Remember to export them, unless you are passing them
# as part of the command
export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=./passwd
export NSS_WRAPPER_GROUP=./group

# Normal shell commands will now return
# the the password entry for bob
getent passwd bob

# As will python scripts. No modification required
./explore-nss-wrapper.py


# Ditto with C/C++
make all
./build/explore-nss-wrapper

# Unset the environment variables to return to normal
unset LD_PRELOAD
unset NSS_WRAPPER_PASSWD
unset NSS_WRAPPER_GROUP
