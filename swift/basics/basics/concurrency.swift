//-*- coding: utf-8 -*-
/**
  concurrency.swift: Explore concurrency
 
  This is an exploration of asynchronous programming in Swift
*/
/* -------------------------------------------------------------------
 * concurrency.swift: Explore concurrency
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License a
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 *-----------------------------------------------------------------*/
// Defines DispatchQueue 
import Foundation
import Dispatch

// There is no safe way to call asynchronous code from synchronous
// code in Swift. Hence Swift does not provide an formal mechanisms
// for this purpose. Either a progam is synchronous or asynchronous.

// The problem for this project (basics) is that the main function is
// synchronous so we cannot fully explore asynchronous programming
// in Swift from within this project. Hence most of the exploration of
// asynchronous programming in Swift will be done in a entirely
// different Xcode project.

// To learn about asynchronous programming in Swift, start with
// this file, and then move on to the asyncs Xcode project.

// To explore asynchronous programming in Swift, we first need to
// understand event loops. Then we explore the use of Tasks without
// return values to call asynchronous code from synchronous code.

// Then we explore unsafe hacks to call asynchronous code from
// synchronous code to get values back from the asynchronous call.
// Using this in production code is not recommended, but it does help
// in understanding how asynchronous code works in Swift.

func exploreEventLoops() {
  // We first start with the idea of a Run Loop
  // A run loop is an event processing loop that you use to schedule
  // work and coordinate the receipt of incoming events.

  // For asynchronous programming to work we need a loop that checks
  // for work that needs to be done, and then calls the function that
  // does that work. That function will execute until it is either done
  // or needs to wait for something to happen. When it waits, it releases
  // control back to the loop, which can then check for more work to do.
  // When the function is ready to continue, the loop calls it again.

  // In interpreted languages like Python or JavaScript,
  // the interpreter itself is the loop. It checks for work to do, and
  // then calls the function that does that work.

  // When you write a command-line program in Swift, you have to
  // manage the run loop yourself. In a GUI application, the framework
  // manages the run loop for you. In a playground, the playground
  // itself manages the run loop for you.
  
  // In a command-line program, a runloop is not started automatically.
  // You have to start it manually and stop it manually. Since this
  // exploration is a command-line program, we will start and stop the
  // run loop manually.

  // We will be using low-level APIs CFRunLoop* to start and stop the
  // run loop.

  // All asynchronous code in Swift is built on top of run loops
  // and threads internally. But you should never have to interact
  // with run loops in non-hacky code. For the correct way to do
  // asynchronous programming follow the instructions in the async
  // project.

  // However this code is valid and correct Swift code. It is just
  // not the recommended way to do asynchronous programming in Swift.


  print("Exploring event loops in Swift")

  // Consider the following function This schedules a simulated network
  // request on a work queue, from which the event loop will pick it up
  // and execute it. This function takes a URL and a completion handler
  // and then schedules a simulated network request on a a work queue.
  // This work queue is provided by the class DispatchQueue. There are
  // four types of queues: main, global, custom(which could either
  // be concurrent or serial). The RunLoop code will pick tasks
  // for execution from these DispatchQueue queues. 
  
  // In this instance we are using a global queue. The global queue
  // is a concurrent queue, which means that it can run multiple tasks
  // at the same concurrently. The global queue is a good choice for
  // network requests, and non UI related work, because it allows
  // multiple requests to be made at the same time.


  func fetchResource(url: String, completion: @escaping (String) -> Void) {
    // Schedule a task on to the global async queue. The task
    // is a closure that is passed to the async function.
    // The task is not actually run immediately. It is scheduled
    // to run on the global queue. The RunLoop function will pick
    // it up and execute it.
    DispatchQueue.global().async {
      // This simulates a network request by sleeping for 5 seconds
      // It then calls the completion handler with a message.
      // The sleep operation will block the current task and 
      // yield control back to the RunLoop for other tasks to run.
      // Execution will be resumed after the sleep when it is complete
      // and the RunLoop schedules this task for exection again.
      sleep(5)
      completion("Resource fetched from \(url)")
    }
  }

  // We get a reference to the current run loop using the
  // low-level API CFRunLoopGetCurrent().
  let runLoop = CFRunLoopGetCurrent()

  // We call fetchResource, which schedules the simulated network
  // request on the global queue. We pass a completion handler
  // to handle the result of the network request
  fetchResource(url: "https://example.com") { result in
    // This function is called from the the task that was passed
    // to the global queue in fetchResource
    // This simply prints the result. And since we have
    // manually started the run loop, we need to manually
    // stop it as well. The CFRunLoopStop function causes the
    // top level run loop to gracefully exit.
    print(result)
    CFRunLoopStop(runLoop)
  }  

  // Finally we start the run loop using the low-level API
  // This executes the task secheduled by fetchResource, executes
  // it, until it is done. It then exits, as the completion handler
  // calls CFRunLoopStop from within the run loop.
  CFRunLoopRun()
  print("Finished exploring event loops in Swift")
}


func exploreConcurrency() {
  // This function demonstrates one of two legimitate ways to
  // call asynchronous code from synchronous code in Swift.
  // Note that there are no return values from Task objects
  // created in this code. There is no way to get the result
  // back from the Task object in synchronous code in a
  // non-hacky manner. For hacks see the next two functions.

  // However, this is still not the best way to do asynchronous
  // programming, becuase it still relies on low-level run loop
  // APIs to cause the main function to wait for the asynchronous
  // task to complete. The best way to do asynchronous programming
  // is to use the techniques described in the asyncs project.

  // The following function is an asynchronous function. It is
  // declared with the async keyword. This means that it can be called
  // from other async functions or from within a Task, and that it can
  // use the await keyword to wait for the result of another async
  // function.

  // The function fetchResource simulates fetching a network
  // resource asynchronously. It takes a URL and returns the
  // resource as a string. The function sleeps for 5 seconds,
  // simulating a network request. During this time, the function
  // yields control back to the run loop, which can then run
  // other tasks.
  
  // The @Sendable attribute is used to indicate that the function
  // can be called from a Task. This is required because the function
  // is asynchronous. And the Task is the Swift concurrency model
  // for running asynchronous code from within a synchronous context.
  @Sendable func fetchResource(url: String) async throws -> String {
    try await Task.sleep(for: .seconds(5))
    return "Resource fetched from \(url)"
  }
  
  // Async functions can only be called from other asyncFunctions
  // and await is only allowed in an async function.

  // So we wrap the call to fetchResource in a Task. which allows
  // for running asynchronous code from within a synchronous context.
  // This Task object is automatically scheduled on the default dispatch
  // queue. The Task object is a handle to the asynchronous task.
  // We don't use the task object directly in this code, so we don't
  // need to store it in a regular variable. The _ is good enough.
  let _ = Task {
    do {
      let content = try await fetchResource(url: "http://example.com/")
      print(content)
    } catch {
      print("Error fetching resource: \(error)")
    }
  }
  
  // Finally we start a run loop to process tasks and block this 
  // function until the asynchronous task is complete.
  // This one runs long enough to guarantee that the task is
  // completed.
  RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
  
  // The above code is somewhat inefficient, and likely prone
  // to race conditions, since we are hoping that the main loop
  // will run longer than it takes the fetchResource task
  // complete. To avoid these problems we can use the technique
  // discussed in exploreEventLoops, where we run the event loop
  // until it is signalled from within a task to stop.

  let runloop1 = CFRunLoopGetCurrent()
  
  let _ = Task {
    do {
      // Await will suspend execution of the task and return
      // control to the run loop until fetchResource has
      // a value to return.
      let content = try await fetchResource(url: "http://example.com/url2")
      print(content)
    } catch {
      print("Error fetching resource: \(error)")
    }
    // Signal the runloop to stop before exiting the task.
    CFRunLoopStop(runloop1)
  }
  
  // Finally run the event loop. This will block and only
  // exit when the runloop is stopped from within the task
  // with a call to CFRunLoopStop.
  CFRunLoopRun()

  // Yet another way to ensure that the main function does not
  // exit before the asynchronous task is complete is to use
  // semaphores. This is a more efficient way to block the main
  // function until the asynchronous task is complete.
  // Here is an example of how to use semaphores to block the
  // main function until the asynchronous task is complete.
  // This is a legitimate way to call asynchronous code. There
  // are no calls to low-level run loop APIs.
  // No issues here. But you must understand semaphores well
  // and be careful to avoid deadlocks.
  let semaphore = DispatchSemaphore(value: 0)
  let _ = Task {
    do {
      let content = try await fetchResource(url: "http://example.com/url3")
      print(content)
    } catch {
      print("Error fetching resource: \(error)")
    }
    semaphore.signal()
  }

  // Wait for the semaphore to be signalled before continuing
  // This code will suspend the main function until the semaphore
  // is signalled from within the task.
  semaphore.wait()
}

// Note the explorations that follow are hacks. The correct way to do
// asynchronous programming is for the entire program to be
// asynchronous. See the asyncs project for the correct way to do
// asynchronous programming in Swift.

// The following stuct and async function are used in the next
// two hacks. So they are defined here.
struct FetchError: Error {
  let message: String
}

@Sendable func mockFetchResource(url: String) async throws -> String {
  try await Task.sleep(for: .seconds(5))
  return "Resource fetched from \(url)"
}

// If you want to get the result of a an async function from outside
// the async function, you can use a completion handler. This is a
// common pattern in Swift. The completion handler is a closure that
// is passed to the async function. The async function calls the
// completion handler when it is done. The completion handler is
// called with the result of the async function. This is similar
// to how fetchResource works, but with a completion handler instead
// of an async function.

// Here's one way. It's less hacky than the other way, but it's still
// not recommended for production code.

func callingAsyncCodeFromSyncCodeHack1() {
  // We define a wrapper around the mockFetchResource function that
  // takes a URL and a completion handller. The wrapper is a
  // synchronous function that creates a Task.

  // The completion handler is a closure that takes a Result
  // object as an argument. The Result object is a Swift enum
  // that represents either a success or a failure. The success
  // case contains the result of the async function. The failure
  // case contains an error. The completion handler is called
  // with the result of the async function.
  func fetchResource(url: String, completion: @escaping (Result<String, Error>) -> Void) {
    Task {
      do {
        let content = try await mockFetchResource(url: url)
        completion(.success(content))
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  // The completion handler is called with the result of the async
  // function. The result is a Result object that contains either
  // the result of the async function or an error. The completion
  // handler prints the result of the async function.
  fetchResource(url: "http://example.com/url3") { result in
    switch result {
    case .success(let content):
      print(content)
    case .failure(let error):
      print("Error: \(error)")
    }
  }

  // Notice that no run loop is needed in this hack. The Task object
  // automatically schedules the task on the default dispatch queue.
  // Since the completion handler is called from the task, it is
  // guaranteed to be called after the task is done. And it runs
  // in the same concurrency domain as the Task and not that
  // of this main function.
}


// This hack is even more hacky than the previous one. But if you
// absolutely need to get the result of an async function from
// outside the async function in the same concurrency domain as
// main function, you can use this hack.

// Result needs to be global. Why? I'm not exactly sure, but it
// has to do with not being a part of a closure. It doesn't quite
// make sense to me, but it works.
var result: Result<String, Error>? = nil
func callingAsyncCodeFromSyncCodeHack2() {
  let runloop2 = CFRunLoopGetCurrent()
  
  // Create a task
  let _ = Task {
    defer { CFRunLoopStop(runloop2) }
    do {
      let content = try await mockFetchResource(url: "http://example.com/url4")
      // return content
      result = .success(content)
    } catch {
      // throw FetchError(message: "mockFetchResource raised an exception")
      result = .failure(error)
    }
  }
  
  // Start the event loop
  CFRunLoopRun()
  
  // Retrieve and print the result
  switch result {
  case .success(let content):
    print(content)
  case .failure(let error):
    print("Error: \(error)")
  case .none:
    print("No result")
  }
}
