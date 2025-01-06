/* -*- coding: utf-8 -*- */
/**
 * test_greet.cc: Unit tests for greet.cc
 */
/* -------------------------------------------------------------------
 * test_greet.cc: Unit tests for greet.cc
 * This is part of the example program that explores Boost unit tests
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

// The boost test framework is fully documented at:
// https://www.boost.org/doc/libs/1_87_0/libs/test/doc/html/index.html
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdisabled-macro-expansion"
#pragma clang diagnostic ignored "-Wused-but-marked-unused"
#pragma clang diagnostic ignored "-Wglobal-constructors"
#pragma clang diagnostic ignored "-Wweak-vtables"
// Define the BOOST_TEST_MODULE macro to specify the name of the test
// module. This is the name that will be displayed in the test output.
// This is required.
#define BOOST_TEST_MODULE example

// Define the BOOST_TEST_DYN_LINK macro to specify that the test module
// is to be linked dynamically with the Boost unit test framework.
// I prefer this way of building tests, as it keeps the test executable
// smaller. The other options are static linking, and header-only
// tests.
#define BOOST_TEST_DYN_LINK
#pragma clang diagnostic pop

#include <example/greet.hh>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wzero-as-null-pointer-constant"
#pragma clang diagnostic ignored "-Wredundant-parens"
#pragma clang diagnostic ignored "-Wold-style-cast"
#pragma clang diagnostic ignored "-Wshadow-field"
#pragma clang diagnostic ignored "-Wexit-time-destructors"
#pragma clang diagnostic ignored "-Wmissing-prototypes"
#pragma clang diagnostic ignored "-Wswitch-enum"
#pragma clang diagnostic ignored "-Wcovered-switch-default"
#pragma clang diagnostic ignored "-Wsign-conversion"
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#pragma clang diagnostic ignored "-Wdeprecated-copy-with-dtor"
#pragma clang diagnostic ignored "-Wcast-qual"
#pragma clang diagnostic ignored "-Wglobal-constructors"
#pragma clang diagnostic ignored "-Wused-but-marked-unused"
#pragma clang diagnostic ignored "-Wweak-vtables"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wuseless-cast"
#pragma GCC diagnostic ignored "-Wpadded"
#pragma GCC diagnostic ignored "-Weffc++"
#pragma GCC diagnostic ignored "-Wsign-conversion"
#pragma GCC diagnostic ignored "-Wunused-const-variable"
// This is the header file that defines the Boost unit test framework
// suitable for dynamic linking of the test framework.
#include <boost/test/unit_test.hpp>
#pragma GCC diagnostic pop
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdisabled-macro-expansion"
#pragma clang diagnostic ignored "-Wused-but-marked-unused"
#pragma clang diagnostic ignored "-Wglobal-constructors"
// This macro defines a test case. The first argument is the name of
// the test case. It effectively creates a function with the name
// test_<name> and registers it with the Boost unit test framework.
BOOST_AUTO_TEST_CASE(test_greet)
{
  // BOOST_TEST is a macro that checks if the expression passed to it
  // is true. If the expression is false, the test case fails.
  // This supercedes the older BOOST_CHECK macro.
  BOOST_TEST(m42::exp::example::greet() == "Hello!");
  BOOST_TEST(m42::exp::example::greet("World") == "Hello, World!");
  BOOST_TEST(m42::exp::example::greet("Sumanth") == "Hello, Sumanth!");
}
#pragma clang diagnostic pop
