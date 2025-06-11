#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 14-docker-build-postgres-test.sh: Build an unoptimized container
# image that runs postgres
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

# This script creates a Postgres Docker image that has postgres
# installed. Unlike postgres-manual, this image is configured
# to automatically start postgres unless it is told to start
# shell mode or an option like --version is passed to it that
# requires it not to start a postgres daemon.
echo '14-docker-build-postgres-test.sh'

# The script relies on the variables and utility functions defined
# in docker-build-postgres-test-utilities.sh. We source that
# script to get access to those variables and functions.
# Read the source of that script to learn how to build a postgres
# docker image.
source ./docker-build-postgres-test-utilities.sh

download_and_build_postgres_test_image
exit $?
