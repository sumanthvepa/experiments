#include <iostream>

auto main() -> int {
  std::cout << "Checking compiler macros" << std::endl;

  // Defined for g++ clang++
  #if defined(__cplusplus)
    std::cout << "__cplusplus is defined" << std::endl;
  #endif

  // __GNUC__ should be defined for gcc, g++, clang and clang++
  #if defined (__GNUC__)
  std::cout << "__GNUC__ is defined and has value: " << __GNUC__ << std::endl;
  #else
  std::cout << "__GNUC__ is NOT defined" << std::endl;
  #endif

  // __GNUG__ should be defined for g++, clang++
  #if defined (__GNUG__)
  std::cout << "__GNUG__ is defined and has value: " << __GNUG__ << std::endl;
  #else
  std::cout << "__GNUG__ is NOT defined" << std::endl;
  #endif

  // Should be defined for gcc, g++
  #if defined (__GNUC_MINOR__)
  std::cout << "__GNUC_MINOR__ is defined and has value: " << __GNUC_MINOR__ << std::endl;
  #else
  std::cout << "__GNUC_MINOR__ is NOT defined" << std::endl;
  #endif

  // Should be defined for gcc, g++
  #if defined (__GNUC_PATCHLEVEL__)
  std::cout << "__GNUC_PATCHLEVEL__ is defined and has value: " << __GNUC_PATCHLEVEL__ << std::endl;
  #else
  std::cout << "__GNUC_PATCHLEVEL__ is NOT defined" << std::endl;
  #endif

  // Should be defined for clang and clang++
  #if defined (__clang__)
  std::cout << "__clang__ is defined and has value: " << __clang__ << std::endl;
  #else
  std::cout << "__clang__ is NOT defined" << std::endl;
  #endif

  #if defined (__clang_major__)
  std::cout << "__clang_major__ is defined and has value: " << __clang_major__ << std::endl;
  #else
  std::cout << "__clang_major__ is NOT defined" << std::endl;
  #endif

  #if defined (__clang_minor__)
  std::cout << "__clang_minor__ is defined and has value: " << __clang_minor__ << std::endl;
  #else
  std::cout << "__clang_minor__ is NOT defined" << std::endl;
  #endif

  #if defined (__clang_patchlevel__)
  std::cout << "__clang_patchlevel__ is defined and has value: " << __clang_patchlevel__ << std::endl;
  #else
  std::cout << "__clang_patchlevel__ is NOT defined" << std::endl;
  #endif

  // Check for gcc and g++
  #if defined(__GNUC__) && ! defined(__clang__)
  std::cout << "Compiler is either gcc or g++" << std::endl;
  #endif

  // Check for g++ only
  #if defined(__GNUC__) && ! defined(__clang__)
  std::cout << "Compiler is g++" << std::endl;
  #endif

  // Check for clang
  #if defined(__clang__)
  std::cout << "Compiler is either clang or clang++" << std::endl;
  #endif

  // Check for clang++
  #if defined(__clang__) && defined(__cplusplus) 
  std::cout << "Compiler is clang++" << std::endl;
  #endif

  return 0;
}
