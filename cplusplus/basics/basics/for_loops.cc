/* -*- coding: utf-8 -*- */
/**
 * for_loops.cc: Explore for loops in C++
 */
/* -------------------------------------------------------------------
 * for_loops.cc: Explore for loops in C++
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

#include <basics/for_loops.hh>
#include <iostream>
#include <vector>

/**
 * Explore range-based for loops
 */
void sv::basics::explore_range_based_for_loops() {
  std::cout << "Exploring range-based for loops...\n";
  // A range-based for loop is a convenient way to iterate over elements in a
  // container. The syntax is:
  // for (type var : container) {
  //   // do something with var
  // }
  // See https://en.cppreference.com/w/cpp/language/range-for for more details.

  // where type is the type of the elements in the container, var is the
  // variable that will hold each element in turn, and container is the
  // container to iterate over.
  // For example, let's iterate over a C array of integers:
  int arr[] = {1, 2, 3, 4, 5};
  for (int i: arr) {
    std::cout << i << " ";
  }
  std::cout << "\n";

  // The type can often be deduced by the compiler, so you can use auto:
  for (auto i: arr) {
    std::cout << i << " ";
  }
  std::cout << "\n";

  // You can also iterate over a std::vector:
  std::vector<int> vec = {1, 2, 3, 4, 5};
  for (auto i: vec) {
    std::cout << i << " ";
  }
  std::cout << "\n";

  // You can iterate over an array of strings
  const char *str_array[] = {"first", "second", "third"};
  for (auto str: str_array) {
    std::cout << str << "\n";
  }
  std::cout << "\n";

  // However, you cannot iterate over a C string using the range-based
  // for loop, since the size of a C sting is not known when the
  // iteration strarts. So the following will not compile:
  // const char *str = "This is a string";
  // for(auto arg: str) {
  //   std::cout << arg << "\n";
  // }
  std::cout << "\n";

  // For the same reason you cannot iterate over the argv
  // array of main, since the length is known.

  std::cout << "...finished exploring range-based for loops\n";
}
