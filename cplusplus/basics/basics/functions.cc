/* -*- coding: utf-8 -*- */
/**
 * functions.cc: Explore functions
 */
/* -------------------------------------------------------------------
 * functions.cc: Explore functions
 * This is part of the basics program that explores C++ concepts.
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

#include <basics/functions.hh>
#include <iostream>

// Functions are always defined at file scope. 
// There are two styles of function declarations:
//   Normal 'C-style' function declarations, and 
//   Trailing return function declarations. 
// Both styles of functions are called the same way but
// are declare differently

// This function is declared using the standard style. Ignore the
// static keyword for now. That just restricts the scope of this
// function to this file.
static int normal_function(const std::string& a, int b) {
  std::cout << "int(12) normal_function(const std::string& a = " << a << ", int b = " << b << ")\n";
  return 12;
}

// This function is declared using trailing return style. Ignore the
// static keyword for now. That just restricts the scope of this
// function to this file.
// This style of declaration starts with auto and then the function
static auto trailing_return_function(const std::string& a, int b) -> int {
  std::cout << "auto trailing_return_function(const std::string& a = " << a << ", int b = " << b << ") -> int(13)\n";
  return 13;
}

// Both function declarations are equivalent. I prefer the trailing
// return function declaration. However, the trailing inner function
// syntax is similar to how lambdas are defined. See explore_functions
// for a lambda function definition/declaration.

// Also some template declarations will only work with the trailing
// syntax method.

// As a matter of style, prefer the trailing return syntax for
// all function declarations and definitions.

/**
 * Explore functions
 */
auto sv::basics::explore_functions() -> void {
  std::cout << "Exploring functions...\n";

  auto value1 = normal_function("a", 1);
  std::cout << value1 << "\n";

  auto value2 = trailing_return_function("b", 2);
  std::cout << value2 << "\n";
  
  // This is a lambda function. The syntax closely matches the
  // trailing-return syntax. (Lambdas are explored more thoroughly in
  // lambdas.cc.)
  auto lambda_function = [](int a) -> int { return a + 1;};
  std::cout << "lambda_function(2) = " << lambda_function(2) << "\n";

  // Trailing-return style function declarations are very useful for
  // template function declarations (see the header file,
  // functions.hh, for the explanation.
  auto sum1 = add1(23, 25.25);
  std::cout << "sum1 = " << sum1 << "\n";
  auto sum2 = add2(30, 30.33);
  std::cout << "sum2 = " << sum2 << "\n";
  
  std::cout << "...finished exploring functions\n";
}
