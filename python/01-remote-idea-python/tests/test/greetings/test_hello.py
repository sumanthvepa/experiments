"""
  test_hello.py: Unit tests for the greetings.hello module.
"""
import unittest

from greetings.hello import message


class TestHello(unittest.TestCase):
  """ Unit tests for the greetings.hello module. """
  def test_message(self) -> None:
    """ Test the message function in greetings.hello. """
    name = 'World'
    expected = f"Hello, {name}!"
    actual = message(name)
    self.assertEqual(expected, actual)
