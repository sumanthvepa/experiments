#include <basics/deleted_functions.hh>
#include <iostream>

auto sv::basics::explore_deleted_functions() -> void {
  // See:
  // https://learn.microsoft.com/en-us/cpp/cpp/explicitly-defaulted-and-deleted-functions?view=msvc-170
  std::cout << "Explore deleted functions" << std::endl;
}
