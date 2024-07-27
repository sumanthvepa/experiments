// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * concurrency.swift: Explore asynchronous programming in Swift
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

import Foundation // Defines URLError


// This function explores concurrency in Swift. Notice
// that the function itself is marked as async. This
// is because only async functions can call other async
// functions (unless you use Task APIs -- which are discussed
// in the basics project).
func exploreConcurrencyBasics() async {
  // First as an example, let's define a function that simulates
  // fetching a resource from a URL. This function is marked
  // as async because it performs a (simulated) network operation.
  // In this case we are using Task.sleep to simulate the network
  // operation. Task.sleep is a function that suspends the current
  // task for a specified amount of time. Since this function
  // also throws an error, we mark it with the throws keyword.
  // Note that the async keyword must come before the throws keyword.
  func fetchResource(url: String) async throws -> String {
    // We use await to suspend the current task until the
    // result of the Task.sleep function is available.
    // We also use try to handle any errors that might be thrown
    // by Task.sleep. Note that the try must come before the await. 
    try await Task.sleep(for: .seconds(5))
    return "Resource fetched from \(url)"
  }

  // Now we can call the fetchResource function. Since it is an
  do {
    // Once again notice the use of await to suspend the current
    // task until the result of the fetchResource function is available.
    // And also the use of try to handle any errors that might be thrown
    let content = try await fetchResource(url: "https://www.example.com/url1")
    // We print the content of the resource that was fetched
    print(content)
  } catch {
    print("Error: \(error)")
  }
}
