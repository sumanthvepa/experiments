.PHONY: all clean

# -Wno-poison-system-directories: This is only relevant for cross-compiling,
# where the build system's system directories are not the same as the target's
# system directories. For this project it is not a concern, so disable this warning
# -Wno-c++98-compat-pedantic: This is a warning that is enabled by -Weverything
# and is not useful for this project as we are targeting C++20 or later.
# -Wno-unknown-pragmas: This is a warning that is enabled by -Weverything
# and is not useful for this project as it will cause the compiler to complain
# about the #pragma ide pragmas used by CLion.
CXX_FLAGS = \
  --std=c++20 \
  -Wall -Wextra --pedantic -Weverything \
  -Wno-poison-system-directories \
  -Wno-c++98-compat-pedantic \
  -Wno-unknown-pragmas \
  -g3 -O0 -I.

all: build/language

build/language: \
  basics/language.cc \
  basics/strings.cc \
  basics/strings.hh \
  basics/null_pointers.cc \
  basics/null_pointers.hh
	mkdir -p build
	g++ $(CXX_FLAGS) -o build/language \
		basics/language.cc \
		basics/strings.cc \
		basics/null_pointers.cc

clean:
	rm -fr build
