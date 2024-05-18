//-*- coding: utf-8 -*-
/**
  typealiases.swift: Explore type aliases in Swift
 
  This is an exploration of typealiases in Swift
*/
/* -------------------------------------------------------------------
 * typealiases.swift: Explore type aliases in Swift.
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

func exploreTypeAliases() {
  // A type alias is an alternative name for an existing type.
  // It is defined with the typealias keyword:
  typealias AudioVolume = UInt8
  
  // All the properties and functions on UInt8 will work.
  print("range of AudioVolume = [\(AudioVolume.min), \(AudioVolume.max)]")
}
