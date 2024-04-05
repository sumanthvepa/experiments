#!/usr/bin/env python3
"""
  check-metal.py: Check if Apple M1 Metal GPU acceleration is available
"""

import torch

# Checks if Apple M1 Metal GPU acceleration is available

if torch.backends.mps.is_available():
  mps_device = torch.device("mps")
  x = torch.ones(1, device=mps_device)
  print('Apple Silicon Metal GPU acceleration is available')
  print(x)
else:
  print('MPS device not found.')
