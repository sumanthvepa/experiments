//-*- coding: utf-8 -*-
/**
 *
 * @module 00-comments.mjs: Explore comments in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @license GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 00-comments.mjs: Explore comments in Javascript.
 *
 * Copyright (C) 2024-25 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
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
 -------------------------------------------------------------------*/

// Javascript comments are very similar to C/C++ and Java comments.
// This is a single line comment. It starts with two forward slashes, and ends with a newline token.
/*
 This is a multi-line comment.
 Multiline comments start with a forward slash and an asterisk,
 and end with an asterisk and a forward slash.
 Unlike Swift They do not nest.
 */

// Note on JSDoc comments and type annotations:
// JSDoc comments are used to provide type information about your code
// they are used by various tools to analyze your code. In particular,
// they are used by the JSDoc tool to generate documentation for your
// code. Additionally, IDEs like IntelliJ IDEA, and Visual Studio Code
// will use JSDoc annotations to provide code completion and type
// checking.

// Because JSDoc comments are comments, they are ignored by the
// Javascript engine. This means that you can use them in your code
// without any fear of breaking it.

// JSDoc comments are always enclosed in a block comment. The block
// comment is always opened with a slash and two asterisks and
// closed with an asterisk and a slash. The block comment is always
// at the beginning of the line.

// JSDoc comments can be used to embed type information about the
// code. This is done because, Javascript itself has no built-in
// static type checking.
// See the following link for more information on JSDoc comments:
// https://jsdoc.app/

// There is a proposal to add type annotations to Javascript. This is
// different from JSDoc comments. You can see the proposal here:
// https://github.com/tc39/proposal-type-annotations/

// For the most part for Javascript, those who want type checking
// use TypeScript, which is a superset of Javascript that adds
// static type checking. TypeScript is a separate language from
// Javascript, but it compiles down to Javascript. I won't be covering
// it in this exploration.
/**
 * This is aJSDoc comment. JSDoc comments are used to provide type
 * information about your code. They are not strictly speaking a
 * part of the Javascript language. They are used by various tools
 * to analyze your code. In particular, they are used by the JSDoc
 * tool to generate documentation for your code. Additionally, IDEs
 * like IntelliJ IDEA, and Visual Studio Code will use JSDoc
 * comments.
 *
 * You will see JSDoc comments in all the explorations, you can
 * get more information on how to use JSDoc here:
 * https://jsdoc.app/
 */

/**
 * @function exploreComments()
 * @description A dummy function to allow the 00-comments.mjs
 * module to be imported and executed.
 * It is intended to be imported and called from the language.mjs
 * This is done for consistency with how other modules are
 * imported and executed.
 */
export function exploreComments() {
  // Just a dummy function.
}


// JSDoc is a whole topic in itself. I will cover it in much more
// detail below, but I'll have to do it in increments, because it is
// a very large topic. For now, I'll just dump a bunch of links
// I find useful here:
// This is the canonical documentation for JSDoc: https://jsdoc.app/
// This is the JSDoc cheatsheet: https://devhints.io/jsdoc
// This is the JSDoc documentation for type annotations:
// https://jsdoc.app/tags-type.html
// This is the JSDoc documentation for type definitions:
// https://jsdoc.app/tags-typedef.html
// This stackoverflow question has a good discussion on how to
// describe object arguments in JSDoc:
// https://stackoverflow.com/questions/6460604/how-to-describe-object-arguments-in-jsdoc