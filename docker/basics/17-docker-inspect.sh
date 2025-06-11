#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 17-docker-inspect.sh: Explore the docker inspect command
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

echo '17-docker-inspect'

# The docker inspect command is used to get detailed information about
# a docker artifact: a container, image, network, or volume. The
# output is in JSON format.

# First lets build an image with labels
docker build --tag nginx-test ./nginx-test

# The output is a JSON object with a lot of information about the image.
echo "JSON Metadata of the image nginx-test:"
echo "---------------------------------------------------------------"
docker inspect nginx-test
echo "---------------------------------------------------------------"

# The output can be filtered using the --format flag. For example, to
# get the ID of the image, you can use the following command:
echo "ID of the image:"
echo "---------------------------------------------------------------"
docker inspect --format='{{.Id}}' nginx-test
echo "---------------------------------------------------------------"

# The --format flag uses the Go template language. You can use any
# valid Go template to format the output.
# In particular to see a subsection of the full JSON output, you can
# use the following command. The format string is a Go template that
# means the following. The {{ }} indicate that the value inside should
# be replaced by the value of the field in the JSON object. The .NAME
# is the field in the JSON object that we want to extract. The . is the
# root of the JSON object. json is a filter that converts the object
# retrieve  by .NAME to a JSON object.
# For details on docker inspect, look at the docker reference:
# https://docs.docker.com/reference/cli/docker/inspect/
# Go templates are described here:
# https://pkg.go.dev/text/template
echo "Config section of the image:"
echo "---------------------------------------------------------------"
docker inspect --format='{{json .Config}}' nginx-test
echo "---------------------------------------------------------------"


# If you want a nice formatted output, you can use the jq command
# which is a command line JSON processor. You can install it with
# the following command:
dnf -y install jq

# Now you can use the jq command to format the output of the docker
# inspect command.
echo "Config section of the image (formatted):"
echo "---------------------------------------------------------------"
docker inspect --format='{{json .Config}}' nginx-test | jq
echo "---------------------------------------------------------------"


# You can see all the labels of the image with the following command
echo "Labels of the image:"
echo "---------------------------------------------------------------"
docker inspect --format='{{json .Config.Labels}}' nginx-test | jq
echo "---------------------------------------------------------------"

# Docker inpect can be used to get information about containers as well.
# First we will run a container from the image
docker container run --name nginx-test-container --detach nginx-test

# Now we can inspect the container
echo "JSON Metadata of the container nginx-test-container:"
echo "---------------------------------------------------------------"
docker inspect nginx-test-container | jq
echo "---------------------------------------------------------------"

# If you want to explicty specify the type of object you want to inspect
# you can use the --type flag. For example, to inspect the image
echo "JSON Metadata of the image nginx-test, using --type option:"
echo "---------------------------------------------------------------"
docker inspect --type=image nginx-test | jq
echo "---------------------------------------------------------------"

# An alternative syntax is to use the type as a subcommand
## docker container inspect nginx-test-container
echo "JSON Metadata of the image ginx-test, using subcommand:"
echo "---------------------------------------------------------------"
docker image inspect nginx-test | jq
echo "---------------------------------------------------------------"

# To inspect the container
echo "Labels of the container nginx-test-container, using subcommand:"
echo "---------------------------------------------------------------"
docker container inspect --format='{{json .Config.Labels}}' nginx-test-container | jq
echo "---------------------------------------------------------------"

# To inspect a network
# TODO: Create a network for inspection
# docker inspect --type=network bridge

# Cleanup: Stop and remove the container
docker container stop nginx-test-container
docker container rm nginx-test-container

# Cleanup: Remove the image
docker image rm nginx-test
