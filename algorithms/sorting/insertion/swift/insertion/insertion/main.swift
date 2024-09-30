#!/usr/bin/swift
// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * main.swift: Explore the Swift programming language
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
import Foundation

func demonstrateInsertionSort() {
  // The sort function is documented at:
  // https://developer.apple.com/documentation/swift/array/sort()
  var students: [String] = ["Darcy", "Elad", "Firdous", "Amy", "Bala", "Che"]
  
  print("unsorted: \(students)")
  students.insertionSort()
  print("ascending: \(students)")
  
  // You can specify an ordering function
  // This version of sort is documented at:
  // https://developer.apple.com/documentation/swift/array/sort(by:)
  students.insertionSort(by: >)
  print("descending: \(students)")
  
  // Scramble the array again.
  students = ["Darcy", "Elad", "Firdous", "Amy", "Bala", "Che"]
  
  // You can also use a non-mutating function
  // The sorted function is documented at:
  // https://developer.apple.com/documentation/swift/array/sorted()
  let studentsAscending: [String] = students.insertionSorted()
  print("ascending: \(studentsAscending)")
  
  // You can pass an ordering function
  // This is documented at:
  // https://developer.apple.com/documentation/swift/array/sorted(by:)
  let studentsDescending: [String] = students.insertionSorted(by: >)
  print("descending: \(studentsDescending)")
  
  // Note that students is still unsorted
  print("unsoorted: \(students)")
}

demonstrateInsertionSort()

