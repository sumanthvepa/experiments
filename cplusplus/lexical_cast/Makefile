.PHONY: all clean

CXX=c++
# CXX_FLAGS= --std=c++20 -Wall -Wextra -pedantic -Weverything -Wno-poison-system-directories -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-double-promotion -I/opt/boost/1_84_0/include -g3
CXX_FLAGS= --std=c++20 -Wall -Wextra -pedantic -Weverything -Wno-poison-system-directories -I/opt/boost/1_84_0/include -g3

all: build/lexical_cast

build/lexical_cast: lexical_cast/lexical_cast.cc
	mkdir -p build
	$(CXX) $(CXX_FLAGS) -o build/lexical_cast lexical_cast/lexical_cast.cc

clean:
	rm -fr build
