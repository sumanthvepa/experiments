.PHONEY: all clean

all: nestedgenerics opaque-collections

nestedgenerics: nestedgenerics.swift
	swiftc nestedgenerics.swift

opaque-collections: opaque-collections.swift
	swiftc opaque-collections.swift

# This will cause the compiler to crash
# So it is not included as a target in all
bug: bug.swift
	swiftc bug.swift

clean:
	rm -f nestedgenerics opaque-collections bug
