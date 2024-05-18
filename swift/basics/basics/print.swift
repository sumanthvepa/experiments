//-*- coding: utf-8 -*-
/**
  print.swift: Explore basic printing to the console in Swift.
 
  This is an exploration of printing to console in swift.
*/
/* -------------------------------------------------------------------
 * print.swift: Explore basic printing to the console in Swift.
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
 This prints the name of this file to the console. It is intended
 to be a demonstration of how to use the builtin print function.
 */
func printSomething() {
  // Use the print function to generate output.
  // You can print like this. This prints the
  // passed string on a separate line by default.
  print("print.swift")
  
  // If you don't want the terminal newline use the following. This
  // explitly specifies the terminator parameter.
  print("This string is not terminated with a new line. ", terminator: "")
  print(); // This adds the final newline.
  
  // You can pass multiple items to print. By default, the items in
  // the list are printed with an intervening space as a separator.
  print("first", 1, 1.0, "second", 2.0, 2)
  
  // To change the separator used, specify the separator parameter
  // The items will be printed with a comma and space separating them.
  print("third", 3, 3.0, "fourth", 4.0, 4, separator: ", ")
  
  // If you want to specify a separator and a terminator use both parameters.
  // The items in the line below are separated by a comma with a space after
  // it and terminated by a period and a newline.
  print("fifth", 5, 5.0, "V", separator: ", ", terminator: ".\n")
  // The general signature for print is
  // print(
  //   _ items: Any...,
  //   separator: String = " ",
  //   terminator: String = "\n"
  // )
  // See, Apples developer documentation for details.
  // https://developer.apple.com/documentation/swift/print(_:separator:terminator:)
}

// There is surprisingly no simple way to print to standard error in Swift.
// Clearly Apple has no interest allowing programmers to use the command line
// easily.
// See this StackOverflow link on solutions for printing to stderr.
// https://stackoverflow.com/questions/24041554/how-can-i-output-to-stderr-with-swift
