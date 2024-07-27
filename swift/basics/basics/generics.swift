//-*- coding: utf-8 -*-
/**
  generics.swift: Explore generics
*/
/* -------------------------------------------------------------------
 * generics.swift: Explore generics
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

func exploreGenerics() {
  // Generics are a way of making reusable components in Swift.
  // They allow you to write flexible, reusable functions and
  // types that can work with any type, subject to certain
  // constraints that you define.

  // Here is a simple example of a generic function that
  // swaps two values of any type.
  func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
  }

  // You can call this function with any type.
  var a = 3
  var b = 4
  swapTwoValues(&a, &b)
  print("a: \(a), b: \(b)")

  var str1 = "Hello"
  var str2 = "World"
  swapTwoValues(&str1, &str2)
  print("str1: \(str1), str2: \(str2)")

  // You can also define generic types. Here is an example of a
  // generic stack.
  struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) {
      items.append(item)
    }
    mutating func pop() -> Element {
      return items.removeLast()
    }
  }

  var stack = Stack<Int>()
  stack.push(1)
  stack.push(2)
  stack.push(3)
  print(stack.pop())
  print(stack.pop())
  print(stack.pop())
}