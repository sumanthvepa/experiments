#!/usr/bin/env python3.12
"""
  cppproject.py: Create cross-platform C++ project given the Visual
  Studio, Xcode, and Makefile project directories.

  First source the virtual environment:
  source venv/bin/activate

  Then Invoke the script with the following command-line arguments:
  python3 cppproject.py --visual-studio <visual_studio_dir> \
    --xcode <xcode_dir> --makefile <makefile_dir> <project>

  The script will create a new project directory named project, with
  the VisualStudio, Xcode and Makefile projects inside it.
"""
# -------------------------------------------------------------------
# cppproject.py: Create Cross-Platform C++ Projects
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
# -------------------------------------------------------------------
import argparse
import os
import shutil
import sys


def create_parser() \
  -> tuple[argparse.ArgumentParser,
           argparse.Action,
           argparse.Action,
           argparse.Action,
           argparse.Action]:
  """
    Creates a command-line argument parser.

    This method returns the created parser and
    the individual option parsers. The latter
    are useful when you need to raise an exception
    in the event of further error processing.

    :return: A tuple containing (parser, visual_studio_dir_arg,
      xcode_dir_arg, makefile_dir_arg, project_arg)
  """
  parser = argparse.ArgumentParser(
    description='Process project directories for development tools.')
  visual_studio_dir_arg = parser.add_argument(
    '--visual-studio', '-s',
    dest='visual_studio_dir',
    required=True,
    help='Visual Studio directory path')
  xcode_dir_arg = parser.add_argument(
    '--xcode', '-c',
    dest='xcode_dir',
    required=True,
    help='Xcode directory path')
  makefile_dir_arg = parser.add_argument(
    '--makefile', '-m',
    dest='makefile_dir',
    required=True,
    help='Makefile directory path')
  project_arg = parser.add_argument(
    "project",
    help="Project directory path (should not exist)")  
  return parser, visual_studio_dir_arg, xcode_dir_arg, makefile_dir_arg, project_arg


def process_command_line() \
      -> tuple[str, str, str, str]:
  """
    Processes command-line arguments and validates directories.

    :return: A tuple containing (visual_studio_dir,
      xcode_dir, makefile_dir, project_dir) or raises
      an InvalidCommandLine exception if validation fails.
  """
  (
    parser,
    visual_studio_dir_arg,
    xcode_dir_arg,
    makefile_dir_arg,
    project_arg
  ) = create_parser()
  parsed_args = parser.parse_args()

  # Validate directories and raise exceptions
  if os.path.exists(parsed_args.project):
    raise argparse.ArgumentError(
      project_arg,
      f"Project directory '{parsed_args.project}' already exists.")
  if (not parsed_args.visual_studio_dir or not os.path.exists(
        parsed_args.visual_studio_dir)):
    raise argparse.ArgumentError(
      visual_studio_dir_arg,
      f"Directory '{parsed_args.visual_studio_dir}' "
      + "does not exist or is not provided.")
  if not parsed_args.xcode_dir or not os.path.exists(
        parsed_args.xcode_dir):
    raise argparse.ArgumentError(
      xcode_dir_arg,
      f"Directory '{parsed_args.xcode_dir}' "
      + "does not exist or is not provided.")
  if not parsed_args.makefile_dir or not os.path.exists(
        parsed_args.makefile_dir):
    raise argparse.ArgumentError(
      makefile_dir_arg,
      f"Directory '{parsed_args.makefile_dir}' "
      + "does not exist or is not provided.")

  return (
    parsed_args.visual_studio_dir,
    parsed_args.xcode_dir,
    parsed_args.makefile_dir,
    parsed_args.project)


def copy_visual_studio_project_files(project: str, vs_dir: str) -> None:
  project_name = os.path.basename(project)
  filenames = [
    project_name + '.sln',
    os.path.join(project_name, project_name + '.vcxproj'),
    os.path.join(project_name, project_name + '.vcxproj.filters')]
  for filename in filenames:
    input_filename = os.path.join(vs_dir, filename)
    output_filename = os.path.join(project, filename)
    # print(f'Copying {input_filename} to {output_filename}')
    shutil.copy(input_filename, output_filename)


def copy_xcode_project_files(project: str, xcode_dir: str) -> None:
  project_name = os.path.basename(project)
  directory = project_name + '.xcodeproj'
  input_directory = os.path.join(xcode_dir, directory)
  output_directory = os.path.join(project, directory)
  # print(f'Copying directory {input_directory} to {output_directory}')
  shutil.copytree(input_directory, output_directory)


def copy_makefile_project_files(project: str, makefile_dir: str) -> None:
  input_filename = os.path.join(makefile_dir, 'Makefile')
  output_filename = os.path.join(project, 'Makefile')
  # print(f'Copying {input_filename} to {output_filename}')
  shutil.copy(input_filename, output_filename)


def main() -> int:
  """
    Main entry point for the script.

    It processes the command line arguments and prints them
    to the console. 

    :return: The program exit code. 0 for success, 1 for failure.
  """
  try:
    visual_studio_dir, xcode_dir, makefile_dir, project_dir \
      = process_command_line()
    project_name = os.path.basename(project_dir)
    # Print all arguments
    # print(f"Project directory: {project_dir}")
    # print(f"Visual Studio directory: {visual_studio_dir}")
    # print(f"Xcode directory: {xcode_dir}")
    # print(f"Makefile directory: {makefile_dir}")
    os.makedirs(project_dir, exist_ok=True)
    os.makedirs(os.path.join(project_dir, project_name), exist_ok=True)
    copy_visual_studio_project_files(project_dir, visual_studio_dir)
    copy_xcode_project_files(project_dir, xcode_dir)
    copy_makefile_project_files(project_dir, makefile_dir)
    return 0
  except argparse.ArgumentError as e:
    print(e)  # Print the exception message
    return 1


if __name__ == "__main__":
  sys.exit(main())
