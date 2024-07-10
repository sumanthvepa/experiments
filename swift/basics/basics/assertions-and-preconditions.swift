//-*- coding: utf-8 -*-
/**
  assertions-and-preconditions.swift: Explore asserts and preconditions
*/
/* -------------------------------------------------------------------
 * assertions-and-preconditions.swift: Explore asserts and preconditions
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

/**
  Explore assertions and preconditions
*/
func exploreAssertionsAndPreConditions() {
  // An assert is a runtime check that will cause your app to stop
  // running if the condition being checked is false. You use an assert
  // to make sure that an essential condition is satisfied before
  // executing any further code. If the condition is true, code
  // execution continues as usual. If the condition is false, the app
  // is terminated, and an error message is logged.

  // For example:
  let age = -3
  print("age = \(age)")
  // This assert will cause program termination.
  // If you run it inside Xcode, you will be dropped into
  // an lldb debugger prompt.
  // Its commented out for this reason.
  // assert(age >= 0, "A person's age cannot be less than zero")
  
  // If you simply want to assert failure when the code reaches
  // a certain place in the code, because you know the progam is
  // in an unrecoverable state, use assertFailure
  // Once agian the code is commented out to prevent the program
  // from stopping here.
  // assertionFailure("The program should never get here")
  
  // A precondition is very similar to an assert, except that
  // semantically it means that execution should not progress
  // if the precondition is not met. This is useful to put
  // at the top of functions.
  func printAge(age: Int) {
    precondition(age > 0, "Age must be positive")
    print(age)
  }
  
  // This will cause a precondition to fail.
  // In Xcode you will get dropped into the lldb prompt
  // Once again, commented out to prevent the program
  // from stopping here.
  // printAge(age: age)
  
  // If you know a precondition has already failed you
  // can use the unconditional version:
  // Same reason as above for commenting out the code.
  // preconditionFailure("Things are real bad man!")
  
  // Note that both assert and precondition are optimized out
  // in some situations. Details of when preconditions and asserts
  // will fail are well described by
  // https://blog.krzyzanowskim.com/2015/03/09/swift-asserts-the-missing-manual/
  
  // The behavior of these functions under variuous build conditions
  // is given below, and is taken from the blog post above.
  
  //  assert   DEBUG mode (will terminate)  RELEASE mode (will not terminate)   RELEASE -Ounchecked (will not terminate)
  //  assertFailure DEBUG mode (will terminate)  RELEASE mode (will not terminate)   RELEASE -Ounchecked (will not terminate)
  //  precondition DEBUG mode (will terminate)  RELEASE mode (will  terminate)   RELEASE -Ounchecked (will not terminate)
  //  preconditionFailure DEBUG mode (will terminate)  RELEASE mode (will terminate)   RELEASE -Ounchecked (will terminate)
  
  // If you want to ensure that a program terminates no matter what conditions it is built under
  // then use fatalError
  // fatalError("This will terminate the program for all types of buiilds")
}
