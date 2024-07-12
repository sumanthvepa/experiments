//-*- coding: utf-8 -*-
/**
 * @module 21-async-await.mjs: Explore promises
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 21-async-await.mjs: Explore async/await
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

export async function exploreAsyncAwait() {
  // Async/await is a way to handle asynchronous programming in
  // Javascript. It is built on top of promises. It provides a way to
  // write asynchronous code that looks synchronous. The async keyword
  // is used to define an asynchronous function. The await keyword is
  // used to wait for the return value of the function.

  // Async/Await is essentially syntactic sugar over Promises. Using
  // async in front of a function makes Javascript automatically wrap
  // the return value in a promise. Using await in front of a promise
  // makes Javascript wait for the promise to resolve before continuing
  // It is equivalent to calling .then() on the promise and passing a
  // callback function that does something with the resolved value.

  // Note that await can only be used inside an async function or at
  // the top level of a module.
  // This is why the exploreAsyncAwait function is defined as an async
  // function. An await statement is used in language.mjs to call this
  // to wait for the result of this function before continuing.

  // An async function
  /**
   * @function delayedMessage
   * @description An async function returning a message after a delay
   * @param {String} message - The message to return
   * @param {number} delay - How long to wait before returning the
   * message (in milliseconds)
   * @return {Promise<String>} A promise that resolves to the message
   * after the delay
   */
  async function delayedMessage(message, delay) {
    /**
     *
     * @type {Promise<string>}
     */
    // The function
    let promisedResult = new Promise((resolve) => {
      setTimeout(() => resolve(message), delay);
    });
    return await promisedResult;
  }

  // Call the async function and await its result.
  let message = await delayedMessage("Hello, World!", 1000);
  console.log(message);

  // Unlike promises, async/await makes it easier to handle errors.
  // You can simply throw an error in an async function and catch it
  // outside the function. This is similar to how you would handle
  // errors in synchronous code.
  /**
   * @function fakeFailure
   * @description An async function that throws an error after a delay of 1 second
   * @return {Promise<void>}
   */
  async function fakeFailure() {
    let sleepCompleted = new Promise((resolve) => {
      setTimeout(() => resolve('done'), 1000);
    });
    await sleepCompleted;
    throw new Error('Fake failure');
  }

  // Simply wrap the call to the async function in a try/catch block
  // to catch the error.
  try {
    await fakeFailure();
  } catch (error) {
    console.error(error);
  }

  // You can also of course use the .catch() method on the promise returned by
  // the async function to catch the error.
  fakeFailure().catch((error) => console.error(error));
}

// You cannot use the await keyword outside an async function except
// at the module level. In order to use an async function within a
// non-async function, simply treat the return value as a promise and
// call .then() on it.
export function exploreCallingAsyncFunctionsFromWithinNonAsyncFunctions() {
  async function delayedMessage(message, delay) {
    let promisedResult = new Promise((resolve) => {
      setTimeout(() => resolve(message), delay);
    });
    return await promisedResult;
  }

  // Use then instead of await
  delayedMessage("Hello, World!", 1000)
    .then((message) => console.log(message));
}