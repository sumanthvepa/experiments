//-*- coding: utf-8 -*-
/**
  operators.swift: Explore operators in swift
*/
/* -------------------------------------------------------------------
 * commonts.swift: Explore comments in Swift
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
  Explore operators in Swift
*/
func exploreOperators() {
  // Arithmetic operators
  let a = 10
  let b = 20
  print("a + b = \(a + b)")
  print("a - b = \(a - b)")
  print("a * b = \(a * b)")
  print("a / b = \(a / b)")
  print("a % b = \(a % b)")
  
  // Compound assignment operators
  var h = 10
  h += 5 // 15
  print("h \(h)")
  h -= 5 // 10
  print("h \(h)")
  h *= 5 // 50
  print("h \(h)")
  h /= 5 // 10
  print("h \(h)")
  h %= 5 // 0
  print("h \(h)")
  
  // Comparision operators
  let i = 10
  let j = 20
  let k = i == j // false
  print("i == j is \(k)")
  let l = i != j // true
  print("i != j is \(l)")
  
  // Logical operators
  let m = true
  let n = false
  let o = m && n // false
  print("m && n is \(o)")
  let p = m || n // true
  print("m || n is \(p)")
  let q = !m // false
  print("!m is \(q)")
  
  // Range operators
  // Closed range operator includes all items from 1 to 5
  // Inclusive of 5. This corresponds to the mathematical
  // notation [1, 5]
  for r in 1...5 {
    print("r = \(r)")
  }
  
  // Half open range operator includes all items from 1 to 4
  // Excludes 5. This corresponds to the mathematical
  // notation [1, 5)
  for s in 1..<5 {
    print("s = \(s)")
  }
  
  // In general the range operators will work for any type that
  // implements the Strideable protocol.
  
  // You can do this...
  let letter_a: Character = "a"
  let letter_z: Character = "z"
  let alphabet = letter_a...letter_z
  
  // ... but it is not useful as you cannot iterate over
  // it as you would with integers.
  // This won't work:
  // for c in alphabet {
  //   print(c)
  // }
  
  // It won't work even if use strings...
  print("type(of: alphabet is \(type(of: alphabet))")
  let alphabet2 = "a"..."z"
  print("type(of: alphabet2 is \(type(of: alphabet2))")
  // ...nope. Not this either:
  // for c in alphabe2 {
  //   print(c)
  // }
  
  
  // Asked ChatGPT how to iterate over alphabet, alphabet2 and I got the
  // following answer:
  
  // Iterating over a `ClosedRange<Character> is not as straightforward
  // as iterating over ranges of integers, because the `Character` and
  // String types in Swift do not conform to the `Strideable` protocol,
  // which is necessary for iteration. However, you can achieve this by
  // converting the characters to their Unicode scalar values and then
  // iterating over those scalar values.
  
  // This approach works because Unicode scalar values for lowercase
  // English letters are contiguous, meaning the values for 'a' to
  // 'z' form an unbroken sequence of integers.

  // Here's how to do it:
  
  // Iterating Over a ClosedRange<Character>
  // 1. **Extract Unicode Scalar Values**: Get the Unicode scalar
  //    values of the start and end characters. This is done using the
  //    `unicodeScalars` property of the `Character` type.
  //    A unicode scalar is the code point of a character. Note that
  //    unicodeScalars returns a collection of Unicode scalars
  //    We can break down the process of getting start as follows:
  //    for the given character. (There can be more than one code point
  //    for a given character.) So we take the first member of that
  //    collection, then get its value (an integer)
  //    We do this for both the starting and ending characters.
  // 2. **Iterate Over Scalar Values**: Use a `for` loop to iterate
  //    over the range of scalar values.
  // 3. **Convert Scalars Back to Characters**: Convert each Unicode
  //    scalar back to a `Character` and print or use it. Take
  //    the scalarValue integer and convert it into a UnicodeScalar,
  //    then convert it into a Character. Finally, print the character.

  
  // The code below does this in a step by step fashion:
  
  // First get a collection of all unicode scalars that could
  // represent this character.
  let a_unicodeScalars = letter_a.unicodeScalars
  print("type(of: a_unicodeScalars) = \(type(of: a_unicodeScalars))") // UnicodeScalarView
  let z_unicodeScalars = letter_z.unicodeScalars
  print("type(of: z_unicodeScalars) = \(type(of: z_unicodeScalars))") // UnicodeScalarView
  
  // Since this characters in this range are all ASCII, they are guarenteed to
  // have only one unicode scalar associated with them. That can be accessed via
  // the first property. Since in general a collection could be empty first is an optioanl.
  let a_optionalScalar = a_unicodeScalars.first
  print("type(of: a_optionalScalar) = \(type(of: a_optionalScalar))") // Optional<Scalar>
  let z_optionalScalar = z_unicodeScalars.first
  print("type(of: z_optionalScalar) = \(type(of: z_optionalScalar))") // Optional<Scalar>
  
  // Get the value of the unicode scaler (keeping in mind that it is an optional)
  let a_start_optional = a_optionalScalar?.value
  print("type(of: a_start_optional) = \(type(of: a_start_optional))") // Optional<Uint32>
  let z_end_optional = z_optionalScalar?.value
  print("type(of: z_end_optional) = \(type(of: z_end_optional))") // Optional<Uint32>
  
  // Now get rid of the optional
  if let start = a_start_optional,
  let end = z_end_optional {
    print("type(of: start) = \(type(of: start))") // Uint32
    print("type(of: end) = \(type(of: end))") // Uint32
    
    // Now iterate over the integer range.
    for number in start...end {
      print("type(of: number) = \(type(of: number))") // Uint32
      
      // To go back to a character, create the UnicodeScalar
      // Constructor below creates optional scalars, because not
      // all numbers have a unicode scalar associated with them.
      let optionalScalar = UnicodeScalar(number)
      print("type(of: optionalScalar) = \(type(of: optionalScalar))") // Optional<UnicodeScalar>
      
      // Get rid of the optional
      if let scalar = optionalScalar {
        print("type(of: scalar) = \(type(of: scalar))") // UnicodeScalar
        
        // Create the character corresponding to the given unicode scalar.
        let character = Character(scalar)
        
        // Print it along with its type information.
        print("character = \(character), type(of: character) = \(type(of: character))")
      }
    }
  }
  
  // Here's the code in a more succint form:
  if let start = letter_a.unicodeScalars.first?.value,
     let end = letter_z.unicodeScalars.first?.value {
    for scalarValue in start...end {
      if let scalar = UnicodeScalar(scalarValue) {
        let character = Character(scalar)
        print(character)
      }
    }
  }
  
  // To iterate over a `ClosedRange<String>` in Swift, you need to
  // follow a similar approach to iterating over a
  // `ClosedRange<Character>`, by leveraging the Unicode scalar values
  // of the characters. Here the procedure for doing it:
  
  // Explanation
  // 1. **Extract Unicode Scalar Value**: Take range 'alphabet2'
  //    and get its lower and upperboud.
  // 2. **Iterate Over Scalar Values**: Use a `for` loop to iterate
  //    over the range of scalar values.
  // 3. **Convert Scalars Back to Strings**: Convert each Unicode
  //    scalar back to a `String` and print or use it.
  
  // Once you get start and end, the code is the same as above.
  
  // But to get start you have to do a two things, first, you need
  // to get the lower and upper bounds of the range alphabet2.
  let lower = alphabet2.lowerBound
  print("type(of: lower) = \(type(of: lower))")
  let upper = alphabet2.upperBound
  print("type(of: upper) = \(type(of: upper))")
  
  // Then you have to get the first character in the string representing
  // the lower and upper bounds. Even though we know there is only
  // one character, the String might in general be empty or longer than
  // one. We use first to get an Optional<Character>, then use if let
  // to remove the optional.
  let optionalStartCharacter = lower.first
  print("type(of: optionalStartCharacter) = \(type(of: optionalStartCharacter))")
  let optionalEndCharacter = upper.first
  print("type(of: optionalEndCharacter) = \(type(of: optionalEndCharacter))")
  if let startCharacter = optionalStartCharacter, let endCharacter = optionalEndCharacter {
    print("type(of: startCharacter) = \(type(of: startCharacter))")
    print("type(of: endCharacter) = \(type(of: endCharacter))")
  }
  
  // Now that you have a character you can do the same thing as you did with ClosedRange<Character>
  
  // Below is a fully streamlined version of the code:
  if let start = alphabet2.lowerBound.first?.unicodeScalars.first?.value,
     let end = alphabet2.upperBound.first?.unicodeScalars.first?.value {
    for scalarValue in start...end {
      if let scalar = UnicodeScalar(scalarValue) {
        let character = String(scalar)
        print(character)
      }
    }
  }
  
  // There are no range operators that exclude the lower
  // bound (1, 5], or completely
  // open on both sides (1, 5) unlike in mathematics.
  // See this Stack Overflow post for how to achieve this
  // https://stackoverflow.com/questions/41437839/swift-range-greater-than-lower-bound
  
  // The nil coalescing operator has been described in optionals.swift
}
  
