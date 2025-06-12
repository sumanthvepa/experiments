#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 20-docker-build-website.sh: Explore building a website served by
# nginx in a Docker container
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

echo '20-docker-build-website.sh'

# We extend the ideas in 08-docker-build-basics.sh where we built an
# nginx container image.

# The primary difference with this image is that it customizes the
# /etc/nginx/nginx.conf file to serve a serve static content, but
# additionally, it is also configured to act as a reverse proxy
# for a web service running on port 5000.

# The docker build context is the website-test directory.
docker image build --tag website-test ./website-test
if [[ $? -ne 0 ]]; then
    echo 'Failed to build the website-test image.'
    exit 1
fi

WEBSITE_PORT=8080
# The image is built successfully, now we can run a container from
# this image.
docker container run --detach \
    --name website-test
    --publish 8080:80 
    --env FLASK_HOST='darkness2.milestone42.com:5000' website-test


# Now we can check if the website has started successfully
echo "Waiting for the website to start..."
IS_WEBSITE_READY=0
while [[  $IS_WEBSITE_READY -ne 200 ]]; do
  sleep 5
  IS_WEBSITE_READY=$(curl --silent --output /dev/null --write-out "%{http_code}" http://localhost:"$WEBSITE_PORT"/)
done
echo "Flask service has started successfully"
