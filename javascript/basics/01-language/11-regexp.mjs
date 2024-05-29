//-*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * 11-regexp.mjs: Explore regular expressions in Javascript
 *
 * Copyright (C) 2024 Sumanth Vepa.
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

/**
 * @function exploreRegexps
 * @description Explore regular expressions in Javascript
 */
export function exploreRegexps() {
  // A regular expression is a sequence of characters that forms a
  // search pattern. You can declare a regular expression using the
  // RegExp constructor or using a regular expression literal.
  /**
   * @description re1 is a regular expression created using the
   * RegExp constructor. It matches any string that starts with
   * '/api/'.
   * @type {RegExp}
   * @constant
   * @default /\/api\/.+/
   */
  const re1 = new RegExp('/api/.+');

  // You can use the test method of the RegExp object to test if a
  // string matches the regular expression.
  console.log(re1);
  console.log(re1.test('/api/users')); // true
  console.log(re1.test('/users')); // false
  console.log(re1.test('/api/')); // false

  // re2 is declared using a regular expression literal.
  // Note the use of \ to escape the / character.
  /**
   * @description re2 is a regular expression created using a
   * regular expression literal. It matches any string that starts
   * with '/api/'.
   * @type {RegExp}
   * @constant
   * @default /\/api\/.+/
   */
  const re2 = /\/api\/.+/;
  console.log(re2);
  console.log(re2.test('/api/users')); // true
  console.log(re1.test('/users')); // false
  console.log(re1.test('/api/')); // false

  // Javascript regular expressions are objects. When you compare
  // two regular expressions using the == operator, you are comparing
  // the object references. Since you are comparing two different
  // objects, the result is false. To compare the regular expressions
  // themselves, you can convert them to strings using the String
  // constructor and compare the strings.

  // Note the type coercion warning. == converts to a number and then
  // does the comparison. Note the use of an IntelliJ idea inspection
  // suppression comment that suppresses the warning.
  // noinspection EqualityComparisonWithCoercionJS
  console.log(re1 == re2); // false.

  // You can use regular expressions to replace parts of
  // of a string that match a regular expression
  // In this example, which is used in 10-template-server,
  // the objective is to strip the leading / from URL.
  const url = '/page/';
  const strippedUrl = url.replace(/^\//,'');
  console.log(`Removing the leading / from ${url} results in ${strippedUrl}`);

  // This is the proper way to check if two regular expressions are the
  // same.
  console.log(String(re1) === String(re2)); // true
}
