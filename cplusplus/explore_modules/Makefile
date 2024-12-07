# -*- coding: utf-8 -*-
 #####################################################################
 # Makefile to build the explore_modules project.
 #
 # Copyright (C) 2024 Sumanth Vepa.
 #
 # This program is free software: you can redistribute it and/or
 # modify it under the terms of the GNU General Public License as
 # published by the Free Software Foundation, either version 3 of the
 # License, or (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see
 # <https://www.gnu.org/licenses/>.
 #####################################################################

.PHONEY: all ccm flags clean

# Get the name of the operating system
# The $(shell <command>) syntax is used to execute a command in the shell and
# return the output of the command. In this case, the command is `uname -s`
OS_NAME := $(shell uname -s)

ifeq ($(OS_NAME), Darwin)
  # macOS, set compiler to clang++
  CXX = clang++
else
  # Linux, set compiler to g++
  CXX = g++
endif

# The CXX_FLAGS variable contains the compiler flags that are passed to the
# compiler when building the project. The flags are different depending on the
# compiler/operator system being used

# The following are common warning flags that are used for both clang and gcc:
# -Wall: Enable most warnings
# -Wextra: Enable extra warnings
# --pedantic: Enable pedantic warnings
# -Weffc++: Enable warnings for Effective C++
COMMON_WARNINGS = -Wall -Wextra -Weffc++

# Uncomment this if you want boos add any other include directories
# you want here.
# COMMON_INCLUDES = -I/opt/boost/1_86_0/include

# The explanation of some common flags is as follows:
# -Wno-poison-system-directories: This is only relevant for cross-compiling,
# where the build system's system directories are not the same as the target's
# system directories. For this project it is not a concern, so disable this warning
# -Wno-c++98-compat-pedantic: This is a warning that is enabled by -Weverything
# and is not useful for this project as we are targeting C++23 or later.
# -Wno-unknown-pragmas: This is a warning that is enabled by -Weverything
# and is not useful for this project as it will cause the compiler to complain
# about the #pragma ide pragmas used by CLion.

ifeq ($(CXX), clang++)
  CXX_FLAGS = \
    --std=c++23 \
    $(COMMON_WARNINGS) -pedantic -Weverything \
    -Wno-poison-system-directories \
    -Wno-c++98-compat-pedantic \
    -Wno-unknown-pragmas \
    -g3 -O0 \
    -I. $(COMMON_INCLUDES)
else
  # Linux
  # Sadly, gcc does not have an equivalent to clang's -Weverything flag.
  # Instead, we have to enable individual warnings that we want to enable.
  # -Wall -Wextra -Wpedantic: Enable most warnings, but not all.
  # To literally enable all warnings, we would use -Wall -Wextra -Wpedantic -Weffc++,
  # and then enable the remaining warnings individually.
  # To see a list of all warnings, we can use the following command:
  # gcc -Q --help=warning
  # See this StackOverflow post for more information:
  # https://stackoverflow.com/questions/11714827/how-can-i-turn-on-literally-all-of-gccs-warnings
  #
  # We do not turn on -Waggregate-return as it is an anachronism for modern
  # code. The waring is tells the programmer, that a function is returning
  # a structure, class or union. This used to be a problem for some C/C++
  # compilers a very long time ago. This is no longer the case.
  # See this Stack Overflow post on the subject
 
  # Using C++ modules requires turning on the modules feature in GCC
  # This is done by specifying -fmodules-ts
  
  # By default GCC creates a module cache called gcm.cache in the
  # directory where it is run. I prefer all build artifacts to be
  # created in the build directory. This is the purpose of the
  # '-fmodule-mapper=|@g++-mapper-server -r'./build/gcm.cache
  # The option above has the effect of causing gcc to place
  # the module cache in the build directory.
  # Note the use of single quotes. This prevents interpretation
  # of the vertical bar (|)and at sign(@) by either shell or
  # the Makefile. 
  #
  # The convluted look of the option is because, GCC starts another
  # daemon process, called a mapper server that tells the compiler
  # where to find the compiled module information.
  # The | indicates to GCC that it should create a pipe to the process.
  # The @ indicates to GCC that it should look for the mapper server
  # executable in the tools directory of the compiler. On Fedora 40
  # running on ARM it is located at: 
  # /usr/libexec/gcc/aarch64-redhat-linux/14/
  #
  # The name of the mapper server follows. The one that comes with
  # the GCC distribution is called g++-mapper-server located in the
  # tools directory above.
  #
  # The -r option is passed to the mapper server and specifies the
  # location of the gcm.cache directory.
  # 
  # Note that this directory must already exist when you invoke
  # g++ with this option. The make target below first creates
  # build and build/gcm.cache before it invokes g++.
  
  # The technique to set the location of the gcm.cache directory
  # is discussed in the following two StackOverflow posts:
  # https://stackoverflow.com/questions/69549286/how-to-modify-gcm-cache-path-when-using-gcc-11-to-build-c20-modules
  # https://stackoverflow.com/questions/68451442/how-to-specify-gcm-cache-location-using-g-cmake

  CXX_FLAGS = \
    --std=c++23 \
    -fmodules-ts \
    '-fmodule-mapper=|@g++-mapper-server -r'./build/gcm.cache \
    $(COMMON_WARNINGS) -Wpedantic \
    -Walloc-zero \
    -Walloca \
    -Wanalyzer-too-complex \
    -Warith-conversion \
    -Wcast-align \
    -Wcast-align=strict \
    -Wcast-qual \
    -Wconversion \
    -Wdate-time \
    -Wdisabled-optimization \
    -Wdouble-promotion \
    -Wduplicated-branches \
    -Wduplicated-cond \
    -Wfloat-equal \
    -Wformat-nonliteral \
    -Wformat-security \
    -Wformat-signedness \
    -Wformat-y2k \
    -Winit-self \
    -Winline \
    -Winvalid-pch \
    -Wlogical-op \
    -Wmissing-declarations \
    -Wmissing-include-dirs \
    -Wmultichar \
    -Wnull-dereference \
    -Wpacked \
    -Wpadded \
    -Wredundant-decls \
    -Wshadow \
    -Wshadow=compatible-local \
    -Wshadow=local \
    -Wsign-conversion \
    -Wstack-protector \
    -Wsuggest-attribute=cold \
    -Wsuggest-attribute=const \
    -Wsuggest-attribute=format \
    -Wsuggest-attribute=malloc \
    -Wsuggest-attribute=noreturn \
    -Wsuggest-attribute=pure \
    -Wsuggest-final-methods \
    -Wsuggest-final-types \
    -Wswitch-default \
    -Wswitch-enum \
    -Wtrampolines \
    -Wundef \
    -Wunused-const-variable \
    -Wunused-macros \
    -Wvector-operation-performance \
    -Wuseless-cast \
    -Wvexing-parse \
    -Wvirtual-inheritance \
    -Wvirtual-move-assign \
    -Wvolatile \
    -Wwrite-strings \
    -Wno-unknown-pragmas \
    -g3 -O0 -I.
endif

all: build/explore_modules

ccm: build/m42.exp.explore_modules.o

build/explore_modules: explore_modules/explore_modules.cc build/m42.exp.explore_modules.o
	mkdir -p build
	mkdir -p build/gcm.cache
	$(CXX) $(CXX_FLAGS) -o build/explore_modules explore_modules/explore_modules.cc build/m42.exp.explore_modules.o

build/m42.exp.explore_modules.o: explore_modules/m42.exp.explore_modules.ccm
	mkdir -p build
	mkdir -p build/gcm.cache
	$(CXX) $(CXX_FLAGS) -x c++ -c -o build/m42.exp.explore_modules.o explore_modules/m42.exp.explore_modules.ccm

ifeq ($(CXX), g++)
flags:
	$(CXX) $(CXX_FLAGS) -Q --help=warning
endif

clean:
	rm -fr build
