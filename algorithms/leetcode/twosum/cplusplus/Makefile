.PHONEY: all clean

CXX_FLAGS = \
  --std=c++2b \
  -Wall -Wextra --pedantic -Weverything \
  -Wno-poison-system-directories \
  -Wno-c++98-compat-pedantic \
  -Wno-unknown-pragmas \
  -g3 -O0 -I.

all: twosum

twosum: twosum.cc
	g++ $(CXX_FLAGS) -o twosum twosum.cc


clean:
	rm -fr twosum twosum.dSYM
