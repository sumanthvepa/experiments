//-*- coding: utf-8 -*-
/**
 * @module 20-callbacks.mjs: Learn about callback style programming
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 20-callbacks.mjs: Learn about callback style programming
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

export function exploreCallbacks() {
  // Callbacks are a way to handle asynchronous programming in
  // Javascript. They are functions that are passed as arguments to
  // other functions. The function that receives the callback function
  // is responsible for calling the callback function when it's done
  // with its work.

  // Note this JSdoc comment describes the signature of the callback
  // function that the doSomething functions take as an argument.
  // See https://stackoverflow.com/questions/24214962/whats-the-proper-way-to-document-callbacks-with-jsdoc
  /**
   * @callback CallbackWithCallerName
   * @description A callback function that takes a string as an argument
   * @param {string} caller - The caller of the callback function
   */

  /**
   * @function doSomething
   * @description A function that takes a callback function as an argument
   * @param {CallbackWithCallerName} callback - A callback function
   */
  function doSomething(callback) {
    console.log("Doing something");
    callback("doSomething");
  }

  // A callback function
  /**
   * @function callback
   * @description A callback function
   * @param {string} caller - The caller of the callback function
   */
  function callback(caller) {
    console.log(`Callback called by ${caller}`);
  }

  // Call the doSomething function with the callback function
  doSomething(callback);

  // If you need to chain multiple asynchronous operations, you can
  // call the next operation in the callback function.
  /**
   * @function doSomethingElse
   * @description Another function that takes a callback function as
   * an argument
   * @param {CallbackWithCallerName} callback - A callback function
   */
  function doSomethingElse(callback) {
    console.log("Doing something else");
    callback("doSomethingElse");
  }


  /**
   * @function callback2
   * @description A second callback function. This calls doSomething
   * with the first callback function.
   * @param {string} caller - The caller of the callback function
   */
  function callback2(caller) {
    console.log(`Callback2 called by ${caller}`);
    doSomething(callback)
  }

  // Call the doSomethingElse function with the second callback
  // function. This chain of operations will call the second callback
  // function, which in turn will call the first callback function
  doSomethingElse(callback2);

  // Callback style programming is typically done by passing anonymous
  // functions as callbacks. This is a common pattern in Javascript.
  // The above example can be rewritten using anonymous functions.
  console.log('Callback style programming with anonymous functions');
  doSomething((caller) => {
    console.log(`First anonymous callback called by ${caller}`);
    doSomethingElse((caller) => {
      console.log(`Second anonymous called by ${caller}`);
    });
  });
}