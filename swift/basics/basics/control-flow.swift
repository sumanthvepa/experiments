//-*- coding: utf-8 -*-
/**
  control-flow.swift: Explore control flow in Swift
*/
/* -------------------------------------------------------------------
 * control-flow.swift: Explore control flow in Swift
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

func exploreControlFlow() {
  // If statements
  // I put the if statement inside function which is passed the
  // result of another function to prevent Swift from complaining
  // about an untaken branch (which I am aware of.)
  func getTemperature(increase: Int) -> Int { return 30 + increase }
  func saySomethingAboutTheTemperature(temperature: Int) {
    // If statements are pretty standard. If let is used to
    // unwrap optionals. See optionals.swift about that.
    if temperature < 32 {
      print("It's freezing outside!")
    } else {
      print("It's not freezing outside!")
    }
  }
  let temperature = getTemperature(increase: 15)
  saySomethingAboutTheTemperature(temperature: temperature)
  
  // Switch statements
  let day = "Monday"
  switch day {
  case "Monday":
    print("It's Monday!")
  case "Tuesday":
    print("It's Tuesday!")
  case "Wednesday":
    print("It's Wednesday!")
  case "Thursday":
    print("It's Thursday!")
  case "Friday":
    print("It's Friday!")
  case "Saturday":
    print("It's Saturday!")
  case "Sunday":
    print("It's Sunday!")
  default:
    print("It's not a day of the week!")
  }

  // For loops.
  // This is the full form of the for loop. The scope of variable
  // i is restricted to the for loop. Note the lack of a let keyword.
  // The let is implied in a for statement. If you don't want to
  // modify the loop variable, then this form works fine.
  for i: Int in 1...5 {
    print(i)
  }

  // In this case the loop variable is being modified
  // within the loop so it needs to be declared var.
  // In general, modifying the loop variable within
  // the loop is not a great idea.
  for var i: Int in 1...5 {
    if i == 1 { i = 2 }
  }

  // This is the short hand version. Notice that there is no type
  // annotation. The type is inferred from context.
  for i in 1...5 {
    print(i)
  }

  // While loops
  var i = 1
  while i <= 5 {
    print(i)
    i += 1
  }

  // Repeat-while loops
  i = 1
  repeat {
    print(i)
        i += 1
    } while i <= 5

  // Continue and break statements
  for i in 1...10 {
    if i % 2 == 0 {
      continue
    }
    if i == 7 {
      break
    }
    print(i)
  }

  // Labeled statements
  outerLoop: for i in 1...5 {
    innerLoop: for j in 1...5 {
      if i == 3 && j == 3 {
        break outerLoop
      }
      print("i: \(i), j: \(j)")
    }
  }

  // Guard statements
  // A guard statement allows you to exit a block early if condition
  // is not met.
  // Consider the following:
  /**
    An exception class used to demonstrate the use of the guard
    statement.
  */
  struct MathError: Error {
    let message: String
    init(message: String) {
      self.message = message
    }
  }

  /**
    Computes positive seuqare root. Throws an error otherwise.
    The function used illustrate the use of the guard statement.
   */
  func squareRoot(number: Double) throws -> Double {
    // The guard statement checks that the condition
    // is met. If it is, it continues executing the code
    // after the guard statement. If it is not, it throws
    // an error.
    guard number >= 0 else {
      throw MathError(message: "Number must be greater than or equal to 0")
    }
    return number.squareRoot()
  }

  // In this code block, squareRoot will throw an exception
  // which is caught an processed.
  do {
    let result = try squareRoot(number: -1)
    print("Square root of -1 is \(result)")
  } catch let error as MathError {
    print("Error: \(error.message)")
  } catch {
    print("An error occurred!")
  }

  // Guard statements need not always throw an error.
  // they can also be used to exit early from a block.
  // Here a break is used to break out of the while loop
  func dummyReadLine() -> String? { return nil }
  while true {
    guard let line = dummyReadLine() else {
      break
    }
    // The guard let statement has unwrapped the optional
    // at this point.
    print(line)
  }
  print ("Outside of the loop!")
  
  // Guards can be used to exit functions early
  // as well. Here the function will return if
  // optionalInt is nil.
  func unwrapInteger() {
    let optionalInt: Int? = 5
    guard let unwrappedInt = optionalInt else {
      print("optionalInt is nil!")
        return // Exits the function unwrapInteger
    }
    print("optionalInt is \(unwrappedInt)")
  }
  unwrapInteger()
  
  // Note: These are constructs the GitHub Copilor recommended
  // as part of the section on control flow. I'll explore them
  // in more detail later. For now I've kept them as a reminder
  // to me that I should explore them further.
  
  // TODO: Expand on #if @available and #available
  // Use this link to start your exploration:
  // https://forums.swift.org/t/if-vs-available-vs-if-available/40266
  // Checking API availability
  if #available(iOS 10, macOS 10.12, *) {
    print("API is available!")
  } else {
    print("API is not available!")
  }

  // Checking API availability with guard
  guard #available(iOS 10, macOS 10.12, *) else {
    print("API is not available!")
    return
  }
  print("API is available!")
}
