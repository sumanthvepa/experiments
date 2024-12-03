/* -*- coding: utf-8 -*- */
/**
  read_text_file.cc: A program to read the contents of a text file.
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
#include <fstream>
#include <sstream>
#include <iostream>

/**
 Read the contents of a file into a string.

 This reads the entire contents of a file into a string. It does
 so rather inefficiently, since the memory allocated for the
 string duplicates the bytes contained in the file which is
 usually opened with an mmap system call. So effectively, 
 there are two copies of the file contents in memory during
 the operation of this function.

 For small files, this is okay. But for larger files, there
 are better ways that will be explored elsewhere.

 For large enough files, this operation will fail in a way
 that cannot be controlled from within this program. If
 the size of the file is larger than actual physical memory
 available, the process itself will be killed by the OOM killer
 process that runs on Linux and (possibly macOS).

 - parameters:
  - filename_: The name of the file to read fiom
 - returns: A string containing the contents of the text file
 - throws: std::ios_base_failure, if the file cannot be opend or read from.
 */
static auto slurp(const std::string& filename_) -> std::string {
  // We want to setup the input stream, so that it throws an execption
  // if it fails to open the file for any reason.

  // To do this, we first create an uninitialized input file stream.
  std::ifstream ifs;
  // We then enable exceptions to be thrown if either a logical
  // error occurs(failbit) or if there is a read/write error (badbit)
  ifs.exceptions(std::ifstream::failbit | std::ifstream::badbit);

  // Then we open the file. Any errors in opening the file will
  // result in an std::ios_base::failure exception being thrown.
  // A std::bad_alloc might also be thrown if the program has
  // trouble allocating memory. Usually we catch the latter
  // in a catch all catch(const std::exception& ex_) clause
  // in the caller.
  ifs.open(filename_);

  // We want to read from the input file stream and write
  // the output to the the output string stream. So we
  // create a output string stream object.
  std::ostringstream oss;

  // This reads the contents of the entire file into the
  // string. The read loop is implicit here. There is
  // a loop inside the << operator. It keeps pulling data
  // from ifs.rdbuf() until rdbuf returns empty.
  // The rdbuf() function returns a streambuf object that
  // has operator << defined on it. The loop is within
  // this operator.
  // Any errors reading the stream will result in an
  // exception being thrown.
  oss << ifs.rdbuf() << std::ends;
  return oss.str();
}

/**
  Exercise the slurp function
  - parameters:
   - argc_: The number arguments on the command line including the
            name of the program.
   - argv_: An array pointers to C strings containing the actual
            program arguments. These should names of files, whose
	    contents need to be read.
*/
auto main(int argc_, const char *argv_[]) -> int {
  // Iterate over the filenames provided on the command line
  // and print out the contents for the files.
  for(int i = 1; i < argc_; ++i) {
    std::string filename = argv_[i];
    try {
      std::cout << slurp(filename) << std::endl;
    } catch (const std::ios_base::failure&) {
      std::cerr << "Could not open or read the contents of file "
        << filename
	<< std::endl;
    } catch (const std::exception& ex_) {
      std::cerr << "Caught an exception: " << ex_.what() << std::endl;
    }
  }
  return 0;
}
