#!/usr/bin/env python3
"""
  random_points.py: Generate random points in 2D space
"""

import argparse
import json
import pprint
import random
import sys

from dataclasses import dataclass


@dataclass()
class RandomPointsSpecification:
  """ Random points specification """
  n: int
  min_x: float
  max_x: float
  min_y: float
  max_y: float


def process_command_line(argv: list[str]) -> RandomPointsSpecification:
  """
    Process command line arguments.

    This program takes the following arguments:
    -n, --number: Number of random points to generate, the default is 10
    --minx: Minimum x value, the default is 0
    --maxx: Maximum x value, the default is 1
    --miny: Minimum y value, the default is 0
    --maxy: Maximum y value, the default is 1

    :return: Random points specification
  """
  parser = argparse.ArgumentParser(description='Generate random points in 2D space')
  parser.add_argument(
    '-n', '--number', type=int, default=10, help='Number of random points to generate')
  parser.add_argument('--minx', type=float, default=0, help='Minimum x value')
  parser.add_argument('--maxx', type=float, default=1, help='Maximum x value')
  parser.add_argument('--miny', type=float, default=0, help='Minimum y value')
  parser.add_argument('--maxy', type=float, default=1, help='Maximum y value')
  args = parser.parse_args(argv)
  return RandomPointsSpecification(args.number, args.minx, args.maxx, args.miny, args.maxy)


def random_points(n: int, x0: float, x1: float, y0: float, y1: float) -> list[tuple[float, float]]:
  """
    Generate random points in 2D space
    :param n: Number of points to generate
    :param x0: Minimum x value
    :param x1: Maximum x value
    :param y0: Minimum y value
    :param y1: Maximum y value
    :return: List of random points
  """
  points = []
  for _ in range(n):
    x = random.uniform(x0, x1)
    y = random.uniform(y0, y1)
    points.append((x, y))
  return points


def main():
  """
    Generate random points in 2D space
  """
  spec = process_command_line(sys.argv[1:])
  points = random_points(spec.n, spec.min_x, spec.max_x, spec.min_y, spec.max_y)
  print(json.dumps(points))


if __name__ == '__main__':
  main()
