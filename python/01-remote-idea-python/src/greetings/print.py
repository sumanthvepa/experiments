"""
  print.py: Print greeting messages
"""

from greetings.hello import message


def print_hello(name: str) -> None:
  """
  Print a greeting message to the console.

  :param name: The greeting message.
  """
  print(message(name))
