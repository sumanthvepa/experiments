#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  generators.py: Explore generators
"""
# -------------------------------------------------------------------
# generators.py: Explore generators
#
# Copyright (C) 2024-25 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License a
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------
from typing import Iterator, Generator


# pylint: disable=too-many-statements, too-many-locals
def explore_generators() -> None:
  """
    Explore generators

    :return: None
  """
  # The concept of a coroutine is that it can yield values, receive
  # values, or exception, return values (or exception), and be closed.
  # The concept of a generator is that is can only be used to yield
  # values. It can be closed, but it cannot receive values or return
  # values. It can raise exceptions, but it cannot be passed an
  # exception.

  # In Python however, the terms coroutine and generator are often
  # used interchangeably, because all coroutines that use yield, will
  # return an object of type Generator, which is a subtype (but not a
  # subclass -- see structural subtyping) of Iterator.

  # However, Python also has async coroutines (discussed in async/await),
  # which are defined to return an object of type Coroutine, which is
  # a subtype (but not a subclass) of Awaitable. These are not
  # Generator types. These are discussed in async_await.py.

  # In this file we wil explore functions that return the type
  # Generator. We've already seen coroutines that return type
  # Generator in coroutines.py, but here we will explore type
  # Generator[YieldType, SendType, ReturnType] and its parameter
  # types.

  # First we need to note that even if a function has yield in it,
  # it need not return type Generator. It is still a Python generator
  # though. In many cases, where the generator only yields values, it
  # makes sense to use Iterator[YieldType] as the return type, since
  # the SendType and ReturnType are not used.

  # The fibonacci function below is a simple example of a generator
  def fibonacci(n: int) -> Iterator[int]:
    """
      Generate the first n Fibonacci numbers
      :param n: The number of Fibonacci numbers to generate
      :yield: The first n Fibonacci numbers
      :return: An iterator that yields the first n Fibonacci numbers
    """
    a, b = 0, 1
    for _ in range(n):
      yield a
      a, b = b, a + b

  # You can use the iterator returned by the generator to iterate over
  # the values, either in a for loop...
  print('Iterating over the first 10 Fibonacci numbers using a for loop:')
  for f in fibonacci(10):
    print(f, end=' ')
  print()

  # Or explicitly using the next() function
  print('Iterating over the first 10 Fibonacci numbers using while True and next():')
  fbg1 = fibonacci(10)
  try:
    while True:
      f = next(fbg1)
      print(f, end=' ')
  except StopIteration:
    print()

  # I don't really like the above code, because it uses an infinite
  # loop and relies on the StopIteration exception to break out of the
  # loop. I prefer exceptions to be used for exceptional cases, not for
  # control flow. So I would rather use a loop that

  # Here is a better way to do it, if you want to use the next()
  # function explicitly

  # The second argument to next(), below, is the default value to return
  # if the iterator is exhausted. In this case, we are using None as
  # to indicate that the iterator is exhausted. If you don't provide a
  # second argument, next() will raise a StopIteration exception when
  # the iterator is exhausted, which is what we saw in the first
  # example.
  fbg2 = fibonacci(10)
  print(
    'Iterating over the first 10 Fibonacci numbers using a while loop '
    + 'with a conditional and next():')
  # Suppress the type checker warning about the type of None.
  # It's some sort of bug in mypy.
  while (f := next(fbg2, None)) is not None:  # type: ignore[arg-type]
    print(f, end=' ')
  print()

  # The most elegant way to iterate over the values of a generator
  # is to use 'listification', which is a Pythonic way to convert an
  # iterable to a list. This is done using the list() function.
  print(list(fibonacci(10)))

  # The same function could have been written to return
  # Generator[int, None, None] if we wanted to. It's the same thing
  def fibonacci2(n: int) -> Generator[int, None, None]:
    """
      Generate the first n Fibonacci numbers
      :param n: The number of Fibonacci numbers to generate
      :yield: The first n Fibonacci numbers
      :return: A generator that yields the first n Fibonacci numbers
    """
    a, b = 0, 1
    for _ in range(n):
      yield a
      a, b = b, a + b

  print(
    'Iterating over the first 10 Fibonacci numbers using function that returns '
    + 'an object of type Generator[int, None, None]:')
  for f in fibonacci2(10):
    print(f, end=' ')
  print()

  # Generators can also receive values from within the function, at
  # points where they yield. This is done using the invoking send()
  # method on the generator object from outside the function.
  # Here is an example of a generator that receives values
  def accumulator() -> Generator[int, int, None]:
    """
      A generator that accumulates values sent to it
    """
    total = 0
    while True:
      value = yield total  # Yield the current total, and wait for a value to be sent
      total += value  # Add the value to the total

  # Create the generator object
  print('Accumulator generator that accumulates values sent to it:')
  acc = accumulator()
  print(next(acc))  # Start the generator, which will yield the initial total (0)
  for f in range(10):
    t = acc.send(f)
    print(t, end=' ')
  print()
  # The close() method is used to stop a generator that does not exit on its
  # own. It raises a GeneratorExit exception inside the generator, which
  # can be caught if the generator is designed to handle it. In this case,
  # the generator does not handle it, so it will simply stop
  acc.close()  # Stop the generator, because it is in an infinite loop

  # We can also use the return statement to return a value from a
  # generator. This is not the same as returning from a function, but
  # it is used to indicate that the generator is done and to return a
  # value.
  def accumulator2() -> Generator[None, int | None, int]:
    """
      A generator that accumulates values sent to it until a None is
      sent.
    """
    total = 0
    while True:
      value = yield
      if value is None:  # If None is sent, return a string and stop the generator
        break
      total += value  # Add the value to the total
    return total

  # Sending values to accumulator2() is similar to the previous example.
  acc2 = accumulator2()
  print('Accumulator generator that accumulates values sent to it until None is sent:')
  next(acc2)  # Start the generator, which will yield None
  for f in range(10):
    acc2.send(f)

  # The difference is that we can now send None to the generator to terminate it
  # rather than calling close() on it. This raises a StopIteration exception
  # which contains the value returned by the generator.
  try:
    acc2.send(None)
  except StopIteration as ex:
    print(ex.value)  # The value returned by the generator is in the exception

  # Generators can also raise exceptions, which can be caught
  # from outside the generator. The normal raise and try/except
  # statements can be used to raise and catch exceptions.
  def error_generator() -> Generator[None, int, None]:
    """
      A generator that raises an exception when it receives a value
    """
    while True:
      value = yield  # Wait for a value to be sent
      if value < 0:  # If the value is negative, raise an exception
        raise ValueError(f'Negative value received: {value}')

  # Create the generator object
  print('Error generator that raises an exception when a negative value is sent:')
  err_gen = error_generator()
  next(err_gen)  # Start the generator, which will yield None
  try:
    err_gen.send(5)  # Normal value, should not raise an exception
    err_gen.send(-5)  # This will raise an exception
  except ValueError as ex:
    print(f'Caught exception: {ex}')  # Catch the exception raised by the generator

  # One can also use the throw() method on the generator to
  # raise an exception inside the generator.

  def error_receiver() -> Generator[None, None, None]:
    """
      A generator that raises an exception when throw() is called
    """
    try:
      while True:
        yield  # Wait for a value to be sent
    except ValueError as e:
      print(f'Caught exception in generator: {e}')  # Catch the exception raised by throw()

  # Now we can create the generator object and call throw() on it
  print('Error receiver that catches an exception raised by throw():')
  err_rec = error_receiver()
  next(err_rec)  # Prime the generator to run to the first yield
  # Now we can call throw() on the generator to raise an exception
  # However, the way this generator has been written, it will
  # catch the exception, print it and exit the generator.
  # The exit will raise a StopIteration exception, which we need
  # to catch.
  try:
    err_rec.throw(ValueError('This is a test exception'))
  except StopIteration as ex:
    print(f'Caught StopIteration exception: {ex}')

  # It could of course have been written to remain in an infinite loop
  # as shown below, in which case we would need to call close() on it.
  # I prefer this style, because it does not use exceptions for
  # control flow.
  def error_receiver2() -> Generator[None, None, None]:
    """
      A generator that raises an exception when throw() is called
      and does not catch it.
    """
    while True:
      try:
        yield  # Wait for a value to be sent
      except ValueError as e:
        # Catch the exception raised by throw() inside the while loop
        print(f'Caught exception in generator: {e}')

  # Create the generator object
  print('Error receiver that catches an exception raised by throw() and does not exit:')
  err_rec2 = error_receiver2()
  next(err_rec2)  # Prime the generator to run to the first yield
  # Now we can call throw() on the generator to raise an exception
  err_rec2.throw(ValueError('This is another test exception'))
  # The generator will catch the exception and print it, but will
  # not exit. We can call close() on it to stop it.
  err_rec2.close()  # Stop the generator, because it is in an infinite loop

  # In some situations, you may want to usa a generator to add to
  # the output of another generator. One way to do this as follows:
  def fibonacci_repeated(n: int) -> Generator[int, None, None]:
    """
      Generate the same sequence fibonacci numbers twice
      :param n: The length of sequence to generate
      :yield: The first n Fibonacci numbers squared
      :return: A generator that yields the first n Fibonacci numbers squared
    """
    # The yield from statement is used to yield values from
    # another generator until it is exhausted, without the need for
    # a loop.
    yield from fibonacci(n)  # Will keep yield the output of fibonacci(n) until it is exhausted
    yield from fibonacci(n)  # Will do the same again, yielding the same values

  # Now we can use the generator to get the first 10 Fibonacci numbers
  # twice
  print('Fibonacci numbers repeated twice using yield from:')
  print(list(fibonacci_repeated(10)))

  # Now consider a more complex example where we want to manipulate
  # the values yielded by a generator inside another generator.
  # Since we are not really using the SendType or ReturnType, we can
  # use Iterator[YieldType] as the return type.
  def square(generator: Iterator[int]) -> Iterator[int]:
    """
      A generator that squares the values yielded by another generator
      :param generator: The generator to square the values of
      :yield: The squared values of the input generator
      :return: An iterator that yields the squared values of the input generator
    """
    yield from (n * n for n in generator)  # Use a generator expression to square the values

  # Now we can use the square generator to square the first 10 Fibonacci numbers
  print('Squaring the first 10 Fibonacci numbers using a generator that squares the values:')
  print(list(square(fibonacci(10))))


if __name__ == '__main__':
  explore_generators()
