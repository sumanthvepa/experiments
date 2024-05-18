//-*- coding: utf-8 -*-
/**
  comments.swift: Explore comments in Swift
 
  This is an exploration of Swift comments This is note 1 in the series exploring swift basics
*/
/* -------------------------------------------------------------------
 * commonts.swift: Explore comments in Swift
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License a
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <https://www.gnu.org/licenses/>.
 *-----------------------------------------------------------------*/


// This a C++ style single line comment. It ends at the newline.

/* 
  This is a C style comment.
  The comment can span multiple lines.
*/

/*
  Unlike comments in C, 

  /* Swift multiline comments in Swift can be nested.*/

  // You can also nest single line comments

  This is useful if you want to comment out large blocks
  of code. You don't have to worry that the comments will
  interefer with other doc comments.
*/

/**
 This is a documentation comment that documents the function makeAComment().
 
 This function prints the string "This is a comment" to the console.
 Documentation comments can be natively viewed in Xcode with ⌥ - click on
 the symbol you want to explore.
 
 For more information see [Markup Formatting Reference](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/)
 */
func documentedWithDocComment() {
  print("This function is documented with a documentation comment")
}

/// This function is documented with a triple-slash single line documentation comment.
/// It works the same way as multi-line documentation comments, except that the comment ends at the newline.
/// Multiple triple-slash comments can combine to document a single function. But multi-line comments should be
/// preferred in this case.
func documentedWithTripleSlashComment() {
  print("This is fuction documented with a triple slash documentation comment")
}

/**
 This function takes an integer and a  double, adds them and converts the result to a string
 The purpose of this function is to demonstrate various aspects involved in documenting a
 function.
 
 Notice that the functions parameters are documented in the parameters section,
 its return value is documented in the return section and the exceptions it raises
 are documented in the throws section.
 
 You can include links in the docmentation comments much like you would with
 markup. [This is the text of a link to Google](https://www.google.com)
 
 You can reference other functions with double backticks like this: ``documentedWithDocComment()``.
 See [this Stackoverflow post](https://stackoverflow.com/questions/38321880/how-to-go-about-adding-a-link-reference-to-another-method-in-documentation-xcode)
 on this feature.
 
 You can create code blocks by leaving one blank line above and below the code block
 and indenting the code block at least 4 spaces or 1 tab from the current indent level.
 This is useful for examples.
 
     for (var n = 0; n < 10; n = n+1) {
      print("Hello, World!")
     }
 
 You can also show code blocks by enclosing them above and below
 with four backtics:
 ````
 for (var n = 0; n < 10; n = n+1 {
  print("Hello World!")
 }
 ````
 You can find more information about [code blocks in documentationn on the Apple Developer site](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/CodeBlocks.html)
 
 
 - parameters
    - param1: An integer, must be positive.
    - param2: A floating point number
 
 - returns
 A string that is the  sum of param1 and param2.
 
 - throws
 An error string "param1 is not positive if param1 is less than or equal to 0.
 */
func someFunction(param1: Int, param2: Double) -> String {
  let number: Double = Double(param1) + param2
  return "The number is \(number)"
}
