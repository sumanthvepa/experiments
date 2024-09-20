#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  explore-nss-wrapper.py: Print the passwd database entry for user bob

  This explore the use of nss_wrapper from within a python script.
  It is called by explore-nss-wrapper.sh to demonstrate that a 
  private passwd database can be substituted to allow a python
  program to think that user bob exists on the system.

"""
# -------------------------------------------------------------------
# explore-nss-wrapper.py: Explore nss_wrapper from python
#
# Copyright (C) 2024 Sumanth Vepa.
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
import pwd
import sys

# Use python's pwd module to read the password database for user
# 'bob'. This will fail on most systems since user bob might not be
# present in the system's /etc/passwd database. But when called from
# within nss-wrapper, it will use the passwd and group file present
# in this folder.
def read_passwd_db() -> None:
  user: str = 'bob'
  try:
    print(pwd.getpwnam('bob'))
  except KeyError as ex:
    print(f'User {user} not found in the password database', file=sys.stderr)

if __name__ == '__main__':
    read_passwd_db()

