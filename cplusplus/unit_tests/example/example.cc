/* -*- coding: utf-8 -*- */
/**
 * example.cc: Example program to explore the Boost unit test framework
 */
/* -------------------------------------------------------------------
 * example.cc: Example program to explore the Boost unit test framework
 * This is part of the example program that explores Boost unit tests
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
#include <example/greet.hh>
#include <iostream>

// This program illustrates how to use the greet function from
// client code. The unit tests for the greet function are in the test
// directory.
auto main() -> int {
  std::cout << m42::exp::example::greet("Sumanth") << std::endl;
  return 0;
}
