/* -*- coding: utf-8 -*- */
/**
 * null_pointers.cc: Explore null pointers in C++
 */
/* -------------------------------------------------------------------
 * null_pointers.cc:  Explore null pointers in C++
 * This is part of the basics program that explores C++ concepts.
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 -------------------------------------------------------------------*/

#include <basics/null_pointers.hh>
#include <iostream>  // May also define NULL
#include <cstddef>  // Defines NULL and std::nullptr_t

// Tell the compiler/clang-tidy to ignore unknown pragmas like pragma ide
// which are interpreted by the CLion IDE.
// Tell CLion to ignore unreachable code and constant condition warnings in the file.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma ide diagnostic ignored "UnreachableCode"
#pragma ide diagnostic ignored "ConstantConditionsOC"
/*!
 * \brief Helper to demonstrate use of nullptr_t in an overloaded
 * context.
 *
 * This function takes a pointer to an int and prints the value
 * pointed to by the pointer if it is not null. If it is null,
 * it prints that the pointer is null.
 *
 * \param p Pointer to an int. Can be null.
 *
 * \see sv::basics::explore_null_pointers()
 * \see overloaded(const double *p)
 * \see overloaded(nullptr_t)
 */
static void overloaded(const int *p) {
  if (p) std::cout << "int *p point to " << *p << "\n";
  else std::cout << "int *p is null\n";
}

/*!
 * \brief Helper to demonstrate use of nullptr_t in an overloaded
 * context.
 *
 * This function takes a pointer to a double and prints the value
 * pointed to by the pointer if it is not null. If it is null,
 * it prints that the pointer is null.
 *
 * \param p Pointer to a double. Can be null.
 *
 * \see sv::basics::explore_null_pointers()
 * \see overloaded(const int *p)
 * \see overloaded(nullptr_t)
 */
static void overloaded(const double *p) {
  if (p) std::cout << "double *p point to " << *p << "\n";
  else std::cout << "double *p is null\n";
}

// Ignore the waring from clang about missing parameter name nullptr
// in the doxygen documentation comment.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
/*!
 * \brief Helper to demonstrate use of nullptr_t in an overloaded
 * context.
 *
 * This function takes a nullptr_t and prints a message indicating
 * that the pointer is null. Note that no parameter name is specified
 * after nullptr_t because it is not needed.
 *
 * \param nullptr Always nullptr.
 *
 * \see sv::basics::explore_null_pointers()
 * \see overloaded(const int *p)
 * \see overloaded(const double *p)
 */
static void overloaded(nullptr_t) {
  std::cout << "overloaded(nullptr_t) was called\n";
}
#pragma clang diagnostic pop

/*!
 * \brief Explore the use of null pointers in C++.
 *
 * Explore the traditional NULL and 0 as well as the C++11 nullptr.
 * Also explore the use of nullptr_t in an overloaded context.
 */
void sv::basics::explore_null_pointers() {
  std::cout << "Exploring null pointers...\n";
  
  // 0 in C++ an invalid reference to a memory location
  // and is used as a null pointer. It inherits this
  // behavior from C++. This type of code is discouraged.
  // Use the nullptr literal described below for modern code.
  // Note the pragma suppressing C++ warnings about using
  // zero as a null pointer. This is done here because
  // we are deliberately using 0 as a null pointer to
  // illustrate a point.
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wzero-as-null-pointer-constant"
  // The comment after the line is to stop clang-tidy from complaining.
  int *p = 0; // Null. NOLINT(*-use-nullptr)
  // Just use p in some way to avoid compiler warnings
  // about an unused variable.
  if (p == 0) std::cout << "p is a null pointer\n"; // NOLINT(*-use-nullptr)
  else std::cout << "p is null\n";
  #pragma clang diagnostic pop
  
  // Dereferencing a null pointer will result in
  // the program crashing. Exact crashing behaviour is
  // undefined.
  // std::cout << *p << endl; // will crash.
  
  // Because it is difficult to see = 0 style assignment
  // many older code bases use the NULL macro which is
  // defined in a variety of places, but I recommend
  // taking the definition from <cstddef>
  // See: https://en.cppreference.com/w/c/types/NULL
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wzero-as-null-pointer-constant"
  // The following is equivalent to int *q = 0
  int *q = NULL;  // NOLINT(*-use-nullptr)
  if (q == 0) std::cout << "q is a null pointer\n"; // NOLINT(*-use-nullptr)
  else std::cout << "q is null\n";
  #pragma clang diagnostic pop

  // Because NULL is often defined as #define NULL 0,
  // it can be assigned to a non-pointer integer type.
  // Don't do this.
  // Note that pragma suppressing the compiler warning
  // that NULL is being converted to (int)0 and (char)0
  // in the code.
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wnull-conversion"
  int r = NULL; // r = 0. Which may or may not be surprising
  std::cout << "r = " << r << "\n"; // No issue using r
                                    // as it is not a pointer.
  char c = NULL;  // c = 0. Once again surprising but legal
  // The 0 character is not printable, so we cannot call print
  // but to avoid compiler warnings about unused variables
  // we can do the following:
  if (!c) std::cout << "c is 0\n";
  else std::cout << "c is not 0\n";
  #pragma clang diagnostic pop
  
  // The above ways of using null pointers has the problem that
  // 0 and NULL are both assignable to non pointer types.
  // In C++11 and later, the nullptr keyword was added that
  // defines a unique null pointer.
  int *s = nullptr;
  if (s) std::cout << "s is not null\n";
  else std::cout << "s is null";
  
  // But nullptr cannot be assigned to a non-pointer type
  // Cannot initialize a variable of type 'int' with an r-value
  // of type std::nullptr_t;
  // int t = nullptr;
  
  // Note that type of nullptr is std::nullptr_t
  // Defined in <cstddef>. This type is useful during
  // function overloading.
  int n = 42;
  int *np = &n;
  double m = 43.43;
  double *mp = &m;
  overloaded(np); // Calls void overloaded(int *pointer)
  overloaded(mp); // Calls void overloaded(double *pointer)
  
  // The following call would be ambiguous if
  // void overloaded(nullptr_t) were not defined
  // because it is not clear from context whether
  // int * version or the double * version needs
  // to be called. But defining void overload(nullptr_t)
  // resolves the ambiguity.
  overloaded(nullptr);
  
  // You can of course explicitly call overloaded(int *p) with
  // a null pointer with a cast. But as the pragmas show,
  // we are effectively using 0 as a nullptr, which is
  // discouraged.
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Wzero-as-null-pointer-constant"
  overloaded(static_cast<int *>(0)); // NOLINT(*-use-nullptr)
  #pragma clang diagnostic pop
  std::cout << "... finished exploring null pointers\n";
}
#pragma clang diagnostic pop
