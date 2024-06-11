//-*- coding: utf-8 -*-
/**
  functions.swift: Explore functions
*/
/* -------------------------------------------------------------------
 * functions.swift: Explore functions
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

func exploreFunctions() {
  // Functions are self-contained chunks of code that perform a
  // specific task. You give a function a name that identifies what
  // it does, and this name is used to "call" the function to perform its task when needed.
  
  // Functions in Swift have the following syntax:
  // func functionName(parameters) -> ReturnType {
  //   statements
  //   return value
  // }
  
  // Here's a simple function that takes two arguments and returns
  // their sum:
  func addTwoNumbers(a: Int, b: Int) -> Int {
    return a + b
  }
  // You can call the function like this:
  let sum = addTwoNumbers(a: 3, b: 5)
  print("The sum of 3 and 5 is \(sum)")

  // Functions can take no arguments and return no value:
  func sayHello() {
    print("Hello, world!")
  }
  sayHello()

  // Functions can also take no arguments and return a value:
  func getPi() -> Double {
    return 3.14159
  }
  let pi = getPi()
  print("The value of pi is \(pi)")
  
  
  // Functions can also take multiple arguments:
  func addThreeNumbers(a: Int, b: Int, c: Int) -> Int {
    return a + b + c
  }
  let sumOfThree = addThreeNumbers(a: 3, b: 5, c: 7)
  print("The sum of 3, 5, and 7 is \(sumOfThree)")


  // Functions have both an argument label and a parameter name.
  // The argument label is used when calling the function, and the
  // parameter name is used within the function.
  // If only one name is specified, it is used as both the argument
  // label and the parameter name.
  // However, you can specify a different argument label as follows:
  func addFourNumbers(
    first a: Int,
    second b: Int,
    third c: Int, 
    fourth d: Int) -> Int {
    // The first string is the argument label for
    // external use, the second string is the parameter
    // name for internal use.
    return a + b + c + d
  }
  let af4 = addFourNumbers(first: 5, second: 6, third: 7, fourth: 8)
  print("af4 = \(af4)")
  // Argument labels allow the function to be more readable

  // If you don't want an argument label, you can use an underscore
  // as the argument label:
  func printIt(_ message: String) {
    print(message)
  }
  // Now you can invoke the function without specifying the argument
  // label:
  printIt("This is a message")

  // Function parameters are constant by default. This means that
  // you cannot change the value of a parameter within a function.
  // If you want to change the value of a parameter, you must declare
  // it as an inout parameter:
  func swapTwoInts(a: inout Int, b: inout Int) {
    let temp = a
    a = b
    b = temp
  }
  var x = 5
  var y = 10
  // You then have to call the function with the & operator
  // to indicate that the arguments are inout parameters:
  swapTwoInts(a: &x, b: &y)

  // Functions can take a variable number of arguments,
  // also called variadic parameter using the ... syntax.
  // Note that in the function below all arguments must
  // be of int Int type.
  func sumOf(numbers: Int...) -> Int {
    print("type(of: numbers) = \(type(of: numbers))")
    var sum = 0
    for number in numbers {
      sum += number
    }
    return sum
  }
  let sumOfNumbers = sumOf(numbers: 1, 2, 3, 4, 5)
  print("The sum of 1, 2, 3, 4, and 5 is \(sumOfNumbers)")
  
  // Functions can also return multiple values using tuples:
  func minMax(array: [Int]) -> (min: Int, max: Int) {
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
      if value < currentMin {
        currentMin = value
      } else if value > currentMax {
        currentMax = value
      }
    }
    return (currentMin, currentMax)
  }
  
  let bounds = minMax(array: [8, -6, 2, 109, 3, 71])
  print("The minimum is \(bounds.min) and the maximum is \(bounds.max)")  
  
  // Functions are first class objects in Swift, which means you can
  // assign them to variables, pass them as arguments to other
  // functions, and return them from other functions:
  func add(a: Int, b: Int) -> Int {
    return a + b
  }
  
  func callFunction(function: (Int, Int) -> Int, a: Int, b: Int) -> Int {
    // Call the function passed as an argument
    return function(a, b)
  }
  
  // Pass add as an argument to callFunction
  print("callFunction(function: add, a: 3, b: 5) = \(callFunction(function: add, a: 3, b: 5))")
  
  // Functions can return other functions:
  // Notice that the returned function carries the
  // context under which it was invoked. In this
  // case it is the value of a that was passed to
  // makeAdder at the point at wich the particular
  // instnace of the adder function was created.
  func makeAdder(a: Int) -> (Int) -> Int {
    func adder(b: Int) -> Int {
      return a + b
    }
    return adder
  }
  
  let add3 = makeAdder(a: 3)
  print("type(of: add3) = \(type(of: add3))")
  print("adder(5) = \(add3(5))") // Prints 8
  
  let add5 = makeAdder(a: 5)
  print("type(of: add5) = \(type(of: add5))")
  print("adder(5) = \(add5(5))") // Prints 10
  
  // Functions can be nested within other functions:
  // In this case innerFunction is not being returned
  // as value, it is being called from within outerFunction.
  // The scope of innerFunction is limited to outerFunction.
  func outerFunction() -> Int {
    func innerFunction() -> Int {
      return 5
    }
    return innerFunction()
  }
  print("outerFunction() = \(outerFunction())")
  
  // You can create anonymous functions using the
  // { (parameters) -> ReturnType in statements } syntax:
  let multiply = { (a: Int, b: Int) -> Int in
    return a * b
  }
  print("multiply(3, 5) = \(multiply(3, 5))")
  
  // You can also omit the parameter types and return type
  // if they can be inferred. Here the type of b is infered
  // as Double because a is a double.
  let a: Double = 10.3
  let divide = { (b) in
    return a / b
  }
  print("divide(\(a), 2) = \(divide(2))")
  
  // Closures are most useful when they are created in-situ
  // You can even skip the return in single expression closures
  // like the one below:
  var names = ["Saoirse", "Niamh", "Caoimhe", "Tadhg"]
  names.sort(by: {(s1, s2) in s1 > s2})
  
  // Swift provides short hand argument names, so the parameter
  // lists can be skipped in the closure above.
  names.sort(by: { $0 > $1 })
  
  // In this instance you can skip the closure altogether and
  // simply pass the operator method that you want to use.
  // Swift will infer everything else from context.
  names.sort(by: >)
  
  // You can also use trailing closures when the closure is the
  // last argument to a function. This makes the code more readable.
  // Here the body of the closure is outside the function call.
  // The parameter list is inferred.
  names.sort() { $0 > $1 }
  print(names)
  
  // If the closure is the only argument to the function, you can
  // skip the parentheses altogether.
  names.sort { $0 < $1 }
  
  // You can also use trailing closures with functions that take
  // multiple arguments. In this case the closure is the last
  // argument to the function.
  let numbers = [1, 2, 3, 4, 5]
  let sumOfNumbers1 = numbers.reduce(0) { $0 + $1 }
  print("sumOfNumbers1 = \(sumOfNumbers1)")
  
  // You can of course use the full syntax for closures as well
  // after the function name.
  let sumOfNumbers2 = numbers.reduce(0) { (a: Int, b: Int) in
    return  a + b
  }
  print("sumOfNumbers2 = \(sumOfNumbers2)")
  
  // Note that closures capture the values of variables by reference
  // not by value. This means that if you change the value of a variable
  // outside the closure, the closure will see the new value.
  
  var indent = 4
  let addIndent = { (line: String) -> String in
    return String(repeating: " ", count: indent) + line
  }
  print(addIndent("Hello, world!")) // Prints "    Hello, world!"
  indent = 2
  print(addIndent("Hello, world!")) // Prints "  Hello, world!"
  
  // In Swift the lifetime of a closure is determined by the lifetime
  // of the variables it captures. If a closure does not capture
  // any variables in its surrounding environment, and is passed
  // to a function then its lifetime is the same as the function
  // it is passed to. This means that normally, the function cannot
  // return the closure, because the closure will be destroyed when
  // the function returns.
  
  // To solve this problem, you can use the @escaping attribute
  // to a closure parameter in a function. This tells the compiler
  // that the closure will be stored outside the function's scope
  // and will be called after the function returns.
  
  // This example is taken from Swift's documentation.
  var listOfFunctions: [() -> Void] = []
  func addToListOfFunctions(function: @escaping () -> Void) {
    listOfFunctions.append(function)
  }
  
  addToListOfFunctions { print("Hello!") }
  addToListOfFunctions { print("Goodbye!") }
  
  for function in listOfFunctions {
    function()
  }

  // TODO: Explore capture lists in more detail later.
  // TODO: Explore 
}
