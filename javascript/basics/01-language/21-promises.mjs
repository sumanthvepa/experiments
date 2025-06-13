//-*- coding: utf-8 -*-
/**
 * @module 21-promises.mjs: Explore promises
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 21-promises.mjs: Explore promises
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

import * as fs from "node:fs";

export function explorePromises() {
  // Promises are a way to handle asynchronous programming in
  // Javascript. They are objects that represent the eventual
  // completion of an asynchronous operation. Promises have three
  // states: pending, fulfilled, and rejected. Promises are created
  // using the new Promise() constructor. The Promise constructor
  // takes a function as an argument. The function takes two
  // arguments: resolve and reject. The resolve function is called
  // when the asynchronous operation is successful. The reject
  // function is called when the asynchronous operation fails.

  // Promise objects have a then() method that is called when the
  // promise is fulfilled. The then() method takes two arguments:
  // onFulfilled and onRejected. The onFulfilled function is called
  // when the promise is fulfilled. The onRejected function is called
  // when the promise is rejected. The then() method returns a new
  // promise object. This allows chaining of promises.

  // The following example demonstrates the use of promises.
  // The example creates a promise object that resolves after 2
  // seconds. The onFulfilled function logs a message to the console
  // when the promise is fulfilled.
  /**
   * @type {Promise<string>} promise
   * @description A promise object that resolves with a string 'Promise resolved' after 5 seconds.
   */
  const promise = new Promise((resolve) => {
    setTimeout(() => {
      resolve("Promise resolved");
    }, 5000);
  });

  // The then() method is called on the promise when the promise is
  // either fulfilled or rejected. The then() method takes two arguments:
  // onFulfilled and onRejected. The onFulfilled function is called when
  // the promise is fulfilled. The onRejected function is called when the
  // promise is rejected. The then() method returns a new promise object.
  // In this example we print the message received on fulfillment of the
  // promise to the console. There is no onRejected function in this example.
  // Furthermore, we ignore the return value of the then() method since
  // we not doing anything further with the return value.
  promise.then((message) => {
    console.log(message);
  });

  // In the previous example, the onFulfilled function logs a message to
  // the console when the promise is fulfilled. The onRejected function is
  // not used and is not specified as an argument to callback passed
  // to the Promise constructor. Consequently the then() method is also
  // not passed an onRejected function.
  // This is okay for this example since the promise is resolved and not
  // rejected. However, when you need to handle failure you will need
  // the callback to the promise to take a reject function as an
  // argument. And the then() method will need to take an onRejected
  // function as an argument as well.

  // The following example reads a file asynchronously using the fs
  // module. The example creates a promise object that resolves when
  // the file is read successfully. The onFulfilled function logs the
  // contents of the file to the console when the promise is fulfilled.
  // The onRejected function logs an error message to the console when
  // the promise is rejected.

  // Note that I would not use this code in a real project. fs already
  // provides a promise-based API. This is just an example to demonstrate
  // how to wrap a callback-based API in a promise.

  /**
   * @callback ReadFileCallback
   * @description The callback function passed to fs.readFile.
   * @param {Buffer} data - The data read from the file.
   * @param {NodeJS.ErrnoException | null } error - An error object if an error occurred.
   */
  /**
   * @type {Promise<Buffer>}
   * @description A promise object that resolves with the data read from the file.
   */
  let rfp = new Promise((resolve, reject) => {
    fs.readFile('promise-data.txt', (error, data) => {
      if (error) {
        reject(error);
      } else {
        resolve(data);
      }
    });
  });
  rfp.then(
      (data) => {
        console.log(data.toString());
      },
      (error) => {
        console.error(error);
      });

  // Notice that the sequence of the code is not the same as the sequence
  // of the output. The previous promise example will be resolved only
  // after 5 seconds. The promise that reads the file will be resolved
  // when the file is read. Usually, the file read promise will be resolved
  // before the 5-second promise. But the order of resolution is not
  // guaranteed. The order of the output will be the order in which the
  // promises are resolved.

  // Chaining Promises

  // Promises can be chained. The then() method returns a new promise
  // object. This allows chaining of promises. The following example
  // demonstrates chaining of promises.
  // The following example reads two file one after the other.

  // Read the first file asynchronously
  /**
   * @ description A promise object that resolves with data read from the file 'promise-data.txt'.
   * @type {Promise<Buffer>}
   */
  let readFile1Promise = new Promise(
      (resolve, reject) => {
    fs.readFile('promise-data.txt',
        (error, data) => {
      if (error) { reject(error); }
      else { resolve(data); }
    });
  });

  // Then (in the then callback) print the data read from the first
  // file and read the second file asynchronously
  /**
   * @type {Promise<Buffer>}
   * @description A promise object that resolves with data read from the file 'promise-data2.txt'.
   */
  let readFile2Promise = readFile1Promise.then(
    (data) => {
      console.log(data.toString());
      return new Promise(
        (resolve, reject) => {
          fs.readFile('promise-data2.txt',
            (error, data) => {
              if (error) { reject(error); }
              else { resolve(data); }
            });
        });
    },
    (error) => { console.error(error);}
  );

  // Then (in the then clause for the second promise) print the data
  // read from the second file.
  readFile2Promise.then(
    (data) => {
      console.log(data.toString());
    },
    (error) => { console.error(error); }
  );

  // You can also read the two files in parallel. The following example
  // demonstrates reading two files in parallel. Notice that in this
  // example, the two promises are created one after another immediately,
  // rather than the second promise being created in the then() method of the first
  // promise.

  // Read the first file asynchronously
  /**
   * @description A promise object that resolves with data read from the file 'promise-data.txt'.
   * @type {Promise<Buffer>}
   */
  let parallelReadFile1Promise = new Promise(
    (resolve, reject) => {
      fs.readFile('promise-data.txt',
        (error, data) => {
          if (error) { reject(error); }
          else { resolve(data); }
        });
    });
  parallelReadFile1Promise.then((data) => { console.log(data.toString()); }, (error) => { console.error(error); });

  // Read the second file asynchronously
  /**
   * @description A promise object that resolves with data read from the file 'promise-data2.txt'.
   * @type {Promise<Buffer>}
   */
  let parallelReadFile2Promise = new Promise(
    (resolve, reject) => {
      fs.readFile('promise-data2.txt',
        (error, data) => {
          if (error) { reject(error); }
          else { resolve(data); }
        });
    });

  // Finally print the data read from the file.
  parallelReadFile2Promise.then(
    (data) => { console.log(data.toString()); },
    (error) => { console.error(error); }
  );


  // The example below uses separate functions for the promise executor
  // and the then() method and makes the code more readable.
  // The example below illustrates the chaining example above using
  // separate functions for the promise executor and the then() methods.

  // These dpc comments define the callback functions that are used in the
  // promise executor and the then() method.
  /**
   * @callback ResolveCallback
   * @param {String} value - The data to be returned by a promise.
   * @return {void}
   */

  /**
   * @callback RejectCallback
   * @param {any | null} reason - The result of a promise that was rejected.
   */

  // This is the promise executor function that resolves with the value 'f1'
  // Note that since the resolve function is the only argument to the executor
  // The reject function is not used in this function. It won't be passed to the
  // function
  /**
   * @function f1
   * 'f1' after 5 seconds.
   * @param {ResolveCallback} resolve - The resolve function of the promise.
   * @returns {void}
   */
  function f1(resolve) { setTimeout(() => { resolve('f1'); }, 5000); }

  // This is the promise executor function that resolves with the value 'f2'
  /**
   * @function f2
   * @description A promise executor function that resolves with value
   * 'f2' after 5 seconds.
   * @param {ResolveCallback} resolve - The resolve function of the promise.
   */
  function f2(resolve) { setTimeout(() => { resolve('f2'); }, 5000); }

  // This is the then function for non-chained promises
  /**
   * @function f1Then
   * @description A function that prints the value returned by a resolved promise
   * @param {string} value
   * @returns {void}
   */
  function f1Then(value) { console.log(value); }

  // This is the then function for chained promises
  /**
   * @function f1ThenWithPromise
   * @description A function that prints the value returned by a resolved promise
   * and returns a new promise with f2 as the executor.
   * @param {string} value
   * @returns {Promise<String>}
   */
  function f1ThenWithPromise(value) { f1Then(value); return new Promise(f2); }


  // This is the function that acts on the value returned by a when the f2 promise is resolved
  function f2Then(value) { console.log(value); }

  // This asynchronously executes the f1 and then f2 and prints the value returned by f1 and f2 in sequence.
  new Promise(f1).then(f1ThenWithPromise).then(f2Then);

  // This executes both f1 and f2 in parallel and prints the values returned as soon as they are resolved.
  new Promise(f1).then(f1Then);
  new Promise(f2).then(f2Then);

  // This executes both f1 and f2 in parallel and prints the values only after both are resolved.
  // Note the use of Promise.all() to wait for all promises to be resolved *before* the then callback is executed.
  Promise.all([new Promise(f1), new Promise(f2)]).then((values) => {
    f1Then(values[0]); f2Then(values[1]);
  });

  // Promise.all will reject if any of the promises passed to it are rejected.
  // The following example demonstrates this.
  function f3a(_, reject) { reject(new Error('f3a failed')); }
  function f3b(resolve) { setTimeout(() => { resolve('f3b'); }, 5000); }
  function f3aThen(value) { console.log(value); }
  function f3bThen(value) { console.log(value); }
  function f3Error(error) { console.error(error); }
  function f3Then(values) { f3aThen(values[0]); f3bThen(values[1]); }

  // This will reject with the error 'f3a failed' since f3a rejects.
  Promise.all([new Promise(f3a), new Promise(f3b)]).then(f3Then).catch(f3Error);

  // TODO: Explore Promise.allSettled(), Promise.race(), and Promise.any()

  // TODO: Explore promise.resolve() and promise.reject()


  /**
   * @function f4
   * @description A promise executor function that rejects with the value 'f3 failed' after 5 seconds.
   * @param {ResolveCallback} resolve - The resolve function of the promise.
   * @param {RejectCallback} reject - The reject function of the promise.
   */
  function f4(resolve, reject) { setTimeout(() => { reject(new Error('f4 failed')); }, 5000); }

  /**
   * @function f4Then
   * @param {any} value The error object returned by the rejected promise.
   */
  function f4Then(value) { console.log(value); }

  /**
   * @function f4Error
   * @param { Error} error
   */
  function f4Error(error) { console.error(error); }

  // This asynchronously executes f4 and prints the error returned by f4.
  new Promise(f4).then(f4Then, f4Error);

  // This executes f4 and lets the error be handled by the catch() method.
  // This is because the then() method does not have an onRejected function.
  // In this case, the catch() method is called when the promise is rejected.
  new Promise(f4).then(f4Then).catch(f4Error);

  // Using catch() is a good practice. It is a good idea to always
  // have a catch() method at the end of a promise chain to handle
  // any errors that may occur.

  // Note that although the Javascript engine will catch errors thrown
  // in a promise executor function, you will not be able to catch
  // those errors using the catch() or the error callback of the then()
  // method. The engine will instead terminate the program with an error.
  // It is therefore a good idea to catch errors in the promise
  // executor function itself, rather than letting them propagate to
  // Javascript engine.

  // In f5, we throw an error after 5 seconds. The error is caught
  // locally and passed to the reject function.
  /**
   * @function f5
   * @description A promise executor function that throws an error after 5 seconds.
   * Note that since resolve, by convention we use _ to indicate that
   * the argument is not used.
   * @param {any} _ - Not used in this function.
   * @param {RejectCallback} reject - The reject function of the promise.
   */
  function f5(_, reject) {
    setTimeout(() => {
      try {
        // noinspection ExceptionCaughtLocallyJS
        throw new Error('f5 failed');
      } catch (error) { reject(error); }}, 5000);
  }

  /**
   * @function f5Then
   * @description A function the prints the value returned the f5 and returns a new promise with f2 as the executor.
   * @param {string} value - Not used in this function.
   * @return {Promise<String>}
   */
  function f5Then(value) { console.log(value); return new Promise(f2); }

  /**
   * @function catchF5Error
   * @description Handles the error thrown by a rejected promise.
   * @param {Error} error - The error object thrown by the rejected promise.
   */
  function catchF5Error(error) { console.error(`Caught error ${error}`); }

  // f4 is executed followed by f2. But since f4 invokes reject, the catch() method is called
  // and f2 is not executed and f2Then is not called either.
  new Promise(f5).then(f5Then).then(f2Then).catch(catchF5Error);

  // You can have a finally() method at the end of a promise chain to
  // execute code after the promise is resolved or rejected. The finally()
  // method is called regardless of whether the promise is resolved or rejected.
  // The finally() method does not take any arguments. The finally() method
  // Here is an example of using the finally() method.
  new Promise(f4).then(f4Then).catch(f4Error).finally(() => { console.log('f4 finally'); });
}
