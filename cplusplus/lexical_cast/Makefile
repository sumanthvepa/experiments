.PHONY: all clean

CXX=c++
CXX_FLAGS=-"-std=c++20 --wall "

all: build/lexical_cast

build/lexical_cast: lexical_cast/lexical_cast.cc
	mkdir -p build
	$(CXX) --std=c++20 -I/opt/boost/1_84_0/include -g -o build/lexical_cast lexical_cast/lexical_cast.cc

clean:
	rm -fr build
