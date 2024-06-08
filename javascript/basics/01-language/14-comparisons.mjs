//-*- coding: utf-8 -*-
/**
 * @module 14-comparisons.mjs: Explore comparisons in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 14-comparisons.mjs: Explore comparisons in Javascript
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

export function exploreComparisons() {
    // Javascript provides a number of operators to compare values.
    // The most common comparison operators are:
    // 1. Equality operator
    // 2. Strict equality operator
    // 3. Inequality operator
    // 4. Strict inequality operator
    // 5. Greater than operator
    // 6. Greater than or equal to operator
    // 7. Less than operator
    // 8. Less than or equal to operator

    // 1. Equality operator:
    // The equality operator is used to compare two values for
    // equality. The equality operator is denoted by the == symbol.
    // The equality operator performs type coercion before comparing
    // the values. If the values are of different types, the equality
    // operator converts the values to numbers before comparing them.
    /**
     * @description A variable that is a number.
     * @type {number}
     */
    let x = 10;
    /**
     * @description A variable that is a string representation of the number x.
     * @type {string}
     */
    let y = '10';
    console.log(`The value of x is ${x} and the value of y is ${y}`);
    // noinspection EqualityComparisonWithCoercionJS
    console.log(`The value of x == y is ${x == y}`);

    // The equality operator has some quirks when comparing null and undefined
    // with other values. For example:
    console.log("null == 0: ", null == 0) // false, because the null value
                                          // is treated as not equal to any
                                          // other value when compared using
                                          // the equality operator,
    // However, the >= > < <= operators do not use the same rules for
    // null and undefined as the == operator. They simply convert the
    // null to a number (0) and then perform the comparison. For example:
    console.log("null >= 0: ", null >= 0) // true, because null is converted
                                          // to 0 before the comparison is made.
    console.log("null > 0: ", null > 0) // false, because null is converted
                                        // to 0 before the comparison is made.

    // Which leads to an odd inconsistency in the comparison rules.
    // null == 0 is  false null > 0 is false but null >= 0 is true.

    // The same is true for undefined. For example:
    console.log("undefined >= 0: ", undefined >= 0) // false, because
                                                   // undefined is converted
                                                   // to NaN before the
                                                   // comparison is made.


    // 2. Strict equality operator:
    // The strict equality operator is used to compare two values for equality.
    // The strict equality operator is denoted by the === symbol. The strict
    // equality operator does not perform type coercion before comparing the
    // values. If the values are of different types, the strict equality operator
    // returns false.
    /**
     * @description A variable that is a number.
     * @type {number}
     */
    let a = 10;
    /**
     * @description A variable that is a string representation of the
     * number 'a'.
     * @type {string}
     */
    let b = '10';
    console.log(`The value of a is ${a} and the value of b is ${b}`);
    // noinspection JSIncompatibleTypesComparison
    console.log(`The value of a === b is ${a === b}`);

    // 3. Inequality operator:
    // The inequality operator is used to compare two values for inequality. The
    // inequality operator is denoted by the != symbol. The inequality operator
    // performs type coercion before comparing the values. If the values are of
    // different types, the inequality operator converts the values to the same
    // type before comparing them.
    /**
     * @description A variable that is a number.
     * @type {number}
     */
    let c = 10;
    /**
     * @description A variable that is a string representation of the number c.
     * @type {string}
     */
    let d = '20';
    console.log(`The value of c is ${c} and the value of d is ${d}`);
    // noinspection EqualityComparisonWithCoercionJS
    console.log(`The value of c != d is ${c != d}`);

    // Be careful when mixing ==  and other comparison operators with
    // null or undefined and 0 For example:
    console.log("null == 0: ", null == 0) // false, because the
}