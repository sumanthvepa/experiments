// Ignore pedantic warnings from boost headers
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdouble-promotion"
#pragma clang diagnostic ignored "-Wzero-as-null-pointer-constant"
#pragma clang diagnostic ignored "-Wweak-vtables"
#pragma clang diagnostic ignored "-Wpadded"
#include <boost/lexical_cast.hpp>
#pragma clang diagnostic pop

#include <iostream>

static auto is_palindrome(int n) -> bool {
  int reversed = 0;
  int original = n;
  while (n > 0) {
    reversed = reversed * 10 + n % 10;
    n /= 10;
  }
  return original == reversed;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage"
auto main(int argc_, const char *argv_[]) -> int {
  for (int n = 1; n < argc_; ++n) {
    const char *arg = argv_[n];
    try {
      auto number = boost::lexical_cast<int>(arg);
      std::cout << arg << (is_palindrome(number)? " is" : " is not") << " a palindrome\n";
    } catch(const boost::bad_lexical_cast&) {
      std::cerr << "'" << arg << "' is not an integer\n";
    }
  }
  return 0;
}
#pragma clang diagnostic pop
