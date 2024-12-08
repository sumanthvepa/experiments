/* -*- coding: utf-8 -*- */
/**
 * explore_modules.cc: Main program file to exploreC++-20 modules.
 * 
 * This progam explores the use and creation of C++-20 modules.
 * This file is the main program is uses the module
 * m42.exp.explore_modules. It does not export any modules.
 */
/* -------------------------------------------------------------------
 * explore_modules.cc: An exploration of C++-20 modules.
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

// The following videos are excellent references for understanding
// C++-20 modules:
// C++ Modules: Getting Started Today by Andreas Weis CppCon 2023
// https://www.youtube.com/watch?v=_x9K9_q2ZXE
// So You Want to Use C++ Modules ...cross-platform by Daniela Engert
// https://www.youtube.com/watch?v=iMNML689qlU

// CLang
// This document describes how to use the CLang compiler to compile
// C++-20 modules.
// https://releases.llvm.org/17.0.1/tools/clang/docs/StandardCPlusPlusModules.html

// GNU GCC
// This document describes how to use the GNU GCC compiler to compile
// C++-20 modules.
// https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Modules.html
// I strongly recommend using GCC 11 or later for C++-20 modules.
// Ideally use GCC 14 or later.

// MSVC
// This is a good introduction to Modules from Microsoft
// https://learn.microsoft.com/en-us/cpp/cpp/modules-cpp?view=msvc-170


// IDEs
// JetBrains CLion
// Documentation on CLion's support for C++ modules is described here:
// https://www.jetbrains.com/help/clion/support-for-c-20-modules.html

// Xcode
// As of XCode 16, neither Apple Clang nor Xcode itself support
// C++ modules


// Using C++ standard library headers.
// For now it seems like it make more sense to use the older include
// syntax for the standard library headers. This is because importing
// you cannot mix import and include directives for standard library
// headers. You have to either use all imports or all includes.
// Since a lot of legacy code uses the include syntax, it is better to
// stick with that for now.

// It's probably a good idea to put includes ahead of imports in
// order to avoid any issues with the import directive.

// provides std::cout, std::endl
#include <iostream>

// provides m42.exp.explore_modules::greeting
import m42.exp.explore_modules;

auto main() -> int {
  std::cout << m42::exp::explore_modules::greeting() << std::endl;
  std::cout << m42::exp::explore_modules::verbose_greeting() << std::endl;
  // Won't work because greeting_prefix is not exported.
  // std::cout << m42::exp::explore_modules::greeting_prefix() << std::endl;
  return 0;
}
