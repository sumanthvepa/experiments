//-*- coding: utf-8 -*-
/**
  optionals.swift: Explore optionals
*/
/* -------------------------------------------------------------------
 * optionals.swift: Explore optionals
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
 This function explores Optionals
 */
func exploreOptionals() {
  // An Optional is a type that can hold either a value or nil
  // It is defined by appending a question mark to the type
  // of the value it holds.
  var optionalInt: Int? = 10 // Optional Int with value 10
  
  // The type of optionalInt is Int? or as printed Optional<Int>
  print("type(of: optionalInt) = \(type(of: optionalInt))")
  
  // Printing a optional is a little more involved than simply
  // passing it to print. The following naive way of printing
  // an optional will produce a compiler/interpreter warning:
  // Warning: String interpolation produces a debug description
  // for an optional value; did you mean to make this explicit?
  // print("optionalInt = \(optionalInt)")
  
  // To avoid the warning explictly convert the optional to a String
  // using the String(describing: ) constructor.
  print("optionalInt = \(String(describing: optionalInt))")
  
  // You can assign nil to an optional to indicate that it has no
  // value. Note that you can only use nil with optional values.
  optionalInt = nil
  
  // If an optional is not initialized with a value, it is given a value
  // of nil.
  var surveyAnswer: String?
  print("surveyAnswer = \(String(describing: surveyAnswer))")
  surveyAnswer = "Some random answer";
  print("surveyAnswer = \(String(describing: surveyAnswer))")
  
  // Parsing strings into Ints or Floats will result in an
  // optional being created. The type is inferred in this
  // context. (Note VSCode shows inferred type as grayed out text.
  // That is not part of the file itself.)
  let possibleInt = Int("123")
  print("type(of: possibleInt) = \(type(of: possibleInt))") // Optional<Int>
  
  if possibleInt == nil {
    print("possibleInt is nil")
  } else {
    // If you are sure that the optional does not contain nil, you
    // can force unwrap the optinal and use the integer value.
    // Within the else clasue, you can be sure that possibleInt
    // actually has a non-nil value.
    // Force unwrapping is done by placing an exclamantion mark after
    // the optional variable.
    let intNumber: Int = possibleInt!
    print("intNumber is \(intNumber)")
    // You can also directly use the unwrapped value.
    print("possibleInt is really an int with value \(possibleInt!)")
  }
  
  
  // If you use the force unwrap operation in a context that does not
  // guarantee that the value is not nil, you can get a fatal error
  // at runtime.
  // let wontWork: Int = optionalInt!
  // print(wontWork)
  
  // You can get at the value within an optional by implicitly
  // unwrapping it with an if let construct
  if let unwrappedValue = possibleInt {
    // The code within the conditional is only executed if
    // possibleInt is not nil. The type of unwrappedValue
    // is Int.
    print("type(of: unwrappedValue) = \(type(of: unwrappedValue))") // type(of: unwrappedValue) = Int
    print("unwrappedValue = \(unwrappedValue)") // unwrappedValue = 123
  }

  // You can specify the type of the unwrapped value explicitly
  // in the if let construct. Although, this is usually not necessary,
  // since the type is easily inferred.
  if let unwrappedValue: Int = possibleInt {
    print("type(of: unwrappedValue) = \(type(of: unwrappedValue))") // type(of: unwrappedValue) = Int
    print("unwrappedValue = \(unwrappedValue)")
  }
  
  // A shorthand for the if let conditional is now available
  if let possibleInt {
    // This code is also only executed if possibleInt is not nil.
    // Here however, there is no need for a unwrappedValue variable.
    // A variable with the same name as the optional
    // but of type Int is created which shadows the
    // optional in the outer scope. Now any reference
    // to possibleInt is to an object of type int.
    print("type(of: possibleInt) = \(type(of: possibleInt))") // type(of: possibleInt) == Int
    print("possibleInt = \(possibleInt)") // possibleInt = 123
  }
  
  // If an optional value is nil then the else conditional (if it
  // exists) is executed.
  if let optionalInt {
    print("This code is never executed. optionalInt = \(optionalInt)")
  } else {
    // This is executed when optionalInt is nil.
    // Notice that in this section. There is no shadowed variable.
    // The type of optionalInt is still Int?
    print("type(of: optionalInt) = \(type(of: optionalInt))")
    print("optionalInt = \(String(describing: optionalInt))")
  }
  
  // You can simplify if let checks with multiple variables by combiing them
  // with commas
  if let optionalInt, let possibleInt {
    print ("optionalInt = \(optionalInt) and possibleInt = \(possibleInt)")
  }
  
  // The code above is equivalent to:
  if let optionalInt {
    if let possibleInt {
      print ("optionalInt = \(optionalInt) and possibleInt = \(possibleInt)")
    }
  }
  
  // Of course it goes without saying that an Optional<Int> is different
  // from an Optional<Double> etc. The parameter type forms part of the
  // type signature.
  var optionalFloat: Float? = nil
  // optionalFloat = optionalInt // Error: Cannot assign value of type Int? to type Float?
  optionalFloat = 23.45
  print("optionalFloat = \(String(describing: optionalFloat))")
  
  // Sometimes you simply want to check if the value is nil and if
  // so create a non-optional variable with a default. This can be
  // done in using the nil coalescing operator.
  // This is similar in function to the null coalescing operator in
  // Javascript.
  let textBoxValue: String? = nil
  // Here username is assigned textBoxValue if it is not nil. Otherwise username
  // is assigned anonymous if textBoxValue is nil. Since textBoxValue is indeed nil
  // username is "anonymous"
  let username: String = textBoxValue ?? "anonymous" // anonymous
  print("textBoxValue: \(String(describing: textBoxValue))")
  print("username: \(username)")
  
  // The code above is equivalent to the following without the use of the nil coalescing
  // operator.
  let textBoxValue2: String? = nil
  var username2: String // Note that username2 is uninitialized at this point.
  if textBoxValue2 != nil {
    username2 = textBoxValue2! // Force Unwrap the optional before assigning its value
  } else {
    username2 = "anonymous" // the optional was nil so set username2 to the default value
  }
  print("username2 = \(username2)")
  
  // An implicitly unwrapped optional is declared with an exclamation
  // mark after the type. For this type of optional, the language
  // assumes that it has a valid value of the underlying type and will
  // allow it to be used in most contexts where the underlying type is
  // permitted. A fatal runtime error will occur if the value is
  // actually nil.
  // Use implicitly unwrapped optionals, when you are absolutely sure
  // that the optional will have a non-null value. Like the situation
  // below. (Or more realistically, a value returned by a function
  // that returns an optional, but is guaranteed not to return nil in
  // the given context.)
  let implicitlyUnwrappedString: String! = "an actual string"
  // The type of implicitlyUnwrappedString is still Optional<String>
  print("type(of: isString) = \(type(of: implicitlyUnwrappedString))")
  // The same technique should be used for printing to avoid warnings about using an optional
  // Warning: String interpolation produces a debug description
  // for an optional value; did you mean to make this explicit?
  // print("implicitlyUnwrappedString = \(implicitlyUnwrappedString)") // Will generate a warning.
  print("implicitlyUnwrappedString = \(String(describing: implicitlyUnwrappedString))") // This is fine
  let trueString: String = implicitlyUnwrappedString // Can assign to a String directly.
                                                     // No forced unwrapping required.
  print("trueString = \(trueString)")

  // Using an implicitly unwrapped optional that has a nil value
  // in a context where the underlying type is required will result
  // in a fatal runtime error.
  // let implicitlyUnwrappedString2: String! = nil
  // let trueString2 = implicitlyUnwrappedString2
  // print("trueString = \(trueString)")
  
  // Optional Chaining is used to access the properties of an instance
  // of an optional over an underlying class or struct.
  // Consider the following struct User
  struct User {
    var username: String
    var name: String
  }
  
  // .. and a function that returns an optional User
  // object. Depending on whether it recoginises a username or not.
  func getUser(username: String) -> User? {
    if username == "joe" {
      return User(username: username, name: "Joe DiMaggio")
    }
    return nil
  }
  
  // Trying to directly access the member name without unwrapping will
  // result in a compiler error.
  // Error: Value of optional type User? must be unwrapped to refer
  // to member 'name' of wrapped base type.
  // var wontWork = getUser(username: "joe").name
  
  // Instead you have to explicitly unwrap the optional.
  let user = getUser(username: "joe")
  if let user {
    print("name of username \(user.username) is \(user.name)")
  }
  
  // This can be cumbersome. The optional chaining operator ?. allows
  // you to conveniently refer to the member directly. Remember
  // however, that the memeber refrence will also be an optional.
  // The type of name will be String?
  
  // The ?. syntax allows you to conveniently
  var name = getUser(username: "joe")?.name
  print("type(of: name) = \(type(of: name))") // Optional<String>
  print("name = \(String(describing: name))")
  
  // You have to explicitly unwrap the memeber to
  // get access to the underlying value type.
  if let name {
    print("name = \(name)")
  } else {
    print("Could not get name")
  }
  
  // You can directly use the user object if you wish
  if let name = user?.name { // Note that this is the long form of the if let.
                             // You cannot use the shorthand notation here.
    print("name = \(name)")
  } else {
    print("Could not get name")
  }
  
  name = getUser(username: "babe")?.name
  print("type(of: name) = \(type(of: name))")
  print("name = \(String(describing: name))")
  if let name {
    print("name = \(name)")
  } else {
    print("Could not get name")
  }
  
  // You can also use guard statements instead of if let constructs
  // to unwrap optionals. (Guard statements can be used for any
  // conditional, not just to unwrap optionals.) The guard statement
  // below executes the the else clause and breaks to the outer scope
  // to continue execution if the user is nil.
  
  // Make note of the do statement without a corresponding catch.
  // This creates a local scope. This is equivalent to simply enclosing
  // code in braces in a language like Java, Javascript or C/C++.
  // Also note the use of a labelled break to break to the outer
  // scope. We do this here because we don't want to exit the function
  // with a return. We merely want to exit the scope.
  outer: do {
    guard let user = getUser(username: "babe") else {
      break outer // This exits the do scope
    }
    print("After guard: user.name = \(user.name)")
  }
  // control passes to this point when the guard statements
  // else expression is executed.
  print("After exiting outer: do scope.")
}
