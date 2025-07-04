//-*- coding: utf-8 -*-
/**
 * @module 04-const.mjs: Explore the const keyword
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 04-const.mjs: Explore the const keyword.
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

// Constants are declared as follows.
// The const keyword makes the identifier a constant that is
// lexically scoped to the block, statement or expression within
// which it occurs.
/**
 * The number of days in a week.
 *
 * @constant DAYS_PER_WEEK
 * @type {number}
 * @default 7
 */
const DAYS_PER_WEEK = 7;

// A Note on the export keyword:
// For language.mjs to be able to use the identifier, we export
// it as a default export. (You can also export it as a non-default
// export, but for were are using a default export for the purposes of
// exposition.)
// See this StackOverflow post
// https://stackoverflow.com/questions/36261225/why-is-export-default-const-invalid
// on why the following is not valid.
// export default const DAYS_PER_WEEK = 7;
//
// Essentially this is because const declares a variable to be lexically
// scoped. For a variable declared the file level of a module file, the
// scope is the module. The variable does not exist outside that scope.
// The default keyword on the other hand expects to receive a
// hoist-able declaration, Class declaration or an AssignmentExpression.
// So you can do this:
// export default DAYS_PER_WEEK = 7;  // DAYS_PER_WEEK = 7 is an assignment
//                                    // expression.
// In the case above DAYS_PER_WEEK will not be constant.
//
// Exports and imports are described in more detail in the
// 04-imports-and-exports.mjs
export default DAYS_PER_WEEK;

// Note that this declares a constant reference. I.e. the
// DAYS_PER_WEEK label is always assigned to the value object 7.
// This is fine for primitive objects like numbers, and strings,
// which are inherently constant.
// But it does not work for non-primitive objects like arrays
// For example: (Ignore the 'export' keyword for now. It is
// explained in 03-imports-and-exports.mjs)
/**
 * A list of approved holidays.
 *
 * @constant HOLIDAYS
 * @type {Array<string>}
 * @default ['New Year', 'Independence Day']
 */
export const HOLIDAYS = ['New Year', 'Independence Day'];
console.log(HOLIDAYS);

// You cannot do this
// HOLIDAYS = ['Kwanzaa', 'Christmas'];

// But you can do this:
HOLIDAYS.splice(
  HOLIDAYS.indexOf('New Year'), 1); // Remove 'New Year' from the array.
HOLIDAYS.splice(
  HOLIDAYS.indexOf('Independence Day'), 1); // RemoveIndependence Day
                                           // from the array.
// Add 'Kwanzaa' and 'Christmas'
HOLIDAYS.push('Kwanzaa');
HOLIDAYS.push('Christmas');
console.log(HOLIDAYS); // HOLIDAYS is now ['Kwanzaa', 'Christmas']
// So the reference is a constant, but not the object it refers to.

