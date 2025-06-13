//-*- coding: utf-8 -*-
/**
 * @module 09-number.mjs: Explore numbers in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 09-number.mjs: Explore numbers in Javascript
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

export function exploreNumbers() {
  // Javascript has a single number type: number.
  // This type can represent both integers and floating point numbers.
  /**
   * @description n is a number. It is used to illustrate that
   * both integers and floating point numbers are represented by the
   * same type.
   * @type {number}
   * @default 1
   */
  let n = 1; // n is an integer.
  console.log(typeof n); // number
  n = 23.45  // n is a floating point number
  console.log(typeof n); // number

  // Standard mathematical operations are supported.
  /**
   * @description a is a number used to illustrate standard
   * mathematical operations.
   * @type {number}
   * @constant
   * @default 33.45
   */
  const a = n + 10; // 33.45
  console.log(a);

  /**
   * @description b is a number used to illustrate standard
   * mathematical operations.
   * @type {number}
   * @constant
   * @default 784.4025
   */
  const b = a * n; // 33.45 * 23.45 = 784.4025
  console.log(b);

  /**
   * @description c is a number used to illustrate standard
   * mathematical operations.
   * @type {number}
   * @constant
   * @default 392.20125
   */
  const c = b / 2; // 392.20125
  console.log(c);

  // Division by zero results in Infinity which is a number in
  // Javascript!
  /**
   * @description d is a number used to illustrate division by zero.
   * @type {number}
   * @constant
   * @default Infinity
   */
  const d = 1 / 0; // Infinity
  console.log(d);
  console.log(typeof d); // number - Infinity is a number in Javascript

  // Division by zero with a negative number results in -Infinity,
  // also a number in Javascript.
  /**
   * @description e is a number used to illustrate division by zero
   * @type {number}
   * @constant
   * @default -Infinity
   */
  const e = -1 / 0; // -Infinity
  console.log(e);
  console.log(typeof e); // number - -Infinity is a number in Javascript

  // Division by zero with zero results in NaN. NaN is also considered
  // a number in Javascript.
  /**
   * @description f is a number used to illustrate division by zero
   * @type {number}
   * @constant
   * @default NaN
   */
  const f = 0 / 0; // NaN
  console.log(f);
  console.log(typeof f); // number - NaN is a number in Javascript

  // NaN is not equal to anything, including itself
  console.log(f === f); // false

  // NaN is the result of an invalid operation
  // For example, the square root of a negative number
  /**
   * @description g is a number used to illustrate that an attempt
   * to perform an illegal mathematical operation results in NaN.
   * @type {number}
   * @constant
   * @default NaN
   */
  const g = Math.sqrt(-1); // NaN
  console.log(g);

  // NaN can also result in at attempt to perform some mathematical
  // operations on strings.
  /**
   * @description h is a number used to illustrate that an attempt
   * to perform a mathematical operation on a string results in NaN.
   * @type {number}
   * @constant
   * @default NaN
   */
  const h = 'hello' / 2; // NaN
  console.log(h);

  // If there is a NaN in any part of a mathematical operation, the
  // entire operation results in NaN.
  /**
   * @description i is a number used to illustrate that an NaN
   * in any part of a mathematical operation results in NaN. i.e.
   * NaN is contagious.
   * @type {number}
   * @constant
   * @default NaN
   */
  const i = 1 + ('hello' / 2); // NaN
  console.log(i);

  // This behavior of Javascript is different from Java or C++ where
  // an invalid mathematical operation, like divide by zero,
  // results in program termination.
  // In Javascript, the program continues to run with the result being
  // NaN. This is both a blessing and a curse. A blessing because the
  // program does not crash. A curse because the program continues to
  // run with an invalid data.

  // Javascript cannot safely represent numbers larger than 2^53 - 1.
  // or less than -2^53 - 1. This is because Javascript uses 64-bit
  // floating point numbers to represent numbers.

  // If you need numbers larger than that you need use 'BigInt'.
  // You can create a BigInt literal by appending 'n' to the number.
  // For example:
  /**
   * @description j is a BigInt used to illustrate how to create a
   * BigInt literal.
   * @type {bigint}
   * @constant
   * @default 1234567890123456789012345678901234567890n
   */
  const j = 1234567890123456789012345678901234567890n;
  console.log(j);
  // Note that the type of bigint is NOT 'number' but 'bigint'.
  console.log(typeof j); // bigint
  // To print a number with commas, use the toLocaleString method.
  console.log(j.toLocaleString());
  // This works for regular numbers as well.
  /**
   * @description m is a number used to illustrate the use of
   * toLocaleString.
   * @type {number}
   * @constant
   * @default 123456789
   */
  const m = 123456789
  console.log(m.toLocaleString());

  // The toLocaleString method is used to format numbers according to
  // the locale of the user. For example, in the US, the comma is used
  // as the thousands separator. In Europe, the period is used as the
  // thousands separator. The toLocaleString method takes an optional
  // argument that specifies the locale. For example:
  console.log(j.toLocaleString('en-US'));
  console.log(j.toLocaleString('de-DE'));
  console.log(j.toLocaleString('en-IN'));
  // The toLocaleString method can also be used to format currency.
  // For example:
  console.log(j.toLocaleString('en-US', {style: 'currency', currency: 'USD'}));
  console.log(j.toLocaleString('de-DE', {style: 'currency', currency: 'EUR'}));
  console.log(j.toLocaleString('en-IN', {style: 'currency', currency: 'INR'}));

  // The toFixed method is used to format a number with a fixed number
  // of decimal places. For example:
  const p = 342314245.34587
  console.log(p.toFixed(2));
  // The toFixed method rounds the number to the specified number of
  // decimal places. For example:
  console.log((1.234).toFixed(2)); // 1.23

  // You can combine the toLocaleString and toFixed methods to format
  // numbers with commas and a fixed number of decimal places. For example:
  console.log(p.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2, style: 'currency', currency: 'INR'}));

  // The normal math operators are available for numbers:
  let q = 1 + 2; // 3
  console.log(q);
  q = 1 - 2; // -1
  console.log(q);
  q = 7 * 3; // 21
  console.log(q);
  q = 10 / 2; // 5
  console.log(q);
  q = 2/3 // 0.6666666666666666 - Javascript uses floating point numbers
  console.log(q);
  q = 10 % 3; // 1
  console.log(q);
  // The exponentiation operator is also available in Javascript.
  // This represents 2 raised to the power of 3.
  q = 2 ** 3; // 8
  console.log(q);

  // The Math object provides a number of mathematical functions.
  // For example:
  console.log(Math.sqrt(9)); // 3
  console.log(Math.abs(-9)); // 9
  console.log(Math.sin(Math.PI/2)); // 1
  console.log(Math.cos(Math.PI)); // -1
  console.log(Math.tan(Math.PI/4)); // 1
  console.log(Math.log(Math.E)); // 1
  console.log(Math.log10(100)); // 2
  console.log(Math.log2(8)); // 3
  console.log(Math.pow(2, 3)); // 8 power function
  console.log(Math.floor(3.14)); // 3
  console.log(Math.ceil(3.14)); // 4
  console.log(Math.round(3.14)); // 3
  console.log(Math.round(3.5)); // 4
  console.log(Math.round(3.4)); // 3
  console.log(Math.random()); // Random number between 0 and 1
  console.log(Math.floor(Math.random() * 10)); // Random number between 0 and 9
  console.log(Math.floor(Math.random() * 10) + 1); // Random number between 1 and 10

  // The atan() method returns the arctangent of a number as a value
  // between -PI/2 and PI/2 radians. The atan2() method returns the
  // angle theta of a (x,y) point as a numeric value between
  // -PI and PI radians.
  console.log(Math.atan(1)); // 0.7853981633974483
  console.log(Math.atan2(1, 1)); // 0.785398163397448

  console.log(Math.acos(0.5)); // 1.0471975511965979
  console.log(Math.asin(0.5)); // 0.5235987755982988

  // The precedence of Javascript operators is the same as in other
  // programming languages, and for the most part is intuitive.
  // You can see the formal precedence list at:
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Operator_Precedence
  // Parentheses can be used to override the default precedence.
  // For example:
  console.log(1 + 2 * 3); // 7
  console.log((1 + 2) * 3); // 9

  // Assignment is an operator, and it has a low precedence. You use
  // feature to chain assignments together:
  let r, s, t;
  r = s = t = 0;
  console.log(r, s, t); // 0 0 0

  // Inplace modification operators provide convenient shortcuts for
  // modifying a variable. For example:
  let u = 1;
  u += 2; // u = u + 2
  console.log(u); // 3
  u -= 2; // u = u - 2
  console.log(u); // 1
  u *= 2; // u = u * 2
  console.log(u); // 2

  // Like C, C++ and Java, Javascript provides the postfix and
  // prefix increment operator: ++
  console.log(++u) // 3 Prefix increment. First increment, then use
  console.log(u++) // 3 Postfix increment. First use, then increment
  console.log(u) // 4
}

// TODO: Explore BigInt in a separate file.
