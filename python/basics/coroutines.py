#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  coroutines.py: Explore coroutines
"""
# -------------------------------------------------------------------
# coroutines.py: Explore coroutines
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
import random
from datetime import datetime
from typing import Callable, Generator, Iterator

# This a custom module I wrote to parse system logs
import syslog


# pylint: disable=too-many-locals, too-many-statements
def explore_coroutines() -> None:
  """ Explore coroutines in Python. """
  # A coroutine is a special type of function that can pause and
  # resume its execution. Python allows the programmer to define
  # the points at which the coroutine can pause and yield control
  # back to the caller. When called again, the coroutine resumes
  # execution from the point it was paused, (i.e. it retains the
  # state of its local variables).

  # Consider a coroutine that generates a sequence of numbers:
  def counter(limit: int) -> Iterator[int]:
    """
      A simple coroutine that generates numbers up to a specified
      limit.
      :param limit: The upper limit for the number generation.
      :return: An iterator that yields numbers from 0 to limit - 1.
    """
    # We just write a loop that calls `yield` with a number each
    # time the while loop iterates. The `yield` statement pauses the
    # coroutine and returns the value to the caller. The next time the
    # function is called, it resumes execution from the point it was
    # paused, retaining the state of its local variable n.
    n = 0
    while n < limit:
      yield n
      n += 1

  # Now we can use this coroutine to generate numbers:

  # Unlike normal functions, calling a coroutine does not execute the
  # function body immediately. Instead, it returns an iterator object
  # that can be used to control the execution. First, let us call the
  # coroutine. This will not execute the function body, but will
  # return an iterator object.
  c = counter(3)

  # To get values from the coroutine, we can use the next() function
  # and pass the iterator created above, which will execute the
  # coroutine until it hits a yield statement. Calling next() on the
  # iterator will execute the coroutine until a yield statement is
  # encountered. At that point the coroutine will pause and return the
  # value passed to the yield statement. In this case, it will return
  # the value of n, which is 0.
  value = next(c)  # Invokes the coroutine and gets the first value
  print(f"First value from coroutine: {value}")  # Output: 0
  value = next(c)  # Invokes the coroutine and gets the second value
  print(f"Second value from coroutine: {value}")  # Output: 1
  value = next(c)  # Invokes the coroutine and gets the third value
  print(f"Third value from coroutine: {value}")  # Output: 2

  # When the coroutine is called again, it resumes execution
  # from the point it was paused, retaining the state of its
  # local variable n. In this case, it will continue from the
  # while loop and increment n to 3. Since n is now equal to
  # the limit, the while loop will terminate and the coroutine
  # will exit. If we try to call next on the iterator again,
  # it will raise a StopIteration exception, indicating that
  # there are no more values to be returned from the coroutine.
  try:
    # Invoking next() on an exhausted coroutine will raise
    # StopIteration.
    # noinspection PyUnusedLocal
    value = next(c)
  except StopIteration:
    # This message will be printed
    print("No more values from coroutine.")

  # The type of coroutine described above is called a generator.
  # Generators are a special type of coroutine that can be used
  # to generate a sequence of values on-the-fly. This is one of the
  # most common use cases for coroutines in Python. So we discuss them
  # in more detail in generators.py.

  # Coroutines can also be used to implement cooperative multitasking,
  # where multiple coroutines can yield control to each other
  # to allow for concurrent execution.

  # Once use for coroutines is to implement a producer-consumer
  # pattern, where one coroutine produces data and another consumes it.

  # In the code below, random_numbers() is a producer coroutine
  # that generates a sequence of random integers, and adder() is a
  # consumer coroutine that consumes those integers and adds them
  # together. The producer coroutine yields random integers, and the
  # consumer coroutine receives those integers.
  # The main function creates instances of both coroutines and
  # coordinates their execution. It does this by calling the producer
  # coroutine to get the next random number, and then sending that
  # number to the consumer coroutine, until the producer is exhausted.
  # The producer coroutine generates 5 random integers in the range
  # and when it returns a StopIteration exception is raised to indicate
  # that the producer has exited (i.e. exhausted). At that point,
  # the main function exits the loop and sends a None value to the
  # consumer coroutine to signal that there are no more values to be
  # consumed. The consumer coroutine then exits and returns the
  # total sum of the numbers consumed. This value is captured by
  # the StopIteration exception raised by the consumer coroutine.
  # StopIteration is a special exception that is raised whenever a
  # generator or coroutine completes its execution. The exception will
  # contain the value returned by the coroutine, which in this case
  # is the total sum of the numbers consumed. We can catch this
  # exception to get the total sum of the numbers consumed by the
  # consumer coroutine.

  def random_numbers() -> Iterator[int]:
    """ A simple producer coroutine that generates 5 random integers in the range [0, 100). """
    for _ in range(5):
      v = random.randrange(0, 100)
      print(f'Producer generated number: {v}')
      yield v

  def adder() -> Generator[None, int | None, int]:
    """ A simple consumer coroutine that adds numbers produced by the producer. """
    total = 0
    while True:
      # Wait for a number to be produced by the producer coroutine.
      n = yield
      if n is None:  # If None is sent, exit the loop.
        break
      total += n
      print(f'Consumer received number: {n}, current total: {total}')
    return total

  print('Exploring coroutines with producer-consumer pattern:')
  producer = random_numbers()
  consumer = adder()
  # Prime the consumer coroutine to receive values.
  # This causes the consumer to start executing until it hits the
  # first yield statement, at which point it will pause and wait
  # for a value to be sent to it.
  next(consumer)

  producer_exhausted = False
  while not producer_exhausted:
    try:
      # Get the next value from the producer coroutine.
      value = next(producer)
      print(f'Produced value: {value}')
      consumer.send(value)
    except StopIteration:
      # If the producer coroutine is exhausted, we break out of the loop.
      print('Producer coroutine exhausted.')
      producer_exhausted = True
  # After the producer is exhausted, we send None to the consumer
  # to signal that there are no more values to be consumed.
  # The 'send' is wrapped in a try-except block to catch the
  # StopIteration exception that will be raised when the consumer
  # coroutine exits. That exception will contain the total
  # sum of the numbers consumed (i.e. the value of the return
  # statement in the consumer coroutine).
  print('Sending None to consumer to signal end of production.')
  try:
    consumer.send(None)
  except StopIteration as ex:
    print(f'Consumer coroutine finished with total: {ex.value}')

  print('A source connected pipeline of coroutines')
  # coroutines can be used to implement complex pipelines of
  # consumers and producers, where data flows through multiple
  # stages of processing. Each processor in the pipeline can be
  # implemented as a coroutine that receives data from the previous
  # stage, processes it, and sends it to the next stage. This allows
  # simplifies the implementation of each stage, as each coroutine
  # only needs to handle the data it receives and send it to the next
  # stage. A driver coroutine can be used to coordinate the execution
  # of the entire pipeline, managing the flow of data between the
  # stages and handling any exceptions that may occur.

  # Here is an example of a pipline that filters out systemd messages
  # from a syslog file. The syslog file is read line by line, parsed
  # into structured data, and then filtered to remove entries with
  # the tag 'systemd'. The filtered entries are then printed to the
  # console.

  # Notice that each stage of the pipline has a very simple
  # implementation. It simply loops over data produced by the
  # previous stage, processes it, and yields the result.
  def reader(filename: str) -> Iterator[str]:
    """ A simple producer coroutine that reads lines from a file. """
    with open(filename, encoding='utf-8') as fle:
      for ln in fle:
        yield ln.strip()

  def parser(source: Iterator[str]) -> Iterator[dict[str, str | datetime | None]]:
    """ A simple consumer coroutine that parses log lines into structured data. """
    for ln in source:
      yield syslog.parse(ln)

  def syslog_filter(
    condition: Callable[[dict[str, str | datetime | None]], bool],
    source: Iterator[dict[str, str | datetime | None]]
  ) -> Iterator[dict[str, str | datetime | None]]:
    """ A simple consumer coroutine that filters log entries by severity. """
    for entry in source:
      if condition(entry):
        yield entry

  for msg in syslog_filter(lambda e: e['tag'] == 'dnf', parser(reader('messages.log'))):
    print(msg)

  print('A target connected pipeline of coroutines')
  # There is another way to implement the same pipeline using coroutines.
  # In this implementation, we pass the target coroutine as a parameter
  # each upstream coroutine. Each upstream coroutine will use yield to
  # get data from its upstream caller and send() its output to the target
  # coroutine, which will then process the data and send() it to the next stage
  # in the pipeline.

  def printer() -> Generator[None, dict[str, str | datetime | None], None]:
    """ A simple consumer coroutine that prints log entries. """
    entry = yield
    while entry is not None:
      print(entry)
      entry = yield

  def syslog_fileter2(
    condition: Callable[[dict[str, str | datetime | None]], bool],
    target: Generator[None, dict[str, str | datetime | None], None]
  ) -> Generator[None, dict[str, str | datetime | None], None]:
    """ A simple consumer coroutine that filters log entries by severity. """
    entry = yield
    while entry is not None:
      if condition(entry):
        target.send(entry)
      entry = yield

  def parser2(
    target: Generator[None, dict[str, str | datetime | None], None]
  ) -> Generator[None, str, None]:
    """ A simple consumer coroutine that parses log lines into structured data. """
    ln = yield
    while ln is not None:
      target.send(syslog.parse(ln))
      ln = yield

  # In this implementation, we have to explicitly prime each coroutine
  # i.e. we have to call next() on each coroutine so that it executes
  # until it hits the first yield statement and pauses, waiting for
  # a value to be sent to it. This is because the coroutines are
  # implemented as generators, and the first call to next() is
  # required to start the generator and get it to the first yield
  # statement. After that, we can send values to the coroutine using
  # the send() method. You can also prime a coroutine by calling
  # send(None) on it, which will have the same effect.
  w = printer()
  next(w)  # Prime the printer coroutine to receive values.
  f = syslog_fileter2(lambda e: e['tag'] == 'dnf', w)
  next(f)  # Prime the filter coroutine to receive values.
  p = parser2(f)
  next(p)  # Prime the parser coroutine to receive values.

  with open('messages.log', encoding='utf-8') as file:
    for line in file:
      p.send(line.strip())


if __name__ == "__main__":
  explore_coroutines()
