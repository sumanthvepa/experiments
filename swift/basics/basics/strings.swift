//-*- coding: utf-8 -*-
/**
  strings.swift: Explore strings in Swift
 
  This is an exploration of stringsin Swift
*/
/* -------------------------------------------------------------------
 * strings.swift: Explore strings in Swift.
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
   This function explore strings.
 */
func exploreStrings() {
  // String in Swift are Unicode compliant and enclosed within double
  // quotes. The type annnotation is String.
  let str = "Hello, World!"
  print(str)
  print(type(of : str))

  // If the the type is not declared, Swift will infer the type as String.
  let str2 = "Hello, World!"
  print(str2)
  print(type(of: str2))

  // Strings literal can be multiline. These are enclosed within triple
  // double quotes.
  let str3 = """
  This is a multiline string.
  It can span multiple lines.
  """
  print(str3)

  // As usual, you can escape characters in strings using the backslash.
  let str4 = "This is a string with a \"quote\" and a newline\n."
  print(str4)

  // You can include unicode characters in strings either directly,
  // or by using the unicode escape sequence.
  let str5 = "This is a string with a directly entered unicode character: 🐶"
  print(str5)

  let str6: String = "This is a string with a unicode escape sequence: \u{03c0}"
  print(str6)

  // You can also use the # to create a raw string literal. This will
  // ignore the escape characters.
  let str7 = #"This is a raw string with a "quote", but the newline escape is not recognized \n."#
  print(str7)

  // The empty string is represented by an empty pair of double quotes.
  let str8 = ""
  print(str8)
  // or alternatively by using the String type.
  let str9 = String()
  print(str9)

  // You can check if a string is empty using the isEmpty property.
  if str8.isEmpty {
    print("The string is empty.")
  } else {
    print("The string is not empty.")
  }

  // Unlike C++ where a const char * repesents an immutable pointer
  // to a string, the contents of the string itself being mutable,
  // in Swift, the mutability of a string is determined
  // by the variable declaration.
  var str10 = "Hello, World!" // mutable
  let str11 = "Hello, World!" // immutable
  str10 += " How are you?" // This is allowed
  print(str10)
  // str11 += " How are you?" // This is not allowed
  print(str11)
  
  // Unlike languages like Java and C++, strings in Swift are value types.
  // This means that when you assign a string to another variable, a
  // copy of the string is created.
  var str12 = "Hello, World!"
  let str13 = str12
  str12 += " How are you?"
  print(str12) // Hello, World! How are you?
  print(str13) // Hello, World!
}
