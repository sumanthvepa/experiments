//-*- coding: utf-8 -*-
/**
 * @file 07-implicit-globals.js: Exploring implicit globals
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 07-implicit-globals.js: Exploring implicit globals.
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
 * @function f1
 * @description A function that creates an implicit global variable.
 * A variable created without the var keyword is an implicit global
 * variable. You can access this value from language.mjs without
 * an import. This is definitely not recommended.
 */
function f1() {
  // noinspection JSUndeclaredVariable
  /**
   * @description An implicit global variable.
   * @type {string}
   * @global
   * @default 'This is an implicit global'
   */
  anImplicitGlobal = 'This is an implicit global'; // eslint-disable-line no-undef
}
f1(); // Call f1 to bring anImplicitGlobal into existence.
// eslint-disable-next-line no-undef
console.log(anImplicitGlobal); // Available outside function scope.
                               // Also see language.mjs.
