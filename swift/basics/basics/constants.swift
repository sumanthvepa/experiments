//-*- coding: utf-8 -*-
/**
  constants.swift: Explore constants in Swift
 
  This is an exploration of constants in Swift
*/
/* -------------------------------------------------------------------
 * constants.swift: Explore constants in Swift.
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
 A function that dummies loading a string from a file.
 - returns
 The string "dummy string"
 */
func loadFromFile() -> String {
  return "dummy string"
}

/**
 This function explores constants.
 */
func exploreConstants() {
  // Constants are declared with the let keyword. Constants
  // must be initialized.
  let constant = 10
  print("constant = ", constant)
  
  // The in the initialization above, the type of the constant
  // was inferred from the type of the literal assigned to it.
  // in this case Int.
  print("type(of: constant) = ", type(of: constant))
  
  // You can explitly specify the type using a type annotation
  let constant2: Float = 25.03
  print(constant2)
 
  // You can declare an uninitialized constant. But you must
  // give it a type-annotation, so the compiler knows its type.
  let constant3: String;
  // print(constant3); // Error: constant2 used befor being initialized.
  // You can initialize a constant after it has been declared.
  // This is useful for situations where the constants value can only
  // be known at runtime.
  constant3 = loadFromFile();
  print(constant3) // Ok. It's been initialized.
  
  // A constant declaration without either an initializer or a
  // type-annotation is an error.
  // This is because Swift is statically typed. The compiler/interperter
  // needs to know at compile time how much storage to allocate
  // for the constant on the stack.
  // let constant4 // Error: Type annotation missing in pattern.
  
  // You can initialize a constant exactly once.
  // Attempts to assign to an already initializd constant will result
  // in an compile-time error.
  // constant3 = "re-definition" // Error: Immutable value constant3
                                 // may only be initialized once.
  
  // You can initialize multiple constans separated by commas,
  // I don't recommend it, though as it is easy to miss the
  // declaration and initialization of the second constant,
  // particularly if it is of a different type.
  let constant5: Double = 43.2763, constant6: String = "constant5"
  print(constant5)
  print(constant6)
  
  
  // constant7 is an unitialized constant of type Double,
  // constant8 is inferred to have type of String and is
  // initialized.
  let constant7: Double, constant8 = "constant8";
  constant7 = 34.5689
  print(constant7)
  print(constant8)
  
  // Constants can have unicode symbols.
  let π = 3.1415926535;
  let ℎ: Double = 6.62607105e-34
  // Reduced Planck's constant
  let ℏ: Double = ℎ/(2.0*π)
  print(ℏ)
}
