.PHONY: all clean

CXX=c++

# The -no- options are to suppress warnings that are not useful for
# this project. This # an explanation of the options:

# -Wno-poison-system-directories is to suppress warnings about using
#  system directories. This is suppressed because using system
#  directories is only a problem if you are cross-compiling code for
#  another system. We are not doing that so, we're good here.
CXX_FLAGS= \
  --std=c++20 \
  -Wall -Wextra -pedantic -Weverything \
  -Wno-poison-system-directories \
  -Wno-c++98-compat \
  -Wno-c++98-compat-pedantic \
  -I/opt/boost/1_86_0/include \
  -g3

all: build/palindrome

build/palindrome: palindrome/palindrome.cc
	mkdir -p build
	$(CXX) $(CXX_FLAGS) -o build/palidrome palindrome/palindrome.cc

clean:
	rm -fr build
