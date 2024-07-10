//-*- coding: utf-8 -*-
/**
  booleans.swift: Explore booleans in Swift
 
  This is an exploration of booleans in Swift
*/
/* -------------------------------------------------------------------
 * booleans.swift: Explore booleans in Swift.
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
import Foundation


func exploreBooleans() {

  // Booleans in Swift are declared with the Bool type.
  // They can have two values: true and false.
  // The type annotation is Bool. As usual, if you
  // initialize the variable, the type is inferred. (Note: VSCode
  // will show the inferred type inline in gray. This is not part
  // of the text file itself.)
  let isTrue = true
  let isFalse = false

  print("isTrue = ", isTrue)
  print("type(of: isTrue) = ", type(of: isTrue))
  print("isFalse = ", isFalse)
  print("type(of: isFalse) = ", type(of: isFalse))

  // Booleans can be used in conditional statements.
  let number: UInt32 = arc4random_uniform(10)
  let condition = number >= 5
  if condition {
    print("condition is true")
  } else {
    print("condition is false")
  }

  let not_condition = !condition
  if not_condition {
    print("not_condition is true")
  } else {
    print("not_condition is false")
  }

  // Booleans can be used in conditional expressions.
  let condition2: Bool = number > 2
  let result = condition2 ? "number is > 2" : "number <= 2"
  print(result)

  // You can explicitly specify the type of a boolean.
  var condition3: Bool
  condition3 = number < 5
  if condition3 {
    print("number < 5")
  } else {
    print("number > 5")
  }
}
