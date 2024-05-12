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
  const s1 = 'Hello, World!';
  console.log(s1); // Hello, World!
  const s2 = "Hello, World!";
  console.log(s2); // Hello, World!
  const s3 = `Hello, World!`;
  console.log(s3); // Hello, World!

  // There isn't any difference between single-quoted and double-quoted
  // strings. They are interchangeable. The primary reason for having
  // both is to allow for the other to be used within the string.
  // For example:
  const s4 = '"Hey!" said the mock turtle.';
  console.log(s4); // "Hey!" said the mock turtle.
  const s5 = "I'm not a tortoise!";
  console.log(s5); // I'm not a tortoise!

  // Backtick string allow you to embed expressions within the string.
  // This is called string interpolation.
  const math_problem
      = `The length of the hypotenuse of a right triangle with sides 3 and 4 is ${Math.sqrt(3 * 3 + 4 * 4)}`;
  console.log(math_problem);

  // Strings are immutable. This means that you cannot change the
  // value of a string once it is defined.
  // This will not work.
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
  function changeString(s) {
    s = 'Goodbye, World!';
    console.log(s); // Goodbye, World!
  }
  changeString(s6); // Goodbye, World!
  console.log(s6); // hello, World!
}