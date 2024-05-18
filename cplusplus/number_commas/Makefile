.PHONY: all clean

all: build/number_commas

build/number_commas: number_commas/number_commas.cc
	mkdir -p build
	g++ --std=c++20 -Wall -Wextra --pedantic -g3 -o build/number_commas number_commas/number_commas.cc

clean:
	rm -fr build
