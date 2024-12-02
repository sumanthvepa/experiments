#include <iostream>
#include <string>
#include <stdexcept>

static auto process_command_line(
    int argc_, const char *argv_[]) -> std::string {
  if (argc_ < 2)
    throw std::invalid_argument(
      "Must specify an input file on the command line");
  return argv_[1];
}

auto main(int argc_, const char *argv_[]) -> int {
  try {
    auto input_filename = process_command_line(argc_, argv_);
    std::cout << input_filename << std::endl;
    return 0;
  } catch (const std::exception& ex_) {
    std::cerr << ex_.what() << std::endl;
    return 1;
  }
}
