#!/usr/bin/swift
/*-------------------------------------------------------------------
  shebang.swift: Notes on the use of the '#!' notation for scripting
-------------------------------------------------------------------*/

/*
  Swift allows a swift program to start with a #! to
  allow for the program to be run as Unix bash script.
  #! must be the first two characters in the file. 
  This is how the Unix shell determines that a program
  is a script. Swift will ignore that first line.

  #! is not allowed anywhere else.

  It will also have no effect on compiled programs
*/

print("shebang.swift")
