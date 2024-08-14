// -*- coding: utf-8 -*-
/// [comments.dart] Explore comments in Dart.
/* -------------------------------------------------------------------
 * comments.dart: Explore comments in Dart.
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
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
 -------------------------------------------------------------------*/
library;

/// Explore comments in Dart.
///
/// This is a documentation comment. It is used to document
/// methods, functions, classes etc.
/// Doc comments start with a triple-slash. This is called
/// the 'C#-style' doc comment. You can also use javadoc-style
/// doc comments. But Dart style recommends the 'C#-style'.
void explore() {
  print("Exploring comments...");
  // Single-line comments work just like C++, Java, Javascript, etc.
  int value = 4;// This is a single line comment.
  print(value);

  /*
    Multi-line comments work the same way aa C++, Java, Javascript, etc.
    Unlike in Swift, and just like in C/C++, Java and Javascript
    they DO NOT nest.
   */
  print("...finished exploring comments.");
}

