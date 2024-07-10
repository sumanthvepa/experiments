//-*- coding: utf-8 -*-
/**
  opaque-collections.swift: Explore opaque collections
*/
/* -------------------------------------------------------------------
 * opaque-collections.swift: Explore opaque collections
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


// The code below shows how one coult use opaque types to
// return concrete type of a generic protocol. But as of
// Swift 5.10, the compiler actually crashes on this code.
// So don't do it. Instead either don't implement a generic
// protocol or don't nest the implementation of the generic
// protocol within a function.

// This is correct code that crashes the compiler:
/*
protocol MyCollection {
  associatedtype Element
  var elements: [Element] {get set} 

  mutating func append(element: Element)
}

func createRepeatingElements(element: Int, times: Int) -> some MyCollection {
  struct MyList: MyCollection {
    typealias Element = Int
    var elements: [Element] = []

    mutating func append(element: Element) {
      self.elements.append(element)
    }
  }

  var mylist = MyList()
  for _ in 0..<times {
    mylist.append(element: element)
  }
  return mylist
}

func exploreOpaqueCollections() {
  let mylist = createRepeatingElements(element: 5, times: 3)
  print(mylist.elements.count)
}
*/

// This is a work around that does not crash the compiler.
// MyList has been moved out of the function. It is no longer
// nested.
protocol MyCollection {
  associatedtype Element
  var elements: [Element] {get set}

  mutating func append(element: Element)
}

struct MyList: MyCollection {
  typealias Element = Int
  var elements: [Element] = []

  mutating func append(element: Element) {
    self.elements.append(element)
  }
}

func createRepeatingElements(element: Int, times: Int) -> some MyCollection {
  var mylist = MyList()
  for _ in 0..<times {
    mylist.append(element: element)
  }
  return mylist
}


func exploreOpaqueCollectionsWorkaround1() {
  let mylist = createRepeatingElements(element: 5, times: 3)
  print(mylist.elements.count)
}


// Avoid the use of nested implementations altogether
// they cause the compiler to crash. Using non-generics
// fails as well.
/*
protocol MyCollection2 {
  var elements: [Int] {get set}

  mutating func append(element: Int)
}


func createRepeatingElements2(element: Int, times: Int) -> some MyCollection2 {
  struct MyList2: MyCollection2 {
    var elements: [Int] = []

    mutating func append(element: Int) {
      self.elements.append(element)
    }
  }

  var mylist = MyList2()
  for _ in 0..<times {
    mylist.append(element: element)
  }
  return mylist
}

func exploreOpaqueCollectionsWorkaround2() {
  let mylist = createRepeatingElements2(element: 5, times: 3)
  print(mylist.elements.count)
}
*/
