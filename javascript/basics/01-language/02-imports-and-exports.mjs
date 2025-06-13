/**
 * @file 02-imports-and-exports.mjs: Notes on using imports and exports
 * in JavaScript.
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @license GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 02-imports-and-exports.mjs: Notes on using imports and exports
 * in JavaScript.
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
 * @function defaultExportedFunction
 * @description This function is exported as the default export of
 * this module. A module can have only one default export.
 */
export default function defaultExportedFunction() {
  console.log('This is a default exported function.');
}

// Wrong.
// export default function defaultExportedFunction2() {
//   console.log("This is a default exported function.");
// }

/**
 * @function namedExportedFunction1
 * @description This function is exported as a named export of
 * this module
 */
export function namedExportedFunction1() {
  console.log('This is a named exported function 1.');
}

/**
 * @function namedExportedFunction2
 * @description A module can have multiple named exports.
 */
export function namedExportedFunction2() {
  console.log('This is a named exported function 2.');
}

/**
 * @function namedExportedFunction3
 * @description A module can have multiple named exports.
 */
export function namedExportedFunction3() {
  console.log('This is a named exported function 3.');
}

/**
 * @function namedExportedFunction4
 * @description A module can have multiple named exports.
 */
export function namedExportedFunction4() {
  console.log('This is a named exported function 4.');
}
