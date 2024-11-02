//-*- coding: utf-8 -*-
/**
  attributes.swift: Explore attributes in Swift
*/
/* -------------------------------------------------------------------
 * attributes.swift: Explore attributes in Swift
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

// Attributes are used to provide additional information about a
// declaration or type. An attribute is specified by prefixing
// the name of an attribute with an @ sign.

// For example, the @discardableResult attribute can be used to
// suppress the warning when the result of a function is not used.
@discardableResult
func addDiscarable(a: Int, b: Int) -> Int {
    return a + b
}

func addNonDiscarable(a: Int, b: Int) -> Int {
    return a + b
}

func exploreAttributes() {
    // The following line will not generate a warning
    addDiscarable(a: 1, b: 2)
    // The following line will generate a warning:
    // Result of call to 'addNonDiscarable(a:b:) is unused.
    addNonDiscarable(a: 1, b: 2)
}



