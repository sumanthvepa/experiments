#!/bin/bash

# Bash provides a way to extract a substring from a string.
# The syntax for doing this is 
# ${VARIABLE:starting_index:length} where VARIABLE is the
# variable from whch you want to extract the substring. 
# starting_index is the index of the start of the substring.
# length is the number of characters you want.
STRING_VAR="Hello, World!"
echo "\$STRING_VAR: $STRING_VAR"
# If you want just the 'Hello' part, i.e the first 5 characters, you can do this:
HELLO=${STRING_VAR:0:5}
echo "\$HELLO: $HELLO"

# If you are dealing with an array of strings, you can extract a substring from each element in the array.
# Here is an example:
STRING_ARRAY=("Hello, World!" "Goodbye, World!")
HELLO=${STRING_ARRAY[0]:0:5}
GOODBYE=${STRING_ARRAY[1]:0:7}
echo "\$HELLO: $HELLO"
echo "\$GOODBYE: $GOODBYE"

# One intresting consequensce is that you can use this to extract
# a substring from a positional parameter:
EXPLORE=${0:2:7}
echo "\$EXPLORE: $EXPLORE"
