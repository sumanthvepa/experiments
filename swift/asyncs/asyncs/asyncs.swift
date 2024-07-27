// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * main.swift: Explore asynchronous programming in Swift
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

// There are only three places where a program can call asynchronous
// functions:
// 1. Code in the body of an asynchronous function, method or property
// 2. Code in the static main() method of a structure, class or
//    enumeration that's marked with @main.
// 3. Code in an unstructured child task.

// Method 1 is not useful as an entry point into asynchronous code.
// Method 2 is used in this project. See below
// Method 3 was demonstrated in the basics code.

// This is the entry point into the asyncs project.
// Unlike basics, the main file has been rename 'asyncs' to
// allow the code to have @main attribute. (The @main attribute
// cannot be present in a file named main. Don't know why.)

// When defined this way. Asyncs.main will not exit until
// all the tasks/async functions it has called also exit.

// Notice that every function call that leads to an async
// function must also be within an async function
@main struct Asyncs {
  static func main() async {
    await exploreConcurrencyBasics()
  }
}
