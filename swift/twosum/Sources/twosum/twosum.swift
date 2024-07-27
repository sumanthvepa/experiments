// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * twosum.swift: A solution to the twosum leetcode problem
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

// This is an implementation of the twosum leecode problem.
// A description of the problem can be found under /algorithms/leetcode/two-sum

// The primary purpose of this project though is two fold:
// 1. Demonstrate the creation of a Swift package.
// 2. Demonstrate the use of the XCTest framework for unit testing.

// These instructions for creating a package in XCode are for
// XCode 15.4 and later (so far.) Xcode has a tendency to
// move things around every few releases, and this information
// might be out of date when viewed for subsequent releases.

// To create a Swift package in Xcode, go to File -> New -> Package...
// then choose Multiplatform and then Library. You cannot create
// MacOS only package in Xcode directly. (You'll have to constrain
// the platform in Package.swift once the package project is created.)
// See the notes in Package.swift


// You need to declare every type you want to be accessible outside
// the package to be public. This is because, everything by
// default has internal access. See the basics project
// for info on on access levels.

public enum TwoSumError: Error {
  case NoSolution
}

public func twoSum(numbers: [Int], sum: Int) throws -> (first: Int, second: Int) {
  for firstIndex in 0..<numbers.count {
    let firstValue = numbers[firstIndex]
    for secondIndex in firstIndex+1..<numbers.count {
      let secondValue = numbers[secondIndex]
      if firstValue + secondValue == sum {
        return (first: firstIndex, second: secondIndex)
      }
    }
  }
  throw TwoSumError.NoSolution
}
