#!/usr/bin/env python3.12
"""
  project.py: An experimental Python program to create an application projects
"""
import sys

from parsec.command_line import parse
from parsec.errors import ParsecError

def main(args: list[str]) -> int:
  """
    Entry point to the project application.

    Process command line arguments and executed the commands specified
    on the command line.

    :param args: Command line arguments.
    :return:  Exit code, 0 for success, non-zero for failure.
  """
  try:
    cmdline = parse(args)
    print(f'Execute command: {cmdline}')
    return 0
  except ParsecError as ex:
    print(ex, file=sys.stderr)
    return ex.exit_code


if __name__ == "__main__":
  sys.exit(main(sys.argv))
