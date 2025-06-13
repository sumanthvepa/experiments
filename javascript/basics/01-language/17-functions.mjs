//-*- coding: utf-8 -*-
/**
 * @module 17-functions.mjs: Explore functions in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 17-functions.mjs: Explore functions in Javascript
 *
 * Copyright (C) 202425 Sumanth Vepa.
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

export function exploreFunctions() {

  // In Javascript functions are described by the 'function' keyword.
  // Unlike other languages, Javascript functions are first-class objects.
  // This means that functions can be passed around as arguments to other
  // functions, returned from other functions, and assigned to variables.
  // Functions in Javascript can be defined in the following ways:
  // 1. Function declaration
  // 2. Function expression
  // 3. Arrow function
  // 4. Anonymous function
  // 5. Immediately invoked function expression (IIFE)

  // 1. Function declaration:
  // A function declaration is a function that is declared with the 'function'
  // keyword followed by the function name and a block of code enclosed in
  // curly braces. Function declarations are hoisted to the top of the
  // containing scope. This means that you can call a function before it is
  // declared.
  // Note that unlike C/C++ functions can be declared in any scope,
  // not just file scope.
  /**
   * @description A function that adds two numbers.
   * @param {number} a - The first number
   * @param {number} b - The second number
   * @returns {number} The sum of the two numbers
   */
  function add(a, b) {
    return a + b;
  }
  const sum = add(10, 20);
  console.log(`The sum of 10 and 20 is ${sum}`);

  // Functions can take a variable number of arguments. The arguments
  // object is an array-like object that contains all the arguments
  // passed to a function.
  /**
   * @description A function that adds any number of arguments.
   * @param {...number} args - The arguments to add.
   * @returns {number}
   */
  function addAny(...args) {
    return args.reduce((acc, val) => acc + val, 0);
  }

  console.log(addAny(1, 2, 3, 4, 5)); // 15

  // 2. Function expression:
  // A function expression is a function that is assigned to a variable.
  // Function expressions are not hoisted. This means that you cannot call
  // a function expression before it is declared.
  const subtract = function(a, b) {
    return a - b;
  };
  const difference = subtract(20, 10);
  console.log(`The difference between 20 and 10 is ${difference}`);

  // 3. Arrow function:
  // An arrow function is a more concise way to write a function expression.
  // Arrow functions are denoted by the '=>' symbol. Arrow functions do not
  // have their own 'this' value. Instead, they inherit the 'this' value from
  // the enclosing scope.
  const multiply = (a, b) => a * b;
  const product = multiply(10, 20);
  console.log(`The product of 10 and 20 is ${product}`);

  // 4. Anonymous function:
  // An anonymous function is a function that does not have a name. Anonymous
  // functions are typically used as callback functions or as arguments to
  // other functions.
  const divide = function(a, b) {
    return a / b;
  };

  // 5. Immediately invoked function expression (IIFE):
  // An IIFE is a function that is declared and immediately called.
  // IIFEs are typically used to create a new scope for variables.
  //  IIFEs are essentially anonymous functions that are defined and
  // immediately called.
  // There is less need for IIFEs in modern Javascript due to the
  // introduction of block-scoped variables with the 'let' and 'const'
  // keywords. But you may see them in older codebases.
  (function() {
    console.log('This is an IIFE');
  })();

  // Functions are first-class objects and can be passed to other
  // functions as arguments. For documentation purposes, you can
  // use the '@callback' tag to define the function signature of
  // the callback function.
  // See https://jsdoc.app/tags-param#:~:text=The%20%40param%20tag%20provides%20the,a%20description%20of%20the%20parameter.
  /**
   * @callback two_param_function
   * @description A function that take two numbers as arguments.
   * @param {number} a - The first number
   * @param {number} b - The second number
   * @returns {number} The result of the operation
   */
  /**
   * @description A function that takes another function as an argument.
   * @param {two_param_function} fn - The function to call.
   */
  function callFunction(fn) {
    return fn(1, 2) + 1;
  }
  console.log(callFunction(add)); // 4

  // Functions can also return other functions. This is known as a
  // higher-order function.
  /**
   * @description A higher-order function that returns a function.
   * @param {string} operation - The operation to perform.
   * @returns {two_param_function} A function that takes two numbers as arguments.
   */
  function returnFunction(operation) {
    if (operation === 'add') {
      return add;
    }
    if (operation === 'subtract') {
      return subtract;
    }
    if (operation === 'multiply') {
      return multiply;
    }
    if (operation === 'divide') {
      return divide;
    }
    // Return the null function if the operation is not recognized.
    // noinspection JSUnusedLocalSymbols
    return (a, b) => 0
  }
  const operation = returnFunction('subtract');
  console.log(operation(10, 5)); // 5

  // Functions can also have default parameters.
  /**
   * @description A function that takes a number and a default value.
   * @param {number} a - The number to add.
   * @param {number} [b=10] - The default value to add.
   * @returns {number} The sum of the two numbers.
   */
  function addDefault(a, b = 10) {
    return a + b;
  }
  console.log(addDefault(5)); // 15
  console.log(addDefault(5, 5)); // 10
  console.log(addDefault(5, 0)); // 5

  // Functions can also have rest or variadic parameters.
  /**
   * @description A function that takes any number of arguments.
   * @param {...number} args - The arguments to add.
   * @returns {number} The sum of the arguments.
   */
  function addRest(...args) {
    return args.reduce((acc, val) => acc + val, 0);
  }
  console.log(addRest(1, 2, 3, 4, 5)); // 15
  console.log(addRest(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)); // 55

  // Functions can also have named parameters.
  /**
   * @description A function that takes named parameters.
   * @param {number} a - The first number.
   * @param {number} b - The second number.
   * @returns {number} The sum of the two numbers.
   */
  function addNamed({ a, b }) {
    return a + b;
  }
  console.log(addNamed({ a: 1, b: 2 })); // 3

  // Functions can also have a 'this' context.
  /**
   * @description A function that uses the 'this' context.
   * @returns {number} The value of 'this'.
   */
  function thisFunction() {
    return this.value;
  }
  const obj = { value: 42 };
  console.log(thisFunction.call(obj)); // 42
  console.log(thisFunction.apply(obj)); // 42
  const boundFunction = thisFunction.bind(obj);
  console.log(boundFunction()); // 42

  // The 'this' keyword is a reference to the object that the function is
  // called on. The value of this is determined by how the function is
  // called. The value of this can be set using the call, apply, or bind
  // methods. It is extensively used to in the definition of classes and
  // objects in Javascript. The use of the 'this' keyword and new keyword
  // is discussed in 17-classes-and-objects.mjs.

  //  An arrow function is a shorthand way to write a function expression.
  // E.g.
  const add2 = function(a, b) {
     return a + b;
  };
  console.log(`add2(1, 3) = ${add2(1, 3)}`);

  // can be written as:
  const add3 = (a, b) => a + b;
  console.log(`add3(1, 3) = ${add3(1, 3)}`);

  // An Arrow function does not have its own 'this' value. Instead, it
  // inherits the 'this' value from the enclosing scope. This is useful
  // when you want to use the 'this' value from the enclosing scope.
  // This will be explore in more detail in 17-classes-and-objects.mjs.
}