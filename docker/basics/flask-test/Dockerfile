# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# flask-test/Dockerfile: Exploratory Docker file to create a
# flask installation running on almalinux:9-minimal
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

# This Dockerfile creates a Flask server running a Flask application
# almalinux:9-minimal. 

FROM almalinux:9-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This a demo image to show how to setup node almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:python-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/python-test"

# Most of the time want the latest available package version
# for python. The default version of python in almalinux:9-minimal
# is 3.9, which is quite old. However, later versions of python
# are available in the almalinux:9-minimal repositories with
# specific version numbers. For example, python3.12 is available
# in the almalinux:9-minimal repositories. So we will install
# that.

# Also note the clean up.

# Finally note that we are creating symbolic links to the python3.12
# and pip3.12 binaries as python3, python and pip3, pip respectively.
# This is to make it easier to use the python interpreter and the
# pip package manager.
RUN microdnf install -y python3.12 python3.12-pip \
    && microdnf clean all \
    && ln -s /usr/bin/python3.12 /usr/bin/python3 \
    && ln -s /usr/bin/pip3.12 /usr/bin/pip3 \
    && ln -s /usr/bin/python3.12 /usr/bin/python \
    && ln -s /usr/bin/pip3.12 /usr/bin/pip

# Create a user and group for running the Flask application.
RUN groupadd --gid=2500 flask
RUN useradd --uid=2500 --gid=flask --no-create-home --shell=/usr/sbin/nologin flask

# Create the directory structure for the Flask application.
RUN mkdir -p /opt/flask
RUN chown -R flask:flask /opt/flask

WORKDIR /opt/flask
USER flask
ENV FLASK_APP="flask_test.flask_test:app"
ENV FLASK_PORT=5000
ENV FLASK_DEBUG=0
ENV VIRTUAL_ENV=/opt/flask/production-venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install the entrypoint script for the Flask application.
COPY --chown=flask:flask entrypoint.sh /opt/flask/entrypoint.sh

# Create a virtual environment for the Flask application.
RUN python3.12 -m venv $VIRTUAL_ENV
# Upgrade pip to the latest version in the virtual environment.
RUN pip3.12 install --no-cache-dir --upgrade pip
RUN pip3.12 install --no-cache-dir gunicorn # Install gunicorn to serve the Flask application.

# Copy production-requirements.txt into the container and install the
# required packages.
COPY --chown=flask:flask production-requirements.txt /opt/flask
# Now install the requirements for the flask application
# DO NOT install flask directly, as it might not match the
# one in the requirements.txt file. In general, it is a good
# idea to install all the requirements from the project's
# requirements.txt file. Gunicorn is the only exception
# as the app does not directly depend on it.
RUN pip3.12 install --no-cache-dir --requirement production-requirements.txt

# Finally, copy the Flask application code into the container.
RUN mkdir -p /opt/flask/flask_test
RUN chown -R flask:flask /opt/flask/flask_test
COPY --chown=flask:flask flask_test /opt/flask/flask_test

# We use an entrypoint script to start the Flask application.
# This script will use the environment variables passed to it (either
# the default values or the ones set by the user when creating the
# container) to start the Flask application using gunicorn or flask.
CMD ["/opt/flask/entrypoint.sh"]