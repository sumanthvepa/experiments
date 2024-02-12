#!/usr/bin/env python3
"""
  args.py: This script prints out all the arguments passed to it.
"""
import sys


def main(argv: list[str]) -> None:
  """
    This function prints out all the arguments passed to it.
    :param argv: list[str] - list of arguments passed to the script
    :return: None
  """
  for arg in argv[1:]:
    print(arg)


if __name__ == '__main__':
  main(sys.argv)
