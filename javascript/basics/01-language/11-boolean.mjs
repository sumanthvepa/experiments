//-*- coding: utf-8 -*-
/**
 * @module 11-boolean.mjs: Explore booleans in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 11-boolean.mjs: Explore booleans in Javascript
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

// Booleans in Javascript are either true or false.
/**
 * @description An example of a boolean variable.
 * @type {boolean}
 * @default false
 */
export let taskCompleted = false;

/**
 * @function completeTask
 * @description A function that sets the taskCompleted variable to true.
 *
 */
export function completeTask() {
  taskCompleted = true;
  // Booleans are often the result of logical comparisons.
  /**
   * @description isGreater is a boolean variable that is the result
   * of a logical comparison.
   * @type {boolean}
   * @constant
   * @default true
   */
  const isGreater = 5 > 1
  if (isGreater) {
    console.log('5 > 1');
  }
  // The if statement evaluates the expression it is
  // given and proceeds to execute the code in the
  // conditional block if the expression evaluates
  // to true.
  if (5 > 1) { // eslint-disable-line no-constant-condition
    console.log('5 > 1');
  }

  // Some values when encountered in a boolean context, such
  // as within the conditional test of an if statement,
  // are considered 'truthy'.
  // See https://developer.mozilla.org/en-US/docs/Glossary/Truthy
  // All values are considered to be truthy, unless they are defined
  // to be falsy. The only values that are falsy are:
  // 0, -0, 0n, "", null, undefined, NaN and document.all. Why
  // the latter? See this explanation on Stackoverflow:
  // https://stackoverflow.com/questions/10350142/why-is-document-all-falsy
  // Note thet document.all is a legacy feature and should not be used
  // and most modern browsers do not support it.
}