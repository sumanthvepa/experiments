//-*- coding: utf-8 -*-
/**
  variables.swift: Explore variables in Swift
*/
/* -------------------------------------------------------------------
 * variables.swift: Explore constants in Swift.
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

func exploreVariables() {
  // Variables are declared with the var keyword.
  // The rules for variables are substantially the same as for
  // constants.
  
  // This is a variable that is also initialized, whose type
  // is infrered from the type of the literal assigned to it.
  // Note that as with constants, the type of the variable shown
  // by IDEs like VSCode is not part of the text file itself.
  // It is inferred by the IDE and displayed for convenience.
  var speed = 32.0
  print ("speed = ", speed)
  print("type(of: speed) = ", type(of: speed)) // Double
  
  // The whole point of a variable is that it can be changed. So...
  speed = 75
  print ("speed = ", speed)
  print("type(of: speed) = ", type(of: speed)) // Double
  
  
  // If you choose not to initialize the variable, you need to
  // specify its type.
  var mass: Double
  // You cannot access a variable that has not been initialized.
  // print("mass = ", mass) // Error variable 'mass' used before
                            // being initialized
  print("type(of: mass) = ", type(of: mass))
  
  mass = 60
  print("mass = ", mass)
  print("type(of: mass) = ", type(of: mass))
  
  // You can of course choose to both initialize the variable as well
  // as specify its type.
  var volume: Double = 50.25
  print("volume = ", volume)
  print("type(of: volume) = ", type(of: volume))
  
  volume = 55.1
  print("volume = ", volume)
  print("type(of: volume) = ", type(of: volume))
  
  // A variable declaration without either an initializer or a
  // type-annotation is an error.
  // This is because Swift is statically typed. The compiler/interperter
  // needs to know at compile time how much storage to allocate
  // for the constant on the stack.
  // var uncartainty // Error: Type annotation missing in pattern
  
  // For the same reason you cannot change the type of a variable
  // after it has been declared.
  // volume = "loud" // Error: Cannot assign value of type 'String'
  // to type 'Double'
  
  // Like, constants, you can initialize multiple variables on a single
  // line. As with constants, this is not recommended.
  var density: Double, message = "This is a message"
  
  density = mass / volume
  print("density = ", density)
  print("type(of: density) = ", type(of: density))
  
  print("message = ", message)
  print("type(of: message) = ", message)
  message = "This is another message"
  print("message = ", message)
  
  // You cannot redeclare a variable after it has already been
  // declared.
  // var density: Double  // Error: Invalid redeclaration of 'density'
  // var density = 45  // Error: Invalid redeclaration of 'density'
  
  // As with constants variables can also be unicode.
  var ε: Double = 0.004
  print("ε = ", ε)
  print("type(of: ε) = ", type(of: ε))
  ε = 0.1
  print("ε = ", ε)
}
