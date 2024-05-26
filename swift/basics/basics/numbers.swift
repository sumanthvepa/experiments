//-*- coding: utf-8 -*-
/**
  numbers.swift: Explore numbers in Swift
 
  This is an exploration of numbers in Swift
*/
/* -------------------------------------------------------------------
 * numbers.swift: Explore numbers in Swift.
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

// We need to import Foundation to get the IntegerFormatStyle class,
// the number.formatted method and String(format: ) method.
import Foundation

/**
 Formats any signed integer type with comma separators
 
 This is a generic method that handles Int, Int8, Int16, Int32 and Int64.
 This use Swifts new way of formatting numbers: ``IntegerFormatStyle``
 Which is a generic class for formatting integers. In this implementation, it
 takes a Int parameter.
 
 See [Apple's Developer Documentation](https://developer.apple.com/documentation/foundation/integerformatstyle)
 for how to use this.
 
 This is a utility function used by ``exploreNumbers()``
 
 - parameters
    - number: The number to be formatted.
 - returns
 A string containing the formatted number.
 */
func withCommas<T: SignedInteger>(number: T) -> String {
  // We use en_US because we want to group digits in 3s,
  // i.e. hundreds, thousands, millions, ...
  // and not 3, followed by groups of 2, hundreds, thousands,
  // lakhs, crores, ...
  // By default IntegerFormatStyle will add commas when printing.
  let style = IntegerFormatStyle<Int>(locale: Locale(identifier: "en_US"))
  return number.formatted(style)
}

/**
 Formats any signed integer type with comma separators
 
 This is a generic method that handles UInt, UInt8, UInt16, UInt32 and UInt64.
 
 This use Swifts new way of formatting numbers: ``IntegerFormatStyle``. Which
 is a generic class for formatting integers. In this implementation, it
 takes a UInt parameter.

 See [Apple's Developer Documentation](https://developer.apple.com/documentation/foundation/integerformatstyle)
 for how to use this.
 
 This is a utility function used by ``exploreNumbers()``
 
 - parameters
    - number: The number to be formatted.
 - returns
 A string containing the formatted number.
 */
func withCommas<T: UnsignedInteger>(number: T) -> String {
  // Note that for this function the template parameter is UInt.
  let style = IntegerFormatStyle<UInt>(locale: Locale(identifier: "en_US"))
  return number.formatted(style)
}

/**
 Formats a number with comma separators using old-style NumberFormatter.
 
 This is included for historical interest, and to document another way
 to format numbers, if needed. It is particuarly useful for NSNumber
 which is used for C/Objective-C compatible numbers.
 
 Note that this will fail if passed an NSNumber represeting UInt.max or UInt64.max
 due to a bug in the swift Foundation library.
 
 This function is not used by the code.
 For more details about NumberFormatter, see
 [Apple's Swift Documentation](https://developer.apple.com/documentation/foundation/numberformatter)
 
 - parameters
  - number: The number to be formatted
 - returns
 A string containing the formatted number.
 */
func oldStyleWithCommas(number: NSNumber) -> String {
  let formatter = NumberFormatter()
  formatter.locale = Locale(identifier: "en_US")
  let str = formatter.string(from: number)!
  return str
}


/**
  Format a UInt with comma separators from first principles.
 
 This function too is included for academic interest, because, it
 is better to use system provided facilities for formatting. But since
 I spent a bunch of time writing it, I figured, I might as well let it remain.
 */
func firstPrincipleswithCommas(number: UInt) -> String {
  // No need for complex calculations if the
  // number is zero.
  if number == 0 {
    return "0"
  }
  // Break up the number into groups of 3 digits
  // from the right.
  var digitGroups: [UInt] = []
  var rest = number
  while rest > 0 {
    let reminder = rest % 1000
    rest = (rest - reminder)/1000
    digitGroups.insert(reminder, at: 0)
  }
  
  var result: String = ""
  for (digitGroupNumber, digitGroup) in digitGroups.enumerated() {
    if digitGroupNumber == 0 {
      result += String(digitGroup) + ","
    } else {
      result += String(format: "%03d", digitGroup)
      if digitGroupNumber < digitGroups.count - 1 {
        result += ","
      }
    }
  }
  return result
}

/**
 Explore integers
 */
func exploreIntegers() {
  // The type Int defines a signed integer whose size matches the word
  // size of the plaform being used. For Apple Silicon that is
  // 64bits.
  let intValue = 42; // 42 is inferred to be of type Int.
  print(intValue);
  
  // You can explicity specify the type:
  let intValue2: Int = 67
  print(intValue2)
  
  // The size of an Int in bits is machine dependent. On Apple Silicon M-class
  // chips it is 64 bits.
  print("Word size of Int is: ", MemoryLayout.size(ofValue: intValue)*8)
  // The range of Int can be obtained as follows (withCommas is a utility function defined above)
  print("range of Int = [\(withCommas(number: Int.min)), \(withCommas(number: Int.max))]")
  
  // You can also print the range using the old style NSNumber. Its a little more verbose,
  // and does not work when passed UInt.max (bug in the Foundation library maybe?)
  // oldStyleWithCommas is a utility function defined above.
  print("range of Int = [\(oldStyleWithCommas(number: NSNumber(value: Int.min))), \(oldStyleWithCommas(number: NSNumber(value: Int.max)))]")
  
  // If you need to explicityl control the size of the integer
  // you can use various specialized types.
  // This is an 8-bit Integer
  let eightBitInt: Int8 = 8
  print(eightBitInt)
  print("Word size of Int8 is: ", MemoryLayout.size(ofValue: eightBitInt)*8)
  print("range of Int8 = [\(Int8.min), \(Int8.max)]")

  // Of course you cannot assign a integer larger than
  // the maximum a type can hold.
  // var tooSmallToFit: Int8 = 128 // Error: Integer literal '128' overflows when stored into Int8

  // You have 16-bit, 32-bit and 64-bit signed integers.
  let sixteenBitInt: Int16 = 16
  print(sixteenBitInt)
  print("Word size of Int16 is: ", MemoryLayout.size(ofValue: sixteenBitInt)*8)
  print("range of Int16 = [\(withCommas(number: Int16.min)), \(withCommas(number: Int16.max))]")
  
  let thirtytwoBitInt: Int32 = 32
  print(thirtytwoBitInt)
  print("Word size of Int32 is: ", MemoryLayout.size(ofValue: thirtytwoBitInt)*8)
  print("range of Int32 = [\(withCommas(number: Int32.min)), \(withCommas(number: Int32.max))]")
  
  let sixtyfourBitInt: Int64 = 64
  print(sixtyfourBitInt)
  print("Word size of Int64 is: ", MemoryLayout.size(ofValue: sixtyfourBitInt)*8)
  print("range of Int64 = [\(withCommas(number: Int64.min)), \(withCommas(number: Int64.max))]")

  // Swift also has unsigned integer counterparts of the Int: UInt
  let uintValue: UInt = 42
  print(uintValue)
  print("Word size of UInt is: ", MemoryLayout.size(ofValue: uintValue)*8)
  print("range of UInt = [\(withCommas(number: UInt.min)), \(withCommas(number: UInt.max))]")

  // And 16-bit, 32-bit and 64-bit equivalents
  let eightBitUnsignedInt: UInt8 = 42
  print(eightBitUnsignedInt)
  print("Word size of UInt8 is: ", MemoryLayout.size(ofValue: eightBitUnsignedInt)*8)
  print("range of UInt8 = [\(withCommas(number: UInt8.min)), \(withCommas(number: UInt8.max))]")

  let sixteenBitUnsignedInt: UInt16 = 42
  print(sixteenBitUnsignedInt)
  print("Word size of UInt16 is: ", MemoryLayout.size(ofValue: sixteenBitUnsignedInt)*8)
  print("range of UInt16 = [\(withCommas(number: UInt16.min)), \(withCommas(number: UInt16.max))]")

  let thirtytwoBitUnsignedInt: UInt32 = 42
  print(thirtytwoBitUnsignedInt)
  print("Word size of UInt32 is: ", MemoryLayout.size(ofValue: thirtytwoBitUnsignedInt)*8)
  print("range of UInt32 = [\(withCommas(number: UInt32.min)), \(withCommas(number: UInt32.max))]")
  
  let sixtyfourBitUnsignedInt: UInt64 = 42
  print(sixtyfourBitUnsignedInt)
  print("Word size of UInt64 is: ", MemoryLayout.size(ofValue: sixtyfourBitUnsignedInt)*8)
  print("range of UInt64 = [\(withCommas(number: UInt64.min)), \(withCommas(number: UInt64.max))]")
  
  // You can specify a number in binary as follows:
  let binary = 0b101010 // 0B101010 is also okay.
  print(binary)
  // To print it as binary use the following:
  print("binary = ", String(binary, radix: 2))
  
  // You can specify a number in octal as follows
  let octal = 0o52
  print(octal)
  // To print it as an octal number:
  print("octal = ", String(octal, radix: 8))
  
  // And of course in hex:
  let hexadecimal = 0x2a
  print(hexadecimal)
  print("hexadecimal = ", String(hexadecimal, radix: 16))
  
  // You can uses underscores to make integer literals more readable:
  let readableInt = 1_234_956_327
  print("readableInt = ", withCommas(number: readableInt))
}

func exploreFloatingPointNumbers() {
  // Swift supports floating point numbers in a fairly usual way.
  // Double precision numbers are 64bits in size.
  let doubleNumber: Double = 23.72
  print(doubleNumber)
  print("Word size of Double is: \(MemoryLayout.size(ofValue: doubleNumber)*8) bits")
  
  // If the type of a floating point number is not specified, then it defaults
  // to double precision.
  let doubleNumber2 = 42.42
  print(doubleNumber2)
  print("Word size of doubleNumber2 is: \(MemoryLayout.size(ofValue: doubleNumber2)*8) bits")
  
  // Single precision floating point numbers are 32bits in size.
  // Single precision numbers must be explicityl specifed as being
  // single precision with the Float type annotation.
  let floatNumber: Float = 50.34
  print("type(of: floatNumber) = \(type(of: floatNumber))")
  print("floatNumber = \(floatNumber)")
  print("Word size of floatNumber is: \(MemoryLayout.size(ofValue: floatNumber)*8) bits")
}
