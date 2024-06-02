//-*- coding: utf-8 -*-
/**
  tuples.swift: Explore tuples
*/
/* -------------------------------------------------------------------
 * tuples.swift: Explore tuples
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
 Explore Tuples
 */
func exploreTuples() {
  // A tuple is a ordered sequence of multiple values.
  // This is an example of a tuple with three integer
  // values. There is no type annotation here, but the
  // type of the tuple is inferred to be (Int, Int, Int)
  let tuple1 = (1, 2, 3)
  print("tuple1: \(tuple1)")

  // You can explicitly specify the type of a tuple
  let tuple2: (Int, Int, Int) = (4, 5, 6)
  print("tuple2: \(tuple2)")

  // You can leave a tuple uninitialized.
  var tuple3: (Int, Int, Int)
  // And then initialize it later.
  tuple3 = (7, 8, 9)
  print("tuple3: \(tuple3)")
  // And if it is a variable you can assign it another tuple:
  tuple3 = (10, 11, 12)
  print("tuple3: \(tuple3)")

  // The elements of a tuple can have different types.
  let tuple4: (Int, String, Double) = (13, "Hello", 3.14)
  print("tuple4: \(tuple4)")

  // The type can be as complex as you want.
  // This tuple has a tuples inside it.
  let tuple5: (Int, (String, Double), (Int, Int))
    = (14, ("World", 2.71), (15, 16))
  print("tuple5: \(tuple5)")

  // Or even an array. This is a tuple that has an array of
  // strings inside it.
  let tuple6: (Int, [String], (Int, Int))
    = (17, ["Hello", "World"], (18, 19))
  print("tuple6: \(tuple6)")

  // Or a class instance...
  class MyClass {
    var value: Int
    init(value: Int) {
      self.value = value
    }
  }
  let tuple7: (Int, MyClass, (Int, Int))
    = (20, MyClass(value: 21), (22, 23))
  
  // Note that the 'address' of the object of instance MyClass is
  // printed not the contents of the object itself. Refer to
  // exploreClassBasics on how to print members of an object.
  print("tuple7: \(tuple7)")
  
  // Tuples can be decomposed by assignment:
  let (a, b, c) = tuple1
  print("a: \(a), b: \(b), c: \(c)")
  
  // If you don't need a value in tuple you can skip
  // it by using _.
  let (d, _, e) = tuple1
  print("d: \(d), e: \(e)")

  // You can access the elements of a tuple using the
  // dot notation followed by the index of the element.
  print("tuple3.0: \(tuple3.0)")
  print("tuple3.1: \(tuple3.1)")
  print("tuple3.2: \(tuple3.2)")
  
  // If you name the elements of the tuple, you can access
  // the elements by their names:
  let notFound: (statusCode: Int, statusMessage: String) = (404, "Not found")
  print("notFound.statusCode = \(notFound.statusCode), notFound.statusMessage = \(notFound.statusMessage)")
  
  // You can assign the names implicitly as well:
  let redirect = (statusCode: 303, statusMessage: "Temporary Redirect")
  print("redirect.statusCode = \(redirect.statusCode), redirect.statusMessage = \(redirect.statusMessage)")
  
  // Tuples are particularly useful when a function needs to return multiople values:
  func makeTuple(intValue: Int, strValue: String) -> (Int, String) {
    return (intValue, strValue)
  }
  let httpOk = makeTuple(intValue: 200, strValue: "Ok")
  print("httpOk = \(httpOk)")
  
  // If the tuple is declared as a var, you can change the value of its memebers.
  var tuple9 = (34, "Hello")
  tuple9.0 = 42
  print("tuple9 = \(tuple9)")
  
  // You can use named elements as well, if you've named them:
  var imATeapot = (statusCode: 418, statusMessage: "I'm a teapot")
  imATeapot.statusMessage = "I'm actually a kettle"
  print("imATeapot = \(imATeapot)")
}
