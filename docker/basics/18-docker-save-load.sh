#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 18-docker-save-load.sh: Explore the docker save and load commands
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

# Stop on failed commands, unset inputs and failed pipelines. Resolve source
# paths from this script, so invocation from any working directory works.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./docker-build-postgres-test-utilities.sh

echo '18-docker-save-load: archive and restore a PostgreSQL image'
# Host: bash /path/to/18-docker-save-load.sh
# Requires the Docker/Buildx, curl, sha256sum and core tools checked by the
# shared builder, plus tar, ls and cmp. Network access supplies native AlmaLinux
# and PGDG packages (GitHub only if gosu is missing). No host psql, sudo,
# published port, firewall change or earlier tutorial resource is needed.
# Use a local Linux daemon matching an x86_64 or arm64 host. Native arm64
# with Docker's classic image store is tested; other daemon modes are not.
die_if_not_available tar ls cmp
die_if_not_docker_available
postgres_test_architecture
IMAGE_NAME="postgres-test:linux-$ARCH_SUFFIX"
CONTAINER_NAME=postgres-save-load-test
EXPORT_CONTAINER=postgres-filesystem-export-test
IMPORT_CONTAINER=postgres-filesystem-import-test
IMPORT_IMAGE="postgres-filesystem:linux-$ARCH_SUFFIX"

# Guard every additional fixed name before the builder acquires anything.
# Conflicts are preserved; inspect them instead of deleting them to rerun.
die_if_docker_container_exists "$EXPORT_CONTAINER" "$IMPORT_CONTAINER"
die_if_docker_image_exists "$IMPORT_IMAGE"

# A label unique to our private directory closes the create/import window:
# even if the client fails before returning an ID, cleanup finds only this
# run's resources. After acquisition, commands below use immutable IDs.
# These callbacks check each failure explicitly because cleanup runs in an
# if condition (see bash-utilities.sh).
remove_filesystem_containers() {
  local ids id
  ids=$(docker container ls --all --quiet --no-trunc --filter "label=$FILESYSTEM_LABEL") || return $?
  for id in $ids; do docker container rm --force "$id" || return $?; done
}
remove_filesystem_image() {
  local ids id
  ids=$(docker image ls --all --quiet --no-trunc --filter "label=$FILESYSTEM_LABEL") || return $?
  for id in $ids; do docker image rm "$id" || return $?; done
}

# 1. Build independently; refuse an existing tag/container before setup.
# Lesson 15 explains this context's automatic PostgreSQL initialization.
# The helper builds in an owned temporary copy, checks the native base,
# and registers cleanup before acquiring images. Existing files are never
# deleted to make room for an archive. mktemp gives us a private directory;
# umask also restricts archive/readback files to this user's access.
download_and_build_postgres_test_image "$IMAGE_NAME" "$CONTAINER_NAME"
umask 077
ARCHIVE_DIRECTORY=$(mktemp --directory --tmpdir docker-basics-save-load.XXXXXXXX)
cleanup_add save-load-archive rm -rf -- "$ARCHIVE_DIRECTORY"
TARBALL_NAME="$ARCHIVE_DIRECTORY/postgres-test-linux-$ARCH_SUFFIX.tar"
FILESYSTEM_TAR="$ARCHIVE_DIRECTORY/container-filesystem.tar"
FILESYSTEM_LABEL="org.docker-basics.save-load.run=${ARCHIVE_DIRECTORY##*/}"
IMAGE_ID=$(docker image inspect --format '{{.Id}}' "$IMAGE_NAME")
IMAGE_PLATFORM=$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$IMAGE_NAME")
IMAGE_TAGS=$(docker image inspect --format '{{json .RepoTags}}' "$IMAGE_NAME")
[[ $IMAGE_PLATFORM == "linux/$ARCH_SUFFIX" ]] || die "Unexpected image platform: $IMAGE_PLATFORM"
printf 'Before save: %s %s %s\n' "$IMAGE_ID" "$IMAGE_PLATFORM" "$IMAGE_TAGS"
read -r -p 'Press ENTER to continue...'

# 2. docker save (alias: docker image save) writes image layers, image
# configuration and selected tags to a tar archive. Naming repo:tag here
# selects this tag; naming a repository without a tag can save more tags.
# --output avoids writing binary archive data to the terminal.
# This is an IMAGE archive, not a backup of a running database/container.
# docker export writes a container filesystem (excluding volume contents);
# docker import creates a filesystem image. That pair does not preserve
# the image's layers, startup configuration and tags as save/load does.
docker save --output "$TARBALL_NAME" "$IMAGE_NAME"
[[ -s $TARBALL_NAME ]] || die 'docker save produced an empty archive.'
tar --list --file "$TARBALL_NAME" > "$ARCHIVE_DIRECTORY/members.txt"
[[ -s $ARCHIVE_DIRECTORY/members.txt ]] || die 'The archive has no members.'
sha256sum "$TARBALL_NAME" > "$ARCHIVE_DIRECTORY/archive.sha256"
ls -lh -- "$TARBALL_NAME"
echo "Verified nonempty tar archive: $TARBALL_NAME"
read -r -p 'Press ENTER to continue...'

# 3. Remove only our tag; an image may still have other tags or consumers.
# A failed removal stops the lesson, rather than claiming a restore test.
# image ls shows local images; the explicit lookup proves this tag is gone.
clean_up_existing_image "$IMAGE_NAME"
REMAINING=$(docker image ls --quiet "$IMAGE_NAME")
[[ -z $REMAINING ]] || die "Saved tag still exists: $IMAGE_NAME"
docker image ls -a
echo "Verified saved tag absent: $IMAGE_NAME"
sha256sum --check "$ARCHIVE_DIRECTORY/archive.sha256"
# Register BEFORE load: an interrupted/failed client can already have
# restored the tag in the daemon. This run saved the trusted archive itself.
POSTGRES_TEST_OWNED_IMAGE=$IMAGE_NAME
cleanup_add postgres-test-image remove_postgres_owned_tag "$IMAGE_NAME"
docker load --input "$TARBALL_NAME"
LOADED_ID=$(docker image inspect --format '{{.Id}}' "$IMAGE_NAME")
LOADED_PLATFORM=$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$IMAGE_NAME")
LOADED_TAGS=$(docker image inspect --format '{{json .RepoTags}}' "$IMAGE_NAME")
[[ $LOADED_ID == "$IMAGE_ID" && $LOADED_PLATFORM == "$IMAGE_PLATFORM" && $LOADED_TAGS == "$IMAGE_TAGS" ]] ||
  die 'Loaded image ID, platform or tags differ from the saved image.'
printf 'After load: %s %s %s\n' "$LOADED_ID" "$LOADED_PLATFORM" "$LOADED_TAGS"
docker image ls -a
read -r -p 'Press ENTER to continue...'

# 4. A successful load is storage, not proof of CPU compatibility/runtime
# usability. Start the restored image and verify password-authenticated SQL
# over container-local TCP, with no published port or host data mount.
export POSTGRES_PASSWORD=save-load-demo-only
CONTAINER_ID=$(docker container create --name "$CONTAINER_NAME" --env POSTGRES_PASSWORD "$IMAGE_NAME")
register_postgres_test_container "$CONTAINER_ID" "$CONTAINER_NAME"
docker container start "$CONTAINER_ID"
wait_for_postgres_test "$CONTAINER_ID"
RESULT=$(docker container exec --env PGPASSWORD="$POSTGRES_PASSWORD" "$CONTAINER_ID" \
  psql --no-psqlrc --set ON_ERROR_STOP=1 --host=127.0.0.1 --username=postgres \
  --dbname=postgres --tuples-only --no-align --command 'SELECT current_user, current_database(), 6 * 7;')
[[ $RESULT == 'postgres|postgres|42' ]] || die "Unexpected restored database result: $RESULT"
echo "Verified restored PostgreSQL TCP query: $RESULT"
read -r -p 'Press ENTER to continue...'

# Loading foreign-architecture image data does not translate its programs.
# Running it needs a compatible CPU or configured emulation; support depends
# on the daemon's image store/platform facilities. save/load transfer the
# variants already present, rather than building or combining architectures.
# Current Docker supports --platform filtering with API1.48+ where the image
# store supports it; an unavailable variant fails. See lesson 23,
# 23-docker-buildx.sh for multi-platform building and build exports.
# https://docs.docker.com/reference/cli/docker/image/save/
# https://docs.docker.com/reference/cli/docker/image/load/
# https://docs.docker.com/reference/cli/docker/container/export/
# https://docs.docker.com/reference/cli/docker/image/import/
# https://docs.docker.com/build/building/multi-platform/

# 5. export (alias: docker container export) writes a container filesystem,
# including its writable layer. Bypass PostgreSQL with --entrypoint /bin/bash:
# this container only writes a harmless file, never initializes/runs PGDATA.
# Single quotes keep this small command for the container shell to interpret.
# Register BEFORE create, so a failed client cannot strand a new container.
ORIGINAL_STARTUP=$(docker image inspect --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' "$IMAGE_ID")
cleanup_add filesystem-source remove_filesystem_containers
EXPORT_ID=$(docker container create --name "$EXPORT_CONTAINER" --label "$FILESYSTEM_LABEL" \
  --entrypoint /bin/bash "$IMAGE_ID" -c 'printf "filesystem marker: 42\n" > /tutorial-filesystem-marker')
docker container start "$EXPORT_ID"
STATUS=$(docker container wait "$EXPORT_ID")
[[ $STATUS == 0 ]] || die "Filesystem marker writer failed: $STATUS."
# wait established a clean exit; export the stopped container by ID.
docker container export --output "$FILESYSTEM_TAR" "$EXPORT_ID"
[[ -s $FILESYSTEM_TAR ]] || die 'docker export produced an empty archive.'
# cmp compares bytes, including the final newline; process substitution
# supplies the expected text without creating another temporary file.
tar --extract --to-stdout --file "$FILESYSTEM_TAR" tutorial-filesystem-marker | \
  cmp --silent - <(printf 'filesystem marker: 42\n')
echo "Verified stopped filesystem archive: $FILESYSTEM_TAR"
read -r -p 'Press ENTER to continue...'

# import (alias: docker image import) creates a new image from the tar.
# Supply its tag separately. --change adds only our ownership LABEL here:
# deliberately do not reconstruct ENTRYPOINT, CMD or the other image config.
# Register BEFORE import, covering daemon success followed by client failure.
cleanup_add filesystem-image remove_filesystem_image
IMPORTED_ID=$(docker image import --change "LABEL $FILESYSTEM_LABEL" "$FILESYSTEM_TAR" "$IMPORT_IMAGE")
IMPORTED_STARTUP=$(docker image inspect --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' "$IMPORTED_ID")
[[ $IMPORTED_STARTUP == 'null null' || $IMPORTED_STARTUP == '[] []' ]] || \
  die "Imported image unexpectedly retained startup configuration: $IMPORTED_STARTUP"
RETAINED_STARTUP=$(docker image inspect --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}' "$IMAGE_ID")
[[ $RETAINED_STARTUP == "$ORIGINAL_STARTUP" ]] || die 'Original startup configuration changed.'
printf 'Original startup retained: %s\nImported startup absent: %s\n' "$RETAINED_STARTUP" "$IMPORTED_STARTUP"
# With no default command, supply the shell and command explicitly. Again,
# register before create, then use the returned immutable container ID.
cleanup_add filesystem-check remove_filesystem_containers
IMPORT_ID=$(docker container create --name "$IMPORT_CONTAINER" --label "$FILESYSTEM_LABEL" \
  --entrypoint /bin/bash "$IMPORTED_ID" -c \
  'cmp --silent /tutorial-filesystem-marker <(printf "filesystem marker: 42\n")')
docker container start "$IMPORT_ID"
STATUS=$(docker container wait "$IMPORT_ID")
[[ $STATUS == 0 ]] || die "Imported filesystem marker verification failed: $STATUS."
echo 'Verified imported filesystem marker bytes; startup defaults were not transferred.'
# export excludes volume contents. This is neither a live database backup
# nor a volume backup: see 05-docker-volume-mounts.sh for data backup/lifetime.
# save/load preserved the original image contract; export/import required
# a new name and explicit runtime configuration. Archive sizes depend on
# content/storage; this comparison is not a size benchmark.
read -r -p 'Press ENTER to continue...'

# 6. Normal cleanup is visible; EXIT/INT/TERM cover earlier failures too.
docker container rm "$IMPORT_ID"
cleanup_cancel filesystem-check
docker image rm "$IMPORTED_ID"
cleanup_cancel filesystem-image
docker container rm "$EXPORT_ID"
cleanup_cancel filesystem-source
docker container stop "$CONTAINER_ID"
STATUS=$(docker container wait "$CONTAINER_ID")
[[ $STATUS == 0 ]] || die "Restored PostgreSQL shutdown failed: $STATUS."
clean_up_existing_container "$CONTAINER_ID"
clean_up_existing_image "$IMAGE_NAME"
rm -rf -- "$ARCHIVE_DIRECTORY"
cleanup_cancel save-load-archive
echo 'Lesson complete; restored container, image tag and temporary archive removed.'
# EXIT also removes the temporary build context and a base acquired here.
# A pre-existing base is preserved. Build cache may remain. SIGKILL cannot
# run traps: inspect postgres-save-load-test, postgres-filesystem-{export,import}-test,
# postgres-filesystem:linux-<arch>, the printed archive directory
# and postgres-test:linux-<arch> before removing only identified leftovers.
# Do not run concurrent writers against the same lesson tag/container.
