//-*- coding: utf-8 -*-
/**
  strings.swift: Explore strings in Swift
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
   Explore strings.
 */
func exploreStrings() {
  // Strings in Swift are Unicode compliant and enclosed within double
  // quotes. The type annnotation is String.
  // Note that when viewed in VSCode, the IDE automatically adds the
  // inferred type to the right of the variable declaration in gray.
  // This text is not really present in the actual code.
  let str = "Hello, World!"
  print(str)
  print(type(of : str))

  // If the the type is not declared, Swift will infer the type as
  // String. (See note about VSCode above.)
  let str2 = "Hello, World!"
  print(str2)
  print(type(of: str2))

  // String literals can be multiline. These are enclosed within triple
  // double quotes. (See note about VSCode above)
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

  // You can get the number of characters in a string using the count
  // property.
  let str14 = "This is a string with a directly entered unicode character: 🐶"
  print(str14.count) // 61

  // This count may differ from the number of bytes in the string.
  print(str14.utf8.count) // 64
  
  // You can compare strings the obvious way using the == operator:
  let str15a = "This is str15"
  let str15b = "This is str15"
  if str15a == str15b {
    print("str15a == str15b")
  } else {
    print("str15a != str15b")
  }
  
  // You can do more compicated comparisons using the
  // compare method of the string class
  let str15c = "THIS IS STR15"
  let compareResult = str15a.compare(str15c, options: .caseInsensitive)
  print("type(of: compareResult) = \(type(of: compareResult))")
  if compareResult == .orderedSame {
    print("str15a is the same as str15c")
  } else {
    print("str15a is NOT the same as str15c")
  }
  
  // Do not make the mistake of converting case and then comparing
  // strings. This works for strings containing English ASCII characters
  // but not for other unicode code point.
  // For example the German work for street is spelled:
  // straße in lower case and as STRAẞE or STRASSE in uppercase.
  // All three will be equal under a case insensitive compare.
  // https://sarunw.com/posts/different-ways-to-compare-string-in-swift/
  // has a good discussion on how to use string compare.
  
  let german_street_lowercase = "straße"
  let german_street_uppercase1 = "STRAẞE"
  let german_street_uppercase2 = "STRASSE"
  if german_street_lowercase.compare(
    german_street_uppercase1, options: .caseInsensitive)
      == .orderedSame {
    print("\(german_street_lowercase) is the same as \(german_street_uppercase1)")
  } else {
    print("\(german_street_lowercase) is NOT the same as \(german_street_uppercase1)")
    
  }
  if german_street_lowercase.compare(
    german_street_uppercase2, options: .caseInsensitive)
      == .orderedSame {
    print("\(german_street_lowercase) is the same as \(german_street_uppercase2)")
  } else {
    print("\(german_street_lowercase) is NOT the same as \(german_street_uppercase2)")
  }
  if german_street_uppercase1.compare(
    german_street_uppercase2, options: .caseInsensitive)
      == .orderedSame {
    print("\(german_street_uppercase1) is the same as \(german_street_uppercase2)")
  } else {
    print("\(german_street_uppercase1) is NOT the same as \(german_street_uppercase2)")
  }
  
  // Compare also allows you to ignore things like diacritics etc.
  let e = "e"
  let eAcute =  "é"
  let eAcuteCapital = "É"
  if e.compare(eAcute, options: .diacriticInsensitive) == .orderedSame {
    print("\(e) is the same as \(eAcute)")
  } else {
    print("\(e) is NOT the same as \(eAcute)")
  }
  if e.compare(eAcuteCapital, options: .diacriticInsensitive) == .orderedSame {
    print("\(e) is the same as \(eAcuteCapital)")
  } else {
    print("\(e) is NOT the same as \(eAcuteCapital)")
  }
  
  // You can combine options by passing a list. Now e and É will be considered
  // the same.
  if e.compare(eAcuteCapital, options: [.diacriticInsensitive ,.caseInsensitive]) == .orderedSame {
    print("\(e) is the same as \(eAcuteCapital)")
  } else {
    print("\(e) is NOT the same as \(eAcuteCapital)")
  }
  
  
  // In general prefer using String.compare when comparing text that might be found
  // in problem domain (for example names, addresses etc.), but use == when comparing
  // strings that are artifacts of
  // computer systems (example GUIDs function names etc.)
}
