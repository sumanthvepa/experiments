#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 04-docker-bind-mounts.sh: Explore docker volume mounts
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

echo "04-docker-bind-mounts"

# -----------
# Bind Mounts
# -----------
# Bind mounts allow you to mount an arbitrary directory
# from the host into the container. These are particularly
# useful to mount things like source code or dev directories
# into a container used for development.

# For a bind mount you do not need to create volume.
# Simply specify the mount src and the type as bind
# as shwon below:
echo "In a bind mount, user specifed directory is mounted "
echo "at a specified mount point"
echo "To test this cd to the /mnt directory and issue the following:"
echo "    cat created-on-host.txt"
echo "This should print 'created on host'"
echo "Next create file in the bound directory as follows:"
echo "    echo 'create in the container' > /mnt/created-in-container.txt"
echo "Now change the ownership of the file to the id of the user who"
echo "owns the directory on on the host. Otherwise, you will not"
echo "be able to modify the file from the host."
echo "    chown 1000.1000 /mnt/created-in-container.txt"
echo "Now on the host, change the contents of created-on-host.txt to"
echo "'modified on host'"
echo "Now cat the file in the container to see the changes."
echo "    cat /mnt/created-on-host.txt"
echo "Now append the following line to created-in-container.txt"
echo "from the host: 'modified on the host'"
echo "cat the file in the container to see the changes:"
echo "    cat /mnt/created-in-container.txt"
echo "Exit the container."

docker run \
  --name='docker-basics-test-bind' \
  --mount 'type=bind,src=./bind-test,dst=/mnt' \
  --interactive \
  --tty \
  --rm \
  almalinux:9-minimal


echo "You can see that the changes have persisted beyond the lifetime"
echo "of the container."
cat ./bind-test/created-in-container.txt

# Note that using --mount to do a bind mount, although recommended
# as the option to use, is not the only way to do a bind mount.
# The -v option is a little more concise. The format is as
# follows: 
#  -v <src>:<dst>
# src is the directory on the host and dst is the mount point
# in the container.
# If you want to mount the directory as readonly, you can
# specify the option as follows:
#  -v <src>:<dst>:ro
# Notice that the mount point is created automatically in the
# container when using the -v option.
echo "Creating a new container using the -v option"
echo "Also show automatic creation of the mount point in the container"
echo "Exit this container when you are done"
docker run \
  --name='docker-basics-test-bind' \
  -v ./bind-test:/test \
  --interactive \
  --tty \
  --rm \
  almalinux:9-minimal

# The documentation on the docker site states that the --mount
# option will not create the mount point in the container. BUT
# THIS NOT TRUE. The mount point is created in the container
# even when using the --mount option.
echo "Creating a new container using the --mount option"
echo "Also show automatic creation of the mount point in the container"
echo "Exit this container when you are done"
docker run \
  --name='docker-basics-test-bind' \
  --mount 'type=bind,src=./bind-test,dst=/test' \
  --interactive \
  --tty \
  --rm \
  almalinux:9-minimal


# Bind mounts work great for readonly mounts, like development
# code files.
echo "Starting a container mounting hello-world-nginx as readonly"
echo "You can cat the files /mnt but you cannot create any files"
echo "in the /mnt directory"
echo "Exit the container after you are done"
docker run \
  --name='docker-basics-test-bind-readonly' \
  --mount 'type=bind,src=./hello-world-nginx,dst=/test/,readonly' \
  --interactive \
  --tty \
  --rm \
  almalinux:9-minimal

# If you want to use the --mount option to create a bind mount
# and the mount point is not present in the image, you need
# to create the mount point in the image.

echo "Clean up the created files"
rm -f ./bind-test/created-in-container.txt
