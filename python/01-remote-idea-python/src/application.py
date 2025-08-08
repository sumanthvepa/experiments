"""
  application.py: Entry point for the application.
"""
from greetings.print import print_hello

def main() -> None:
  """
  Main function to start the application.
  """
  print_hello('Dear User')


if __name__ == "__main__":
  main()
