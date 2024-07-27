#include <iostream>
#include <vector>
#include <utility>
#include <exception>

class no_solution: std::exception {
public:
  const char *what() const noexcept override;
};

std::pair<int, int> two_sum(const std::vector<int>& numbers, int sum);

const char *no_solution::what() const noexcept {
  return "no solution";
}

std::pair<int, int> two_sum(const std::vector<int>& numbers, int sum) {
  typedef std::vector<int>::size_type index_t;

  for (index_t fi = 0; fi < numbers.size(); ++fi) {
    for(index_t si = fi + 1; si < numbers.size(); ++si) {
      if (numbers[fi] + numbers[si] == sum) {
        return std::pair<int, int>(fi, si);
      }
    }
  }
  throw no_solution();
}

int main() {
  try {
    std::vector<int> numbers = {3, 4, 2, 5};
    int sum = 6;
    std::pair<int, int> result = two_sum(numbers, sum);
    std::cout << result.first << "\n";
    std::cout << result.second << std::endl;
  } catch(const no_solution& ex) {
    std::cerr << ex.what() << std::endl;
  }
}
