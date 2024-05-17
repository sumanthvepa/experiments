//--------------------------------------------------------------------
// lexical_cast.cc: A program to demonstrate the usage of
//  boost::lexical_cast
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
//--------------------------------------------------------------------

// Ignore pedantic warnings from boost headers
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wc++98-compat" 
#pragma clang diagnostic ignored "-Wc++98-compat-pedantic"
#pragma clang diagnostic ignored "-Wdouble-promotion"
#pragma clang diagnostic ignored "-Wzero-as-null-pointer-constant"
#pragma clang diagnostic ignored "-Wweak-vtables"
#pragma clang diagnostic ignored "-Wpadded"
#include <boost/lexical_cast.hpp>
#pragma clang diagnostic pop

#include <iostream>
#include <exception>

/**
 *  \brief Parse command line arguments into integers using
 *  boost::lexical_cast. 
 * 
 * @param argc_ The length of the argument list.
 * @param argv_ The list of argument. The first argument is the 
 *  name by which this program was invoked.
 * 
 * @return Number of errors encountered during parsing
 */
int main(int argc_, const char *argv_[]) {
  int errors = 0;
  for (int i = 1; i < argc_; ++i) {
    try {
      int n = boost::lexical_cast<int>(argv_[i]);
      std::cout << n << " ";
    } catch (const std::exception& ex_) {
      std::cerr << ex_.what();
      ++errors;
    }
    std::cout << std::endl;
  }
  return errors;
}
