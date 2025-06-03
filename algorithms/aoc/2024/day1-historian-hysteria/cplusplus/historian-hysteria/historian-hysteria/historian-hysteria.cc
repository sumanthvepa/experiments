#include <boost/algorithm/string.hpp>

// Get defintion of std::fstream
#include <fstream>
// Get definition of std::ostringstream
#include <sstream>
// Get defintion of std::cout, std::cerr, std::endl, std::ends
#include <iostream>
// Get definition of std::vector
#include <vector>
// Get definition of std::tuple
#include <tuple>
// Get definition of std::string
#include <string>
// Get definition of std::exception
#include <stdexcept>

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
 process that runs on Linux and macOS.

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

static auto split_lines(const std::string& input_) -> std::vector<std::string> {
  std::vector<std::string> lines;
  std::istringstream ss(input_);
  std::string line;
  while (getline(ss, line, '\n')) {
    lines.push_back(line);
  }
  return lines;
}

static auto make_string_pair(const std::string& line_) -> std::pair<std::string, std::string> {
  std::pair<std::string, std::string> result;
  boost::split(result, line_, boost::is_any_of("\t "));
  return result;
}

static auto make_lists(
    const std::vector<std::string>& lines_) -> std::pair<std::vector<std::string>, std::vector<std::string> > {
  std::vector<std::string> list1;
  std::vector<std::string> list2;
  for (auto line: lines_) {
    auto [s1, s2] = make_string_pair(line);
    list1.push_back(s1);
    list2.push_back(s2);
  }
  return {list1, list2};
}


static auto help() -> std::string {
  return "TODO: help message here";
}

static auto process_command_line(
    int argc_, const char *argv_[]) -> std::string {
  if (argc_ < 2)
    throw std::invalid_argument(
      "No input filename specifed on the command line");
  return argv_[1];
}

static auto read_input(const std::string& filename_) -> std::pair<std::vector<int>, std::vector<int> > {
  auto input = slurp(filename_); // Grab the input file
  auto lines = split_lines(input); // Split it to lines
  auto [strings1, strings2] = make_string_lists(lines); // Split the lines into two lists of strings
  // Convert the lists of strings into lists of integers
  auto list1 = string_to_int(strings1);
  auto list2 = string_to_int(strings2);
  // Return the pair of lists
  return {list1, list2};
}

static auto print_list(const std::vector<int>& list_) {
  for (auto element: list_)
    std::cout << element << "\n";
}

auto main(int argc_, const char *argv_[]) -> int {
  try {
    auto input = process_command_line(argc_, argv_);
    auto [list1, list2] = read_input(filename);
    print_list(list1);
    print_list(list2);
    return 0;
  } catch (const std::exception& ex_) {
    std::cerr << ex_.what() << std::endl;
    std::cerr << help() << std::endl;
    return 1;
  }
}
