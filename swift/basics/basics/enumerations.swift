//-*- coding: utf-8 -*-
/**
  enumerations.swift: Explore enumerations
*/
/* -------------------------------------------------------------------
 * enumerations.swift: Explore enumerations
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

func exploreEnumerations() {
  // An enumueration defines a common type for a group
  // of related values and allows you to work with those
  // values in a type safe way.
  // E.g
  enum HttpError {
    case NotFound
    case BadRequest
    case Unauthorized
    case Forbidden
    case InternalServerError
  }
  // Example usage of the HttpError enumeration
  func handleHttpError(error: HttpError) {
    switch error {
    case .NotFound:
      print("404 - Page not found")
    case .BadRequest:
      print("400 - Bad request")
    case .Unauthorized:
      print("401 - Unauthorized")
    case .Forbidden:
      print("403 - Forbidden")
    case .InternalServerError:
      print("500 - Internal server error")
    }
  }

  // Call the function with different HttpError cases
  handleHttpError(error: .NotFound)
  handleHttpError(error: .BadRequest)
  handleHttpError(error: .InternalServerError)

  // You can get the total number of enum cases if
  // you implement the CaseIterable protocol
  enum PaintColors: CaseIterable {
    case Red
    case Blue
    case Green
    case Cyan
    case Magenta
    case Yellow
    case White
    case Black
  }
  let totalNumberOfColors = PaintColors.allCases.count
  print("There are \(totalNumberOfColors) colors available")

  // You can iterate over individual cases if you have implemented
  // the CaseIterable protocol
  for color in PaintColors.allCases {
    print(color)
  }

  // Enumerations can have associated values.
  // The assocated value is associated with an instance of the enum
  // case, not the enum case itself.
  enum Shape {
    case Circle(radius: Double)
    case Rectangle(width: Double, height: Double)
    case Triangle(base: Double, height: Double)
  }

  // You can iterate over the associated values
  // using a switch statement. The associated value
  // can be accessed using an associated let
  // clause as shown below.
  func calculateArea(shape: Shape) -> Double {
    switch shape {
    case .Circle(let radius):
      return Double.pi * radius * radius
    case .Rectangle(let width, let height):
      return width * height
    case .Triangle(let base, let height):
      return 0.5 * base * height
    }
  }

  let circle = Shape.Circle(radius: 5.0)
  let rectangle = Shape.Rectangle(width: 3.0, height: 4.0)
  let triangle = Shape.Triangle(base: 6.0, height: 8.0)

  let circleArea = calculateArea(shape: circle)
  let rectangleArea = calculateArea(shape: rectangle)
  let triangleArea = calculateArea(shape: triangle)

  print("Area of circle: \(circleArea)")
  print("Area of rectangle: \(rectangleArea)")
  print("Area of triangle: \(triangleArea)")

  // Enumerations can have values associated with each
  // case, not just an instance of a case. This is more
  // in line with how enums work in languages like Java.
  // This technique is discussed in exceptions.swift.
  // It is reproduced here for completeness.

  enum HttpErrorExtended: Error {
    case FileNotFound(filename: String)
    case InternalServerError(details: String)
    case ImATeapot

    /**
      The HTTP error code for the error
      The code computed property returns the Http status
      code associated wtih the error type. This is
      different from the associated value of the case.
      which is the filename in the case of FileNotFound
      and details in the case of InternalServerError.
    */
    var code: Int {
      get {
        switch self {
        case .FileNotFound:
          return 404
        case .InternalServerError:
          return 500
        case .ImATeapot:
          return 418
        }
      }
    }

    /**
      The HTTP status message for the error.
      This is another computed property that returns
      the status message associated with the error type.
      This is different from the associated value of the case.
      which is the filename in the case of FileNotFound
      and details in the case of InternalServerError.
    */
    var status: String {
      get {
        switch self {
        case .FileNotFound:
          return "File Not Found"
        case .InternalServerError:
          return "Internal Server Error"
        case .ImATeapot:
          return "I'm a teapot"
        }
      }
    }
  }

  // Enumerations can have raw values. Raw values are
  // prepopulated values that are the same for all instances.
  // Raw values can be of type String, Character, Int, or Float.
  // Raw values are defined when the enumeration is declared.
  // Raw values are accessed using the rawValue property.
  // Raw values are useful when you need to map an enumeration
  // to a value that is known at compile time.
  // Raw values are an alternative to computed properties.
  // But they are not as flexible as computed properties.
  // With computed properties, you can have multiple computed
  // properties that return different types of value. For example,
  // in the HttpErrorExtended enum, we have two computed properties
  // code and status that return Int and String respectively.
  // However if you use raw values, you can only have one type
  // of raw value. For example, in the Weekday enum below, the
  // raw value is Int. You cannot have a raw value of type String
  // and Int at the same time.
  // Nothing prevents you from having both raw values and computed
  // properties in the same enumeration though. The is weekend
  // property in the Weekday enum is a computed property.
  enum Weekday: Int {
    case Sunday = 1
    case Monday // implicitly assigned 2
    case Tuesday // implicitly assigned 3
    case Wednesday // implicitly assigned 4
    case Thursday // implicitly assigned 5
    case Friday // implicitly assigned 6
    case Saturday // implicitly assigned 7

    var isWeekend: Bool {
      switch self {
      case .Saturday, .Sunday:
        return true
      default:
        return false
      }
    }
  }
  // In the above example, Sunday is explicitly assigned the
  // raw value 1, while Monday is implicitly assigned
  // the raw value 2, Tuesday is assigned 3, and so on.
  // You can access the raw value using the rawValue property.
  let monday = Weekday.Monday
  print("Monday is \(monday.rawValue)")

  // And you can get case specific values like isWeekend
  // from the computed property. (It could also have been a
  // method. But computed properties are more idiomatic in Swift.)
  if monday.isWeekend {
    print("Monday is a weekend")
  } else {
    print("Monday is a weekday")
  }

  // You can initialize an enumeration with from a raw value
  // using the init(rawValue:) initializer. This initializer
  // returns an optional enumeration value. If the raw value
  // does not match any of the enumeration cases, the initializer
  // returns nil.
  let sunday = Weekday(rawValue: 1)
  if let sunday = sunday {
    print("Sunday is \(sunday)")
  } else {
    print("Invalid raw value")
  }

  // It is possible for an enums associated value to be an enum
  // of the same type. This is called recursive enumeration.
  // Recursive enumerations are useful when you need to model
  // a tree like structure. For example, a binary tree can be
  // modeled using a recursive enumeration.
  // The following example models a simple arithmetic expression
  // using a recursive enumeration.
  enum ArithmeticExpression {
    case Number(Int)
    indirect case Addition(ArithmeticExpression, ArithmeticExpression)
    indirect case Multiplication(ArithmeticExpression, ArithmeticExpression)
  }
  // The indirect keyword is used to indicate that the enumeration
  // case is recursive.

  // You can create an instance of the ArithmeticExpression enum
  // as shown below.
  let five = ArithmeticExpression.Number(5)
  let four = ArithmeticExpression.Number(4)
  let sum = ArithmeticExpression.Addition(five, four)
  let product = ArithmeticExpression.Multiplication(sum, ArithmeticExpression.Number(2))

  // You can evaluate the expression using a recursive function
  func evaluate(expression: ArithmeticExpression) -> Int {
    switch expression {
    case .Number(let value):
      return value
    case .Addition(let left, let right):
      return evaluate(expression: left) + evaluate(expression: right)
    case .Multiplication(let left, let right):
      return evaluate(expression: left) * evaluate(expression: right)
    }
  }

  print(evaluate(expression: sum)) // Prints 9
  print(evaluate(expression: product)) // Prints 18
}

