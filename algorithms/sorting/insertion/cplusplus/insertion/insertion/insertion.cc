/* -*- coding: utf-8 -*- */
/**
 * insertion.cc: Implementation of the insertion sort algorithm
 */
/* -------------------------------------------------------------------
 * insertion.cc: Implementation of the insertion sort algorithm
 *
 * This is part of the insertion program that explores the insertion
 * sort algorithm.
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

#include <iostream>
#include <fstream>
#include <vector>
#include <iterator>


static auto load_dataset(const char *filename) -> std::vector<int> {
  // Open the file. Raise an exception if it fails.
  std::ifstream file(filename);
  if (!file) throw std::runtime_error("Could not open file");

  // Read the data from the file as integers.
  std::vector<int> data;
  int number;
  while (file >> number) data.emplace_back(number);

  // Raise an exception if the reason for exiting the loop was not EOF.
  if (!file.eof()) throw std::runtime_error("Error reading file");

  return data;
}

template <class bidirectional_iterator_t>
static auto insertion_sort(bidirectional_iterator_t begin, bidirectional_iterator_t end) -> void {
  for (auto i = std::next(begin); i != end; ++i) {
    auto key = *i;
    // Insert (key) A[i] into the sorted sequence A[0..i-1].
    auto j = std::prev(i);
    while (j >= begin && *j > key) {
      *(std::next(j)) = *j;
      --j;
    }
    *(std::next(j)) = key;
  }
}

static auto print_data(std::vector<int> &data) -> void {
  for (auto const &element: data) std::cout << element << " ";
  std::cout << std::endl;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage"
auto main(int argc, const char * argv[]) -> int {
  try {
    for (int i = 1; i < argc; i++) {
      auto data = load_dataset(argv[i]);
      insertion_sort(data.begin(), data.end());
      print_data(data);
    }
  } catch (const std::exception &e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }
  return 0;
}
#pragma clang diagnostic pop
