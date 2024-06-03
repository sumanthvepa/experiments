//-*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * 07-dynamic-typing.mjs: Explore dynamic typing
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

// Javascript is a dynamically typed language.
// This means that the 'type' of a variable is determined at runtime.
// For example:
/**
 * @description A variable that is initially a number and then a string.
 * Notice that the type of the variable is not specified in the JSDoc
 * comment. This is because the type of the variable is determined at
 * runtime.
 */
let x = 5; // type of x is number
console.log(typeof x); // number

x = 'hello'; // type of x is now string
console.log(typeof x); // string

/**
 * @description A variable that is initially a string, then a number
 * and finally a boolean.
 *
 * But this time the range of values that the variable can take is
 * specified in the JSDoc comment. This has no effect on the runtime
 * behavior of the variable. But many tools like IntelliJ
 * IDEA IDEs can use this information to provide better code
 * completion and type checking. In particular mypy will warn when a
 * variable is assigned a value that is not in the range of types
 * specified in the JSDoc comment.
 * @type {number | string | boolean}
 */
let y = 'hello'; // type of y is string
console.log(typeof y); // string
y = 5; // type of y is now number
console.log(typeof y); // number

// Assigning a type that is not in the range of types specified in the
// JSDoc comment will not cause a runtime error. But it will cause a
// warning from IntelliJ IDEA.
y = true; // type of y is now boolean. Notice the warning from IntelliJ IDEA.
console.log(typeof y); // boolean
