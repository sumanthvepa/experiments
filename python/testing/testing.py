"""
  testing.py: An exploration of python unit tests
"""

# This project demonstrates how one can create a project with
# unit tests in python. The project is structured as follows:
# testing.py - The main driver file (same name as the project itself)
#   |
#   +-- sample/  This directory (which is a package) contains the main
#   |     |      functionality of the project. There can be multiple
#   |     |      such modules at this level.
#   |     |
#   |     +-- sample.py  This module contains functionality used by
#   |                    testing.py. Obviously there can be many such
#   |                    modules.
#   +-- tests/  This directory (which is a package) contains the unit
#          |    tests for the project.
#          |
#          +-- test_sample.py  This module contains the unit tests for
#                              the sample module. It imports the sample
#                              module and tests the functions in it.

from sample import sum_of, broken_sum_of, fibonacci

def main() -> None:
  """
    Main function
    This is just a dummy driver function for the project.

    As a convention, I create function called main that
    calls all the main functionality of the project.

    In general, the main function should be as simple as possible,
    since we typically will not write unit tests for it.

    All important code should be in the modules used by main.

    In this case main is really not useful, as the purpose of the
    project is to demonstrate unit tests.

    # see test/test_sample.py for the unit tests and how to write
    # and run them.

    :return: None
  """
  print(sum_of(45, 67))
  print(broken_sum_of(45, 67))
  print(fibonacci(40))



if __name__ == '__main__':
  main()
