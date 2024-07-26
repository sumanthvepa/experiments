// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * two-sum-cli: A command line program that uses the twosum package
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
// The primary purpose of this code is to demonstrate how to create
// a command line application that uses a custom swift package.

// The way to add a package as a dependency in Xcode 15.x is
// 1. Go to File -> Add Package Dependencies
// 2. Then click the "Add Local" button
// 3. Navigate the file system to the location of the package.
//    This is normally the directory containing the Xcode
//    package project.
// 4. Add the directory.

// You could add a github respository. But I prefer
// the local technique. My preference for swift, is
// that custom packages will always be chkecd out into
// the same absolute location on disk. This works
// because, all these packages will be used in
// Xcode on a Mac.

// For information on how to create Swift package, see
// /swift/twosum in this repository.

import twosum

do {
  let numbers = [3, 4, 5, 1]
  let result = try twoSum(numbers: numbers, sum: 9)
  print("first\(result.first) = \(numbers[result.first]), second\(result.second) = \(numbers[result.second])")
} catch {
  print(error)
}
