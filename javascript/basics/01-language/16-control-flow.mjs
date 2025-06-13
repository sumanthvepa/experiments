//-*- coding: utf-8 -*-
/**
 * @module 16-control-flow.mjs: Explore control flow in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 16-control-flow.mjs: Explore control flow in Javascript
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

export function exploreControlFlow() {
  // Control flow in Javascript is the order in which statements are executed.
  // Javascript provides a number of control flow statements to control the
  // flow of execution of a program. The most common control flow statements
  // are:
  // 1. Conditional statements
  // 2. Looping statements
  // 3. Jump statements

  // 1. Conditional statements:
  // Conditional statements are used to execute different code blocks based
  // on different conditions. The most common conditional statements in
  // Javascript are:
  // 1. if statement
  // 2. if-else statement
  // 3. if-else-if statement
  // 4. switch statement

  // 1. if statement:
  // The if statement is used to execute a block of code if a condition is true.
  // The if statement is denoted by the 'if' keyword.
  /**
   * @description A variable that is a number.
   * @type {number}
   */
  let x = 10;
  if (x > 5) {
    console.log('x is greater than 5');
  }

  // 2. if-else statement:
  // The if-else statement is used to execute one block of code if a condition
  // is true and another block of code if the condition is false.
  // The if-else statement is denoted by the 'if' and 'else' keywords.
  if (x > 5) {
    console.log('x is greater than 5');
  } else {
    console.log('x is less than or equal to 5');
  }

  // 3. if-else-if statement:
  // The if-else-if statement is used to execute one block of code if a
  // condition is true and another block of code if the condition is false.
  // The if-else-if statement is denoted by the 'if', 'else', and 'else if' keywords.
  if (x > 5) {
    console.log('x is greater than 5');
  } else if (x < 5) {
    console.log('x is less than 5');
  } else {
    console.log('x is equal to 5');
  }

  // 4. switch statement:
  // The switch statement is used to execute different code blocks based on
  // different conditions. The switch statement is denoted by the 'switch',
  // 'case', and 'break' keywords.
  switch (x) {
    case 5:
      console.log('x is equal to 5');
      break;
    case 10:
      console.log('x is equal to 10');
      break;
    default:
      console.log('x is not equal to 5 or 10');
  }

  // The switch statement can also be used with strings.
  let name = 'John';
  switch (name) {
    case 'John':
      console.log('Hello John!');
      break;
    case 'Jane':
      console.log('Hello Jane!');
      break;
    default:
      console.log('Hello!');
  }

  // Javascript allows multiple case statements to be executed without
  // a break statement. This can be useful in some cases, but it can also
  // lead to unintended behavior. It is generally a good practice to use
  // a break statement after each case to avoid unintended behavior.

  // Unfortunately, the switch statement does not support regular
  // expression matches. You have to use the re module and if
  // statements.

  // Notice that the break statement is used to exit the switch statement
  // after a case is executed. If the break statement is not used, the
  // switch statement will continue to execute the code blocks after the
  // matching case. IntelliJ IDEA will warn about this. Hence, the
  // noinspection directive is used to suppress the warning.
  // noinspection FallThroughInSwitchStatementJS
  switch (x) {
    case 5:
      console.log('x is equal to 5');
    case 10:
      console.log('x is equal to 10');
    default:
      console.log('x is not equal to 5 or 10');
  }

  // There is also a ternary operator that can be used to write conditional
  // statements in a more concise way. The ternary operator is denoted by
  // the '?' and ':' symbols.
  // In the code below we can technically skip the parentheses around the
  // conditional expression, but it is good practice to use them.
  /**
   * @description A variable that is a number.
   * @type {string}
   */
  let y = (x > 5) ? 'x is greater than 5' : 'x is less than or equal to 5';
  console.log(y);

  // 2. Looping Statements:
  // Looping statements are used to execute a block of code multiple times.
  // The most common looping statements in Javascript are:
  // 1. for loop
  // 2. while loop
  // 3. do-while loop
  // 4. for-in loop
  // 5. for-of loop

  // 1. for loop:
  // The for loop is used to execute a block of code a specified number of times.
  // The for loop is denoted by the 'for' keyword.
  for (let i = 0; i < 5; i++) {
    console.log(i);
  }

  // 2. while loop:
  // The while loop is used to execute a block of code while a condition is true.
  // The while loop is denoted by the 'while' keyword.
  let j = 0;
  while (j < 5) {
    console.log(j);
    j++;
  }

  // 3. do-while loop:
  // The do-while loop is used to execute a block of code at least once, and then
  // repeatedly execute the block of code while a condition is true.
  // The do-while loop is denoted by the 'do' and 'while' keywords.
  let k = 0;
  do {
    console.log(k);
    k++;
  } while (k < 5);

  // 4. for-in loop:
  // The for-in loop is used to iterate over the properties of an object.
  // The for-in loop is denoted by the 'for' and 'in' keywords.
  /**
   * @description An object with properties.
   * @type {Object}
   */
  let obj = {a: 1, b: 2, c: 3};
  for (let prop in obj) {
    console.log(prop, obj[prop]);
  }

  // 5. for-of loop:
  // The for-of loop is used to iterate over the values of an iterable object.
  // The for-of loop is denoted by the 'for' and 'of' keywords.
  /**
   * @description An array of numbers.
   * @type {number[]}
   */
  let arr = [1, 2, 3];
  for (let val of arr) {
    console.log(val);
  }

  // 3. Jump Statements:
  // Jump statements are used to control the flow of execution of a program.
  // The most common jump statements in Javascript are:
  // 1. break statement
  // 2. continue statement
  // 3. return statement
  // 4. throw statement

  // 1. break statement:
  // The break statement is used to exit a loop or switch statement.
  // The break statement is denoted by the 'break' keyword.
  for (let i = 0; i < 5; i++) {
    if (i === 3) {
      break;
    }
    console.log(i);
  }

  // You can also use the break statement to exit a labeled loop.
  outer: for (let i = 0; i < 5; i++) {
    for (let j = 0; j < 5; j++) {
      if (j === 3) {
        break outer;
      }
      console.log(i, j);
    }
  }

  // 2. continue statement:
  // The continue statement is used to skip the current iteration of a loop.
  // The continue statement is denoted by the 'continue' keyword.
  for (let i = 0; i < 5; i++) {
    if (i === 3) {
      continue;
    }
    console.log(i);
  }

  // Like with the break statement, you can also use the continue
  // statement to skip the current iteration of a labeled loop.
  outer: for (let i = 0; i < 5; i++) {
    for (let j = 0; j < 5; j++) {
      if (j === 3) {
        continue outer;
      }
      console.log(i, j);
    }
  }

  // 3. return statement:
  // The return statement is used to return a value from a function.
  // This is discussed in more detail in the  16-functions.mjs module.

  // 4. throw statement:
  // The throw statement is used to throw an exception.
  // This is discussed in more detail in the 17-exceptions.mjs module.
}