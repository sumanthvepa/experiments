#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# initialize.sh: Initialize owned container data before dropping privileges
#
# Copyright (C) 2026 Sumanth Vepa.
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

set -euo pipefail
[[ $(id -u):$(id -g) == 0:0 ]]
[[ $(stat --format='%u:%g:%a' /demo/runtime) == 0:0:700 ]]
printf 'Initializer identity: uid=%s gid=%s pid=%s\n' "$(id -u)" "$(id -g)" "$$"
printf 'initialized by root\n' > /demo/runtime/seed
[[ $(stat --format='%u:%g' /demo/runtime/seed) == 0:0 ]]
echo 'Root initialized seed; runtime directory before: 0:0:700.'
# Only this container's known private directory is changed; no host mounts.
chown --recursive 10001:10001 /demo/runtime
[[ $(stat --format='%u:%g:%a' /demo/runtime) == 10001:10001:700 ]]
echo 'Runtime directory after initialization: 10001:10001:700.'
# Both exec and gosu replace the process rather than retaining a root parent.
exec gosu 10001:10001 /usr/local/bin/application.sh "$@"
