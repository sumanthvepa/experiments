#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 09-docker-build-cmd-entrypoint.sh: Explore CMD and ENTRYPOINT
# commands in the Dockerfile
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

echo '09-docker-build-cmd-entrypoint'

# The following video explains the difference between CMD and ENTRYPOINT
# very nicely: https://www.youtube.com/watch?v=U1P7bqVM7xM

# The CMD and ENTRYPOINT instructions in a Dockerfile are used to
# specify the command that will be run when the container is started.

# By themselves, both ENTRYPOINT and CMD do the same thing.
# For example the image created to run dig in dig-cmd
# and dig-entrypoint are identical in behavior ONLY AS LONG
# AS NO ARGUMENTS ARE PASSED TO THE RUN COMMAND.

# First we will build the images
docker build --tag dig-cmd ./dig-cmd
docker build --tag dig-entrypoint ./dig-entrypoint

# Now we will run the images with no arguments
# The dig-cmd image will run the dig command with no arguments
# The dig-entrypoint image will also run the dig command with no arguments
docker container run --rm dig-cmd
docker container run --rm dig-entrypoint

# Notice that the output is the same for both images

# But the behaviour changes when we pass arguments to the run command
# with CMD the arguments passed to the run command will override the
# arguments in the CMD instruction in the Dockerfile
docker container run --rm dig-cmd ls -l
# This prints a file listing instead of running dig

# With ENTRYPOINT the arguments passed to the run command will be
# appended to the command specified in the ENTRYPOINT instruction
docker container run --rm dig-entrypoint www.google.com
# This will call dig www.google.com

# However, calling the entrypoint version with ls -l will fail
# as it will try to run dig with the arguments ls -l
docker container run --rm dig-entrypoint ls -l

# This fails.

# Similarly, calling the cmd version with www.google.com will fail
# because the dig command has not been specified
docker container run --rm dig-cmd www.google.com


# Finally we will remove the images
docker image rm dig-cmd
docker image rm dig-entrypoint

