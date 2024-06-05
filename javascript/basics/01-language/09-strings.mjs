//-*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * 09-strings.mjs: Explore strings in Javascript
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

export function exploreStrings() {
  // Strings in Javascript can be single-quoted, double-quoted or
  // with backticks.
  /**
   * @description Single-quoted string
   * @type {string}
   * @constant
   * @default 'Hello, World!'
   */
  const s1 = 'Hello, World!';
  console.log(s1); // Hello, World!
  /**
   * @description Double-quoted string
   * @type {string}
   * @constant
   * @default 'Hello, World!'
   */
  const s2 = "Hello, World!";
  console.log(s2); // Hello, World!
  /**
   * @description Backtick string
   * @type {string}
   * @constant
   * @default 'Hello, World!'
   */
  const s3 = `Hello, World!`;
  console.log(s3); // Hello, World!

  // There isn't any difference between single-quoted and double-quoted
  // strings. They are interchangeable. The primary reason for having
  // both is to allow for the other to be used within the string.
  // For example:
  /**
   * @description s4 is a double-quoted string that contains a
   * single-quoted string.
   * @type {string}
   * @constant
   * @default "Hey!" said the mock turtle.
   */
  const s4 = '"Hey!" said the mock turtle.';
  console.log(s4); // "Hey!" said the mock turtle.
  /**
   * @description s5 is a single-quoted string that contains a
   * single-quote.
   * @type {string}
   * @constant
   * @default I'm not a tortoise!
   */
  const s5 = "I'm not a tortoise!";
  console.log(s5); // I'm not a tortoise!

  // Backtick string allow you to embed expressions within the string.
  // This is called string interpolation.
  /**
   * @description math_problem is a backtick string that contains
   * an expression that is evaluated and the result is embedded in the
   * string.
   * @type {string}
   * @constant
   * @default The length of the hypotenuse of a right triangle with sides 3 and 4 is 5
   */
  const math_problem
      = `The length of the hypotenuse of a right triangle with sides 3 and 4 is ${Math.sqrt(3 * 3 + 4 * 4)}`;
  console.log(math_problem);

  // Strings are immutable. This means that you cannot change the
  // value of a string once it is defined.
  // This will not work.
  /**
   * @description s6 is a string that is defined and then an attempt is
   * made to change the first character of the string. This will not work.
   * @type {string}
   */
  let s6 = 'Hello, World!';
  console.log(s6); // Hello, World!
  // s6[0] = 'h'; // TypeError: Cannot assign to read only property '0' of string 'Hello, World!'
  // You can only change the value of the variable that holds the string.
  s6 = 'hello, World!';
  console.log(s6); // hello, World!

  // Because strings are immutable, there is no practical difference
  // between them being a value type or a reference type. You can
  // pass a string to a function and the function can change the
  // value of the passed parameter (it cannot modify the string itself),
  // but the original will remain
  // unchanged.
  /**
   * @function changeString
   * @description changeString is a function that takes a string and
   * attempts to change it. The change will NOT be reflected in the
   * original string.
   * @param {string} s - The string to change
   */
  function changeString(s) {
    s = 'Goodbye, World!';
    console.log(s); // Goodbye, World!
  }
  changeString(s6); // Goodbye, World!
  console.log(s6); // hello, World!

  // The plus operator works on strings. It concatenates them.
  /**
   * @description s7 is a string that is the concatenation of two strings.
   * @type {string}
   * @constant
   * @default 'Hello, World!'
   */
  const s7 = 'Hello, ' + 'World!';
  console.log(s7); // Hello, World!
}