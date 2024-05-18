//--------------------------------------------------------------------
// number_commas.cc: A program to demonstrate formatting on numbers
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
#include <sstream>
#include <iostream>
#include <locale>

/**
 *  \brief Return a comma/space formatted string corresponding to
 *  the given number appropriate to the current locale.
 *
 *  @param number_ The number to be formatted.
 *  @return A formatting string with commas or space separated groups
 *          of digits appropriate for the locale.
 */	    
template <class T>
std::string with_commas(T number_) {
  std::stringstream ss;
  // Get the current locale.
  ss.imbue(std::locale(""));
  ss << std::fixed << number_;
  return ss.str();
}


/**
 *  \brief Print a number with commas/dot and grouping appropriate
 *  for the locale
 *
 * @return 0
 */
int main() {
  int return_value = 0;
  try {
    int number1 = 1234567;
    double number2 = 987654321.231;
    std::cout << with_commas(number1) << '\n';
    std::cout << with_commas(number2) << std::endl;
  } catch (const std::exception& ex_) {
    std::cerr << ex_.what() << std::endl;
    return_value = 1;
  }
  return return_value;
}
