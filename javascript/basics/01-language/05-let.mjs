//-*- coding: utf-8 -*-
/**
 * @module 05-let.mjs: Exploring the let keyword
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 05-let.mjs: Exploring the let keyword.
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

// The let keyword is used to declare a lexically block-scoped variable.
// For example, this variable is only defined within this module.
/**
 * A block-scoped variable that has been initialized.
 * @type {number}
 * @default 10
 */
let x = 10;
console.log(x);
// Unlike const variables, let variables can be reassigned.
x = 20;
console.log(x);

// Let variables need not be initialized at the time of declaration.
/**
 * Another block scoped variable. This is not initialized at the time
 * of declaration.
 * @type {number}
 * @default undefined
 */
let y;

// Supress IntelliJ IDEA warning about using an uninitialized variable.
// noinspection JSUnusedAssignment
console.log(y); // undefined
y = 30;
console.log(y); // 30

// To export a variable out of the module use the export keyword.
// Note that an exported variable cannot be modified outside
// the module.
// See this blog post:
// https://2ality.com/2015/07/es6-module-exports.html#es6-modules-export-immutable-bindings
// It can however be modified inside the module.
// See languages.mjs for an example.
/**
 * Yet another block-scoped variable with initialization. This one
 * is exported out of the module.
 * @type {number}
 * @default 40
 */
export let exportedVariable = 40;

/**
 * @function modifyExportedVariable
 * @description A function that modifies the exportedVariable.
 * @param value The new value of the exportedVariable.
 */
export function modifyExportedVariable(value) {
  exportedVariable = value;
}

// Let variables are most useful within a block scope.
// For example in a for loop. The variable i is not
// accessible outside the loop.
for (let i = 0; i < 5; i++) {
    console.log(i);
}
// console.log(i); // ReferenceError: i is not defined

// Unlike var variables, within a block, let variables are NOT hoisted
// to the top of the block. This means that you cannot access a let
// variable before it is declared.
{
    // console.log(j); // ReferenceError: Cannot access 'j' before initialization
    let j = 50;
    console.log(j);
}
// j is not defined outside the block.
// console.log(j); // ReferenceError: j is not defined

/**
 * @function letExample
 * @description An example of the usage of the let keyword within a function.
 * The function demonstrates block scoping and non-hoisting.
 */
export function letExample() {
  // The variable k is scoped to this function.
  let k = 60;
  console.log(k);
  {
    // The variable l is scoped to this inner block.
    let l = 70;
    console.log(l); // 70, l is accessible here
    console.log(k); // 60, k is accessible here
  }
  // l is not defined outside the block.
  // console.log(l); // ReferenceError: l is not defined
  console.log(k); // 60, k is still accessible here

  // As before, let variables are not hoisted to the top of the block.
  // console.log(m); // ReferenceError: Cannot access 'm' before
                     // initialization
  let m = 80;
  console.log(m); // 80, m is accessible here
}
