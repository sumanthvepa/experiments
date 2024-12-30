#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 04-docker-kill-top-stats.sh: Explore docker container kill, top and
# stats commands
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

echo '04-docker-kill-top-stats'

# You can send a signal to a container using the kill command
# allong with the standard signal name
# Consider the following container that is detached
docker container run \
  --name='docker-basics-nginx' --publish 9000:80 --detach nginx

# You can send a signal to the container to reload its configuration
# as follows
docker container kill --signal='SIGHUP' docker-basics-nginx


# You can see what processes are running in a container using docker
# container top. Unlike the top shell command, docker top is a one
# shot commmand. It won't keep running.
docker container top docker-basics-nginx

# You can see the stats of a container using docker container stats
# The following will print the stats of the container once and exit
docker container stats --no-stream docker-basics-nginx 

# If you want a top like experience, remove the --no-stream option
# The following will print the stats of the container every second
echo 'Press Ctrl-C  3 times to exit docker container stats'
sleep 5
docker container stats docker-basics-nginx

echo 'Cleaning up containers'
docker container stop docker-basics-nginx
docker container rm docker-basics-nginx

