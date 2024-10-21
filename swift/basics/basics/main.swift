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
 that are referenced from main.swift either as comments or through
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
  12. exceptions.swift: Using xceptions
  13. assertions-and-preconditions.swift: Using assertions and preconditions
  14. operators.swift: Using operators in Swift
  15. control-flow.swift: Control flow structures in Swift
  16. functions.swift: Using functions in Swift
  17. enumerations.swift: Using enumerations in Swift
  18. classes-and-structures.swift: Explore classes and structures


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

// Note on Xcode's Swift Language Version Build setting
// By default this setting in Project Settings > Build Setings >
// [Search for Swift Language Version] is set to unspecified. It is
// recommended that when building the project the language version be
// chaged to the latest version of Swift. This will flag any
// incompatibilities in code. For exsisting project, one should bump
// up the language version when building with a newer verison of
// Swift. Any problems identified should be fixed.
// See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/compatibility/
// and: https://forums.developer.apple.com/forums/thread/128965
// and:
// https://stackoverflow.com/questions/52867411/xcode-swift-language-version-different-between-unspecified-and-version
// and: https://stackoverflow.com/questions/30790188/how-do-i-see-which-version-of-swift-im-using



// The current version Swift is 6.0
// See this link for notes on what is new in 6.0
// https://www.hackingwithswift.com/articles/269/whats-new-in-swift-6


// Note on statements in Swift.
// Statements in swift are terminated with a newline token
// A semicolon can also be used, but is not necessary.

// A Note on Swift Programming Style
// I follow Google's Style Guide for Swift
// https://google.github.io/swift/


// Note:1 comments.swift: Comments in Swift.
documentedWithDocComment()
documentedWithTripleSlashComment()

// Note2: shebang.swift: Using Swift as a scripting language.
// This file is a separate project outside of this Xcode project.
// It explores the use of Swift as a scripting language.

// Note 3: print.swift: Basic printing to console in Swift.
printSomething()

// Note 4: constants.swift: Explore Constants
exploreConstants()

// Note 5: variables.swift: Explore Variables.
exploreVariables()

// Note 6: numbers.swift: Explore numbers
exploreIntegers()
exploreFloatingPointNumbers()

// Note 7: strings.swift: Explore strings
exploreStrings()

// Note 8: booleans.swift: Explore booleans
exploreBooleans()

// Note 9: typealiases.swift: Explore typealiases
exploreTypeAliases()

// Note 10: optionals.swift: Explore optionals
exploreOptionals()

// Note 11: tuples.swift: Explore tuples
exploreTuples()

// Note 12: exceptions.swift: Explore exceptions
exploreExceptions()

// Note 13: assertions-and-preconditions.swift: Explore assertions
// and preconditions
exploreAssertionsAndPreConditions()

// Note 14: operators.swift: Explore operators in Swift
exploreOperators()

// Note 15: control-flow.swift: Explore control flow in Swift
exploreControlFlow()

// Note 16: fnctions.swift: Explore functions
exploreFunctions()

// Note 17: enumerations.swift: Explore enumerations
exploreEnumerations()

// Note 18: classes-and-structures.swift: Explore classes and structures
exploreClassesAndStructures()
exploreInheritance()
exploreAdvancedClassConcepts()
exploreExtensions()

// Note 19: protocols.swift: Explore protocols
exploreProtocols()
exploreConditionalProtocolConformance()
exploreAssociatedTypes()
exploreOpaqueTypes()
exploreBoxedTypes()

// Note 20: opaque-collections.swift:
// Explore the complex interactions involved in returning opaque collections
exploreOpaqueCollectionsWorkaround1()

// Note 21: Explore Generics
exploreGenerics()

// Note 22: Explore Concurrency
// Please note that this exploration of concurrency in this project
// is necessarily limited. This is because, in Swift, the entire
// project must be asynchronous to use concurrency. But the basics
// project is not asynchronous.
// A complete exploration of concurrency can be found in the
// asyncs project.
// To learn about concurrency in Swift, start here, and then
// move on to the asyncs project.
exploreEventLoops()
exploreConcurrency()
callingAsyncCodeFromSyncCodeHack1()
callingAsyncCodeFromSyncCodeHack2()

// TODO: Explore arrays
