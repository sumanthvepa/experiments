#!/usr/bin/env python3.12
'''
  parseargs.py: Explore the use of the argparse library
'''
# -------------------------------------------------------------------
# parseargs.py: Explore the use of the argparse library
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('project')
parser.add_argument('--foo', dest='foo', required=True)

args = parser.parse_args()

print(args.foo)
print(args.project)
