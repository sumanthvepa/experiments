#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-build-postgres-test-utilities.sh: A collection of utility
# functions for building the postgres-test Docker image
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

# This script contains utility functions that are used to download
# relevant files and build the postgres-test Docker image.
# It is intended to be sourced by other scripts that need to build
# the postgres-test Docker image.
# To use this script, source it in the script that needs to build
# the postgres-test Docker image. Then call the function
# download_and_build_postgres_test_image to download the necessary
# files and build the image. If the return value of this function
# is non-zero, then the image build failed and the calling script
# should clean up and exit with the returned error code.
# Write code as follows:
# source ./docker-build-postgres-test-utilities.sh
# download_and_build_postgres_test_image
# exit $?

# We need to know the architecture of the CPU that the script is
# running on so that we can download the appropriate Postgres
# RPM and gosu binary.
CPU_ARCHITECTURE=$(uname -m)
echo "CPU architecture as reported by 'uname -m' is $CPU_ARCHITECTURE"
# Determine the architecture suffix to be used to
# get the appropriate Postgres RPM and gosu binary distribution
if [[ "$CPU_ARCHITECTURE" == "x86_64" ]]; then
  ARCH_SUFFIX='amd64'
elif [[ "$CPU_ARCHITECTURE" == "aarch64" ]]; then
  ARCH_SUFFIX='arm64'
fi


# Clean up any previously running container with the given name
function clean_up_existing_container() {
  # Get the name of the container from the first argument to the function
  # or use 'postgres-test-test' as the default container name.
  local container_name=${1:-'postgres-test-test'}

  # Check if the container exists before doing anythig
  local container_exists=$(docker container ps --quiet --all --filter name=$container_name)
  if [[ ! -z $container_exists ]]; then
    echo "Stopping existing container: $container_name"
    # Stop the container first before removing it.
    docker container stop $container_name
    # Wait for the container to stop. It takes some time for the container
    # shutdown gracefully and be removed. Just keep checking if the container
    # is still running every 10 seconds. The loop exits when the container
    # is no longer running.
    while [[ ! -z  $container_exists ]]; do
      sleep 10
      container_exists=$(docker container ps --quiet --all --filter name=$container_name)
    done
    # Remove the container
    echo "Removing existing container: $container_name"
    docker container rm $container_name
  fi
  return 0
}

function clean_up_existing_image() {
  # Get the name of the image from the first argument to the function
  # or use 'postgres-test' as the default image name.
  local image_name=${1:-'postgres-test'}
  # Check if the postgres-test image exists and remove it if it does.
  local image_exists=$(docker image ls --quiet $image_name)
  if [[ ! -z $image_exists ]]; then
    echo "Removing existing image: $image_name"
    docker image rm $image_name
  fi
  return 0
}


function download_postgres_repo_rpm() {
  # Download the postgres RPM from the postgres repository if it
  # not present in the postgres-test directory
  local postgres_repo_rpm="./postgres-test/${ARCH_SUFFIX}/pgdg-redhat-repo-latest.noarch.rpm"
  local postgres_repo_rpm_url="https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${CPU_ARCHITECTURE}/pgdg-redhat-repo-latest.noarch.rpm"
  if [[ ! -f $postgres_repo_rpm ]]; then
    echo "${postgres_repo_rpm}  not found"
    # Create architecture-specific download directory
    mkdir -p ./postgres-test/${ARCH_SUFFIX}
    echo "Downloading from postgres repository"
    echo "URL: $postgres_repo_rpm_url"
    curl -fsSL $postgres_repo_rpm_url -o $postgres_repo_rpm
    if [[ $? -ne 0 ]]; then
      echo "Failed to download the Postgres repository RPM"
      return 1
    fi
  fi
  return 0
}

function download_gosu_binary() {
  # Download gosu for the given architecture if it is not present in the
  # postgres-test directory.
  local gosu_binary="./postgres-test/${ARCH_SUFFIX}/gosu-${ARCH_SUFFIX}"
  local gosu_binary_url="https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH_SUFFIX}"
  local gosu_signature="./postgres-test/${ARCH_SUFFIX}/gosu-${ARCH_SUFFIX}.asc"
  local gosu_signature_url="https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH_SUFFIX}.asc"

  if [[ ! -f $gosu_binary ]]; then
    echo "${gosu_binary} not found"
    # Create architecture-specific download directory
    mkdir -p ./postgres-test/${ARCH_SUFFIX}
    echo "Downloading gosu from the official repository"
    echo "URL: $gosu_binary_url"
    curl -fsSL $gosu_binary_url -o $gosu_binary
    if [[ $? -ne 0 ]]; then
      echo "Failed to download the gosu binary"
      return 1
    fi
    curl -fsSL $gosu_signature_url -o $gosu_signature
    if [[ $? -ne 0 ]]; then
      echo "Failed to download the gosu signature"
      return 1
    fi
  fi
  return 0
}

function build_postgres_test_image() {
  # Now we can build the Postgres Docker image
  # Set the tagname for the image to 'postgres-test' by default
  # unless it is provided as an argument to the function (the first
  # argument.)
  local tag=${1:-'postgres-test'}
  docker build --tag $tag --build-arg ARCH_SUFFIX=${ARCH_SUFFIX} ./postgres-test
  if [[ $? -ne 0 ]]; then
    echo "Failed to build the Postgres Docker image"
    return 1
  fi
  echo "Postgres Docker image built successfully"
  return 0
}

function download_and_build_postgres_test_image() {
  # Get the name of the image from the first argument to the function
  # or use 'postgres-test' as the default image name.
  local image_name=${1:-'postgres-test'}

  # Get the name of the container from the second argument to the function
  # or use 'postgres-test-test' as the default container name.
  # TODO: What really needs to happen here is that we need to stop
  # and remove all containers that are based on the image $image_name
  local container_name=${2:-'postgres-test-test'}
  clean_up_existing_container $container_name
  clean_up_existing_image $image_name
  download_postgres_repo_rpm
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  download_gosu_binary
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  build_postgres_test_image $image_name
  if [[ $? -ne 0 ]]; then
    return 1
  fi
}
