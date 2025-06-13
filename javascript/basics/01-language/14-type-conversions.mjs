//-*- coding: utf-8 -*-
/**
 * @module 14-type-conversions.mjs: Explore strings in Javascript
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 14-type-conversions.mjs: Explore type conversions in Javascript
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


export function exploreTypeConversion() {
    // Javascript provides a number of functions to convert values from one type to another.
    // The most common type conversions are:
    // 1. String conversion
    // 2. Number conversion
    // 3. Boolean conversion

    // 1. String conversion:
    // String conversion is the most common type conversion in Javascript. It is
    // performed using the String() function. The String() function converts a
    // value to a string.
    /**
     * @description A variable that is a number that will be converted to a string.
     * @type {number}
     */
    let x = 123;
    /**
     * @description A variable that is a string representation of the number x.
     * @type {string}
     */
    let y = String(x);
    console.log(`The value of x is ${x} and the value of y is ${y}`);

    // 2. Number conversion:
    // Number conversion is performed using the Number() function. The Number()
    // function converts a value to a number.
    /**
     * @description A variable that is a string that will be converted to a number.
     * @type {string}
     */
    let a = '123';
    /**
     * @description A variable that is a number representation of the string 'a'.
     * @type {number}
     */
    let b = Number(a);
    console.log(`The value of a is ${a} and the value of b is ${b}`);

    // Unary plus operator is used to convert a value to a number.
    /**
     * @description A variable that is a string that will be converted to a number.
     * @type {string}
     */
    let c = '123';
    /**
     * @description A variable that is a number representation of the string 'c'.
     * @type {number}
     */
    let d = +c;  // Unary plus operator
    console.log(`The value of c is ${c} and the value of d is ${d}`);

    // This works for strings that contain numbers. If the string does not contain
    // a number, the result is NaN (Not a Number).
    /**
     * @description A variable that is a string that will be converted to a number.
     * @type {string}
     */
    let e = 'abc';
    /**
     * @description A variable that is a number representation of the string 'e'.
     * @type {number}
     */
    let f = +e;  // Unary plus operator
    console.log(`The value of e is ${e} and the value of f is ${f}`);

    // The unary operator also works on booleans. It converts true to 1 and false to 0.
    /**
     * @description A variable that is a boolean that will be converted to a number.
     * @type {boolean}
     */
    let g = true;
    /**
     * @description A variable that is a number representation of the boolean 'g'.
     * @type {number}
     */
    let h = +g;  // Unary plus operator
    console.log(`The value of g is ${g} and the value of h is ${h}`);


    // 3. Boolean conversion:
    // Boolean conversion is performed using the Boolean() function. The Boolean()
    // function converts a value to a boolean.
    /**
     * @description A variable that is a number that will be converted to a boolean.
     * @type {number}
     */
    let m = 0;
    /**
     * @description A variable that is a boolean representation of the number 'm'.
     * @type {boolean}
     */
    let n = Boolean(m);
    console.log(`The value of m is ${m} and the value of n is ${n}`);

    // For object conversion to and from strings is a little more complex.
    // Javascript provides the JSON.stringify() and JSON.parse() functions to
    // convert objects to and from JSON strings. JSON: JavaScript Object Notation
    // can be thought of as the serialization format for objects in Javascript.
    // It makes it easy to exchange data between a client and a server, or between
    // two servers. JSON is a subset of the object literal notation of Javascript.
    /**
     * @description An object that will be converted to a string.
     *
     * @type {{name: string, age: number}}
     */
    let obj = {
        name: 'Sumanth',
        age: 25
    };

    /**
     * @description A string representation of the object 'obj'.
     * @type {string}
     */
    let objString = JSON.stringify(obj);
    console.log(`The value of obj is ${obj} and the value of objString is ${objString}`);

    // You can go the other way and convert a JSON string to an object
    /**
     * @description A JSON string that will be converted to an object.
     * @type {string}
     */
    let jsonString = '{"name": "Sumanth", "age": 25}';
    /**
     * @description An object representation of the JSON string 'jsonString'.
     * @type {{name: string, age: number}}
     */
    let objFromJsonString = JSON.parse(jsonString);
    console.log(`The value of jsonString is ${jsonString} and the value of objFromJsonString is ${objFromJsonString}`);
}