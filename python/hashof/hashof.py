#!/usr/bin/env python3
"""
  hashof.py: This script takes a message as an argument and returns
  the MD5 hash of the message.
"""

import hashlib
import sys


def main(argv: list[str]) -> None:
  """
  This function takes a list of messages as an argument and prints the
  MD5 hash and length of each message.
  :param argv: The command line arguments
  :return: None
  """
  for message in argv[1:]:
    hex_digest = hashlib.md5(message.encode()).hexdigest()
    print(hex_digest)
    print(len(hex_digest))


if __name__ == '__main__':
  main(sys.argv)
