/* -*- coding: utf-8 -*- */
/**
 * language.cc: A series of notes on the C++ programming language,
 * written as a collection of C++ functions in separate files.
 * This file contains the main function which calls all the other
 * functions.
 */
/* -------------------------------------------------------------------
 * language.cc: A series of notes on the C++ programming language,
 * written as a collection of C++ functions in separate files.
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

// The C++ programming language standard can be found at:
// https://www.open-std.org/JTC1/SC22/WG21/
// The C++ programming language standard is maintained by the ISO C++ Standards Committee
// The C++ programming language standard is also known as ISO/IEC 14882
// This tutorial series, is based on the C++20 standard.
// This is enforced in the Makefile with --c++2b

// Notes on CLion IDE errors
// When you create a new file, you might get the following warning:
// Does not belong to any project target. Code insight features might not work properly.
// To fix this issue, I set the basics directory as containing 'Project Sources and Headers'
// This is done by right-clicking on the basics directory and selecting
// 'Mark Directory as' -> 'Project Sources and Headers'

// Note on include file paths in CLion
// To get CLion to recognize the include file paths for a Makefile project, you need to
// add the include directories to CXX_FLAGS in the Makefile. For example:
// CXX_FLAGS = -I.
// The . in this case is the current directory, relative to the Makefile.
// You may need to delete and recreate the project. I had to do this to get the include
// paths to work.

// Note on Xcode C++ development
// You have to manually synchronize the settings in the Xcode project
// and the Makefile. There is no automated way to do this.

// Note on Xcode Header and Library Search Paths
// Click on the project in the project navigator panel (usually its the left panel.)
// Click on the files icon if it is not already selected. Then click on the project line.
// This is the top line in the files tree. It will have the Apple Xcode icon. When
// selected, the editor panel will open up with various settings. Choose the
// the 'Build settings' tab and then In the search bar, search for 'Search'
// In the 'Search Paths' section, look for the 'Header Search Paths' entry.
// Add the project root folder to it. I do this, by adding .
// You can also add other paths like boost include paths as you see fit.
// Similarly look for 'Library Search Paths' and add the library search paths
// you want to add. For this project no library search paths are needed.

// Note on setting the language level in Xcode.
// To set the language level, follow the instructions above for Xcode Header and Library
// Search Paths, and navigate to the 'Build Settings' tab. Search for Language and
// find the section named 'Apple Clang Language C++. Choose c++20 to match what is
// specified in the Makefile for the project.

// Project specific includes
#include <basics/strings.hh>

// System includes
#include <iostream>

/**
 * Main function
 * This is the simpler form of the main function.
 * In C++ main must be defined in one of two ways:
 * int main() { body }
 * or
 * int main(int argc, char* argv[]) { body }
 * @return 0
 */
int main() {
  std::cout << "C++ basics" << std::endl;
  explore_strings();

  // The return value in a C++ program is optional.
  // If there is no return statement, the compiler will insert a return 0; statement.
  // Main should return zero upon successful completion, and non-zero upon failure.
  // The exact non-zero value is up to the program. But this value is can be
  // used by bash scripts to determine the success or failure of the program.
  return 0;
}
