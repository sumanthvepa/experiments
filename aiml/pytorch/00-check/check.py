#!/usr/bin/env python3
""
  check.py: Check that pytorch has been installed correctly
""
#--------------------------------------------------------------------
# check.py: Check that pytorch has been installed correctly
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
#--------------------------------------------------------------------

import torch

# Check that pytorch is installed correctly.
# This example is taken from:
# https://pytorch.org/get-started/locally/
x = torch.rand(5, 3)
print(x)
