#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 06-docker-bind-mounts.sh: Explore docker bind mounts
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

echo '06-docker-bind-mounts'

# Stop on unexpected errors, unset variables and failed pipelines.
set -euo pipefail

# Change to the directory of this script, so that the relative paths
# used below, such as ./bind-test, work wherever the script is run
# from. With set -e on, the script stops if the cd fails.
cd "$(dirname "${BASH_SOURCE[0]}")"

# Use the same error and cleanup helpers as 05-docker-volume-mounts.sh.
source ./bash-utilities.sh

# The script uses cmp on the host to check that created-on-host.txt
# holds its original contents. cmp is not part of coreutils. It is
# usually in the diffutils package. Check for it before creating
# anything, so that a missing cmp is not reported as a changed file.
if ! command -v cmp >/dev/null; then
  die 'This script needs cmp, usually in the diffutils package.' \
    'Install it with the package manager of your Linux distribution.'
fi

# Bind mounts

# A bind mount makes a directory or a file of the host appear at a
# path in the container. A volume is storage that Docker manages in a
# directory of its own (see 05-docker-volume-mounts.sh). A bind mount
# can use any path on the host, and Docker does not manage the files.
# The container and the host see the same files. A change made on one
# side is seen at once on the other, and the files stay on the host
# when the container is removed. So bind mounts are useful to give a
# development container the source code that you are editing on the
# host, or to give a server its configuration or content.
#
# The other side of this is that a program in the container can
# change or delete the files on the host. Mount only what the
# container needs, and mount it read only if the container only needs
# to read it. See Read only bind mounts below.

# Here, "host" means the machine running the Docker daemon. With a
# remote Docker context, the source must exist on that remote machine;
# Docker does not upload the files from the client. These examples
# assume a local Linux daemon, so Docker and the host-side commands
# use the same files. Docker Desktop has its own file-sharing support
# between your machine and the daemon's virtual machine.

# The examples use the files in ./bind-test. created-on-host.txt is
# part of the repository and holds the line "created on the host".
# The first example asks you to change it, and to create
# created-in-container.txt next to it. The second creates
# created-with-user.txt. The cleanup below puts ./bind-test back as it
# was. The --mount and --volume example creates ./bind-missing, and
# removes it. The host side commands use the full paths, so that the
# paths in the messages work from any directory.
BIND_TEST_DIR="$PWD/bind-test"
HOST_FILE="$BIND_TEST_DIR/created-on-host.txt"
CONTAINER_FILE="$BIND_TEST_DIR/created-in-container.txt"
USER_FILE="$BIND_TEST_DIR/created-with-user.txt"
MISSING_DIR="$PWD/bind-missing"
HOST_FILE_TEXT='created on the host'

# Your user and group ids on the host, for the chown and --user
# examples below.
HOST_UID=$(id --user)
HOST_GID=$(id --group)

# docker info --format prints the security options of the Docker
# daemon with a Go template, for example
# [name=seccomp,profile=builtin name=cgroupns]. They show whether the
# daemon is rootless, uses userns-remap or uses SELinux.
SECURITY_OPTIONS=$(docker info --format='{{.SecurityOptions}}')
ROOTLESS='no'
if [[ $SECURITY_OPTIONS == *name=rootless* ]]; then
  ROOTLESS='yes'
fi

# 22-docker-rootless.sh covers running Docker commands without sudo
# and running container programs as non-root users. Rootless Docker,
# where the daemon also runs without root privileges, is a separate
# configuration, detected here. That script does not yet cover it.

# A rootful daemon can also use userns-remap, which maps root and
# other container ids to subordinate ids on the host. Unlike
# rootless Docker, root in the container is then not your host user.
# The chown and --user examples below would use the wrong ids, and
# the container may not be able to write to ./bind-test. Stop before
# starting containers or registering cleanup for the host files.
if [[ $SECURITY_OPTIONS == *name=userns* ]]; then
  die 'Docker uses userns-remap, which this script does not support.' \
    'The bind mount ownership examples require rootful Docker without' \
    'userns-remap, or rootless Docker. See the comments in' \
    "$PWD/06-docker-bind-mounts.sh."
fi

# SELinux, on hosts such as Fedora and AlmaLinux, labels every file
# and process, and its rules decide which labels a process may use.
# Docker can be configured to use it, with "selinux-enabled": true in
# /etc/docker/daemon.json. Each container then runs with a label that
# lets it use only files labelled for containers. The files in your
# home directory are not, so reading a bind mount of them fails with
# "Permission denied", even though the file permissions allow it.
# --volume takes the options z, to relabel the source so that all
# containers can use it, and Z, so that only this container can, for
# example --volume ./bind-test:/mnt:z. --mount has no such options.
# Relabelling changes the files on the host. Never relabel a system
# directory, or your whole home directory. Docker CE, which
# 01-install-docker.sh installs, does not use SELinux by default. So
# the script stops if Docker uses it, rather than relabel files.
if [[ $SECURITY_OPTIONS == *name=selinux* ]]; then
  die 'Docker uses SELinux, so the bind mounts in this script would' \
    'fail with "Permission denied". See the comments on SELinux in' \
    "$PWD/06-docker-bind-mounts.sh."
fi

# A run that was stopped part way, for example with kill -KILL, which
# cannot be trapped, may have left files behind. Stop rather than
# remove or overwrite files that this run did not create. rm can
# remove the files even if root owns them, as explained below.
# -e follows symbolic links, so also use -L to catch dangling links.
for LEFTOVER in "$CONTAINER_FILE" "$USER_FILE" "$MISSING_DIR"; do
  if [[ -e $LEFTOVER || -L $LEFTOVER ]]; then
    die "$LEFTOVER is left over from an earlier run. If you no" \
      "longer need it, remove it with: rm --recursive --force $LEFTOVER"
  fi
done

# cmp --silent compares every byte, including the final newline.
# <(...) gives it the expected line as a file without creating one
# on disk. Unlike $(cat ...), this preserves trailing newlines in
# the comparison, so cleanup cannot silently discard blank lines.
# A missing or unreadable host file also makes cmp fail.
if ! cmp --silent "$HOST_FILE" <(printf '%s\n' "$HOST_FILE_TEXT"); then
  die "$HOST_FILE does not hold the line \"$HOST_FILE_TEXT\"," \
    'possibly because an earlier run was stopped part way. Restore' \
    "it with: git restore $HOST_FILE"
fi

# restore_bind_test: put ./bind-test back as it was before the
# examples, for cleanup_add. It removes the files that the examples
# create there, and writes the original line back into
# created-on-host.txt.
#
# rm can remove a file that root owns, because removing a file
# changes the directory that holds it, not the file, and you own
# ./bind-test. --force makes rm ignore files that do not exist, and
# not ask before removing a file that you cannot write to.
restore_bind_test() {
  rm --force "$CONTAINER_FILE" "$USER_FILE" || return $?
  echo "$HOST_FILE_TEXT" >"$HOST_FILE" || return $?
}

# Save the cleanup before the first container starts, so that
# ./bind-test is put back even if the script stops part way. The end
# of the script cleans up itself, and then cleanup_cancel forgets the
# saved command.
cleanup_add bind-test restore_bind_test

# die_container_failed, from bash-utilities.sh, stops the script
# after an interactive docker container run returns a non-zero
# status, and explains what may have gone wrong. If the Docker client
# itself is killed, the container may still be running. See the
# recovery commands near the end of the script.


# Bind mounting a directory with --mount

# For a bind mount there is no need to create anything first. Give
# --mount the type bind, and a path on the host as the source. Like a
# volume mount (see 05-docker-volume-mounts.sh), it takes a comma
# separated list of key=value pairs:
# type=bind: Specifies that this is a bind mount.
# source=./bind-test: The directory on the host. src is a short alias
#   for source.
# target=/mnt: The directory in the container where it is mounted.
#   dst and destination are aliases for target.
#
# The docker command turns a relative source into a full path, using
# its current directory, which is the directory of this script.
# Docker 23.0 and later accept relative paths. Older versions need a
# full path, such as "$PWD/bind-test".
#
# The image has an empty /mnt directory. A bind mount hides whatever
# the image has at the target. See A bind mount hides the files of the
# image, below.

# Files and ownership
#
# The kernel stores the owner of a file as a number, the user id
# (uid), and its group as a group id (gid). Names such as root are
# looked up in /etc/passwd and /etc/group, and the container has its
# own copies of these files. So ls in the container shows the owner of
# created-on-host.txt as a number, because the image has no user with
# your uid.
#
# In the default rootful configuration, root in the container is
# root, uid 0, on the host. bash in the container runs as root, so the
# file that it creates is owned by root on the host too, and you
# cannot change it there without sudo. chown in the container gives
# the file to your uid and gid. Running the container with your own
# ids, as the next example does, avoids the problem.
#
# With rootless Docker, the daemon runs as your user, and root in the
# container is your own user on the host. So the file is already
# yours. Do not chown it to your uid in the container. Other uids in
# the container are mapped to other uids on the host, so your uid in
# the container is not you on the host.
#
# As in 05-docker-volume-mounts.sh, --rm removes the container when
# you exit bash, and --name gives the container a name for the error
# messages and for the recovery commands below.
echo 'In a bind mount, a directory of the host is mounted at a'
echo 'directory in the container. ./bind-test is mounted at /mnt.'
echo 'In the container, show the file that is already on the host:'
echo '    cat /mnt/created-on-host.txt'
echo "This prints '$HOST_FILE_TEXT'. Then create a file, and list the"
echo 'files with their owners:'
echo "    echo 'created in the container' > /mnt/created-in-container.txt"
echo '    ls --format=long /mnt'
if [[ $ROOTLESS == 'yes' ]]; then
  echo 'Docker is rootless, so the new file is already yours on the host.'
else
  echo 'The new file is owned by root. Give it to your user on the'
  echo 'host, or the host cannot change it:'
  echo "    chown $HOST_UID:$HOST_GID /mnt/created-in-container.txt"
fi
# Inspect while the container is running: --rm removes it on exit.
# The json template prints only the Mounts field. Its Source is the
# full path used by the daemon, useful when diagnosing a wrong path.
echo 'While the container is running, in a second terminal on the host,'
echo 'inspect the mount that Docker created:'
echo '    docker container inspect \'
echo "      --format '{{json .Mounts}}' docker-basics-bind-mount"
echo 'Type should be "bind", Source the full path to bind-test, and'
echo 'Destination "/mnt". RW is true here; a read only mount has RW false.'
echo 'Propagation is "rprivate", the default. The note on nested mounts'
echo 'and propagation in the script explains what it means.'
echo 'Next, in that host terminal, change the line in'
echo 'created-on-host.txt, and add a line to created-in-container.txt:'
printf "    echo 'modified on the host' > %q\n" "$HOST_FILE"
printf "    echo 'modified on the host' >> %q\n" "$CONTAINER_FILE"
echo 'Back in the container, see the changes:'
echo '    cat /mnt/created-on-host.txt /mnt/created-in-container.txt'
echo 'Then leave the container with:'
echo '    exit 0'
read -r -p 'Press ENTER to start the container...'

# Stop on every non-zero status. See 05-docker-volume-mounts.sh for
# why to leave with exit 0, and why || saves the status.
SHELL_STATUS=0
docker container run \
  --name='docker-basics-bind-mount' \
  --mount 'type=bind,source=./bind-test,target=/mnt' \
  --interactive \
  --tty \
  --rm \
  almalinux:10-minimal || SHELL_STATUS=$?
if [[ $SHELL_STATUS -ne 0 ]]; then
  die_container_failed 'docker-basics-bind-mount' "$SHELL_STATUS"
fi

# Exiting the shell successfully does not prove that the commands
# worked. Check on the host that the file written in the container is
# there. grep --fixed-strings --line-regexp looks for exactly this
# line, and --quiet prints nothing. grep fails if the line or the file
# is missing.
if ! grep --quiet --fixed-strings --line-regexp \
  'created in the container' "$CONTAINER_FILE"; then
  die "Expected $CONTAINER_FILE to hold the line" \
    '"created in the container". Check any error above and run the' \
    'script again.'
fi

# ls on the host shows the owners by name.
echo 'The container has been removed, but the file that it created'
echo 'is still on the host:'
ls --format=long "$BIND_TEST_DIR"
echo 'With the changes made in the container and on the host:'
cat "$HOST_FILE" "$CONTAINER_FILE"


# Running the container with your own user and group ids

# --user sets the uid, and optionally the gid, that the program in the
# container runs as, in place of the user given by the image, which is
# root for almalinux:10-minimal. id --user and id --group printed your
# ids on the host above. The files that the program creates in a bind
# mount are then owned by you, and no chown is needed. id in the
# container prints the ids. The image has no user with your uid, so id
# prints only numbers, and an interactive bash would show "I have no
# name!" in its prompt. The program runs as an ordinary user, so it
# cannot do what needs root in the container, such as installing
# packages with microdnf.
#
# With rootless Docker, root in the container is already you, and
# your uid in the container is another uid on the host, as explained
# above. So the script skips this example with rootless Docker.
if [[ $ROOTLESS == 'yes' ]]; then
  echo 'Docker is rootless, so the --user example is skipped.'
else
  echo 'Creating a file in the bind mount with --user...'
  docker container run --rm \
    --user "$HOST_UID:$HOST_GID" \
    --mount 'type=bind,source=./bind-test,target=/mnt' \
    almalinux:10-minimal \
    bash -c 'id && echo "created with --user" > /mnt/created-with-user.txt'

  # stat --format=%u prints the uid of the owner of the file.
  if [[ $(stat --format=%u "$USER_FILE") != "$HOST_UID" ]]; then
    die "Expected $USER_FILE to be owned by uid $HOST_UID."
  fi
  echo 'The new file is owned by you on the host:'
  ls --format=long "$USER_FILE"
fi


# .dockerignore does not filter runtime bind mounts

# .dockerignore excludes matching paths from an image's build context.
# It has no effect on a bind mount made by docker container run.
# ./bind-test/.dockerignore excludes created-on-host.txt from a build
# whose context is ./bind-test. The read only mount below still lets
# cat read that file. Likewise, mounting a project directory can expose
# readable .env files and .git contents, even if a build excludes them.
# Mount only the directory or file that the container needs.
echo './bind-test/.dockerignore excludes created-on-host.txt from builds'
echo 'using ./bind-test as their context. A runtime mount still exposes it:'
echo 'The exclusion pattern, followed by the file contents:'
docker container run --rm \
  --mount 'type=bind,source=./bind-test,target=/mnt,readonly' \
  almalinux:10-minimal \
  cat /mnt/.dockerignore /mnt/created-on-host.txt


# --mount and --volume with a source that does not exist

# The --volume option is an older, shorter way to mount. It takes the
# source, the target and, optionally, a comma separated list of
# options, separated by colons:
#   --volume source:target[:options]
# A source that starts with /, ./ or ../ is a bind mount. A plain name
# is a named volume (see 05-docker-volume-mounts.sh).
#
# The two options differ when the source does not exist on the host.
# --mount fails with "bind source path does not exist", and docker
# container run returns 125, which means that Docker itself failed
# before the container started. --volume creates the missing directory
# instead. The Docker daemon creates it, so in the default rootful
# configuration it is owned by root. A mistyped path then silently
# gives the container a new, empty directory in place of your files.
# This is the main reason to prefer --mount.
#
# The Docker documentation says that --mount does not create a missing
# source on the host. Both options create the target, the mount point,
# in the container if the image does not have it. /test is not in
# almalinux:10-minimal, but the containers below find it.
echo 'First, --mount with a source directory that does not exist fails:'
MOUNT_STATUS=0
docker container run --rm \
  --mount 'type=bind,source=./bind-missing,target=/test' \
  almalinux:10-minimal \
  true || MOUNT_STATUS=$?
if [[ $MOUNT_STATUS -ne 125 ]]; then
  die 'Expected --mount to fail with status 125, but it returned' \
    "$MOUNT_STATUS."
fi
echo 'As expected, Docker did not start the container.'

# remove_missing_dir: remove ./bind-missing, which --volume creates
# below, for cleanup_add. It does nothing if the directory does not
# exist, for example if the script stops before --volume runs. rmdir
# removes only an empty directory, so it cannot remove files by
# mistake. It works although root owns the directory, because removing
# it changes the directory of this script, which you own.
remove_missing_dir() {
  if [[ -e $MISSING_DIR ]]; then
    rmdir "$MISSING_DIR" || return $?
  fi
}
cleanup_add bind-missing remove_missing_dir

# ls --directory lists /test itself, and not the files in it.
echo 'With --volume, Docker creates the source directory on the host,'
echo 'and the mount point /test in the container:'
docker container run --rm \
  --volume './bind-missing:/test' \
  almalinux:10-minimal \
  ls --directory --format=long /test
echo 'Notice the owner of the new directory on the host:'
ls --directory --format=long "$MISSING_DIR"
rmdir "$MISSING_DIR"
cleanup_cancel bind-missing

echo '--mount also creates the mount point /test in the container:'
docker container run --rm \
  --mount 'type=bind,source=./bind-test,target=/test' \
  almalinux:10-minimal \
  ls --format=long /test


# Read only bind mounts

# Add readonly to the --mount options, or the option ro to --volume, to
# mount a directory read only. ro is also a short alias for readonly
# in --mount. The container can read the files, but it cannot create,
# change or remove them. This is the usual way to give a container
# source code, content or configuration that it only reads.
# 02-docker-container-basics.sh mounts ./hello-world-nginx read only
# in this way, for nginx to serve. A read only mount only stops the
# container. You can still change the files on the host, and the
# container sees the changes.
echo 'Next, ./hello-world-nginx is mounted read only at /test.'
echo 'You can list and read the files:'
echo '    ls --format=long /test'
echo '    cat /test/index.html'
echo 'But you cannot create any files in /test. This fails with'
echo '"Read-only file system":'
echo '    touch /test/readonly-test.txt'
echo 'Then leave the container with:'
echo '    exit 0'
read -r -p 'Press ENTER to start the container...'

# Stop on every non-zero status, as above. The touch fails, so leave
# with exit 0, and not plain exit.
SHELL_STATUS=0
docker container run \
  --name='docker-basics-bind-readonly' \
  --mount 'type=bind,source=./hello-world-nginx,target=/test,readonly' \
  --interactive \
  --tty \
  --rm \
  almalinux:10-minimal || SHELL_STATUS=$?
if [[ $SHELL_STATUS -ne 0 ]]; then
  die_container_failed 'docker-basics-bind-readonly' "$SHELL_STATUS"
fi

# Check the same with --volume and ro, in a container that runs one
# command, without a terminal. The ls works, but the touch fails with
# 1. Any other status means that something else went wrong. 0 means
# that the directory could be written to, so the example would be
# misleading. touch then created the file, so remove it.
echo 'Mounting the same directory read only with --volume.'
echo 'ls works, but touch fails:'
WRITE_STATUS=0
docker container run --rm \
  --volume './hello-world-nginx:/test:ro' \
  almalinux:10-minimal \
  bash -c 'ls --format=long /test && touch /test/readonly-test.txt' ||
  WRITE_STATUS=$?
if [[ $WRITE_STATUS -eq 0 ]]; then
  rm --force "$PWD/hello-world-nginx/readonly-test.txt"
  die 'The read only bind mount could be written to. Stopping.'
elif [[ $WRITE_STATUS -ne 1 ]]; then
  die "The read only example failed with status $WRITE_STATUS."
fi
echo 'As expected, the container could not write to the directory.'


# Advanced note: nested mounts and propagation

# A source directory can contain another mounted filesystem. Docker
# includes these existing submounts by default. Later mount and
# unmount events are different from edits to ordinary files: the
# default propagation, rprivate, does not pass such events between
# the host and container. File edits remain visible as shown above.
# docker container inspect, in the first example, shows the
# propagation of a mount as "Propagation": "rprivate".
# bind-propagation changes this behavior on Linux when the host's
# mounts support it. Docker Desktop does not support propagation.
#
# Read only submounts need Docker Engine 25.0 or later, and Linux 5.12
# or later. Before Docker Engine 25.0, submounts were always writable,
# even when the main bind mount was read only. From 25.0, on older
# kernels, submounts remain writable by default. With --mount,
# readonly,bind-recursive=readonly requires read only submounts and
# fails on an older kernel. --volume has no bind-recursive option.
# bind-recursive controls inclusion and read only handling of
# submounts; it is separate from propagation. These examples need
# neither option.


# A bind mount hides the files of the image

# Docker fills an empty volume with the files that the image has at
# the target (see 05-docker-volume-mounts.sh). A bind mount is never
# filled. It hides the files that the image has at the target, for as
# long as it is mounted. The files of the image are not changed.
#
# /etc/skel of almalinux:10-minimal holds .bash_logout, .bash_profile
# and .bashrc. Their names start with a dot, so ls shows them only
# with --almost-all (-A), which lists all files except . and ..
# With ./bind-test mounted over /etc/skel, ls shows the files of
# ./bind-test in their place. The mount is read only, so that nothing
# can change ./bind-test.
echo 'The files in /etc/skel of the image:'
docker container run --rm \
  almalinux:10-minimal \
  ls --almost-all /etc/skel
echo 'With ./bind-test mounted over /etc/skel, its files take their place:'
docker container run --rm \
  --mount 'type=bind,source=./bind-test,target=/etc/skel,readonly' \
  almalinux:10-minimal \
  ls --almost-all /etc/skel


# Bind mounting a single file

# The source can also be a file. The target is then a file in the
# container. This is useful to give a program a single configuration
# file, without hiding the rest of the directory that holds it.
#
# A bind mount of a file follows the file itself, and not its name.
# Many editors, and sed --in-place, save a file by writing a new file
# and renaming it over the old one. The container then keeps seeing
# the old contents, until it is started again. To see such changes,
# mount the directory that holds the file. --volume, given a single
# file that does not exist, creates a directory with that name.
#
# The mount below uses the short aliases src, dst and ro, to fit on
# one line.
echo 'Mounting created-on-host.txt as the file /file.txt:'
docker container run --rm \
  --mount 'type=bind,src=./bind-test/created-on-host.txt,dst=/file.txt,ro' \
  almalinux:10-minimal \
  cat /file.txt


# Recovering from an interrupted run

# If the script is interrupted while a container is running, the
# container may survive. The exit trap restores ./bind-test and
# removes ./bind-missing, but it does not remove containers. A forced
# kill (SIGKILL) cannot run the exit trap at all.
#
# To recover, first list and inspect any surviving containers:
#   docker container ls --all --filter 'name=^docker-basics-bind-'
#   docker container inspect CONTAINER_ID
# If the demonstration containers are no longer needed, remove them:
#   docker container rm --force docker-basics-bind-mount
#   docker container rm --force docker-basics-bind-readonly
# A command reports an error if that container was already removed.
# Inspect an existing container before removing it, because a name
# conflict may involve a container from another run. Then, from the
# directory of this script, remove the files that the examples create,
# and restore created-on-host.txt:
#   rm --recursive --force ./bind-test/created-in-container.txt \
#     ./bind-test/created-with-user.txt ./bind-missing
#   git restore ./bind-test/created-on-host.txt


# Clean up

# Put ./bind-test back as it was, and forget the saved cleanup
# command.
echo 'Cleaning up...'
restore_bind_test
cleanup_cancel bind-test
echo '...cleanup completed.'
