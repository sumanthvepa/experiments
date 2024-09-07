/**
 * stdlibraries.cc: Explore the C++ standard library
 */
/* -------------------------------------------------------------------
 * stdlibraries.cc: Explore the C++ standard library
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
#include <stdlibraries/streams.hh>
#include <stdlibraries/vectors.hh>
#include <stdlibraries/iterators.hh>
#include <iostream>


auto main(int, const char **) -> int {
  sv::stdlibraries::explore_iterators();
  sv::stdlibraries::explore_vectors();
  sv::stdlibraries::explore_streams();
}
