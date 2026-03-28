"""
  dirents.py: Prints all filenames in a given directory.
"""
from pathlib import Path
import sys


def load_filepaths(dirname: Path) -> list[Path]:
  """
    Load all file paths from the specified directory.

    :param dirname: Path to the directory containing files to be renamed.
    :return: A list of file paths in the directory.
    :raises ValueError: If the directory cannot be read.
  """
  try:
    return [entry for entry in dirname.iterdir() if entry.is_file()]
  except OSError as ex:
    raise ValueError(
      f"Error reading directory {dirname}: {ex}") from ex


def main(args: list[str]) -> None:
  """
    Main function to demonstrate loading all filenames in
    a given directory
  """
  try:
    if len(args) != 2:
      raise ValueError(
        'Expected a directory name. ' +
        f'Usage: {args[0]} <directory>')

    dirpath = Path(args[1])
    filepaths: list[Path] = load_filepaths(dirpath)
    for filepath in filepaths:
      print(filepath)
  except ValueError as ex:
    print(ex)
    sys.exit(1)


if __name__ == '__main__':
  main(sys.argv)
