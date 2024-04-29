.PHONY: all clean

# -Wno-poison-system-directories: This is only relevant for cross-compiling, where the build system's system directories
# are not the same as the target's system directories.
CXX_FLAGS = --std=c++20 -Wall -Wextra --pedantic -Weverything -Wno-poison-system-directories -g3 -I.

all: build/language

build/language: basics/language.cc basics/strings.cc basics/strings.hh
	mkdir -p build
	g++ $(CXX_FLAGS) -o build/language basics/language.cc basics/strings.cc

clean:
	rm -fr build
