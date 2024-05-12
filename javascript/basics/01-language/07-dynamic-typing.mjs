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
let x = 5; // type of x is number
console.log(typeof x); // number

x = 'hello'; // type of x is now string
console.log(typeof x); // string

// So the type of the variable can change at runtime.
// That's all there is to it.