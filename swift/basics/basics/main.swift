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
/**
main.swift: Explore the Swift Programming Language.

 This file is the top-level driver codefor a serises of exploratory
 notes and tutorials on the Swift programming language. 
 
 These notes are written as a series of heavily commented Swift files,
 that are referenced from man.swift either as comments or through
 actual function/method calls. This effectively specifes the order in
 which various files in this project should be read. The order of the
 files is as follows:
  0. main.swift: This file describes how to get setup and use Xcode
   for Swift development.
  1. comments.swift: Describes the types of comments in swift
  2. shebang.swift: This is a file separate project outside of xcode
    exploring the use of swift as a scripting language.
  3. print.swift: Printing to the console
  4. constants.swift: Using constants in Swift
  5. variables.swift: Using variables in Swift
  6. numbers.swift: Using numbers in Swift
  7. strings.swift: Using strings in Swift
  8. booleans.swift: Using booleans in Swift
  9. typealiases.swift: Using typealiases in Swift
  10. optionals.swift: Using optionals in Swift
  11. tuples.swift: Using tuples in Swift

 For more information on the Swift Programming language, see the
 following references:
 1. [The Swift Documentation Websie](https://swift.org/)
 2. [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
 2. [The Swift Programming Language Reference](https://www.swift.org/documentation/tspl/)
*/


// A note on Xcode build error: LoggingError: Failed to initialize
// logging system. Log messages may be missing. This seems to be weird
// error that started popping up with Xcode. The solution, as described
// in [this Stackoverflow post](https://stackoverflow.com/questions/78129981/logging-error-failed-to-initialize-logging-system-log-messages-may-be-missing)
// seems to be to set the environment variable IDEPreferLogStreaming
// First select the scheme: ![Show how to select scheme in Xcode](select-scheme.png "Select Scheme")
// Then chose to Edit scheme and set the environment variable
// IDEPreferLogStreaming to YES : ![SetIDEPreferLogStreaming to YES](set-idepreferlogstreaming.png "Set IDEPreferLogStreaming)
// No idea why that works.

// A note on the filename main.swift
// XCode requires that the entry point into
// a swift program be in a file named main.swift.

// Outside of Xcode, this is not required, you
// can either run the file as in interpreted mode
// swift ./filename
// Or if it has a #!
// ./filename
// You can compile a single line program using make.
// see the shebang project which is located at the
// same level as basics for more details.

// A note on the #! line.
// Swift uses C/C++ style comments, so # is not the
// start of a comment. So swift compromises and allows
// for the first line in the main file of a program
// have a #! line.

// For a Swift Xcode project, this means that only,
// the main.swift file can have the #! line.

// Note on statements in Swift.
// Statements in swift are terminated with a newline token
// A semicolon can also be used, but is not necessary.

// A Note on Swift Programming Style
// I follow Google's Style Guide for Swift
// https://google.github.io/swift/


// Note:1 comments.swift: Comments in Swift.
documentedWithDocComment()
documentedWithTripleSlashComment()

// Note 2: print.swift: Basic printing to console in Swift.
printSomething()

// Note 3: contants.swift: Explore Constants
exploreConstants()

// Note 4: variables.swift: Explore Variables.
exploreVariables()

// Note 5: numbers.swift: Explore numbers
exploreIntegers()
exploreFloatingPointNumbers()

// Note 6: strings.swift: Explore strings
exploreStrings()

// Note 7: booleans.swift: Explore booleans
exploreBooleans()

// Note 8: typealiases.swift: Explore typealiases
exploreTypeAliases()

// Note 9: optionals.swift: Explore optionals
exploreOptionals()

// Note 10: tuples.swift: Explore tuples
exploreTuples()

// Note 11: Explore exceptions
exploreExceptions()

// Note 12: Explore assertions and preconditions
exploreAssertionsAndPreConditions()

// Note 13: Explore operators in Swift
exploreOperators()

// Note 14: Explore control flow in Swift
exploreControlFlow()

// Note 15: Explore functions
exploreFunctions()
