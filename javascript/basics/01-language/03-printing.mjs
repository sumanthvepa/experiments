//-*- coding: utf-8 -*-
/**
 * @module 03-printing.mjs: Explore output to the console in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 03-printing.mjs: Explore output to the console in Javascript.
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

/**
 * @function explorePrinting
 * @description Explore output to the console in Javascript
 */
export function explorePrinting() {
  // Printing in Javascript is done using the console object.
  // The console object is a global object that is available in all
  // Javascript environments. The console object has a number of
  // methods that can be used to print to the console.
  // The most common method is the log method. The log method is
  // used to print to the console.
  console.log('This message printed to the console using the log method.');

  // You can pass multiple strings to the log method. The arguments
  // are printed to the console separated by a space.
  console.log('first', 'second', 'third', 'fourth');

  // You can also pass multiple objects to the log method. The objects
  // are printed to the console separated by a space.
  console.log('first', 2, 3.0, 4);
  console.log({a: 1, b: 2}, 5, 6.0);

  // If the first argument to the log method is a string that contains
  // format specifiers, the remaining arguments are used to replace
  // the format specifiers in the string.
  // The format specifiers recognized are %d, %f, %s %o and %c
  // %d and %i are used to print integers.
  // %f is used to print floating point numbers.
  // %s is used to print strings.
  // %o is used to print objects.
  console.log('the numbers are: %d, %f, %d', 2, 3.26, 4);

  // The %c format specifier is used to apply CSS styles to the output.
  // The second argument to the log method is a CSS style string.
  // This only works in the browser console, not in the Node.js console.
  console.log('%cThis is a styled message', 'color: red; font-size: 20px');

  // The %o format specifier is used to print objects. The object is
  // printed as a string.
  console.log('The object %o is not null.', {a: 1, b: 2});

  // Although the format specifier looks like it conforms to the rules
  // of C printf, that is not the case. For example '%.2f' does not
  // work as expected. In other words the '%.2f' is not recognized as
  // a format specifier. It is just treated as a string.
  console.log('%.2f', 3.14159); // prints %.2f 3.14159 in the console.

  // A more useful way to format output is to use a combination of
  // template literals, number .toFixed method, and string .padStart
  // methods. This is more flexible then format specifiers.
  // see 09-strings.mjs for more information on template literals
  // and how to use them for formatting.

  // To print to stderr, use the console.error method or the console.warn
  // warn method.
  console.error('This message printed to the console using the error method.');
  console.warn('This message printed to the console using the warn method.');

  // You can also call the info message for informational messages. It
  console.info('This message printed to the console using the info method.');

  // On Node.js, error and worn messages are printed to stderr. Info and log messages
  // are printed to stdout.

  // However, in the browser, the error messages are printed to the console in red.
  // while the warn messages are printed in yellow. Info messages are printed with
  // a blue 'i' icon. Log messages are printed with in black and white.

  // User error, warn and info to report status of the program. Use log for debugging
  // information and for general output.
}
