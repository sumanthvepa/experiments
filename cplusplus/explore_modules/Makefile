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

# This is where all compiled binarys and intermediate artifacts will
# be placed
BUILD_ROOT = build

# Get the name of the operating system
# We need this because the build process is different on different OSes.
# For now this Makefile supports compilation on Linux and macOS.

# The $(shell <command>) syntax is used to execute a command in the shell and
# return the output of the command. In this case, the command is `uname -s`
OS_NAME := $(shell uname -s)

ifeq ($(OS_NAME), Darwin)
  # macOS, set compiler to clang++
  # We define two variables CXX_TYPE and CXX.
  # CXX_TYPE refers to the family the compiler belongs to.
  # On macOS the compiler family is usally clang++.
  # The CXX flag is the name of the actual C++ compiler binary.
  # Usually this is also clang++ -- the default C++ compiler
  # provided by Xcode. But on occassion, in might be necessary
  # to use a different compiler toolchain. Such as in this instnace.
  # Here we are using the clang version 19 provided by macports.
  # This is done becuase the default clang++ that comes with Apple
  # does not support C++modules (as of Xcode 16)
  # In general, the CXX variable can refer to any compiler toolchain
  # in the same family. A different version of clang for example.
  CXX_TYPE = clang++
  CXX = clang++-mp-19
else
  # Linux, set compiler to g++
  # We go with the default g++ installation. On the Linux versions
  # that I use, the default g++ supports C++ modules.
  CXX_TYPE = g++
  CXX = g++
endif

# The CXX_FLAGS variable contains the compiler flags that are passed to the
# compiler when building the project. The flags are different depending on the
# compiler family and operating system being used.

# The following are common warning flags that are used for both clang and gcc:
# -Wall: Enable most warnings
# -Wextra: Enable extra warnings
# --pedantic: Enable pedantic warnings
# -Weffc++: Enable warnings for Effective C++
COMMON_WARNINGS = -Wall -Wextra -Weffc++

# Uncomment this if you want boost. Add any other include directories
# you want here.
# COMMON_INCLUDES = -I/opt/boost/1_87_0/include

# The explanation of some common flags is as follows:
# -Wno-poison-system-directories: This is only relevant for cross-compiling,
# where the build system's system directories are not the same as the target's
# system directories. For this project it is not a concern, so disable this warning
# -Wno-c++98-compat-pedantic: This is a warning that is enabled by -Weverything
# and is not useful for this project as we are targeting C++23 or later.
# -Wno-unknown-pragmas: This is a warning that is enabled by -Weverything
# and is not useful for this project as it will cause the compiler to complain
# about the #pragma ide pragmas used by CLion.

ifeq ($(CXX_TYPE), clang++)
  CXX_FLAGS = \
    --std=c++23 \
    $(COMMON_WARNINGS) -pedantic -Weverything \
    -Wno-poison-system-directories \
    -Wno-c++98-compat-pedantic \
    -Wno-unknown-pragmas \
    -g3 -O0 \
    -fprebuilt-module-path=$(BUILD_ROOT) \
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
  # The module mapper is documented at:
  # https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Module-Mapper.html
  # The design and rationale for module mapper is described by
  # Nathan Sidwell at:
  # https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1184r2.pdf
  # It appears that the module mapper is based on libcody:
  # https://github.com/urnathan/libcody

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

# The build commands for each compiler family are different, and
# the intermediate outputs have different names. We construct
# build commands and suffixes based on which compiler family
# is being used. Doing this allows the make rules themselves to
# be compiler family agnostic. i.e. the same build rule will
# work with both clang++ and g++.
ifeq ($(CXX_TYPE), clang++)
  # We need to create build root directory if it does not exist
  CREATE_BUILD_ROOT_CMD = mkdir -p $(BUILD_ROOT)

  # In addition to all the normal C++ flags, the module build
  # command also requires that --precompile be specified.
  # -x c++-module tells the compiler to treat the source file
  # as a C++ module. Usually, clang++ family compilers will
  # use the suffix to determine if the file is a module. And
  # .ccm is recoginzed as a C++ module file suffix
  # But we prefer not to depend on such things, and explicity
  # specify that the input source will be a C++ module.
  MODULE_BUILD_CMD = $(CXX) $(CXX_FLAGS)  -x c++-module --precompile

  # There are no clang++ specific flags to generate executable
  EXECUTABLE_BUILD_CMD = $(CXX) $(CXX_FLAGS) 

  # The suffix that clang expects for compiled modules is
  # .pcm
  COMPILED_MODULE_SUFFIX = .pcm
else
  # In addition to creating the build root directory, g++
  # requires that the module cache directory also be created
  # We combine both operations into a single one by placing
  # gcm.cache within the build root and using mkdir -p.
  CREATE_BUILD_ROOT_CMD = mkdir -p $(BUILD_ROOT)/gcm.cache

  # g++, does not need to be told that a file is a C++ module
  # but it won't recognize .ccm files as being C++ files.
  # We need to explicitly tell the compiler to treat .ccm
  # files as C++ source code. Hence the -x c++.
  # The -c flag is the standard flag to compile object
  # files. It works for modules as well.
  MODULE_BUILD_CMD = $(CXX) $(CXX_FLAGS) -x c++ -c 

  # Strictly speaking since I a .cc suffix non-module C++
  # source, and g++ recognizes, .cc files as C++ source
  # code, there is no need to explicitly specify the
  # source as being C++. However, as a matter of policy
  # we want to be explicit about the type code being
  # processed, so we would want to ad -x c++ here as well.
  # But it seems to cause g++ to crash. So I'm just
  # commenting out this command line below and using
  # one without the -x c++
  #EXECUTABLE_BUILD_CMD = $(CXX) $(CXX_FLAGS) -x c++
  EXECUTABLE_BUILD_CMD = $(CXX) $(CXX_FLAGS)

  # G++ makes no distinction between compiled modules
  # and object files. Both use the same suffix
  COMPILED_MODULE_SUFFIX = .o
endif

# Build Rules
# Note that, for now, dependencies are explicitly managed in the 
# Makefile. This probably won't work for a large project with many
# hundreds of dependencies.
all: build/explore_modules
ccm: $(BUILD_ROOT)/m42.exp.explore_modules$(COMPILED_MODULE_SUFFIX)

$(BUILD_ROOT)/explore_modules: \
  explore_modules/explore_modules.cc \
  $(BUILD_ROOT)/m42.exp.explore_modules$(COMPILED_MODULE_SUFFIX)
	$(CREATE_BUILD_ROOT_CMD)
	$(EXECUTABLE_BUILD_CMD) -o $(BUILD_ROOT)/explore_modules explore_modules/explore_modules.cc $(BUILD_ROOT)/m42.exp.explore_modules$(COMPILED_MODULE_SUFFIX)

$(BUILD_ROOT)/m42.exp.explore_modules$(COMPILED_MODULE_SUFFIX): \
  explore_modules/m42.exp.explore_modules.ccm
	$(CREATE_BUILD_ROOT_CMD)
	$(MODULE_BUILD_CMD) -o $(BUILD_ROOT)/m42.exp.explore_modules$(COMPILED_MODULE_SUFFIX) explore_modules/m42.exp.explore_modules.ccm



ifeq ($(CXX_TYPE), g++)
flags:
	$(CXX) $(CXX_FLAGS) -Q --help=warning
endif

clean:
	rm -fr build
