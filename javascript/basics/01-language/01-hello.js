//-*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * 01-hello.js: A program that prints  "Hello, World!".
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

// This file is the canonical 'Hello, World!' program.
// It prints 'Hello, World!' to the console.

// The use "use strict"; directive is used to enforce stricter
// parsing and error handling in your code.
//
// 'use strict'; with single quotes can also be used. But for
// stylistic reasons, I prefer double quotes for just this string.
//
// It must be the first statement in a script. (i.e. the first
// non-comment statement.)
//
// "use strict"; is a string literal. This means that it is ignored
// by Javascript engines that do not support it. This is why it is
// safe to use it in your code.
// The directive is supported in all modern browsers. It is also
// supported in Node.js.
//
// Use script is only needed for .js files. It is not needed for
// .mjs files (i.e. Javascript modules.) The latter are always in
// strict mode.
//
// Code inside a class is automatically in strict mode, even in a
// .js file.
//
// You can enable strict mode for a specific function by placing
// the directive inside the function. In this case strict mode only
// applies to the function. This is not recommended because it can
// lead to confusion.
//
// Finally, I recommend using the directive in all Javascript code.
// More details about it can be found here:
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode
"use strict";

// The console object provides access to the browser's debugging console.
// or in the case of Node.js, the terminal.
console.log('Hello, World');
