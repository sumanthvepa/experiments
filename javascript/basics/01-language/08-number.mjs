//-*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * 08-number.mjs: Explore numbers in Javascript
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

// Javascript has a single number type: number.
// This type can represent both integers and floating point numbers.
let n = 1; // n is an integer.
console.log(typeof n); // number
n = 23.45  // n is a floating point number
console.log(typeof n); // number

// Standard mathematical operations are supported.
let a = n +10; // 33.45
console.log(a);
let b = a * n; // 33.45 * 23.45 = 784.4025
console.log(b);
let c = b / 2; // 392.20125
console.log(c);

// Division by zero results in Infinity which is a number in
// Javascript!
let d = 1 / 0; // Infinity
console.log(d);
console.log(typeof d); // number - Infinity is a number in Javascript

// Division by zero with a negative number results in -Infinity,
// also a number in Javascript.
let e = -1/0; // -Infinity
console.log(e);
console.log(typeof e); // number - -Infinity is a number in Javascript

// Division by zero with zero results in NaN. NaN is also considered
// a number in Javascript.
let f = 0 / 0; // NaN
console.log(f);
console.log(typeof f); // number - NaN is a number in Javascript

// NaN is not equal to anything, including itself
console.log(f === f); // false

// NaN is the result of an invalid operation
// For example, the square root of a negative number
let g = Math.sqrt(-1); // NaN
console.log(g);

// NaN can also result in at attempt to perform some mathematical
// operations on strings.
let h = 'hello' / 2; // NaN
console.log(h);

// If there is a NaN in any part of a mathematical operation, the
// entire operation results in NaN.
let i = 1 +  ('hello' / 2); // NaN
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
let j = 1234567890123456789012345678901234567890n;
console.log(j);
// Note that the type of bigint is NOT 'number' but 'bigint'.
console.log(typeof j); // bigint
// To print a number with commas, use the toLocaleString method.
console.log(j.toLocaleString());
// This works for regular numbers as well.
let m = 123456789
console.log(m.toLocaleString());

// TODO: Explore BigInt in a separate file.
