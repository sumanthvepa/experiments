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

auto m42::exp::example::greet(const std::string& name_) -> std::string {
  return "Hello, " + name_ + "!";
}

