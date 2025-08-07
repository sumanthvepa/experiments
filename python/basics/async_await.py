#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  async_await.py: Explore async/await
"""
# -------------------------------------------------------------------
# async_await.py: Explore async/await
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

import asyncio
import time
from typing import Any, Coroutine, Generator, Tuple, cast
from datetime import datetime, timezone


# pylint: disable=too-many-statements, too-many-locals
def explore_async_await() -> None:
  """
    Explore async/await in Python
    :return: None
  """
  # To motivate the need for async/await, consider the following ways
  # of printing a message after a delay of 5 seconds. This can represent
  # some long-running I/O bound operation like disk read or a network
  # request. (NOT a CPU bound operation, which is not suitable for
  # async/await)

  # The first way is to use a blocking function that sleeps for 5 seconds
  # and then prints the message. This is a synchronous function.
  # The downside of this approach is that it blocks the entire Python
  # process until the sleep is over. This means that no other code can
  # run while the sleep is in progress.
  def delayed_message_sync(delay: int, message: str) -> None:
    """
      Print a message after a delay
      :param delay: int The delay in seconds
      :param message: str
      :return: None
    """
    # This is a blocking function. It will block the entire python
    # process until the sleep is over.
    time.sleep(delay)
    print(message)

  delayed_message_sync(5, 'First message (sync)')

  # The next way is to use a coroutine that checks if the delay is over
  # in a loop and yields control back to the caller until the delay is
  # over. This is a non-blocking function.

  # To use this approach, we need to call coroutine using a loop
  # until a StopIteration exception is raised. However, we can do
  # other work when the coroutine is yielding control to the calling
  # while loop. In this case we call do_something_else().

  # While this is an improvement over the blocking function, it is
  # quite cumbersome to use. You have to call the coroutine in a loop
  # and handle the StopIteration exception to know when the coroutine
  # is done. It is also potentially inefficient, since it runs the CPU
  # in a tight loop.
  def delayed_message_coroutine(
        delay: int, message: str) -> Generator[None, None, None]:
    """
      Print a message after a delay
      :param delay: int The delay in seconds
      :param message: str
      :return: None
    """
    current = time.perf_counter()
    end = current + delay
    while current < end:
      yield
      current = time.perf_counter()
    print(message)

  def do_something_else() -> None:
    """
      Do something else while waiting for the coroutine to complete
      :return: None
    """
    print('Doing something else while waiting for the coroutine to complete')

  # prime the generator to be used as a coroutine
  coroutine = delayed_message_coroutine(5, 'Second message (coroutine)')
  next(coroutine)  # This will start the coroutine and run it until the first yield
  # Now we can run the coroutine in a loop until it is done
  while True:
    try:
      next(coroutine)  # This will run the coroutine until the next yield
      do_something_else()
    except StopIteration:
      break  # The coroutine is done, so we can exit the loop

  # While this is an improvement over the blocking function, it is
  # still quite cumbersome to use. You have to call the coroutine in
  # a loop and handle the StopIteration exception to know when the
  # coroutine is done.

  # Both of the methods above are essentially synchronous in nature,
  # even though the second one uses a coroutine that yields control to
  # an event loop.

  # Python 3.5 introduced the async/await syntax, which makes it
  # possible to write truly asynchronous code that is easy to read
  # and write. The async/await syntax allows you to define true
  # asynchronous functions (coroutines). These methods are dispatched
  # by an event loop. Although technically one does not need to use
  # asyncio for the event loop, and one can write their own event
  # loop, using the asyncio module is the recommended way to write
  # asynchronous code in Python.

  # Asynchronous functions are defined using the `async def`
  # syntax. They can use the `await` keyword to call other asynchronous
  # functions. Note that async function CANNOT use the `yield` keyword.

  # This the asynchronous version of the delayed_message_...() functions

  # Notice that the return type of the async function in its
  # definition is just the normal return type of the function.
  # Not a generator or Iterator like it is for coroutines.  But,
  # when called, the async function returns a coroutine object, not
  # the result of executing the function. We will explore this
  # further below.

  # The function `asyncio.sleep()`, which is a non-blocking
  # function async function itself. The await keyword in front of
  # `the asyncio.sleep()` call causes control to be yielded back to the
  # event loop, which will only schedule continued execution of this
  # function when the asyncio.sleep() function is done sleeping.
  async def delayed_message_async(
        delay: int, message: str) -> None:
    """
      Print a message after a delay
      :param delay: int The delay in seconds
      :param message: str
      :return: None
    """
    await asyncio.sleep(delay)  # This is a non-blocking sleep
    print(message)

  # Just like synchronous coroutines, when the async function is
  # called, it does not execute immediately. Instead, it returns
  # a coroutine object that can be scheduled to run by an event loop.
  # Just like the Generator type is used to represent a synchronous
  # coroutine, an asynchronous coroutine is represented by the
  # Coroutine type. The Coroutine type is a generic type that takes
  # three type parameters: the Yield type, the Send type, and the
  # Return type. The yield type is the type of the value that the
  # coroutine yields (via async yield), the send type is the
  # type of the value that can be sent to the coroutine (via async
  # send),
  # For most normal async functions, the yield type and send type
  # are always Any. This is because most async functions do not
  # yield or send any values and Python does not enforce any type
  # checking on the values that are yielded or sent to Any. In
  # practice, the first two generic type parameters are always Any,
  # and the third type parameter is the return type of the async
  # function. In this case, the return type is None,
  delayed_async_coroutine: Coroutine[Any, Any, None] = delayed_message_async(
    5, 'Third message (async)')

  # To actually run the async function, we need to create an event
  # loop and run the async function using the loop. The asyncio.run()
  # function creates an event loop, and schedule the coroutine to
  # run within the loop.

  # Note that the asyncio.run() itself is a blocking function,
  # which means that it will block the entire Python process until
  # all coroutines scheduled in the event loop are done running.

  # For the sake of exposition, this code has multiple calls to
  # asyncio.run(). This is done to show various uses of async/await.
  # In practice, you would typically have only one call to
  # asyncio.run() in your program, and schedule all the coroutines
  # that you want to run within that event loop.
  asyncio.run(delayed_async_coroutine)

  # This message is printed only after asyncio.run has completed
  print('Completed first run of asyncio.run()')
  print(datetime.now(tz=timezone.utc))

  # Of course, the thw two lines above can be combined into a single
  # line as follows:
  asyncio.run(delayed_message_async(
    5, 'Fourth message (async)'))
  print('Completed second run of asyncio.run()')
  print(datetime.now(tz=timezone.utc))

  # If you want to run more than one async function in the same loop,
  # define a master async function that calls the other async
  # functions.

  # Here is one way to do this:
  async def master_coroutine1() -> None:
    """
      Master coroutine that runs multiple async functions
      :return: None
    """
    # This will run the delayed_message_async() function and wait for it to complete
    await delayed_message_async(5, 'Fifth message')
    # This will run the delayed_message_async() function and wait for it to complete
    await delayed_message_async(5, 'Sixth message')

  # Now we can run the master coroutine using asyncio.run()
  start_time = time.perf_counter()
  asyncio.run(master_coroutine1())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed third run of asyncio.run() [master_coroutine1]: {delta:.2f}s')

  # The problem with master_coroutine1() is that it runs the async
  # functions sequentially, one after the other. This might be what
  # you want if the second async function depends on the first one
  # running to completion.

  # There are a few ways to run multiple async functions concurrently.
  # The simplest way is to use the asyncio.create_task() function to
  # create a task for each async function, and then await the tasks
  # to complete. This will run the async functions concurrently.
  async def master_coroutine2() -> None:
    """
      Master coroutine that runs multiple async functions concurrently
      using asyncio.wait()
      :return: None
    """
    # Create a task for each async function using asyncio.create_task()
    task1: asyncio.Task[None] = asyncio.create_task(
      delayed_message_async(5, 'Seventh message'))
    task2: asyncio.Task[None] = asyncio.create_task(
      delayed_message_async(5, 'Eighth message'))
    tasks = (task1, task2)
    await asyncio.wait(tasks)

  # Now we can run the master coroutine using asyncio.run()
  start_time = time.perf_counter()
  asyncio.run(master_coroutine2())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed fourth run of asyncio.run() [master_coroutine2]: {delta:.2f}s')

  # Another way to run multiple async functions concurrently is to
  # use the asyncio.gather() function. This function takes multiple
  # async functions and returns a Future that will be done when all
  # the async functions are done running. The Future will contain a
  # tuple of the return values of the async functions, in the same
  async def master_coroutine3() -> None:
    """
      Master coroutine that runs multiple async functions concurrently
      :return: Coroutine object
    """
    # Create a Future object that will run the two async functions
    # concurrently. The tasks object is a Future that is parameterized
    # by a tuple containing the return values of the two coroutines.
    # In this case, both coroutines return None, so the type of the
    # tasks object is asyncio.Future[Tuple[None, None]].

    # Note that type Future is defined in the asyncio module, and
    # not the built-in 'typing' module. So we need to import it from
    # asyncio. Hence, the module name asyncio.Future.

    # asyncio.gather() is a function that takes multiple coroutines
    # and returns a Future that will be done when all the coroutines
    # are done. The Future will contain a tuple of the return values
    # of the coroutines, in the same order as the coroutines were
    # passed to the gather() function.
    tasks: asyncio.Future[Tuple[None, None]] = asyncio.gather(
      delayed_message_async(5, 'Ninth message'),
      delayed_message_async(5, 'Tenth message'))

    # Now wait for the tasks to complete. This will block until all
    # the coroutines in the tasks Future are done running.
    await tasks

  # Finally, we can schedule the master coroutine to run within an
  # event loop using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine3())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed fifth run of asyncio.run() [master_coroutine3]: {delta:.2f}s')

  # The last way to run multiple async functions concurrently is to
  # use Task groups. A Task group is a context manager that allows you
  # to create multiple tasks and wait for them to complete. The Task
  # group will automatically cancel all the tasks if any of the tasks
  # raises an exception. This is useful for error handling and
  # cleanup. The Task group is created using the asyncio.TaskGroup()
  # function.
  async def master_coroutine4() -> None:
    """
      Master coroutine that runs multiple async functions concurrently
      using Task groups
      :return: None
    """
    # Create a Task group using the asyncio.TaskGroup() function.
    # This will create a context manager that will automatically
    # cancel all the tasks if any of the tasks raises an exception.
    async with asyncio.TaskGroup() as tg:
      # Create a task for each async function using tg.create_task()
      tg.create_task(delayed_message_async(5, 'Eleventh message'))
      tg.create_task(delayed_message_async(5, 'Twelfth message'))

  # As usual, we schedule the master coroutine using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine4())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed sixth run of asyncio.run() [master_coroutine4]: {delta:.2f}s')

  # Often you want to an asynchronous function to return a value
  # instead of just None. You can do this by simply returning a value
  # from the async function. The return type of the async function
  # will be the type of the value that is returned. The return type
  # will be wrapped in a Future object when the async function is
  # called. The Future object will contain the return value of the
  # async function when it is done running. The Future object can be
  # awaited to get the return value of the async function.
  async def delayed_message_async_with_return(
        delay: int, message: str) -> str:
    """
      Print a message after a delay and return the message
      :param delay: int The delay in seconds
      :param message: str The message to return
      :return: str The message
    """
    await asyncio.sleep(delay)  # This is a non-blocking sleep
    return message

  # If you want to get the result of an async function from the non-async
  # part of your code, you can use the asyncio.run() function's return
  # value.
  start_time = time.perf_counter()
  output: str = asyncio.run(
    delayed_message_async_with_return(5, 'Thirteenth message'))
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Result from delayed_message_async_with_return() = {output}')
  print(f'Completed seventh run of asyncio.run() [delayed_message_async_with_return]: {delta:.2f}s')

  # From within another async function, you can just await the
  # async function to get the return value. This is similar to how
  # you would await a coroutine to get the value that it yields.
  async def master_coroutine5() -> None:
    """
      Master coroutine that runs an async function that returns a value
      :return: None
    """
    # Call the async function and get a Future object that contains
    # the return value of the async function.
    task: asyncio.Future[str] = asyncio.create_task(
      delayed_message_async_with_return(5, 'Fourteenth message'))

    # Wait for the Future to complete and get the return value of the
    # async function.
    result: str = await task
    print(f'Result from async function: {result}')

  # As usual, we schedule the master coroutine using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine5())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed eighth run of asyncio.run() [master_coroutine5]: {delta:.2f}s')

  # If you are running multiple async functions that return values,
  # And you want to get the return values of all the async functions,
  # there is no way to do it directly outside the event loop. However,
  # you can use a single master_coroutine that runs all the async
  # functions concurrently and returns a tuple of the return values.
  async def master_coroutine6() -> Tuple[str, str]:
    """
      Run multiple async functions concurrently and return a tuple
      of their return values
      :return: A tuple of strings containing the return values of the
      async functions called.
    """
    tasks: asyncio.Future[Tuple[str, str]] = asyncio.gather(
      delayed_message_async_with_return(5, 'Fifteenth message'),
      delayed_message_async_with_return(5, 'Sixteenth message'))
    # Wait for the tasks to complete and get the return values of the
    # async functions.
    return await tasks

  # Schedule the master coroutine using asyncio.run(). The return
  # value of the asyncio.run() function will be a tuple of the return
  # values of the async functions that were called in the master
  # coroutine.
  start_time = time.perf_counter()
  output_tuple: Tuple[str, str] = asyncio.run(master_coroutine6())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Result from asyncio.gather() = {output_tuple}')
  print(f'Completed ninth run of asyncio.run() [asyncio.gather()]: {delta:.2f}s')

  # If you prefer using Task groups, you can get the return values
  # from multiple async functions as follows:
  async def master_coroutine7() -> Tuple[str, str]:
    """
      Run multiple async functions concurrently and return a tuple
      of their return values using Task groups
      :return: A tuple of strings containing the return values of the
      async functions called.
    """
    async with asyncio.TaskGroup() as tg:
      # Create a task for each async function using tg.create_task()
      tasks = [
        tg.create_task(delayed_message_async_with_return(5, 'Seventeenth message')),
        tg.create_task(delayed_message_async_with_return(5, 'Eighteenth message'))]
      results: Tuple[str, str] = (await tasks[0], await tasks[1])
      return results

  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  output_tuple = asyncio.run(master_coroutine7())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Result from asyncio.gather() = {output_tuple}')
  print(f'Completed tenth run of asyncio.run() [asyncio.gather()]: {delta:.2f}s')

  # There is a slight problem with master_coroutine7() above.
  # The results are awaited in the order that the tasks were created,
  # This is not usually a problem if you need all the results, since
  # the time it will take to get all the results will be determined
  # by the slowest task.

  # However, if you want to get the results as soon as they are
  # available, you can use the asyncio.as_completed() function. This
  # function takes an iterable of async functions and returns an
  # iterable of Future objects that will be done when the async
  # functions are done running. The Future objects will be
  # yielded in the order that the async functions are done running,
  # not in the order that they were passed to the as_completed()
  # function. This is useful if you want to get the results as soon
  # as they are available, and not wait for all the async functions
  # to complete.
  async def master_coroutine8() -> None:
    """
      Run multiple async functions concurrently and return a tuple
      of their return values using asyncio.as_completed()
      :return: A tuple of strings containing the return values of the
      async functions called.
    """
    tasks = [
      delayed_message_async_with_return(5, 'Nineteenth message'),
      delayed_message_async_with_return(1, 'Twentieth message')]
    # Use asyncio.as_completed() to get the results as soon as they are available
    for future in asyncio.as_completed(tasks):
      result: str = await future
      print(f'Result from asyncio.gather() = {result}')

  # Schedule the master coroutine as usual using asyncio.run().
  # Notice that Twentieth message is printed before Nineteenth.
  start_time = time.perf_counter()
  asyncio.run(master_coroutine8())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed eleventh run of asyncio.run() [asyncio.gather()]: {delta:.2f}s')

  # Finally, if you want to run an async function in the background
  # and not wait for it to complete, you can use the asyncio.create_task()
  # function to create a task for the async function. The task will
  # run in the background and, you can continue to do other work in
  # your program. The task will be scheduled to run by the event loop
  # and will run concurrently with the rest of your program. You can
  # use the asyncio.Task.cancel() method to cancel the task if you
  # want to stop it from running. Note that cancelling a task does
  # not guarantee that the task will stop immediately. The task may
  # still run for a short time after it is cancelled, depending on
  # what it is doing. If the task is waiting for an I/O operation to
  # complete, it will not stop until the I/O operation is done.
  async def background_task() -> None:
    """
      A background task that runs in the background and prints a message
      :return: None
    """
    count = 0
    while True:
      await asyncio.sleep(5)  # This is a non-blocking sleep
      print(f'Background message count {count}')
      count += 1

  async def master_coroutine9() -> None:
    """
      Master coroutine that runs a background task
      :return: None
    """
    # Create a task for the background task using asyncio.create_task()
    # This starts the background task
    task: asyncio.Task[None] = asyncio.create_task(background_task())
    # Wait for a few seconds to let the background task run
    await asyncio.sleep(30)
    # Cancel the background task
    task.cancel()
    # Now await the task in a try/except block to handle the
    # asyncio.CancelledError exception that will be raised when the
    # task is cancelled. This is important to avoid leaving the
    # task in a cancelled state and to ensure that the task is cleaned
    # up properly.
    try:
      await task  # Wait for the task to be cancelled
    except asyncio.CancelledError:
      print('Background task was cancelled')

  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine9())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed twelfth run of asyncio.run() [master_coroutine9()]: {delta:.2f}s')

  # Sometimes, async functions need to raise exceptions to signal
  # errors. You can raise exceptions in async functions just like
  # you would in normal functions. The exception will be raised
  # when the async function is awaited. If the exception is not
  # handled, it will propagate up the call stack and cause the
  # program to terminate. If you want to handle the exception, you
  # can use a try/except block around the await statement that
  # calls the async function. This is similar to how you would
  # handle exceptions in normal functions.
  async def delayed_message_async_with_exception(
        delay: int, message: str) -> str:
    """
      Print a message after a delay and return the message
      :param delay: int The delay in seconds
      :param message: str The message to return
      :return: str The message
    """
    await asyncio.sleep(delay)  # This is a non-blocking sleep
    if delay > 3:
      raise ValueError('Delay is too long')
    return message

  async def master_coroutine10() -> None:
    """
      Master coroutine that runs an async function that raises an exception
      :return: None
    """
    try:
      # Call the async function and get a Future object that contains
      # the return value of the async function.
      result: str = await delayed_message_async_with_exception(5, 'Twenty-first message')
      print(f'Result from async function: {result}')
    except ValueError as error:
      print(f'Caught exception: {error}')

  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine10())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed thirteenth run of asyncio.run() [master_coroutine10()]: {delta:.2f}s')

  # If the exception is not handled within asynchronous code, it will
  # propagate up to the event loop and can be caught by a try/except
  # block around the asyncio.run() call.
  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  try:
    asyncio.run(delayed_message_async_with_exception(5, 'Twenty-second message'))
  except ValueError as ex:
    print(f'Caught exception from asyncio.run(): {ex}')
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed fourteenth run of asyncio.run() [master_coroutine10()]: {delta:.2f}s')

  # Often, you want to run multiple async functions, some of which
  # might fail with an exception, and you want the return values of
  # the ones that succeed, and the exceptions raised by the ones that
  # fail. You can do this using the asyncio.gather() function with the
  # return_exceptions=True argument. This will return a list of the
  # return values of the async functions that succeeded, and the
  # exceptions raised by the async functions that failed. The
  # exceptions will be wrapped in a Future object, so you can check
  # if the Future is done and if it is, you can check if it contains
  # an exception.
  async def master_coroutine11() -> None:
    """
      Master coroutine that runs multiple async functions and returns
      the results and exceptions
      :return: None
    """
    tasks: list[Coroutine[Any, Any, str]] = [
      delayed_message_async_with_exception(5, 'Twenty-third message'),
      delayed_message_async_with_exception(2, 'Twenty-fourth message')]
    # Use asyncio.gather() to get the results and exceptions
    future: asyncio.Future[list[str | BaseException]] \
        = asyncio.gather(*tasks, return_exceptions=True)
    results: list[str | ValueError] = cast(list[str | ValueError], await future)
    for result in results:
      if isinstance(result, ValueError):
        print(f'Caught exception: {result}')
      else:
        print(f'Result from async function: {result}')

  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine11())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed fifteenth run of asyncio.run() [master_coroutine11()]: {delta:.2f}s')

  # You can also use asyncio.wait() to wait for multiple async
  # functions to complete and get the results and exceptions.
  async def master_coroutine12() -> None:
    """
      Master coroutine that runs multiple async functions and returns
      the results and exceptions using asyncio.wait()
      :return: None
    """
    tasks: list[asyncio.Task[str]] = [
      asyncio.create_task(delayed_message_async_with_exception(5, 'Twenty-fifth message')),
      asyncio.create_task(delayed_message_async_with_exception(2, 'Twenty-sixth message'))]
    # Use asyncio.wait() to get the results and exceptions
    # pylint: disable=unused-variable
    done, pending = await asyncio.wait(tasks, return_when=asyncio.ALL_COMPLETED)
    for future in done:
      if future.exception() is not None:
        print(f'Caught exception: {future.exception()}')
      else:
        print(f'Result from async function: {future.result()}')

  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine12())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed sixteenth run of asyncio.run() [master_coroutine11()]: {delta:.2f}s')

  # Asyncio.wait() is more flexible than asyncio.gather(), because
  # you can specify when you want the wait to end. In the previous
  # example, we used asyncio.ALL_COMPLETED to wait for all the tasks
  # to complete. You can also use asyncio.FIRST_COMPLETED to wait for
  # the first task to complete, or asyncio.FIRST_EXCEPTION to wait for
  # the first task to raise an exception. This can be useful if you
  # want to run multiple async functions concurrently and get the
  # results as soon as they are available, or if you want to stop
  # waiting for the tasks to complete as soon as one of them raises
  # an exception.
  # In the code below, we use asyncio.FIRST_EXCEPTION to wait for the
  # first task to raise an exception, and then we print the results
  async def master_coroutine13() -> None:
    """
      Master coroutine that runs multiple async functions and returns
      the results and exceptions using asyncio.wait()
      :return: None
    """
    tasks: list[asyncio.Task[str]] = [
      asyncio.create_task(delayed_message_async_with_exception(5, 'Twenty-seventh message')),
      asyncio.create_task(delayed_message_async_with_exception(2, 'Twenty-eighth message'))]
    # Use asyncio.wait() to get the results and exceptions
    done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_EXCEPTION)
    for future in done:
      if future.exception() is not None:
        print(f'Caught exception: {future.exception()}')
      else:
        print(f'Result from async function: {future.result()}')

    print(f'Pending tasks: {len(pending)}')
    # You can then cancel the pending tasks if you want to:
    for future in pending:
      future.cancel()
      print(f'Cancelled pending task: {future}')

  # Schedule the master coroutine as usual using asyncio.run().
  start_time = time.perf_counter()
  asyncio.run(master_coroutine13())
  end_time = time.perf_counter()
  delta = end_time - start_time
  print(f'Completed seventeenth run of asyncio.run() [master_coroutine11()]: {delta:.2f}s')


if __name__ == '__main__':
  explore_async_await()
