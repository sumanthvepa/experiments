.PHONY: all clean

CXX=c++

all: build/gcd

build/gcd: gcd/gcd.cc
	mkdir -p build
	$(CXX) --std=c++20 -Wall -Wextra -Wpedantic -I/opt/boost/1_84_0/include -g -o build/gcd gcd/gcd.cc

clean:
	rm -fr build
