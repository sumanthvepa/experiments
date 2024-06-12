//-*- coding: utf-8 -*-

/**
 * @module 17-objects-and-classes.mjs: Explore objects and classes
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 17-objects-and-classes.mjs: Explore objects and classes
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

/**
 * @function exploreObjects
 * @description Explore objects and classes in Javascript
 * @return {void}
 */
export function exploreObjects() {
  // Javascript has two distinct types of object orientation.
  // 1. Object-oriented programming using objects and prototypes and
  // 2. Object-oriented programming using classes and inheritance.
  // This function explore objects and prototypes.

  // In Javascript objects are collections of key-value pairs. The keys
  // are strings and the values can be any data type. Objects in Javascript
  // are used to represent real-world entities. Objects can be created
  // using the object literal syntax or the 'new' keyword.

  // 1. Object literal syntax:
  // The object literal syntax is the simplest way to create an object.
  // An object is created by enclosing a list of key-value pairs in curly
  // braces. The keys are strings and the values can be any data type.

  /**
   * @description A person object
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  const person1 = {
    firstName: 'John',
    lastName: 'Doe',
    age: 30,
    email: 'user@example.com'
  };

  // You can add properties to an object using the dot notation or the
  // bracket notation. Although the dot notation is more common, the
  // bracket notation is useful when the property name is dynamic.
  // or when the property name is a reserved keyword or a number or
  // some string that does not conform to the rules for variable names.

  // For example, the following two statements are equivalent:
  // However, ESLint will complain about the dot notation if the property
  // was not described in the @type annotation above for the object
  // noinspection JSUndefinedPropertyAssignment
  person1.city = 'New York';

  // The bracket notation is useful when the property name is dynamic.
  // ESLint will not complain about the bracket notation in this case.
  person1['city'] = 'New York';

  // 2. Using the 'new' keyword:
  // You can also create an object using the 'new' keyword. The 'new'
  // keyword creates an instance of a class. We will explore classes
  // later in this module. For now, let's see how to create an object
  // using the 'new' keyword.

  // Note that for this sort of object creation, it's better to use
  // the object literal syntax. The 'new' keyword better suits the
  // creation of instances of classes.

  // noinspection JSPrimitiveTypeWrapperUsage
  /**
   * @description A person object created using new
   *
   * Note that the type annotation is Object and not the specific
   * structure of the object as was the case with person1.
   *
   * @type {Object}
   */
  let person2 = new Object();
  // Note that this time ESLint and IntelliJ IDEA will not complain about
  // the dot notation or the bracket notation. This is because the object
  // person2 is created using the 'new' keyword and the properties are
  // not described in the @type annotation above.
  person2.firstName = 'Jane';
  person2.lastName = 'Doe';
  person2.age = 25;
  person2.email = 'jane@example.com';

  // Note that unlike Java, C++, Python or Swift, you don't need to
  // create a class to create an object. You can create an object
  // directly using the object literal syntax. This is because Javascript
  // is a prototype-based language. We will explore prototypes later
  // in this module.

  // 3. Accessing object properties:
  // You can access object properties using the dot notation or the
  // bracket notation. The dot notation is more common. The bracket
  // notation is useful when the property name is dynamic or when the
  // property name is a reserved keyword or a number or some string
  // that does not conform to the rules for variable names.
  console.log(person1.firstName); // John
  console.log(person1['firstName']); // John

  // Bracket notation is also useful if you are trying to access
  // a property that does not exist. The dot notation will throw an
  // error if the property does not exist. The bracket notation will
  // return 'undefined' if the property does not exist.
  try {
    // noinspection JSUnusedLocalSymbols,JSUnresolvedReference
    /**
     * @description Country that person1 is from
     * @type {string}
     */
    let country = person1.country; // Throws an error
    // noinspection JSUnresolvedReference
    console.log(person1.country); // New York
  } catch (e) {
    console.error(e);
  }

  /**
   * @description Country that person1 is from
   * @type {string}
   */
  let country = person1['country']; // undefined
  console.log(country); // undefined

  // You can also use the bracket notation to access properties that
  // are dynamically determined. Let's say you have a variable 'key'
  // that contains the name of the property you want to access.
  // Then using the bracket notation you can access the property
  // using the value of the variable 'key'. The dot notation does
  // not work in this case.
  /**
   * @description name of the property
   * @type {string}
   */
  let key = 'city';
  console.log(person1[key]); // New York
  // console.log(person1.key) // There is no property called 'key'

  // You can get a list for all the properties of an object using the
  // Object.keys() method. This method returns an array of strings
  // representing the properties of an object.
  /**
   * @description An array of property names of the object person1
   * @type {string[]}
   */
  let keys = Object.keys(person1);
  for (let key of keys) {
    console.log(key, person1[key]);
  }
  // You can also directly iterate over the properties of an object
  // using the 'for...in' loop. This loop iterates over the enumerable
  // properties of an object. The properties are iterated in the order
  // in which they were added to the object, unless they are integer
  // properties. Integer properties are sorted. The 'for...in' loop does
  // not iterate over the prototype properties of an object.
  for (let key in person1) {
    console.log(key, person1[key]);
  }

  // In general, it is not a good idea to rely on the order in which
  // keys are returned by Object.keys() or the 'for...in' loop.
  let oddObject = {
    '34': 'thirty-four',
    '2': 'two',
    'city': 'New York',
    '67': 'sixty-seven'
  }
  // Will print in the following order: 2, 34, 67, city
  for (let key in oddObject) {
    console.log(key, oddObject[key]);
  }

  // You can test the existence of a property in an object using the
  // 'in' operator. The 'in' operator returns 'true' if the property
  // exists in the object and 'false' otherwise.
  console.log('firstName' in person1); // true
  console.log('country' in person1); // false

  // Do not test for the existence of a property using comparison
  // to 'undefined'. This is because the property may exist and have
  // the value 'undefined'. In such cases, the comparison to 'undefined'
  // will return 'true' even though the property exists.
  console.log(person1['country'] === undefined); // true. But country is not a property of person1

  // 4. Deleting object properties:
  // You can delete object properties using the 'delete' keyword.
  // The 'delete' keyword removes a property from an object.
  // This removes the property entirely. The property is no longer
  // accessible and the property name is no longer in the list of
  // properties of the object.
  console.log(person1.city); // New York
  delete person1.city;
  console.log(person1.city); // undefined

  // 5. Computing property names:
  // You can compute property names using expressions in the bracket
  // notation. The expression is evaluated and the result is used as
  // the property name. This is useful when you want to dynamically
  // create properties.
  // Note that instead of having a property called 'propertyName', the
  // property is called 'city'. The value of the variable 'propertyName'
  // is used as the property name.
  /**
   * @description name of the property
   * @type {string}
   */
  let propertyName = 'city';
  /**
   * @description An object with a computed property name
   * @type {{[p: string]: string}}
   */
  let object1 = {
    [propertyName]: 'New York'
  };
  console.log(object1.city); // New York

  // It is often common to create object form variables whose names
  // are the same as the property names. In such cases, you can use
  // the shorthand notation. The shorthand notation allows you to
  // omit the property name if the property name is the same as the
  // variable name.
  /**
   * @description first name of the person
   * @type {string}
   */
  let firstName = 'John';
  /**
   * @description last name of the person
   * @type {string}
   */
  let lastName = 'Doe';
  /**
   * @description age of the person
   * @type {number}
   */
  let age = 30;
  /**
   * @description email of the person
   * @type {string}
   */
  let email = 'john@example.com';
  /**
   * @description A person object
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  let person3 = { firstName, lastName, age, email };
  console.log(person3.firstName); // John
  console.log(person3.lastName); // Doe
  console.log(person3.age); // 30
  console.log(person3.email); //

  // 6. Objects as Reference Types, Object Comparison:
  // Objects are reference types in Javascript. When you assign an
  // object to a variable, you are assigning a reference to the object.
  // This means that the variable does not contain the object itself.
  // Instead, it contains a reference to the object. When you assign
  // an object to another variable, you are copying the reference to
  // the object. This means that both variables point to the same object.
  // If you modify the object using one variable, the changes are
  // reflected in the other variable as well.
  /**
   * @description A person object
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  const person4 = {
    firstName: 'John',
    lastName: 'Doe',
    age: 30,
    email: 'john@example.com'
  }
  // noinspection UnnecessaryLocalVariableJS
  /**
   * @description A reference to the person object
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  let person5 = person4;
  person5.firstName = 'Jane';

  // Note that person4 is modified as well, even though it has been
  // marked as a constant. This is because the constant refers to the
  // reference to the object and not the object itself. The object is
  // mutable even though the reference is constant.
  console.log(person4.firstName); // Jane.

  let person6 = {
    firstName: 'Jane',
    lastName: 'Doe',
    age: 30,
    email: 'john@example.com'
  }

  // Two objects are equal only if they refer to the same object.
  // In general, even though == does compare references in the case
  // of objects, it is better to use === to compare objects. This is
  // because == can have unexpected behavior. For example, == will
  // return true if the two objects have the same properties and
  // values, even though they refer to different objects.

  // noinspection EqualityComparisonWithCoercionJS
  console.log(person4 == person5); // true. They refer to the same object.
                                   // The comparison is done by comparing the references.

  console.log(person4 === person5); // true. They refer to the same object
  // noinspection EqualityComparisonWithCoercionJS
  console.log(person4 == person6); // false. They refer to different
                                   // objects even though the properties
                                   // and their values are the same.
  console.log(person4 === person6); // false. They refer to different objects

  // 7. Object Cloning
  // You can clone an object manually by creating a new object and
  // copying the properties of the original object to the new object.
  /**
   * @description A person object that will be cloned
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  const person7 = {
    firstName: 'Joe',
    lastName: 'Somebody',
    age: 25,
    email: 'joe@example.com'
  }

  /**
   * @description A new object that is a clone of person7
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  let person8 = {};
  for (let key in person7) {
    person8[key] = person7[key];
  }
  console.log(person8.firstName); // Joe
  console.log(person8.lastName); // Somebody
  console.log(person8.age); // 25
  console.log(person8.email); //

  console.log(person7 === person8); // false. They refer to different
                                    // objects even though the properties
                                    // and their values are the same.

  // You can also clone an object using the Object.assign() method.
  // To clone an object, you can use the Object.assign() method.
  // The Object.assign() method copies the properties of one or more
  // source objects to a target object. The method returns the target
  // object. The target object is the first argument to the method.
  // The source objects are the subsequent arguments to the method.
  // The properties of the source objects are copied to the target
  // object. If the target object already has a property with the
  // same name as the property being copied, the property is
  // overwritten. The Object.assign() method does a shallow copy.
  // This means that the properties of the source objects are copied
  // to the target object. If the properties are objects themselves,
  // the assign() method copies their references. The objects
  // themselves are not cloned.
  /**
   * @description A person object that is a clone of person7
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  let person9 = Object.assign({}, person7);
  console.log(person9.firstName); // Joe
  console.log(person9.lastName); // Somebody
  console.log(person9.age); // 25
  console.log(person9.email); //

  // You can merge two objects into one
  /**
   * @object location
   * @description A location object
   * @type {{country: string, city: string, state: string}}
   */
  let location = {
    city: 'New York',
    state: 'New York',
    country: 'USA'
  }

  /**
   * @description A person object that is a clone of person7 and
   * has the properties of the location object as well.
   * @type {{firstName: string, lastName: string, age: number, email: string} & {country: string, city: string, state: string}}
   */
  let person10 = Object.assign({}, person7, location);
  for (let key in person10) {
    console.log(key, person10[key]);
  }

  // Object.assign() only does shallow copies. If the properties of
  // the object are objects themselves, the properties are copied by
  // reference and not cloned. This means that if you modify the
  // properties of the source object, the properties of the target
  // object are modified as well.
  /**
   * @description A person object, with a location object as a property
   * @type {{firstName: string, lastName: string, age: number, email: string, location: {country: string, city: string, state: string}}}
   */
  let person11 = {
    firstName: 'Jenny',
    lastName: 'Somebody',
    age: 25,
    email: 'jenny@example.com',
    location: location
  }
  /**
   * @description A person object that is a shallow clone of person11
   * @type {{firstName: string, lastName: string, age: number, email: string, location: {country: string, city: string, state: string}}}
   */
  let person12 = Object.assign({}, person11);
  console.log(person11.location === person12.location); // true as it is a shallow copy
  console.log(person12.location.city); // New York
  location.city = 'Los Angeles';
  console.log(person12.location.city); // Los Angeles
  console.log(person11.location.city); // Los Angeles as well.


  // If you want to do a deep clone, use the structuredClone() function
  let person13 = {
    firstName: 'Jackie',
    lastName: "O'Hare",
    age: 25,
    email: 'jackie@example.com',
    location: {
      city: 'Burbank',
      state: 'California',
      country: 'USA'
    }
  };
  let person14 = structuredClone(person13);
  console.log(person14 === person13); // false
  console.log(person13.location === person14.location); // false

  // structuredClone works with most data types, but not with functions.

  // For a more comprehensive deep clone, use a library like lodash or
  // implement a deep clone function yourself.
  // lodash provides a cloneDeep() function that does a deep clone of
  // an object. The cloneDeep() function clones an object and all its
  // properties, including nested objects and methods.
  // For more details about lodash see https://lodash.com/


  // 8. Object methods
  // Objects in Javascript can have methods. A method is a function
  // that is a property of an object. The method is called on the
  // object using the dot notation. The method can access the object
  // using the 'this' keyword. The 'this' keyword refers to the object
  // on which the method is called.  The 'this' keyword is used to
  // access other properties of the object within the method.

  // You can add a method to an object just as you would add a property
  // to an object. The method is a function that is assigned to a property
  // of the object.
  /**
   * @description A person object with a greet method
   * @type {{firstName: string, lastName: string, age: number, email: string}}
   */
  let person15 = {
    firstName: 'John',
    lastName: 'Doe',
    age: 30,
    email: 'doe@example.com',
  }
  // noinspection JSUndefinedPropertyAssignment
  person15.greet =  function() {
    console.log(`Hello, my name is ${this.firstName} ${this.lastName}`);
  }

  // You can invoke the method using the dot notation.
  person15.greet(); // Hello, my name is John Doe

  // You can also add a method to an object using the object literal syntax.
  // The method is defined as a function in the object literal syntax.
  /**
   * @description A person object with a method defined in the object literal syntax
   * @type {{firstName: string, lastName: string, age: number, email: string, greet: (function(): void)}}
   */
  let person16 = {
    firstName: 'Jane',
    lastName: 'Doe',
    age: 25,
    email: 'jane@example.com',
    greet: function () {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}`);
    }
  }
  person16.greet(); // Hello, my name is Jane Doe

  // greet: function() can be simplified further by simply defining
  // the function without the function keyword. This is called the
  // method shorthand, and should be the preferred way to define
  // methods in objects.
  /**
   * @description A person object with a method defined in the object literal syntax
   * @type {{firstName: string, lastName: string, age: number, email: string, greet: (function(): void)}}
   */
  let person17 = {
    firstName: 'Jackie',
    lastName: 'McNamara',
    age: 25,
    email: 'jackie@example.com',
    greet() {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}`);
    }
  }
  person17.greet(); // Hello, my name is Jackie McNamara

  // Arrow functions are not suitable for object methods. This is because
  // arrow functions do not have their own 'this' keyword. The 'this'
  // keyword in an arrow function refers to the 'this' value of the
  // enclosing lexical context. This means that the 'this' keyword in
  // an arrow function will not refer to the object on which the method
  // is called. Instead, it will refer to the object in which the arrow
  // function is defined. This is not what you want in an object method.
  // Therefore, you should not use arrow functions to define object methods.
  // Use the method shorthand instead.

  // This example is taken from https://javascript.info/object-methods
  // and modified for the purpose of this exposition.

  let user = {
    firstName: 'Ilya',
    sayHi() {
      // The 'this' is taken from the outer "normal" function that
      // defines the arrow function. In this case 'sayHi'
      let arrow = () => console.log(this.firstName);
      arrow()
      return arrow
    }
  }
  let af = user.sayHi(); // Illya
  af(); // Also Illya, since it was defined in the same context as sayHi

  // 9. Constructors and operator new
  // The object literal is useful for one-off objects or pure
  // data objects, but having to repeatedly create same structure
  // for multiple objects can be cumbersome. To help with that
  // we can use constructor functions

  // Constructors are technically just regular functions. By
  // convention, they start with a capital letter. It is only
  // when they are used with a 'new' keyword that they become
  // constructors. The 'new' keyword creates a new object and
  // sets 'this' to that object. The constructor function is
  // then called to complete the initialization.
  /**
   * @description A constructor function for a person object
   * @param {string} firstName - first name of the person
   * @param {string} lastName - last name of the person
   * @param {number} age - age of the person
   * @param {string} email - email of the person
   * @constructor
   */
  function Person(firstName, lastName, age, email) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.age = age;
    this.email = email;
    this.greet = function () {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`);
    }
    // Note that constructors normally do not have a return, since the new will return
    // the 'this' object.
    // If however, you return a primitive value, it will be ignored.
    // If you return an object, that object will be returned instead of 'this'
    // It's not good practice to return an object from a constructor.
  }

  // The constructor function can be used create multiple objects.
  let user1 = new Person('John', 'Doe', 30, 'doe@example.com');
  user1.greet(); // Hello, my name is John Doe...
  let user2 = new Person('Jane', 'Doe', 25, 'jane@example.com');
  user2.greet();

  // You don't have to define the constructor function upfront, you can define it
  // as part of the call to new and have it be immediately executed.
  let user3 = new function() {
    this.firstName = 'Mary';
    this.lastName = 'Lamb';
    this.age = '18';
    this.email = 'mary@example.com';
    this.greet = function () {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`);
    }
  };
  user3.greet();
}

/**
 * @function exploreClasses
 * @description Explore classes in Javascript
 * @return {void}
 */
export function exploreClasses() {
  // While objects and constructors are one way to create objects,
  // classes provide a more structured way to create objects. Classes
  // are a blueprint for creating objects. Classes encapsulate data
  // and behavior. Classes are used to represent real-world entities.
  // Objects created from classes are called instances of the class.
  // Classes are a fundamental part of object-oriented programming.

  // In Javascript classes are for the most part syntactic sugar over
  // the underlying objects/and prototypes system (although there are
  // some semantic differences that will be covered below.)

  // The constructor() function below is essentially syntactic
  // suger for creating the object and initializing it. It
  // is the same as creating a constructor function named Person(...)

  // The additional syntactic sugar that the class notation provides
  // is the ability to define methods directly in the class. The
  // methods are defined as functions within the class. The methods
  // are called on the object using the dot notation. The methods
  // can access the object using the 'this' keyword. Everything about
  // them works the same way as methods defined directly on objects.

  class Person {
    /**
     * @description Constructor for the Person class
     * @param firstName {string} - first name of the person
     * @param lastName {string} - last name of the person
     * @param age {int} - age of the person
     * @param email {string} - email of the person
     */
    constructor(firstName, lastName, age, email) {
      // This is the constructor. It is called when a new instance
      // of the class is created. The constructor initializes the
      // properties of the object.
      this.firstName = firstName;
      this.lastName = lastName;
      this.age = age;
    }

    /**
     * @description A method to greet the person
     * @return {string} A greeting message
     */
    greet() {
      return `Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`;
    }
  }

  let user1 = new Person('John', 'Doe', 30, 'john@example.com');
  console.log(user1.greet());
}