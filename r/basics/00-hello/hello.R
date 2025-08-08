#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# hello.R: The canonical first program
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

# Installing R on macOS
# I use macports to install R on macOS.
# sudo port install R
# sudo port install R-app

# Create a directory named libs (if you have not already done so)
# The directory will be common for multiple R projects, so choose
# a location that is convenient for those projects.
# I chose the location r/libs relative to the git repository root
# in this repository.

# Start R from the terminaal and invoke
# .libPaths("libs"), the path should be the path to the libs directory.
# It can be a relative path.
# Now install the jsonlite package which the VSCode R language server
# requires.
# install.packages("jsonlite")
# You may be propted to select a CRAN mirror.

# Now open a file named .Rprofile in your R project root. This
# directory is the directory from where you will run R. Or
# if you are using VSCode, it is the folder that you open that
# contains the R project you want to work on.
# Add the following line to the .Rprofile file:
# .libPaths("libs")
# Replace libs with the path to the libs directory you created
# earlier. This will ensure that the R interpreter uses the libs
# directory as the library path for all R projects in this
# repository. The path can be relative to .Rprofile file or an
# absolute path.

# Using R in VSCode
# Install the R extension for VSCode.
# Search for the R extension in the VSCode marketplace and install it.
# This will also install the R language server. (It may take a while
# to install the R language server, as it has to compile a bunch of
# stuff so be patient.) It's not clear to me if I have to install
# a Clang or GCC compiler to supprt the R language server installation.
# But I have both installed on my macOS system so it seems to work.

# This is the first program you should run in R.
print("Hello, World!")
