.PHONY: all flags clean

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

# The following are common warning flagsthat are used for both clang and gcc:
# -Wall: Enable most warnings
# -Wextra: Enable extra warnings
# --pedantic: Enable pedantic warnings
# -Weffc++: Enable warnings for Effective C++
COMMON_WARNINGS = -Wall -Wextra -Weffc++

COMMON_INCLUDES = -I/opt/boost/1_87_0/include

# The explanation of some common flags is as follows:
# -Wno-poison-system-directories: This is only relevant for cross-compiling,
# where the build system's system directories are not the same as the target's
# system directories. For this project it is not a concern, so disable this warning
# -Wno-unknown-pragmas: This is a warning that is enabled by -Weverything
# and is not useful for this project as it will cause the compiler to complain
# about the #pragma ide pragmas used by CLion.

ifeq ($(CXX), clang++)
  CXX_FLAGS = \
    --std=c++20 \
    $(COMMON_WARNINGS) -pedantic -Weverything \
    -Wno-poison-system-directories \
    -Wno-c++98-compat \
    -Wno-unknown-pragmas \
    -Wno-unknown-warning-option \
    -g3 -O0 \
    $(COMMON_INCLUDES)
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

  CXX_FLAGS = \
    --std=c++20 \
    $(COMMON_WARNINGS) -Wpedantic \
    -Waggregate-return \
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
    -g3 -O0 \
    $(COMMON_INCLUDES)
endif

all: build/lexical_cast

build/lexical_cast: lexical_cast/lexical_cast.cc
	mkdir -p build
	$(CXX) $(CXX_FLAGS) -o build/lexical_cast lexical_cast/lexical_cast.cc

# This is a convenience target that prints out the compiler warning flags
# that are supported by this version of GCC.
# are 
flags:
	gcc -Wall -Wextra -Wpedantic -Q --help=warning

clean:
	rm -fr build
