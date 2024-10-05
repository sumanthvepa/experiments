#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 13-docker-build-postgres.sh: Explore building a postgres Docker
# image
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

echo '13-docker-build-postgres-manual.sh'

# We need to know the architecture of the CPU that the script is
# running on so that we can download the appropriate Postgres
# RPM and gosu binary.
CPU_ARCHITECTURE=$(uname -m)

echo "CPU architecture as reported by 'uname -m' is $CPU_ARCHITECTURE"

# Determine the architecture suffix to be used to
# get the appropriate Postgres RPM and gosu binary distribution
if [ "$CPU_ARCHITECTURE" == "x86_64" ]; then
  ARCH_SUFFIX='x64'
elif [ "$CPU_ARCHITECTURE" == "aarch64" ]; then
  ARCH_SUFFIX='arm64'
fi

# Download the postgres RPM from the postgres repository if it
# not present in the postgres-manual directory
POSTGRES_REPO_RPM="./postgres-manual/pgdg-redhat-repo-latest.noarch.rpm"
#POSTGRES_REPO_RPM_URL="https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${CPU_ARCHITECTURE}/pgdg-redhat-repo-latest.noarch.rpm"
POSTGRES_REPO_RPM_URL="https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-aarch64/pgdg-redhat-repo-latest.noarch.rpm"
if [ ! -f $POSTGRES_REPO_RPM ]; then
  echo "${POSTGRES_REPO_RPM}  not found"
  echo "Downloading from postgres repository"
  curl -fsSL $POSTGRES_REPO_RPM_URL -o $POSTGRES_REPO_RPM
fi

# Download gosu for the given architecture if it is not present in the
# postgres-manual directory.
GOSU_BINARY="./postgres-manual/gosu"
GOSU_BINARY_URL="https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH_SUFFIX}"
GOSU_SIGNATURE="./postgres-manual/gosu.asc"
GOSU_SIGNATURE_URL="https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH_SUFFIX}.asc"

if [ ! -f $GOSU_BINARY ]; then
  echo "${GOSU_BINARY} not found"
  echo "Downloading gosu from the official repository"
  curl -fsSL $GOSU_BINARY_URL -o $GOSU_BINARY
  curl -fsSL $GOSU_SIGNATURE_URL -o $GOSU_SIGNATURE
fi

# Now we can build the Postgres Docker image
docker build --tag postgres-manual ./postgres-manual
