"""
  samply.py: This is a sample python file with some methods need are unit tested
"""


def sum_of(a: int, b: int) -> int:
  """
  Add two numbers
  :param int a: The first number
  :param int b: The second number
  :return int: The sum of the two numbers
  """
  return a + b

def broken_sum_of(a: int, b: int) -> int:
  """
  Add two numbers incorrectly

  This is used to demonstrate a failing test case

  :param int a: The first number
  :param int b: The second number
  :return int: The sum of the two numbers plus 1
  """
  return a + b + 1

# noinspection PyUnusedLocal
def fibonacci(n: int) -> list[int]:  # pylint: disable=unused-argument
  """
  Generate the first n Fibonacci numbers
  :param n: The number of Fibonacci numbers to generate
  :return: A list of the first n Fibonacci numbers
  """
  result: list[int] = []
  index: int = 0
  while index < n:
    if index <= 1:
      result.append(index)
    else:
      result.append(result[index - 1] + result[index - 2])
    index += 1
  return result
