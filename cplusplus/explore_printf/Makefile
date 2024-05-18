.PHONY: all clean

CXX=c++
CXX_FLAGS=-"-std=c++20 -wall "

all: explore_printf

explore_printf: explore_printf.cc
	$(CXX) --std=c++20 -Wall -Wextra --pedantic -g3 -o explore_printf explore_printf.cc

clean:
	rm -fr explore_printf explore_printf.dSYM
