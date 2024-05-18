#include <iostream>
#include <ctime>
#include <cstdlib>

int main()
{
  srand(time(nullptr));
  for (int n = 0; n < 100; ++n) {
    int r = rand();
    std::cout << r << std::endl;
  }
  return 0;
}
