//-*- coding: utf-8 -*-
/**
 * @module 13-null-and-undefined.mjs: Explore null and undefined in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 13-null-and-undefined.mjs: Explore null and undefined in Javascript
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
 * @function exploreNullAndUndefined
 * @description Explore null and undefined in Javascript
 */
export function exploreNullAndUndefined() {
  // null represents a value that is explicitly empty.
  // It is often used to indicate that a variable has been
  // initialized but does not have a value.
  /**
   * @description A variable that is explicitly empty.
   * @type {null}
   * @constant
   * @default null
   */
  const emptyValue = null;
  console.log(`emptyValue = ${emptyValue}`); // null

  // Null is its own type but is considered an object by the typeof operator.
  // This is a bug in the language that has been preserved for backward
  // compatibility.
  console.log(`typeof emptyValue = ${typeof emptyValue}`); // object

  // undefined represents a value that is not initialized.
  // It is often used to indicate that a variable has been declared
  // but not assigned a value.
  /**
   * @description A variable that is not initialized.
   * @type {undefined | number}
   * @default undefined
   */
  let uninitializedValue;
  // noinspection JSUnusedAssignment
  console.log(`uninitializedValue = ${uninitializedValue}`); // undefined

  // undefined is its own type.
  console.log(`typeof uninitializedValue = ${typeof uninitializedValue}`); // undefined
  uninitializedValue = 5; // Now the variable has a value.
  console.log(`After assignment with 5, uninitializedValue = ${uninitializedValue}`); // 5

  // Strictly speaking, you can assign undefined to a variable,
  // but it is not recommended.
  uninitializedValue = undefined; // Ok, but not recommended.
  console.log(`After assignment with undefined, uninitializedValue = ${uninitializedValue}`); // undefined

  // Type conversions with null and undefined have some interesting
  // properties.

  // When evaluated in a boolean context (such as within the conditional
  // test of an if statement), both null and undefined are considered
  // 'falsy'.
  // See https://developer.mozilla.org/en-US/docs/Glossary/Falsy
  console.log(`Boolean(null) = ${Boolean(null)}`); // false
  console.log(`Boolean(undefined) = ${Boolean(undefined)}`); // false

  // When evaluated in a numeric context, null converts to 0 and
  // undefined converts to NaN.
  console.log(`Number(null) = ${Number(null)}`); // 0
  console.log(`Number(undefined) = ${Number(undefined)}`); // NaN

  // Null is of course === to null.
  // noinspection PointlessBooleanExpressionJS
  /**
   * @description cmp0 is the result of comparing null to itself using ===.
   * @type {boolean}
   * @constant
   * @default true
   */
  const cmp0 = null === null; // true
  console.log(`null === null: ${cmp0}`);

  // Undefined is also === to undefined.
  // noinspection PointlessBooleanExpressionJS
  /**
   * @description cmp1 is the result of comparing undefined to itself using ===.
   * @type {boolean}
   * @constant
   * @default true
   */
  const cmp1 = undefined === undefined; // true
  console.log(`undefined === undefined: ${cmp1}`);

  // Type conversions and comparisons with null and undefined
  // can be tricky. The == operator performs type conversion
  // before comparison. The === operator does not perform
  // type conversion.
  // Null converts to 0 and undefined converts to NaN.
  /**
   * @description cmp2 is the result of comparing null and 0 using ==.
   * @type {boolean}
   * @constant
   * @default true
   */
  const cmp2 = null == 0; // true. == converts null to a
                                   // number, 0 and then does the
                                   // comparison.
  console.log(`null == 0: ${cmp2}`);

  /**
   * @description cmp3 is the result of comparing null and 0 using ===.
   * @type {boolean}
   * @constant
   * @default false
   */
  const cmp3 = null === 0; // false, === does not perform type
                                    // conversion. typeof null is
                                    // object and typeof 0 is number.
                                    // So the comparison is false.
  console.log(`null === 0: ${cmp3}`);

  // undefined converts to NaN when compared using ==.
  // But because Nan is not equal to anything, the result is false.
  // noinspection JSComparisonWithNaN,EqualityComparisonWithCoercionJS
  /**
   * @description cmp4 is the result of comparing undefined and NaN using ==.
   * @type {boolean}
   * @constant
   * @default false
   */
  const cmp4 = undefined == NaN; // false.
  console.log(`undefined == NaN: ${cmp4}`);

  // But when compared using ===, the result is false because
  // undefined is not equal to NaN.
  // noinspection JSComparisonWithNaN
  /**
   * @description cmp5 is the result of comparing undefined and NaN using ===.
   * @type {boolean}
   * @constant
   * @default false
   */
  const cmp5 = undefined === NaN; // false.
  console.log(`undefined === Nan: ${cmp5}`);

  // When using ==, null is equal to undefined because both
  // convert to 0.
  // noinspection PointlessBooleanExpressionJS
  /**
   * @description cmp6 is the result of comparing undefined and null using ==.
   * @type {boolean}
   * @constant
   * @default true
   */
  const cmp6 = undefined == null; // true.
  console.log(`undefined == null: ${cmp6}`);

  // But when using ===, null is not equal to undefined because
  // they are different types.
  // noinspection PointlessBooleanExpressionJS
  /**
   * @description cmp7 is the result of comparing undefined and null using ===.
   * @type {boolean}
   * @constant
   * @default false
   */
  const cmp7 = undefined === null; // false.
  console.log(`undefined === null: ${cmp7}`);

  // Comparing undefined to undefined using == will return true, because
  // no type conversion is necessary for the comparison.
  // noinspection EqualityComparisonWithCoercionJS,PointlessBooleanExpressionJS
  /**
   * @description cmp8 is the result of comparing undefined to itself using ==.
   * @type {boolean}
   * @constant
   * @default true
   */
  const cmp8 = undefined == undefined; // true
  console.log(`undefined == undefined: ${cmp8}`);

  // Comparing undefined to undefine using === will also return true.
  // This is because the undefined type is a singleton. There is
  // only one instance of it.
  // noinspection PointlessBooleanExpressionJS
  /**
   * @description cmp9 is the result of comparing undefined to itself using ===.
   * @type {boolean}
   * @constant
   * @default true
   */
  const cmp9 = undefined === undefined; // true.
  console.log(`undefined === undefined: ${cmp9}`);

  // One useful operator to know about when dealing with
  // null and undefined is the nullish coalescing operator.
  // This operator returns the right-hand operand when the
  // left-hand operand is null or undefined. Otherwise, it
  // returns the left-hand operand.

  // For example, consider the following code:
  /**
   * @description userValue is a variable that is either null or a number.
   * @type {null | number}
   */
  let userValue = null; // A user value that is either null or a number
  /**
   * @description defaultValue is a default value that is used when the
   * userValue is null or undefined.
   * @type {number}
   */
  let defaultValue = 5; // A default value that is used when

  // We can use the nullish coalescing operator to set a variable
  // to the user value if it is not null or undefined, otherwise
  // we can set it to the default value.
  let result = userValue ?? defaultValue; // result will be 5, the default value
  console.log(`result = ${result}`); // 5

  userValue = 10; // Now the user value is set to 10
  result = userValue ?? defaultValue; // result will be 10, the user value
  console.log(`result = ${result}`); // 10

  // Another useful operator is the optional chaining operator ?.
  // This is useful in situations where you need to access the property
  // of an object that may not be present.
  // In the code below, the person object may have an optional
  // employerName pro
  /**
   * @function getMockPerson
   * @description Returns a person object with an optional employer
   * name specified.
   * @param employer {string | null } An optional employer name.
   * @returns {{name: string} | {name: string, employer: string}}
   */
  function getMockPerson(employer) {
    if (employer === null) {
      return {
        'name': 'Joe',
      };
    }
    return {
      'name': 'Joe',
      'employer': employer
    }
  }

  /**
   * @descrption A mock person object used to illustrate the use
   * of the optional chaining operator.
   * @type {{name: string}|{name: string, employer: string}}
   * @constant
   */
  const person1 = getMockPerson(null);
  // Prints 'Joe is employed by undefined'
  console.log(`${person1.name} is employed by ${person1?.employer}`);

  /**
   * @description A mock person object used to illustrate the use
   * of the optional chaining operator.
   * @type {{name: string}|{name: string, employer: string}}
   * @constant
   */
  const person2 = getMockPerson('Google');
  // Prints 'Joe is employed by Google'
  console.log(`${person2.name} is employed by ${person2?.employer}`);
}
