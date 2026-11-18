#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# application.sh: Check non-root permissions, then execute the application
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
MODE=${1:?Choose direct or gosu}
[[ $(id -u):$(id -g) == 10001:10001 ]]
printf 'Application identity: uid=%s gid=%s pid=%s mode=%s\n' "$(id -u)" "$(id -g)" "$$" "$MODE"
case $MODE in
  direct)
    printf 'written by USER\n' > /demo/prepared/message
    # Redirection happens in a subshell so its permission error is captured.
    if (printf 'must fail\n' > /demo/runtime/forbidden); then
      echo 'Unexpected write to the root-owned runtime directory.' >&2
      exit 1
    else
      STATUS=$?
      [[ $STATUS == 1 ]]
      echo 'USER denied writing root-owned /demo/runtime (status 1).'
    fi
    ;;
  gosu)
    [[ $(cat /demo/runtime/seed) == 'initialized by root' ]]
    printf 'written after gosu\n' > /demo/runtime/message
    ;;
  *) echo "Unknown application mode: $MODE" >&2; exit 1;;
esac
if (printf 'must fail\n' > /root/forbidden); then
  echo 'Unexpected application write to /root.' >&2
  exit 1
else
  STATUS=$?
  [[ $STATUS == 1 ]]
  echo 'Non-root application denied writing /root (status 1).'
fi
# exec replaces this Bash process; the long-running application's PID is 1.
echo "Application ready: $MODE; executing sleep as PID 1."
if [[ $MODE == direct ]]; then touch /demo/prepared/ready; else touch /demo/runtime/ready; fi
exec sleep 600
