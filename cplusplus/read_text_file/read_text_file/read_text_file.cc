#include <fstream>
#include <sstream>
#include <iostream>

static auto slurp(const std::string& filename_) -> std::string {
  std::ifstream ifs(filename_);
  std::ostringstream oss;
  oss << ifs.rdbuf() << std::ends;
  return oss.str();
}

auto main(int argc_, const char *argv_[]) -> int {
  for(int i = 1; i < argc_; ++i) {
    std::cout << slurp(argv_[i]) << std::endl;
  }
  return 0;
}
