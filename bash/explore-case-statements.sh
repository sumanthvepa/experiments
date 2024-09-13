#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# explore-case-statements.sh: Explore case statements in Bash
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

# case statments in bash are defined as follows:
EXPRESSION='postgres'
case $EXPRESSION in
  'mysql')
    echo 'You choose MySQL'
    ;;
  'postgres')
    echo 'You chose PostgreSQL'
    ;;
  *)
    echo 'You chose poorly!'
    ;;
esac

# The case is actually a pattern. For example
FILENAME='picture.jpg'
case $FILENAME in
  *.jpg)
    echo 'You chose a JPEG file'
    ;;
  *.png)
    echo 'You chaose a PNG file'
    ;;
  *)
    echo 'You chose garbage'
    ;;
esac

# The pattern is not a full regular expression,
# but the file globbing patterns that bash supports.
# ChatGPT reports that the following patterns are
# supported:
# Pattern Syntax:
# *: Matches any string, including an empty string.
# ?: Matches exactly one character.
# [abc]: Matches any single character inside the brackets.
# [a-z]: Matches any single character in the range.
# |: Separates multiple patterns (acts like an OR).
