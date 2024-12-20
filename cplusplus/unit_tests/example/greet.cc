/* -*- coding: utf-8 -*- */
/**
 * greet.cc: Greet a person by name
 */
/* -------------------------------------------------------------------
 * greet.cc: Greet a person by name
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
#include <string>

auto m42::exp::example::greet() -> std::string {
  return greet("");
}
auto m42::exp::example::greet(const std::string& name_) -> std::string {
  // g++ (as of version 14.2.1) does not understand constexpr
  // std::strings. So do not use constexpr when compiling under
  // g++
  // Note compiler detection macros are described in this 
  // stack overflow post:
  // https://stackoverflow.com/questions/28166565/detect-gcc-as-opposed-to-msvc-clang-with-macro
  #if defined(__GNUG__)
  static std::string greeting = "Hello";
  #else
  static constexpr std::string greeting = "Hello";
  #endif
  if (name_.empty()) return greeting + "!";
  return greeting + ", " + name_ + "!";
}

