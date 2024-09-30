// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * insertion.swift: Insertion sort implemented as an exetension on
 * an Array.
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

extension Array where Element: Comparable {
  mutating func insertionSort() {
    self.insertionSort(by: <)
  }
  
  mutating func insertionSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
    for i in 1..<count {
      var j = i
      while j > 0 && areInIncreasingOrder(self[j], self[j-1]) {
        self.swapAt(j, j-1)
        j -= 1
      }
    }
  }
  
  func insertionSorted() ->[Self.Element] {
    var copy = self
    copy.insertionSort()
    return copy
  }
  
  func insertionSorted(by areInIncreasingOrder: (Element, Element) -> Bool) ->[Self.Element] {
    var copy = self
    copy.insertionSort(by: areInIncreasingOrder)
    return copy
  }
}
