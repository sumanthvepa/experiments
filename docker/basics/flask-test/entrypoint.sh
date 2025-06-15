#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# flask-test/entrypoint.sh: Entry point script to start gunicorn
# to run a Flask application.
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

# This entry point script looks at the values of various environment
# variable and either runs flask or gunicorn to run the Flask
# application specified by the FLASK_APP environment variable on the
# port specified by FLASK_PORT environment variable.

# First check if the any command line arguments were passed to
# this script. If so, just run them as a command.
if [[ $# -gt 0 ]]; then
    exec "$@"
fi

# Check if the FLASK_APP and FLASK_PORT environment variables are set.
if [[ -z "$FLASK_APP" ]]; then
    echo "FLASK_APP environment variable is not set. Exiting."
    exit 1
fi
if [[ -z "$FLASK_PORT" ]]; then
    echo "FLASK_PORT environment variable is not set. Exiting."
    exit 1
fi

# Finally run either flask or gunicorn based on the value of
# the FLASK_DEBUG environment variable.
# Note the use of `exec` to replace the shell with the Flask or
# Gunicorn process. This allows the Flask process to receive signals
# directly, such as SIGTERM for graceful shutdown.
if [[ "$FLASK_DEBUG" == "1" ]]; then
  exec flask --app="$FLASK_APP" run --host=0.0.0.0 --port="$FLASK_PORT"
else
  exec gunicorn --workers=2 --bind=0.0.0.0:"$FLASK_PORT" "$FLASK_APP"
fi
