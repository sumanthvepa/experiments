# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# flask-test/Dockerfile: Exploratory Docker file to create a
# flask installation running on almalinux:10-minimal
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

# This Dockerfile creates a Flask server running a Flask application
# almalinux:10-minimal.

FROM almalinux:10-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs a Flask application on almalinux:10-minimal"

# AlmaLinux 10 defaults to Python 3.12. See lesson 12 for RPM paths.
# Keep package-owned /usr/bin paths intact; the venv provides python/pip.
# shadow-utils supplies groupadd/useradd. The existing coreutils false
# executable denies logins without assuming nologin is installed.
RUN microdnf install -y python3 python3-pip shadow-utils \
    && microdnf clean all \
    && python3 -c "import sys; assert sys.version_info[:2] == (3, 12)" \
    && python3 -m pip --version \
    && test -x /usr/bin/false \
    && groupadd --gid=2500 flask \
    && useradd --uid=2500 --gid=flask --no-create-home --shell=/usr/bin/false flask \
    && mkdir -p /opt/flask \
    && chown flask:flask /opt/flask

WORKDIR /opt/flask
USER flask
# Gunicorn and Python tooling may write user state below HOME. This
# application directory is owned by flask; no host home is mounted.
ENV HOME=/opt/flask
ENV FLASK_APP="flask_test.flask_test:app"
ENV FLASK_PORT=5000
ENV FLASK_DEBUG=0
ENV VIRTUAL_ENV=/opt/flask/production-venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# venv isolates app dependencies from RPM-managed Python. Install as the
# runtime user; python -m pip selects the venv's installer unambiguously.
RUN python3 -m venv "$VIRTUAL_ENV" \
    && python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir gunicorn
COPY --chown=flask:flask production-requirements.txt /opt/flask/
# Install the project's pinned requirements, rather than a separate Flask
# version. Gunicorn serves the WSGI application and is not an app import.
RUN python -m pip install --no-cache-dir --requirement production-requirements.txt \
    && python -m pip check
COPY --chown=flask:flask entrypoint.sh /opt/flask/entrypoint.sh
COPY --chown=flask:flask flask_test /opt/flask/flask_test

# CMD starts the script in exec form. It chooses Gunicorn or the Flask
# development server from FLASK_DEBUG and exec replaces the shell with it.
# Arguments passed directly to the script are executed instead; ordinary
# Docker arguments after the image replace this CMD (see lesson 09).
CMD ["/opt/flask/entrypoint.sh"]
