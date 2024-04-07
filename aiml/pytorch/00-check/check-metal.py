#!/usr/bin/env python3
"""
  check-metal.py: Test availability of Apple Silicon GPU accleration
"""
#--------------------------------------------------------------------
# check-metal.py: Test avaibility of Apple Silicon GPU acceleration
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

# Checks if Apple M1 Metal GPU acceleration is available

if torch.backends.mps.is_available():
  mps_device = torch.device("mps")
  x = torch.ones(1, device=mps_device)
  print('Apple Silicon Metal GPU acceleration is available')
  print(x)
else:
  print('MPS device not found.')
