#!/usr/bin/env python3.12
# -*- coding: utf-8 -*-
"""
  async_await.py: Explore async/await
"""
# -------------------------------------------------------------------
# async_await.py: Explore async/await
#
# Copyright (C) 2024 Sumanth Vepa.
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

# Python's async/await features are built on top of the asyncio module,
import asyncio
from typing import List
from datetime import datetime, timezone


# pylint: disable=too-many-statements, too-many-locals
def explore_async_await() -> None:
  """
    Explore async/await in Python
    :return: None
  """
  # Async/await is a feature in Python that allows you to write
  # asynchronous code in a synchronous style. This makes it easier
  # to write and understand asynchronous code, which can be
  # complex and error-prone.
  # Async/await is built on top of the asyncio module, which provides
  # support for asynchronous programming in Python.
  # To use async/await, you define functions that are marked with
  # the async keyword. These functions can contain the await keyword,
  # which is used to call other async functions.
  # When you call an async function with await, the function is
  # executed asynchronously, and the calling function is suspended
  # until the async function completes.
  # Here is an example of an async function:

  # The function below is an async function. It is marked with the
  # async keyword. The effect of the async keyword is that the
  # function returns a coroutine object, which can be awaited.
  async def delayed_message(delay: int, message: str) -> None:
    """
      Print a message after a delay
      :param delay: int The delay in seconds
      :param message: str
      :return: None
    """
    # We do not use the time.sleep function here because it is blocking.
    # The entire python process will be blocked until the sleep is over.
    # Instead, we use the asyncio.sleep function, which is non-blocking.
    # This allows other parts of the python interpreter to run while
    # the await blocks on the sleep.
    # Note that this is how you call an async function from another
    # async function. Using the await keyword.
    await asyncio.sleep(delay)
    print(message)

  # Simply calling the async function will result in a coroutine object
  # being returned. The actual code in the function is not executed.
  # The code is scheduled for execution in the asyncio event loop
  # only when the coroutine is awaited.
  coroutine = delayed_message(5, 'First message')

  # From within a non-async function, you can execute the coroutine
  # using the asyncio.run function. This function runs the coroutine
  # in the asyncio event loop. 
  print('Starting sequential execution of coroutines')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(coroutine)

  # You can directly call the async function from within the parameter
  # list passed to the asyncio.run function. This is a shorthand for
  # the above code. Delayed message will return a coroutine object
  # which will be executed by the asyncio.run function.
  asyncio.run(delayed_message(5, 'Second message'))

  # This message is printed only after asyncio.run has completed
  # Asyncio.run itself is a blocking function. It will block until
  # the coroutine is complete.
  print('Completed sequential execution of coroutines')
  print(datetime.now(tz=timezone.utc))

  # Notice that the second message is printed after a delay of ~10
  # seconds. This is because asyncio.run is blocking. The first
  # call asyncio.run(coroutine) will block until the coroutine is
  # complete. Only then will the second call to asyncio.run be
  # executed.

  # If you want to run multiple coroutines concurrently, you can
  # create a task object for each coroutine and schedule those
  # tasks to run concurrently and then await the completion of
  # those tasks. Here is an example:
  async def all_routines_concurrently1() -> None:
    """
      Run all coroutines concurrently
      :return: None
    """
    # Create a task object for each coroutine. The task is scheduled
    # for execution right away. The current function continues to
    # execute without waiting for the task to complete.
    task1 = asyncio.create_task(delayed_message(5, 'Set 1: Concurrent message1'))
    task2 = asyncio.create_task(delayed_message(5, 'Set 1: Concurrent message2'))

    # Await the completion of the tasks. This will suspend the current
    # function until task1 is complete.
    print(f'Before await task1 {datetime.now(tz=timezone.utc)}')
    await task1  # Suspends the current function until task1 is complete
    print(f'Between await task1 and task 2 {datetime.now(tz=timezone.utc)}')
    # Await completion of the second task. This will suspend the
    # current function until task2 is complete.
    await task2  # Suspends the current function until task2 is complete
    print(f'After await task2 {datetime.now(tz=timezone.utc)}')
    print('Exiting all_routines_concurrently1')

  # Now we can run the all_routines_concurrently1 function using
  # asyncio.run. This will run both coroutines concurrently.
  print('Starting concurrent execution of coroutine set 1')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(all_routines_concurrently1())
  print('Completed concurrent execution of coroutine set 1')
  print(datetime.now(tz=timezone.utc))

  # Notice that the total time taken to run both coroutines is
  # now ~5 seconds. This is because the coroutines are running
  # concurrently.

  # Also notice that the code above will wait for task1 to finish
  # before checking on the completion of task2. So if task2
  # finishes early then we won't know about it until task1 finishes.

  # This is another way to run multiple coroutines concurrently.
  # You can use the asyncio.gather function. This function takes a
  # list of coroutines and returns a single task object that
  # will run all the coroutines concurrently. You can then call
  # asyncio.await on the task object to schedule the coroutines.
  # Finally, you can wait for all the coroutines to complete by
  # calling the all_routines_concurrently2 function using asyncio.run.
  # This will run both coroutines concurrently, and wait for them
  # to complete.
  async def all_routines_concurrently2() -> None:
    coroutines = [delayed_message(5, 'Set 2: Concurrent message1'),
                  delayed_message(5, 'Set 2: Concurrent message2')]
    # The asyncio.gather function takes a list of coroutines
    # and returns a single task object that represents all the tasks
    # It will create and schedule all tasks for execution concurrently
    tasks = asyncio.gather(*coroutines)
    print(f'type(tasks) = {type(tasks)}')
    # The awaitable object returned by asyncio.gather can be awaited
    # to wait for all the coroutines to complete.
    await tasks  # Suspends the current function until all tasks are complete
    print('All concurrent messages printed')

  # Now you can run the all_routines_concurrently2 function using
  print('Starting concurrent execution of coroutine set 2')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(all_routines_concurrently2())
  print('Completed concurrent execution of coroutine set 2')
  print(datetime.now(tz=timezone.utc))

  # Notice that this time too, the total time taken to run both
  # coroutines is ~5 seconds. This is because the coroutines are
  # run concurrently.

  async def all_routines_concurrently3() -> None:
    # Here you create the tasks explicitly using asyncio.create_task
    # as was done in all_routines_concurrently1. This schedules the
    # tasks for asynchronous execution.
    tasks = [asyncio.create_task(delayed_message(5, 'Set 3: Concurrent message1')),
             asyncio.create_task(delayed_message(5, 'Set 3: Concurrent message2'))]
    # You can await the completion of all tasks using asyncio.wait.
    # Unlike asyncio.gather which will wait for all tasks to complete,
    # asyncio.wait allows you to control when the waiting will stop.
    # You have three options for the return_when parameter:
    # asyncio.FIRST_COMPLETED: Return when any task completes.
    # asyncio.FIRST_EXCEPTION: Return when any task raises an exception.
    # asyncio.ALL_COMPLETED: Return when all tasks are done.
    # To simulate the behavior of asyncio.gather, you can use
    # asyncio.wait with the return_when parameter set to
    # asyncio.ALL_COMPLETED.
    # The return value of asyncio.wait is a tuple of two sets:
    # the first set contains the tasks that are done,
    # and the second set contains the tasks that are pending.
    # For this example the pending set will be empty, since
    # we are waiting for all tasks to complete. In any case,
    # we will ignore the returned tuple for this example,
    # since we are only interested in waiting for all tasks to
    # complete.
    await asyncio.wait(tasks, return_when=asyncio.ALL_COMPLETED)
    print('All concurrent messages printed')

  # As usual, you can run the all_routines_concurrently3 function using
  # asyncio.run. This will run both coroutines concurrently.
  print('Starting concurrent execution of coroutine set 3')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(all_routines_concurrently3())
  print('Completed concurrent execution of coroutine set 3')
  print(datetime.now(tz=timezone.utc))

  # One more way to run multiple coroutines concurrently is to
  # use the TaskGroup class from the asyncio module. This class
  # allows you to group multiple coroutines together and run them
  # concurrently. Here is an example:
  async def all_routines_concurrently4() -> None:
    async with asyncio.TaskGroup() as group:
      # You can use the create_task method of the TaskGroup object
      # to create and schedule a task for execution.
      group.create_task(delayed_message(5, 'Set 4: Concurrent message1'))
      group.create_task(delayed_message(5, 'Set 4: Concurrent message2'))
      # The wait is implicit. The TaskGroup object will wait for
      # all tasks to complete before exiting the async with
      # block.
    print('All concurrent messages printed')

  # Once again, you can run the all_routines_concurrently4 function
  # using asyncio.run.
  print('Starting concurrent execution of coroutine set 4')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(all_routines_concurrently4())
  print('Completed concurrent execution of coroutine set 4')
  print(datetime.now(tz=timezone.utc))

  # All these ways of running coroutines concurrently are equivalent.
  # The choice of which method to use depends on your preference.
  # If you don't have a strong preference, you should go with
  # TaskGroup, as it is easy to reason about.

  # An async function can return a value using the return statement.
  # The return value is wrapped in a coroutine object. You can await
  # the coroutine object to get the return value. Here is an example:
  async def delayed_echo(message: str, delay: int) -> str:
    """
      Returns the message passed to it after a delay
      :param message: str The message to return
      :param delay: int The delay in seconds
      :return: str The message passed to the function
    """
    await asyncio.sleep(delay)
    return message

  # You can call the delayed_echo function using asyncio.run and
  # await the return value to get the message.
  result = asyncio.run(delayed_echo('Hello', 5))
  print(f'The message is: {result}')

  # You can wait for the value of the coroutine to be available
  # using the await keyword from within an async function.
  async def print_delayed_echo1() -> None:
    """
      Print the message returned by delayed_echo
      :return: None
    """
    message = await delayed_echo('Hello', 5)
    print(f'The message is: {message}')

  # As usual, you have to run the print_delayed_echo function
  # using asyncio.run.
  asyncio.run(print_delayed_echo1())

  # You can also get the return value of a coroutine using the
  # asyncio.create_task function. This function creates a task
  # object that represents the coroutine. You can then await the
  # task object to get the return value of the coroutine.
  async def print_delayed_echo2() -> None:
    """
      Get the message returned by delayed_echo
      :return: None
    """
    task = asyncio.create_task(delayed_echo('Hello', 5))
    message = await task
    print(f'The message is: {message}')

  # As usual, you have to run the print_delayed_echo2 function
  # using asyncio.run.
  asyncio.run(print_delayed_echo2())

  # You can run multiple coroutines concurrently and get the return
  # values of all the coroutines using the asyncio.gather function.
  # For example, you can run the delayed_echo function twice
  # concurrently and get the return values of both coroutines.
  async def get_all_messages() -> None:
    """
      Get the messages returned by delayed_echo
      :return: None
    """
    # You can use the asyncio.gather function to run multiple
    # coroutines concurrently and get the return values of all
    # the coroutines.
    messages = await asyncio.gather(delayed_echo('Hello', 5),
                                    delayed_echo('World', 5))
    print(f'The messages are: {messages}')

  # As usual, you have to run the get_all_messages function
  # using asyncio.run.
  asyncio.run(get_all_messages())

  # You can also run multiple coroutines concurrently and get the
  # return values of all the coroutines using the TaskGroup class.
  # For example, you can run the delayed_echo function twice
  # concurrently and get the return values of both coroutines.
  async def get_all_messages2() -> None:
    """
      Get the messages returned by delayed_echo
      :return: None
    """
    async with asyncio.TaskGroup() as group:
      # You can use the create_task method of the TaskGroup object
      # to create and schedule a task for execution.
      # Store the task objects in a list so that you can await them
      tasks = [group.create_task(delayed_echo('Hello', 5)),
               group.create_task(delayed_echo('World', 5))]

      # Now use await to get the return values of all the coroutines.
      messages = [await task for task in tasks]
      print(f'The messages are: {messages}')

  # As usual, you have to run the get_all_messages2 function
  # using asyncio.run.
  asyncio.run(get_all_messages2())

  # You can also run multiple coroutines concurrently and get the
  # return values of all the coroutines using the asyncio.wait function.
  # For example, you can run the delayed_echo function twice
  # concurrently and get the return values of both coroutines.
  # For example:
  async def get_all_messages3() -> None:
    """
      Get the messages returned by delayed_echo
      :return: None
    """
    tasks = [asyncio.create_task(delayed_echo('Hello', 5)),
             asyncio.create_task(delayed_echo('World', 5))]
    # You can use asyncio.wait to wait for all tasks to complete.
    # The return_when parameter is set to asyncio.ALL_COMPLETED,
    # which means that the function will wait for all tasks to
    # complete.
    # Note the use _ to ignore the second set of tasks that are
    # pending. We are only interested in the tasks that are done.
    done, _ = await asyncio.wait(tasks, return_when=asyncio.ALL_COMPLETED)
    # You can get the return values of all the coroutines by
    # iterating over the done set.
    messages = [task.result() for task in done]
    print(f'The messages are: {messages}')

  # As usual, you have to run the get_all_messages2 function
  # using asyncio.run.
  asyncio.run(get_all_messages3())

  # If your function raises an exception, the exception will be
  # propagated to the caller. You can catch the exception using
  # a try-except block. Here is an example:
  async def limited_delayed_message(message: str, delay: int) -> str:
    """
      Raise an exception
      :return: None
    """
    if delay > 5:
      raise ValueError('Delay too long')
    await asyncio.sleep(delay)
    return message

  try:
    asyncio.run(limited_delayed_message('Hello', 10))
  except ValueError as ex:
    print(f'Caught exception: {ex}')

  # If you are using asyncio.gather to run multiple coroutines
  # concurrently, and one of the coroutines raises an exception,
  # the exception will be propagated to the caller. You can catch
  # the exception using a try-except block. The other coroutines
  # are not affected by the exception and will continue to run.
  # However, the return value of those coroutines will be lost.
  async def multiple_coroutines_with_exception1() -> None:
    """
      Run multiple coroutines concurrently and handle exceptions
      raised by them.
      :return: None
    """
    try:
      coroutines = [limited_delayed_message('Does not raise an exception', 5),
                    limited_delayed_message('Raises an exception', 10)]
      messages = await asyncio.gather(*coroutines)
      # This will never be reached since coroutine2 raises an exception
      print(f'The messages are: {messages}')
    except ValueError as e:
      print(f'Caught exception: {e}')

  # As usual, you have to run the multiple_coroutines_with_exception1
  # function using asyncio.run.
  print('Starting concurrent execution of error prone coroutines using technique 1')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(multiple_coroutines_with_exception1())
  print('Finished concurrent execution of error prone coroutines using technique 1')
  print(datetime.now(tz=timezone.utc))

  # If you want to get the return values of all the coroutines
  # even if one of them raises an exception, you can do it with
  # by creating a task object for each coroutine and awaiting
  # the task object. Here is an example:
  async def multiple_coroutines_with_exception2() -> None:
    """
      Run multiple coroutines concurrently and handle exceptions
      raised by them.
      :return: None
    """
    # First start the tasks using create_task. The mypy type
    # annotation is optional, but is included here to make it clear
    # that tasks is a list of
    tasks = [
      asyncio.create_task(limited_delayed_message('Does not raise an exception', 5)),
      asyncio.create_task(limited_delayed_message('Raises an exception', 10))
    ]  # type: List[asyncio.Task[str]]

    # Then iterate over the task list awaiting the completion of each task to
    # get the return value, or catch an exception.
    messages = []  # type: List[str]
    for task in tasks:  # type: asyncio.Task[str]
      try:
        messages.append(await task)
      except ValueError as e:
        print(f'Caught exception: {e}')
    # Finally print the received messages
    print(f'The messages are: {messages}')

  # As usual, you have to run the multiple_coroutines_with_exception2
  # function using asyncio.run.
  print('Starting concurrent execution of error prone coroutines using technique 2')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(multiple_coroutines_with_exception2())
  print('Finished concurrent execution of error prone coroutines using technique 2')
  print(datetime.now(tz=timezone.utc))

  # You can do the same thing with asyncio.gather, if you use the
  # return_exceptions parameter. If this parameter is set to True,
  # the gather function will return the exceptions raised by the
  # coroutines as return values. Here is an example:
  async def multiple_coroutines_with_exception3() -> None:
    """
      Run multiple coroutines concurrently and handle exceptions
      raised by them.
      :return: None
    """
    # Use asyncio.gather with the return_exceptions parameter set to True.
    # This will cause the gather function to return the exceptions raised
    # by the coroutines as return values.
    messages = await asyncio.gather(
      limited_delayed_message('Does not raise an exception', 5),
      limited_delayed_message('Raises an exception', 10),
      return_exceptions=True
    )
    # Print the return values of the coroutines. If a coroutine raised an
    # exception, the exception will be returned as a return value.
    print(f'The messages are: {messages}')

  # As usual, you have to run the multiple_coroutines_with_exception3
  # function using asyncio.run.
  print('Starting concurrent execution of error prone coroutines using technique 3')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(multiple_coroutines_with_exception3())
  print('Finished concurrent execution of error prone coroutines using technique 3')
  print(datetime.now(tz=timezone.utc))

  # You can also use asyncio.wait to run multiple coroutines concurrently
  # and handle exceptions raised by them. The return_when parameter is
  # set to asyncio.FIRST_EXCEPTION, which means that the function will
  # return when the first coroutine raises an exception. Here is an example:
  async def multiple_coroutines_with_exception4() -> None:
    """
      Run multiple coroutines concurrently and handle exceptions
      raised by them.
      :return: None
    """
    # Use asyncio.wait with the return_when parameter set to
    # asyncio.FIRST_EXCEPTION. This will cause the function to
    # return when the first coroutine raises an exception.
    tasks = [asyncio.create_task(limited_delayed_message('Does not raise an exception', 5)),
             asyncio.create_task(limited_delayed_message('Raises an exception', 10))]
    done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_EXCEPTION)
    # Iterate over the done set to get the return values of the coroutines.
    # If a coroutine raised an exception, the exception will be returned as
    # a return value.
    messages = []
    for task in list(done) + list(pending):
      try:
        messages.append(await task)
      except ValueError as e:
        messages.append(str(e))
    print(f'The messages are: {messages}')

  # As usual, you have to run the multiple_coroutines_with_exception4
  # function using asyncio.run.
  print('Starting concurrent execution of error prone coroutines using technique 4')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(multiple_coroutines_with_exception4())
  print('Finished concurrent execution of error prone coroutines using technique 4')
  print(datetime.now(tz=timezone.utc))

  # If you want to pick a technique, you should go with the asyncio.gather
  # method with return_exceptions set to True. This is the most concise.

  # Tasks can be cancelled while they are running. You can cancel a task
  # by calling the cancel method on the task object. An
  # asyncio.CancelledError is raised and can be caught by the async
  # method itself or in a try/block
  # Here is an example:
  async def cancel_delayed_message() -> None:
    try:
      # Create and schedule a task object for the delayed_echo coroutine
      task = asyncio.create_task(delayed_echo('This is a really delayed message', 600))
      # Wait for 10 seconds
      await asyncio.sleep(10)
      # Cancel the task
      task.cancel()
      # Await the task to cause the asyncio.CancelledError to be raised
      await task
    except asyncio.CancelledError:
      print('Task was cancelled')

  # As usual, you have to run the cancel_delayed_message function
  # using asyncio.run.
  print('Starting task cancellation')
  print(datetime.now(tz=timezone.utc))
  asyncio.run(cancel_delayed_message())
  print('Finished task cancellation')
  print(datetime.now(tz=timezone.utc))

  # TODO: Explore async for loops
  # Refer to this video from mCoding for guidance:
  # https://www.youtube.com/watch?v=dEZKySL3M9c
