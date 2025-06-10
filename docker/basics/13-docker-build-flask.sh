#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 13-docker-build-flask.sh: Explore building a flask application image
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

echo '13-docker-build-flask.sh'

# There isn't much to do outside of the Dockerfile to build
# a Flask application image.
docker build --tag flask-test ./flask-test

# Let's set the port that the Flask application will run on.
FLASK_PORT=5000

# Now we can run the image (we have to detach it so that it runs in
# the background)
docker container run --name=flask-test --detach --publish "$FLASK_PORT":"$FLASK_PORT" flask-test

# Now we can check if the Flask application is running
echo "Waiting for the flask service to start..."
IS_FLASK_SERVER_READY=0
while [[  $IS_FLASK_SERVER_READY -ne 200 ]]; do
  sleep 5
  IS_FLASK_SERVER_READY=$(curl --silent --output /dev/null --write-out "%{http_code}" http://localhost:"$FLASK_PORT"/)
done
echo "Flask service has started successfully"

# Now we can test the Flask application by sending a request to it
# (Well, if execution has reach here, then we've already done that,
# but we'll do it again to show that it works)
curl http://localhost:"$FLASK_PORT"/

# We can stop stop the container now that we've tested it
docker container stop flask-test

# We now wait for the container to stop
docker wait flask-test

# Now we can remove the container
docker container rm flask-test

# Finally we clean up by removing the image
docker image rm flask-test
