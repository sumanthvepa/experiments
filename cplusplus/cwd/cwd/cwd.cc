/* -*- coding: utf-8 -*- */
/**
  cwd.cc: Print the current working directory of the program.
 */
// -------------------------------------------------------------------
// read_text_file.cc: A program to read the contents of a text file.
//
// Copyright (C) 2024 Sumanth Vepa.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
// -------------------------------------------------------------------

// provides std::filesystem::path, std::filesystem::current_path,
// and std::filesystem::filesystem_error
#include <filesystem>
// Provides std::cout std::cerr, and std::endl
#include <iostream>
// Provided std::bad_alloc
#include <exception>

auto main() -> int {
  try {
    // std::filesystem::path is a class/struct defining an OS independent
    // representation of a filesystem path.
    // It is described at: https://en.cppreference.com/w/cpp/filesystem/path
    // The current_path() function returns the current working directory.
    // It is described at https://en.cppreference.com/w/cpp/filesystem/current_path
    std::filesystem::path cwd = std::filesystem::current_path();
    
    // path has a method string() that returns a string form of the path.
    // This can be useful in some circumstances.
    std::string strpath = cwd.string();
    std::cout << strpath << std::endl;
    
    // But std::filesystem::path provides an overload of the operator <<
    // to allow it to be directly printed to stdout.
    std::cout << cwd << std::endl;
    return 0;
  } catch(const std::filesystem::filesystem_error& ex_) {
    // Any OS error in retrieving the current path results in an exception.
    std::cerr << "Could not retrieve current path: " << ex_.what() << std::endl;
  } catch (const std::bad_alloc& ex_) {
    // Since the path object has components that are stored on the heap, creating one
    // can result in a bad_alloc exception
    std::cerr << "Could not allocate memory to create the current path: " << ex_.what() << std::endl;
  }
}

