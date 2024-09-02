/* -*- coding: utf-8 -*- */
/**
 * functions.hh: Header file for functions.cc. Explore functions
 */
/* -------------------------------------------------------------------
 * functions.hh: Header file for functions.cc. Explore functions
 *
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
#ifndef sv_basics_functions_hh
#define sv_basics_functions_hh
#pragma once

#include <utility>  // Provides std::declval

namespace sv::basics {
  auto explore_functions() -> void;

  // See explanation of trailing-return style declarations in
  // functions.cc. This explanation should be read in that context.
  // (There is a comment note directing the reader to this code here.)
 

  // The example below is taken from:
  // https://blog.petrzemek.net/2017/01/17/pros-and-cons-of-alternative-function-syntax-in-cpp/

  // Trailing-return style declarations make it possible to define 
  // functions like following, where the return type is a decltype
  // of input parameters.
  // (see decltype_and_declval.cc for an explanation of decltypes)
  // This syntax relies on left_ and right_ being defined by the time
  // they are used in the decltype invocation, which is indeed the
  // case here.
  template <typename Left, typename Right>
  auto add1(const Left& left_, const Right& right_) -> decltype(left_ + right_) {
    return left_ + right_;
  }

  // This would not be feasible if the function were declared using
  // the normal function declaration syntax. left_ and right_ are used
  // before they are declared in the function's parameters. The
  // following code will not compile:
  //
  // template <typename Left, typename Right>
  // decltype(left_ + right_) add(const Left& left_, const Right& right_);

  // There is a workaround for the problem with normal function
  // declarations in this case using declval (see
  // decltypes_and_declval.cc for an explanation of declval)
  template <typename Left, typename Right>
  decltype(std::declval<Left>() + std::declval<Right>()) add2(const Left& left_, const Right& right_) {
    return left_ + right_;
  }
}

#endif // sv_basics_functions_hh
