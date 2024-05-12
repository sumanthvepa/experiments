//-*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * 05-vars.mjs: Exploring the var keyword.
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

// Note on var declarations
// The var keyword is used to declare a variable that is scoped to the
// function in which it is declared. If it is declared outside a function
// it is globally scoped. (Unless it is declared in a module, in which
// case it is module-scoped.)

// Avoid using var declarations in modern Javascript code. Use let and
// const instead. The var keyword is a leftover from the early days of
// Javascript and is not recommended for modern code.


// The variable f1a is scoped to the function foo.
export function f1() {
  // Note that IntelliJ IDEA will warn you that the variable 'a' is
  // declared using var, and suggest that you replace it with let
  // or const.
  // noinspection ES6ConvertVarToLetConst
  var f1a = 10;
  console.log(f1a);
}
// console.log(f1a) // ReferenceError: f1a is not defined.


// The var keyword is hoisted to the top of the function or module in
// which it is declared. This means that the variable can be accessed
// before it is declared.
export function f2() {
  // Supress IntelliJ IDEA warning about use before initialization.
  // We're doing this on purpose for illustration.
  // noinspection JSUnusedAssignment
  console.log(f2a); // undefined. Not 10 because the initialization
                    // still takes place at the line where
                    // it is declared.
  // Supress IntelliJ IDEA recommendation to convert to let or const.
  // We're doing this on purpose for illustration.
  // noinspection ES6ConvertVarToLetConst
  var f2a = 10;
  console.log(f2a); // 10
}

// In a for loop, using var is occasionally useful, if you need to
// access the loop variable outside the loop.
export function f3() {
  let a = [1, 2, 7, 5, 12];
  // noinspection ES6ConvertVarToLetConst
  for (var i = 0; i < a.length; ++i) {
    if (a[i] === 5) break;
  }
  // You can access the variable i outside the loop.
  console.log(i); // 3 Prints the location where the value 5 was found.
}

// Of course 'i' is not available outside the function.
// console.log(i) // ReferenceError: 'i' is not defined.

// A var variable may be redeclared multiple times within a function,
// without any errors. It will be considered the same variable.
export function f4() {
  {
    // Supress IntelliJ IDEA recommendation to convert to let or const.
    // and the warning about duplicate declaration. This is done
    // on purpose for illustration.
    // noinspection ES6ConvertVarToLetConst,JSDuplicatedDeclaration
    var a = 10;
    console.log(a); // 10

    // Same reason as above to supress IntelliJ IDEA warnings.
    // noinspection ES6ConvertVarToLetConst, JSDuplicatedDeclaration
    var a ="Hello, World!"; // Not an error. Redeclaration allowed.
    console.log(a); // Hello, World!
  }
}

