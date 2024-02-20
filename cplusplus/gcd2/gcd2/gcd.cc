// -------------------------------------------------------------------
// gcd.cc: A program to compute the greatest common divisor between
// two
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
#include <boost/lexical_cast.hpp>
#include <iostream>
#include <tuple>
#include <string>
#include <stdexcept>

/**
 * \brief: Retrieve the name of the program from the command line
 * arguments.
 *
 * This function return argv_[0] as the name of the program. If argv_[0]
 * is not srt for some reason, the default name "gcd" is returned.
 *
 * @param argc_ The number of command line arguments
 * @param argv_ The command line arguments
 * @return The name of the program
 */
std::string_view program_name(int argc_, const char *argv_[]) {
  static constexpr auto default_parameter_name = "gcd";
  return (argv_ != nullptr && argc_ > 0 && argv_[0] != nullptr)?
    argv_[0] : default_parameter_name;
}
/**
 * \brief: Generate a help message for the user for the case when too
 * few arguments are supplied.
 *
 * @param program_name_ The name of the program. @see program_name
 * @return A help message string.
 */
std::string help(const std::string_view& program_name_) {
  return
    std::string("Too few arguments. Invoke the program as follows:\n") +
    std::string(program_name_) + std::string(" <dividend> <divisor>");
}

/**
 * \brief: Generate a warning message for the user for the case when
 * too many arguments are supplied.
 *
 * @param program_name_ The name of the program. @see program_name
 * @return A warning message string.
 */
std::string warn(const std::string_view& program_name_) {
  return
    std::string("Too many arguments. Only the first two will be used\n.") +
    std::string("Invoke the program as follows:\n") +
    std::string(program_name_) + std::string(" <dividend> <divisor>");
}

/**
 * \brief: Process the command line arguments and return the dividend
 * and divisor as a tuple.
 *
 * If the number of arguments is less than 3, an invalid_argument
 * exception is thrown. If the number of arguments is greater than 3,
 * a warning message is printed to the standard error stream.
 * Additionally, if the arguments are not positive integers, an
 * invalid_argument exception is thrown.
 *
 * @param argc_ The number of command line arguments
 * @param argv_ The command line arguments
 * @return A tuple containing the dividend and divisor
 */
std::tuple<unsigned int, unsigned int> process_command_line(
    int argc_, const char *argv_[]) {
  auto name = program_name(argc_, argv_);
  if (argc_ < 3) throw std::invalid_argument(help(name));
  if (argc_ > 3) std::cerr << warn(name) << std::endl;
  try {
    auto dividend = boost::lexical_cast<unsigned int>(argv_[1]);
    auto divisor = boost::lexical_cast<unsigned int>(argv_[2]);
    return {dividend, divisor};
  } catch (const boost::bad_lexical_cast& ex) {
    throw std::invalid_argument("Both dividend and divisor must be positive integers");
  }
}

/**
 * \brief: Compute the greatest common divisor of two positive
 * integers.
 *
 * This function computes the greatest common divisor of two positive
 * integers using the Euclidean algorithm.
 *
 * @param m_ The first positive integer
 * @param n_ The second positive integer
 * @return The greatest common divisor of m_ and n_
 */
constexpr unsigned int gcd(unsigned int m_, unsigned int n_) {
  while (n_ != 0) {
    auto t = n_;
    n_ = m_ % n_;
    m_ = t;
  }
  return m_;
}

/**
 * \brief: The main function of the program.
 *
 * This function processes the command line arguments and computes the
 * greatest common divisor of the two positive integers. If the
 * command line arguments are invalid, an error message is printed to
 * the standard error stream and the program returns 1. Otherwise, the
 * greatest common divisor is printed to the standard output and the
 * program returns 0.
 *
 * Note that the function only processes the first to command line
 * arguments after the program name. If more arguments are supplied,
 * a warning message is printed to the standard error stream and the
 * arguments are ignored,
 *
 * @param argc_ The number of command line arguments
 * @param argv_ The command line arguments
 * @return 0 if the program runs successfully, 1 otherwise
 */
int main(int argc_, const char *argv_[]) {
  try {
    auto params = process_command_line(argc_, argv_);
    auto dividend = std::get<0>(params);
    auto divisor = std::get<1>(params);
    std::cout << gcd(dividend, divisor) << std::endl;
    return 0;
  } catch (const std::exception& ex) {
    std::cerr << ex.what() << std::endl;
    return 1;
  }
}
