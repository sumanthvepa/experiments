#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 05-docker-volume-mounts.sh: Explore docker volume mounts
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

echo '05-docker-volume-mounts'

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail

# Use the same error and cleanup helpers as 03-docker-image-basics.sh.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"

# Volume mounts

# Every container has its own writable layer on top of its image.
# The files that a program in the container writes go into that
# layer, and they are deleted with the container. If you want to
# keep data that a program in a container writes, the best way to do
# it is to use a volume mount. A volume is storage that Docker
# manages separately from any container. It keeps its data until you
# remove the volume itself, however many containers use it in the
# meantime.

# create_demo_volume: create a new, empty volume for the examples,
# and save a cleanup command that removes it.
#
# Usage: create_demo_volume name
#   name: the name of the volume. It is also the key of the cleanup
#         command, for cleanup_cancel.
#
# The examples need new, empty volumes. docker volume create does not
# fail if a volume with the name already exists. It just prints the
# name. A volume left over from a run that was stopped part way could
# still hold the files that the examples write. The examples would
# then find the old files, even if this run wrote nothing, and the
# end of the script would remove a volume that this run did not
# create. So stop if the volume already exists. docker volume inspect
# fails if there is no volume with the name.
#
# The saved cleanup command attempts to remove the volume if the
# script stops part way through. A surviving container can keep the
# volume in use, so this can fail. See the recovery commands below.
# The end of the script removes the volumes itself, to show how,
# and then cleanup_cancel forgets the saved commands.
create_demo_volume() {
  local name=$1
  if docker volume inspect "$name" >/dev/null 2>&1; then
    die "The volume $name already exists. If you no longer need it," \
      "remove it with: docker volume rm $name"
  fi
  docker volume create "$name"
  cleanup_add "$name" docker volume rm "$name"
}

# First create a docker volume to store your data. docker volume
# create prints the name of the new volume. You can leave this step
# out: docker container run creates a named volume that does not
# exist yet when it mounts it. Creating it first makes the step
# visible.
#
# The examples use three volumes. docker-basics-test-volume is used
# first. The other two are used at the end, to show how Docker fills
# an empty volume from the image. They are all created here, so that
# a volume left over from an earlier run stops the script before the
# interactive examples, and not after them.
create_demo_volume 'docker-basics-test-volume'
create_demo_volume 'docker-basics-copy-volume'
create_demo_volume 'docker-basics-nocopy-volume'

# die_container_failed, from bash-utilities.sh, stops the script
# after an interactive docker container run returns a non-zero
# status, and explains what may have gone wrong. If the Docker client
# itself is killed, the container may still be running, and keep its
# volume in use, so the cleanup cannot remove the volume. See the
# recovery commands near the end of the script.

# Now create a container that uses the volume, with the --mount
# option. --mount takes a comma separated list of key=value pairs:
# type=volume: Specifies that this is a volume mount.
# source=docker-basics-test-volume: The name of the volume to mount.
#   src is a short alias for source.
# target=/test: The directory in the container where the volume is
#   mounted. dst and destination are aliases for target.
#
# As usual we use --interactive and --tty to interact with bash in
# the terminal. --rm removes the container when you exit bash.
# --name gives the container a name, so that it can be found after it
# has been removed, below.
echo 'Now write some test data to the mounted volume:'
echo '    cd /test/'
echo "    echo 'Test data' > ./test.txt"
echo '    exit 0'
read -r -p 'Press ENTER to start the container...'

# The shell exits with the status of the last command typed in it,
# unless exit is given a number. docker container run then exits with
# the same status. Use exit 0 so that a mistyped command just before
# exit does not stop the script. A non-zero status can come from
# Docker, from starting the container's command, or from the command
# itself. The status alone cannot tell these cases apart, so stop on
# every non-zero status. The file is checked after the reader exits.
# || saves the status for the message. An if ! ... test would lose
# it, because ! turns it into 0.
SHELL_STATUS=0
docker container run \
  --name='docker-basics-volume-writer' \
  --mount 'type=volume,source=docker-basics-test-volume,target=/test' \
  --interactive \
  --tty \
  --rm \
  almalinux:10-minimal || SHELL_STATUS=$?
if [[ $SHELL_STATUS -ne 0 ]]; then
  die_container_failed 'docker-basics-volume-writer' "$SHELL_STATUS"
fi

# --rm has removed the container. The name filter matches any
# container whose name contains the text, so ^ and $ make it match
# the whole name only. The list shows only its column headings.
echo 'Notice that the container has been removed.'
echo 'docker container ls --all does not show it:'
docker container ls --all --filter 'name=^docker-basics-volume-writer$'

# --rm also removes the anonymous volumes of the container. These are
# volumes mounted without a source, which Docker gives a random name.
# It never removes a named volume such as docker-basics-test-volume.
# So the file written into /test is still in the volume.
echo 'But if we run another container with the same volume'
echo 'mounted on to it, the data created by the earlier'
echo 'container will be available. You can test this by doing:'
echo '    cat /test/test.txt'
echo 'from inside the container. Notice that the data is still present.'
echo 'Then leave the container with:'
echo '    exit 0'
read -r -p 'Press ENTER to start the container...'

# Stop on every non-zero status, as above.
SHELL_STATUS=0
docker container run \
  --name='docker-basics-volume-reader' \
  --mount 'type=volume,source=docker-basics-test-volume,target=/test' \
  --interactive \
  --tty \
  --rm \
  almalinux:10-minimal || SHELL_STATUS=$?
if [[ $SHELL_STATUS -ne 0 ]]; then
  die_container_failed 'docker-basics-volume-reader' "$SHELL_STATUS"
fi

# Exiting both shells successfully does not prove that the write
# command worked. Check the file from a third container before
# reporting success. Mount the volume read only for this check, so
# that the check cannot change the data. Read only mounts are
# explained below, in the Read only volume mounts section.
# The assignment checks that cat succeeded, and the comparison
# checks the text, ignoring trailing newlines stripped by $(...).
echo 'Checking that the volume still contains the expected data...'
if ! docker container run --rm --mount \
  'type=volume,source=docker-basics-test-volume,target=/test,readonly' \
  almalinux:10-minimal \
  bash -c 'data=$(cat /test/test.txt) &&
    [[ $data == "Test data" ]]'; then
  die 'The volume check failed. Expected /test/test.txt to contain' \
    '"Test data". Check any error above and repeat the example.'
fi

echo 'Okay. The container has been removed. But the data written'
echo 'into /test is preserved beyond the lifetime of the container.'


# Read only volume mounts

# Add readonly to the --mount options to mount a volume read only. ro
# is a short alias for readonly. The container can read the files in
# the volume, but it cannot create, change or remove them. This is
# useful when a container only needs to read data, for example
# configuration or content that another container writes. It protects
# the data from mistakes, and from a program in the container that has
# been broken into.
#
# The following containers do not need a terminal or a name, because
# they only run one command and exit. They are not interactive, so
# the script does not pause before them. bash -c runs the command
# given to it as a string. ls --format=long, the long form of ls -l,
# shows the details of each file. The ls works, but the touch fails
# with "Read-only file system".
echo 'Mounting the volume read only. ls works, but touch fails:'
WRITE_STATUS=0
docker container run --rm --mount \
  'type=volume,source=docker-basics-test-volume,target=/test,readonly' \
  almalinux:10-minimal \
  bash -c 'ls --format=long /test && touch /test/readonly-test.txt' ||
  WRITE_STATUS=$?

# touch fails with 1. Any other status means that something else went
# wrong, and 0 means that the volume could be written to, so the
# example would be misleading.
if [[ $WRITE_STATUS -eq 0 ]]; then
  die 'The read only volume could be written to. Stopping.'
elif [[ $WRITE_STATUS -ne 1 ]]; then
  die "The read only example failed with status $WRITE_STATUS."
fi
echo 'As expected, the container could not write to the volume.'

# The shorter --volume option

# The --volume option is an older, shorter way to mount a volume. It
# takes the source, the target and, optionally, a comma separated list
# of options, separated by colons:
#   --volume source:target[:options]
# So the following mounts docker-basics-test-volume read only at
# /test, as the --mount option above does. Both are given the volume
# by name, so they mount the same volume and see the same file.
#
# --mount is easier to read, because it names each field, and it is
# stricter, so it is preferred. With --volume, Docker decides what to
# mount from the form of the source:
# - A name, such as docker-basics-test-volume, mounts a named volume.
# - A path, such as /srv/data or ./data, bind mounts that directory of
#   the host. See 06-docker-bind-mounts.sh for bind mounts. If the
#   directory does not exist, --volume creates it. In the default
#   rootful configuration, the new directory is owned by root. With
#   rootless Docker, it is owned by the user running the daemon.
#   By default, --mount fails if the source directory does not exist.
# - With no source, such as --volume /data, Docker creates an
#   anonymous volume, and mounts it at /data.
#
# With either option, a mistyped volume name does not cause an error.
# Docker creates a new, empty volume with that name, and mounts it.
echo 'Mounting the same volume read only with --volume:'
docker container run --rm \
  --volume 'docker-basics-test-volume:/test:ro' \
  almalinux:10-minimal \
  ls --format=long /test


# Docker fills an empty volume from the image

# A volume can be mounted over a directory that already has files in
# the image. If the volume is empty, Docker first copies the files of
# the image's directory into it, along with the ownership and
# permissions of the directory. So the program in the container finds
# the files that it expects, for example the default configuration
# of a server, and its changes to them are kept in the volume.
#
# The /etc/skel directory of almalinux:10-minimal holds the files that
# are copied into the home directory of a new user: .bash_logout,
# .bash_profile and .bashrc. Their names start with a dot, so ls
# shows them only with --almost-all (-A), which lists all files
# except . and ..
#
# Mount the empty docker-basics-copy-volume over /etc/skel, in a
# container that runs the true command, which does nothing and
# succeeds. Then mount the same volume at /copy, a directory that is
# not in the image, and list it. The files of the image are now in
# the volume.
echo 'Mounting an empty volume over /etc/skel...'
docker container run --rm --mount \
  'type=volume,source=docker-basics-copy-volume,target=/etc/skel' \
  almalinux:10-minimal \
  true
echo 'The volume now holds a copy of the files from the image:'
docker container run --rm \
  --mount 'type=volume,source=docker-basics-copy-volume,target=/copy' \
  almalinux:10-minimal \
  ls --almost-all --format=long /copy

# Docker copies the files only into an empty volume. A volume that
# already has files hides the files of the image's directory, and is
# not changed. So if a newer image has new or changed files in that
# directory, a volume that was filled from an older image does not
# get them.
#
# Bind mounts are never filled. A bind mount always hides the files of
# the image's directory.
#
# The nocopy option turns the copy off. With --volume, it is written
# as the option after the second colon, as below. With --mount, add
# volume-nocopy to the comma separated list, for example:
#   --mount 'type=volume,source=VOLUME,target=/etc/skel,volume-nocopy'
# The empty docker-basics-nocopy-volume then hides the files of the
# image's directory, and ls --almost-all prints nothing.
echo 'With nocopy, the volume stays empty, and ls prints nothing:'
docker container run --rm \
  --volume 'docker-basics-nocopy-volume:/etc/skel:nocopy' \
  almalinux:10-minimal \
  ls --almost-all /etc/skel
echo '(End of the list.)'

# Where volumes are kept, backups

# docker volume inspect prints the details of a volume. Its
# Mountpoint is the directory on the host where Docker keeps the data
# of the volume. By default, with rootful Docker on Linux, it is
# under /var/lib/docker/volumes/. With rootless Docker, the default
# is ~/.local/share/docker/volumes/ of the user running the daemon.
# Docker's data directory can be configured, so inspect prints the
# actual path on the daemon's host. Docker Desktop keeps the data
# inside its virtual machine. --format picks out the directory
# with a Go template.
docker volume inspect --format='{{.Mountpoint}}' \
  'docker-basics-test-volume'

# DO NOT back up, copy or change the files in that directory
# directly. Docker manages it, its layout can change between Docker
# versions, and a container may be writing to the files at the same
# time.
#
# To back up the data in a volume, go through Docker instead. docker
# container cp copies files out of a container, including from a
# volume mounted in it. The container does not have to be running,
# and the image does not need tar or any other tools. With - in place
# of a host path, docker container cp writes a tar archive to its
# standard output. So the following creates a container that mounts
# the volume without starting it, saves the contents of /test in
# test-volume.tar on the host, and removes the container:
#
#   BACKUP_ID=$(docker container create --mount \
#     'type=volume,source=docker-basics-test-volume,target=/test' \
#     almalinux:10-minimal)
#   docker container cp "$BACKUP_ID:/test" - > test-volume.tar
#   docker container rm "$BACKUP_ID"
#
# Stop any container that writes to the volume first, so that the
# backup does not catch files half written. To restore the backup,
# create a container that mounts a volume at /test in the same way,
# and copy the archive back in with:
#
#   docker container cp - "$RESTORE_ID:/" < test-volume.tar
#
# Another way is to run a container that mounts the volume, as well
# as a directory of the host with a bind mount, and creates a tar
# archive of the volume in that directory. See 06-docker-bind-mounts.sh
# for bind mounts.


# Listing and removing volumes

# You can list all volumes using the docker volume ls command. Its
# --filter option can match names. --filter 'name=docker-basics'
# lists volumes whose names contain docker-basics, which may include
# volumes from other scripts.
docker volume ls

# Anonymous volumes are removed by --rm, as above, or by docker
# container rm --volumes. A plain docker container rm leaves them
# behind, unused, with a random name that does not say what they
# hold. docker volume prune removes all unused anonymous volumes.
# With --all, it also removes every named volume that no container
# uses, which can include data that you want to keep. The script does
# not run it, because it would remove volumes that it did not create.

# If the script is interrupted while a container is running, the
# container may survive and keep its volume in use. The exit trap
# attempts volume cleanup, but it does not remove containers. A
# forced kill (SIGKILL) cannot run the exit trap at all.
#
# To recover, first list and inspect any surviving containers:
#   docker container ls --all --filter 'name=^docker-basics-volume-'
#   docker container inspect CONTAINER_ID
# If the demonstration containers and their data are no longer
# needed, remove the surviving containers, then the leftover volumes:
#   docker container rm --force docker-basics-volume-writer
#   docker container rm --force docker-basics-volume-reader
#   docker volume rm docker-basics-test-volume \
#     docker-basics-copy-volume docker-basics-nocopy-volume
# A command reports an error if that resource was already removed.
# Inspect an existing container before removing it, because a name
# conflict may involve a container from another run.

# You can remove a volume using docker volume rm. Note that you
# cannot remove a volume that is in use by a container, even a
# stopped one. All the containers above have been removed, so the
# volumes are no longer in use. docker volume rm prints the name of
# each volume that it removed.
echo 'Cleaning up...'
docker volume rm 'docker-basics-test-volume' \
  'docker-basics-copy-volume' 'docker-basics-nocopy-volume'
cleanup_cancel 'docker-basics-test-volume'
cleanup_cancel 'docker-basics-copy-volume'
cleanup_cancel 'docker-basics-nocopy-volume'
echo '...cleanup completed.'
