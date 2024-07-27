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
  };
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
  };

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
  };

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
  };
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
  };
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
  };
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
  };
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
  };

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

  // 10. Property Flags
  // Properties in Javascript objects have flags that define how
  // the property can be accessed. The flags are set when the property
  // is created. The flags have default values when the property
  // is created. The flags can be changed using the Object.defineProperty()
  // method. The Object.defineProperty() method allows you to define new
  // properties or modify existing properties on an object. The method
  // takes three arguments: the object on which the property is defined,
  // the name of the property, and a property descriptor object that
  // specifies the attributes of the property.
  let person18 = {
    name: 'Harry Potter',
    age: 18
  };
  let descriptor = Object.getOwnPropertyDescriptor(person18, 'name');
  console.log(descriptor);

  // Standard properties have the following flags:
  // 1. writable: If 'true', the property can be changed using the assignment operator.
  // 2. enumerable: If 'true', the property is iterated over by the 'for...in' loop.
  // 3. configurable: If 'true', the property can be deleted and its attributes can be changed.
  // By default, all three flags are 'true' for standard properties.

  // Note that it's probably not a good idea to change the flags of regular properties.
  // In particular if you are trying to make a property read-only, it's better to use
  // a getter method to simulate a read-only property.

  // You can change the flags using the Object.defineProperty() method.
  // The method takes three arguments: the object on which the property is defined,
  // the name of the property, and a property descriptor object that specifies the
  // attributes of the property.
  Object.defineProperty(person18, 'name', { writable: false });

  // Now the name property is read-only. You cannot change the value of the name property.
  // The following statement will throw an error in strict mode.
  try {
    person18.name = 'Hermione Granger'; // Throws an error in strict mode
  } catch (e) {
    console.error(e);
  }

  // Note that if the property is a reference type, the reference itself is read-only.
  // The object that the property refers to is not read-only.

  // You can also use the Object.defineProperty() method to define new properties.
  // If the property does not exist, the method creates a new property with the
  // specified attributes. If the property already exists, the method changes the
  // attributes of the property.
  Object.defineProperty(person18, 'city', { value: 'London', writable: false });
  console.log(person18.city); // London

  // 11. Property Getters and Setters
  // Javascript objects can have properties that are computed on the fly.
  // These properties are called computed or accessor properties. Computed properties
  // are defined using getter and setter methods. The getter method is
  // called when you retrieve the value of a property. The setter
  // method is called when you set a property's value.
  let person19 = {
    firstName: 'Harry',
    lastName: 'Potter',
    get fullName() {
      return `${this.firstName} ${this.lastName}`;
    },
    set fullName(value) {
      let parts = value.split(' ');
      this.firstName = parts[0];
      this.lastName = parts[1];
    }
  };

  // You can access the computed property using the dot notation as
  // if it were a regular property.
  console.log(person19.fullName); // Harry Potter
  person19.fullName = 'Hermione Granger';
  console.log(person19.fullName); // Hermione Granger
  console.log(person19.firstName); // Hermione
  console.log(person19.lastName); // Granger

  // Using a getter without a setter is a good way to simulate a
  // read-only property.
  let person20 = {
    firstName: 'Ron',
    lastName: 'Weasley',
    get fullName() {
      return `${this.firstName} ${this.lastName}`;
    }
  };
  console.log(person20.fullName); // Ron Weasley

  // Using a setter without a getter is a good way to simulate a
  // write-only property. This is not very common, but it is possible.
  let person21 = {
    _password: '',
    set password(value) {
      this._password = value;
    }
  };
  person21.password = 'secret';

  // 12. Private properties and methods
  // Javascript does not have private properties and methods. All
  // properties and methods of an object are public. By convention,
  // however, properties and methods that are intended to be private
  // are prefixed with an underscore. This is a signal to other
  // developers that the property or method is intended to be private.
  // The underscore is not enforced by the language. It is a convention
  // that is followed by developers.

  // In the example below, the _first and _last properties are
  // intended to be private. They are prefixed with an underscore to
  // signal that they are private. The fullName property is a computed
  // property that is public. It is intended to be accessed by other
  // developers.
  /**
   * @description A person object with private properties
   * @type {{_first: string, _last: string, readonly name: string}}
   */
  let person22 = {
    _first: 'Harry',
    _last: 'Potter',
    get name() {
      return `${this._first} ${this._last}`;
    }
  };
  console.log(person22.name); // Harry Potter
}

export function exploreObjectInheritance() {
  // Inheritance is a fundamental concept in object-oriented programming.
  // Inheritance allows you to create a new class that is based on an
  // existing class. The new class inherits the properties and methods
  // of the existing class. The existing class is called the base class
  // or the superclass. The new class is called the derived class or
  // the subclass. The subclass can add new properties and methods or
  // override existing properties and methods.

  // In Javascript, inheritance is implemented using prototypes. The
  // prototype chain allows objects to inherit properties and methods
  // from other objects. The prototype chain is a chain of objects
  // that are linked together. Each object has a prototype property
  // that points to another object. The prototype object has its own
  // prototype object. This forms a chain of objects that are linked
  // together. The prototype chain allows objects to inherit properties
  // and methods from other objects.
  // E.g.:
  let person = {
    name: 'John Doe',

    eat() {
      console.log(`${this.name} is eating...`);
    },

    greet() {
      console.log(`Hello, my name is ${this.name}`);
    }
  }

  // You can define a derived object that inherits from the base object
  // by setting the prototype of the derived object to the base object.
  // This can be done using the __proto__ property.  (Although this
  // is not the recommended way to set the prototype of an object. See
  // below for Object.create() method.)
  let employee = {
    // Note that __proto__ is a getter/setter for the [[Prototype]] of an object.
    // It is not the actual prototype of the object. The actual prototype of an
    // object can be accessed using the Object.getPrototypeOf() method.
    __proto__: person,
    job: 'Software Engineer',
    greet() {
      console.log("Hello, my name is " + this.name + ", and I am a " + this.job);
    }
  }

  // Get the prototype of the employee object
  let employeePrototype = Object.getPrototypeOf(employee);
  console.log(employeePrototype === person); // true

  // The derived object inherits the properties and methods of the base object.
  // If a method or property is not found in the derived object, the prototype
  // chain is followed to find the method or property in the base object.
  employee.eat(); // John Doe is eating...
  employee.greet(); // Hello, my name is John Doe, and I am a Software Engineer

  // But there are subtle foot-guns with prototypal inheritance. In the example below:
  // You would assume that changing the name of the employee through the inherited
  // name property would change the name of the person object. That is not what
  // happens. Instead, a new name property is created on the employee object.
  // This property shadows the name property of the person object.
  employee.name = "Jane Doe";
  // Employee greet() will pick up the name property of the employee object
  // and, it will appear that all is well. That is misleading.
  employee.greet(); // Hello, my name is Jane Doe and, I am a Software Engineer
  // When you try to print the person objects name, you will see that it is still
  // John Doe.
  console.log(person.name); // Still John Doe

  // Remove the name variable shadowing the person object's name property
  delete employee.name;

  // The name goes back to being the name of the person object
  employee.greet(); // Hello, my name is John Doe, and I am a Software Engineer

  // Now if you change the name of the person object, the employee object will
  // reflect the change as well.
  person.name = "Jack Doe";
  employee.greet(); // Hello, my name is Jack Doe, and I am a Software Engineer

  // You can access the name property of the person object using the
  // employee object though. The prototypal chain is followed to find
  // the property in the base object.
  console.log(`Employee's name is: ${employee.name}`); // Jack Doe

  // If you define a new method on the person object, e.g. changeName()
  // it will be available to the employee object as well.
  person.changeName = function (newName) {
    this.name = newName;
  }

  // The changeName() method is available to the employee object as well.
  employee.changeName("Jill Doe");
  // Now the employee object has a name property of Jill Doe
  employee.greet(); // Hello, my name is Jill Doe, and I am a Software Engineer

  // However if you define a new method on the employee object, it will
  // not able to change values inherited from the person object. Instead,
  // it will create a new property on the employee object.
  employee.changeName2 = function (newName) {
    this.name = newName;
  }
  employee.changeName2("Jackie Doe");
  // Calling greet on employee will show 'Jackie Doe' as the name
  // because a new name property with the name 'name' and value 'Jackie Doe'
  // is created that shadows the name property of the person object.
  employee.greet(); // Hello, my name is Jackie Doe, and I am a Software Engineer'
  // You can see that the person object's name property is still 'Jill Doe'
  person.greet();  // Hello, my name is Jack Doe
  // Calling eat() will show the name of the employee object
  // because the 'this' reference in the eat() method is bound to the
  // employee object.
  employee.eat(); // Jackie Doe is eating...
  // Calling person.eat() will still show 'Jack Doe' because the
  // 'this' reference in the eat() method is bound to the person object.
  // and the name property of the person object is still 'Jack Doe'.
  person.eat(); // Jack Doe is eating...

  // Bottom line, if you are using prototypal inheritance, make sure that
  // you do not accidentally shadow properties of the base object. This can
  // lead to subtle bugs that are hard to track down.

  // To actually change a property of the base object, when operating
  // on the derived object, you can use the __proto__ property to access
  // the base object. Then you can assign values to the properties of
  // the base object, or call methods that change the properties of the
  // base object.

  let person1 = {
    name: 'John Doe',
    greet() {
      console.log(`Hello, my name is ${this.name}`);
    },

    changeName(newName) {
      this.name = newName;
    }
  };

  let employee1 = {
    __proto__: person1,
    job: 'Software Engineer',

    changeName(newName) {
      let person = this.__proto__
      person.changeName(newName);
    },

    changeName2(newName) {
      super.changeName(newName);
    },

    changeName3(newName) {
      Object.getPrototypeOf(this).changeName(newName);
    }
  };

  employee1.changeName('Jane Doe');
  console.log(`Person's name is: ${person1.name}`); // Jane Doe
  console.log(`Employee's name is: ${employee1.name}`); // Jane Doe

  // Even using super in changeName2 will not work because super is only
  // super will call the method of the same name in the prototype chain
  // but the 'this' reference will still be bound to the employee object.
  // So setting the name property will still create a new property on the
  // employee object.
  employee1.changeName2('Marty McFly');
  console.log(`Person's name is: ${person1.name}`); // Jane Doe
  console.log(`Employee's name is: ${employee1.name}`); // Marty McFly
  delete employee1.name; // Need to clean up the unwanted property
                         // that is shadowing the person object's name
                         // property.

  // The correct way to change the name property of the person object
  // is to use Object.getPrototypeOf(this).changeName(newName) in the
  // changeName3 method. This will call the changeName method of the
  // person object and set the name property of the person object.
  employee1.changeName3('George Costanza');
  console.log(`Person's name is: ${person1.name}`); // George Costanza
  console.log(`Employee's name is: ${employee1.name}`); // George Costanza

  // The downside to the above approach is that every derived class will
  // need to override the changeName method to use the Object.getPrototypeOf(this)
  // method to call the changeName method of the base class. This can be
  // cumbersome and error-prone.

  // In general, it is best to define data properties in the constructor
  // and methods on the prototype. This way the data is always stored
  // in the leaf object and does not shadow properties of the base object.
  // Finally, the created object should only be accessed via its derived
  // object handle and never via the base object handle. This will allow
  // you to program with objects in a way that is similar to other
  // object-oriented languages like Java or C++.
  // This is the basis for the more modern class syntax in Javascript.
  // Later demonstrations will work our way towards the class
  // syntax.

  // E.g.: This is the base object. It only contains methods. No
  // data members are defined in the object. The data members are
  // created when they are assigned in the constructor. Since the
  // constructor will always be called via the derived object, the
  // 'this' reference will always be bound to the derived object.
  // so the data members will always be created in the derived object.
  let person2 = {
    // Note that there is nothing special about the name 'constructor'.
    // It is just a method like any other.
    constructor(firstName, lastName, age, email) {
      // Note no data members are defined outside the constructor
      this.firstName = firstName;
      this.lastName = lastName;
      this.age = age;
      this.email = email;
    },

    changeName(firstName, lastName) {
      this.firstName = firstName;
      this.lastName = lastName;
    },

    greet() {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`);
    }
  };

  let employee2 = {
    // We first set up the prototype chain
    __proto__: person2,
    // Now we override the constructor method to call the constructor
    // of the base object. This is done by calling the constructor method
    // by using the super keyword. The super keyword is a reference to
    // the base object. The super keyword is used to call methods of the
    // base object. Finally, function initializes variables that are
    // specific to this object.
    constructor(firstName, lastName, age, email, job) {
      super.constructor(firstName, lastName, age, email);
      this.job = job;
    }
  };

  // Initialize person2
  employee2.constructor('John', 'Doe', 30, 'john@example.com');
  // The following will not work because the person2 object does not hold any data.
  person2.greet(); // Hello, my name is undefined. I am undefined years old. You can reach me at undefined
  // This works.
  employee2.greet(); // Hello, my name is John Doe. I am 30 years old. You can reach me at john@example.com

  // Change the name of the employee
  employee2.changeName('Jane', 'Doe');
  person2.greet(); // Hello, my name is Jane Doe. I am 30 years old. You can reach me at john@example.com
  employee2.greet(); // Hello, my name is Jane Doe. I am 30 years old. You can reach me at john@example.com


  // The __proto__ property is a non-standard way to set the prototype of an object.
  // It is not recommended to use __proto__ in production code. It is better to use
  // Object.create() to set the prototype of an object. The Object.create() method
  // creates a new object with the specified prototype object. There are some
  // subtle differences between __proto__ and Object.create(). The __proto__ property
  // sets the prototype of the object itself. The Object.create() method creates a
  // new object with the specified prototype object. The object itself is not modified.
  // The Object.create() method is the recommended way to set the prototype of an object.
  let employee3 = Object.create(person);
  employee3.job = 'Software Engineer';
  console.log(`Employee's name is: ${employee3.name}`); // John Doe
  console.log(`Employee's job is: ${employee3.job}`); // Software Engineer
}

export function exploreConstructorFunctionBasedClasses() {
  // Constructors and Prototypes
  // There is another way to construct an object that inherits from another object.
  // This technique is essentially the same as the object literal inheritance technique
  // shown above, but with a some syntactic and semantic support from the language
  // itself.
  // This is a little more standard way to do it.
  // The technique is to use a constructor function and the prototype property
  // of the constructor function. The prototype property of a constructor
  // function is an object that is used as the prototype of objects created by
  // the constructor function, when it is invoked via the new operator. The
  // prototype object has a constructor property that points back to the
  // constructor function. The prototype object is shared among all objects
  // created by the constructor function. The prototype object is used to
  // define methods that are shared among all objects created by the constructor
  // function. The methods are defined on the prototype object and
  // not on the objects themselves. This saves memory because the methods are
  // shared among all objects created by the constructor function.
  // We define the methods on the prototype object and not on the objects
  // themselves. This saves memory because the methods are shared
  // among all objects created by the constructor function.

  // These features taken together essentially make the prototype object
  // along with the constructor function a class definition.

  // First we need to note that every function in Javascript has a prototype
  // property. It does not have to be a constructor function. The
  // designation of a function as a constructor only comes when it
  // is called with the 'new' operator.
  // So the following normal function has a prototype property.:
  function foo() {
    console.log('foo');
  }
  // noinspection JSPotentiallyInvalidConstructorUsage
  console.log(`foo.prototype: ${foo.prototype}`); // [object Object]

  // By default, the prototype property of a function is the root
  // Object prototype. This is the prototype of all objects in
  // Javascript.

  // Now let's define a base object using object literal notation.
  // Note that there are no raw data properties in the object. This
  // is for the same reason as discussed at the end of exploreObjectInheritance.
  let person = {
    constructor(firstName, lastName, age, email) {
      this.firstName = firstName;
      this.lastName = lastName;
      this.age = age;
      this.email = email;
    },

    greet() {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`);
    }
  };

  // Now we define a constructor function that will be used to create
  // objects that inherit from the person object.
  function Employee(firstName, lastName, age, email, job) {
    // The constructor function is called with the new operator.
    // The new operator creates a new object and sets the 'this'
    // reference to that object. The constructor function is then
    // called to initialize the object.
    // Within the function the 'this' reference is bound to the object
    // that the new operator created and passed implicitly to the
    // constructor function.

    // We call the constructor method of the person object to initialize
    // the base object.
    this.constructor(firstName, lastName, age, email);
    // Then the rest of the fields are initialized here.
    // Whether the order of these calls matter depends on the
    // specific use case. But generally this order should
    // be followed.
    this.job = job;
    this.sayJob = function() {
      console.log(`I am a ${this.job}`);
    }
  }
  // Then we set the prototype of the constructor function to the
  // base object. This is done assigning person to the prototype
  // property of the constructor function.
  Employee.prototype = person;

  // Now create a new employee.
  let employee = new Employee('John', 'Doe', 30, 'johndoe@example.com', 'Software Engineer');

  employee.greet(); // Hello, my name is John Doe. I am 30 years old.
                    // You can reach me at 'johndoe@example.com'
  employee.sayJob(); // I am a Software Engineer

  // The object system above has a few limitations. First:
  // the base object is a singleton. This means that there is only
  // one instance of person. If you want to create multiple distinct
  // employee (not one person who has multiple jobs), you will have
  // to create a new object for each employee.
  // The second limitation is that the base object defines methods
  // as part of the object. So every object created from the constructor
  // function will have its own copy of the method. This is not
  // efficient in terms of memory usage.

  // You can remove these limitations by defining the base object
  // itself as a constructor function. And then defining the methods
  // as properties of the prototype of the constructor function.

  // Javascript will search for methods in the prototype chain
  // and use them when it finds them. This way methods are shared
  // amongst all objects created by the constructor function. Objects
  // of type employee will differ only in the data members that
  // are specific to the object.

  // This is the constructor function for the base class. We now
  // use the term class, since the function is the template for
  // a class of objects: persons.
  function Person2(firstName, lastName, age, email) {
    // You can create objects of type Person2 directly, by calling
    // new Person2(...). In this case the 'this' reference will
    // be to an object of type Person2. The data members will be
    // initialized as part of that object.
    // You can also create objects of the derived class Employee2 by
    // calling new Employee2(...). In the latter
    // case, the 'this' reference to the object being created will be
    // the derived object, and the data members will be initialized
    // as part of the derived object.
    this.firstName = firstName;
    this.lastName = lastName;
    this.age = age;
    this.email = email;
  }

  // The limitation of not sharing methods is removed by defining
  // the methods on the prototype of the constructor function.

  // Instead of defining the greet method in the object itself as
  // was done earlier, you can define it on the prototype of the
  // constructor function. This way Javascript will find it when it
  // looks for the method in the prototype chain of an object created
  // by the constructor.
  Person2.prototype.greet = function() {
    console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`);
  }

  // We also define a mutating function on the prototype of the base object.
  // We will use this to demonstrate how calling this method on a derived
  // object will result in the properties stored in the derived object
  // being changed.
  Person2.prototype.changeName = function(newName) {
    let parts = newName.split(' ');
    this.firstName = parts[0];
    this.lastName = parts[1];
  }

  // Now we define the derived object as a constructor function.
  function Employee2(firstName, lastName, age, email, job) {
    // Call the constructor of the base object to initialize
    // the properties that the base object needs.
    // You have to use the call syntax to call the constructor of the
    // base object. This is because the 'this' reference is bound to
    // the object being created by the new operator. The call method
    // allows you to set the 'this' reference to the object being
    // created.
    Person2.call(this, firstName, lastName, age, email);

    // Initialize the fields specific to this object
    this.job = job;
  }
  // Set the prototype of the derived object to the prototype of the
  // base object. There are two ways to do this. First, you can directly
  // set the prototype of the derived object to the prototype of the
  // base object. This is done by assigning the prototype of the base
  // object to the prototype of the derived object. This shown below.
  // Do not use this technique. Use the next technique.
  // Employee2.prototype = Person2.prototype; // DO NOT USE.

  // However, any changes to the prototype of the derived object will
  // also change the prototype of the base object. This is because the
  // prototype of the derived object is the prototype of the base object.
  // This is not what you want. You want the derived object to have its
  // own prototype that is separate from the prototype of the base object.
  // To do this, you can use the Object.create() method to create a new
  // object with the prototype of the base object. This is shown below.
  // Now you have clone of the prototype of the base object. Any changes
  // to the prototype of the derived object will not affect the prototype
  // of the base object.
  Employee2.prototype = Object.create(Person2.prototype);

  // Now you can point the constructor property of the prototype of the
  // derived object to the constructor function of the derived object.
  Employee2.prototype.constructor = Employee2;


  // We also define a mutating method on the derived object.
  // this will change the job property that is specific to the
  // derived object.
  Employee2.prototype.changeJob = function(newJob) {
    this.job = newJob;
  }

  Employee2.prototype.changeEmail = function(newEmail) {
    this.email = newEmail;
  }

  // Now create a new employee.
  let employee2 = new Employee2('Jane', 'Doe', 30, 'janedoe@example.com', 'Software Engineer');
  employee2.greet(); // Hello, my name is Jane Doe. I am 30 years old.
                     // You can reach me at 'janedoe@example.com'
  console.log(`Employee's job is: ${employee2.job}`); // Software Engineer
  console.log(`Employee's email is: ${employee2.email}`); // janedoe@example.com

  employee2.changeName('Jack Doe');
  employee2.changeJob('Plumber');
  employee2.changeEmail('jack@example.com');
  employee2.greet(); // Hello, my name is Jack Doe. I am 30 years old.
                     // You can reach me at 'jack@example.com'

  // You can create multiple objects from the same constructor function.
  let employee2b = new Employee2('Sam', 'Vyper', 52, 'vyper@example.com');
  employee2b.greet(); // Hello, my name is Sam Vyper. I am 52 years old.
                     // You can reach me at 'vyper@example.com'

  // This technique effectively the same as the class syntax in Javascript.
  // (The class syntax is explained in the next function exploreClasses().)
  // The class syntax provides syntax to accomplish the semantics of the
  // above code in a more concise and readable way.

  // In general, you should prefer the class syntax over the object literal
  // technique or the constructor function technique.

  // Because Javascript is so flexible, you can use variations of the
  // techniques defined about to create different types of object
  // systems.

  // Note that Javascript does not support multiple inheritance. The
  // builtin prototype chain search feature only allows for single
  // inheritance. You can however use mixins to simulate multiple
  // inheritance. Mixins are objects that contain methods that can
  // be added to other objects. Mixins can be used to add methods
  // from multiple objects to a single object. Mixins are a way to
  // simulate multiple inheritance in Javascript.
  // E.g.:
  let canEat = {
    eat() {
      console.log(`${this.name} is eating...`);
    }
  };

  let canWalk = {
    walk() {
      console.log(`${this.name} is walking...`);
    }
  };

  function Person3(name) {
    this.name = name;
  }

  // Mixin the canEat and canWalk objects into the Person3 object.
  // The Object.assign() method copies the properties of the canEat
  // and canWalk objects to the prototype of the Person3 object.
  // Note that it *copies* the properties. The properties are not
  // shared among objects. This is different from the prototype
  // chain where the properties are shared among objects.
  Object.assign(Person3.prototype, canEat, canWalk);

  let person3 = new Person3('John Doe');
  person3.eat(); // John Doe is eating...
  person3.walk(); // John Doe is walking...
}

/**
 * @function exploreClasses
 * @description Explore classes in Javascript
 * @return {void}
 */
export function exploreClasses() {
  // Javascript provides syntactic sugar for creating objects using
  // the techniques described in the previous function. The class
  // syntax provides a more structured way to create objects.


  // While objects, constructor functions are one way to create objects,
  // classes provide a more structured way to create objects. Classes
  // are a blueprint for creating objects. Classes encapsulate data
  // and behavior. Classes are used to represent real-world entities.
  // Objects created from classes are called instances of the class.
  // Classes are a fundamental part of object-oriented programming.

  // In Javascript classes are for the most part syntactic sugar over
  // the underlying objects/and prototypes system (although there are
  // some semantic differences that will be covered below.)

  // The constructor() function below is essentially syntactic
  // suger for creating the object and initializing it.
  // is the same as creating a constructor function named Person(...)
  // Unlike the function named 'constructor' in the object literal
  // notation, constructor is a keyword in this context. It represents
  // a special function in a class that is called when a new instance
  // of the class is created. The constructor initializes the properties
  // of the object.

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
      this.email = email;
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

  // 1. Checking for class membership
  // You can check if an object is an instance of a class using the
  // instanceof operator. The instanceof operator returns 'true' if
  // the object is an instance of the class and 'false' otherwise.
  console.log(user1 instanceof Person); // true
}

export function exploreClassInheritance() {
  // You can create a class that inherits from another class using the
  // extends keyword. The derived class inherits the properties and
  // methods of the base class. The derived class can add new properties
  // and methods or override existing properties and methods.
  /**
   * @classdesc A class representing a person
   */
  class Person {
    /**
     * @description Constructor for the Person class
     * @param firstName
     * @param lastName
     * @param age
     * @param email
     */
    constructor(firstName, lastName, age, email) {
      this.firstName = firstName;
      this.lastName = lastName;
      this.age = age;
      this.email = email;
    }

    greet() {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}.`);
    }
  }

  /**
   * @classdesc A class representing an employee
   */
  class Employee extends Person {
    /**
     * @description Constructor for the Employee class
     * @param firstName {string} - first name of the employee
     * @param lastName {string} - last name of the employee
     * @param age {int} - age of the employee
     * @param email {string} - email of the employee
     * @param job {string} - job of the employee
     */
    constructor(firstName, lastName, age, email, job) {
      super(firstName, lastName, age, email);
      this.job = job;
    }

    /**
     * @description A method to greet the employee
     * @return {string} A greeting message
     */
    greet() {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}. I am ${this.age} years old. You can reach me at ${this.email}. I am a ${this.job}.`);
    }
  }

  let user1 = new Employee('John', 'Doe', 30, 'johndoe@example.com', 'Software Engineer');
  user1.greet(); // Hello, my name is John Doe. I am 30 years old. You can reach me at johndoe@example.com. I am a Software Engineer.

  // Class Expressions
  // You can also define classes using class expressions. A class expression
  // is similar to a function expression. A class expression can be named or
  // unnamed. Named class expressions are useful for creating classes
  // that reference themselves. Unnamed class expressions are useful
  // for creating classes that are not referenced by other code.
  // E.g.:
  // Named class expression
  let MyRectangle = class Rectangle {
    constructor(width, height) {
      this.width = width;
      this.height = height;
    }

    area() {
      return this.width * this.height;
    }

    definitionOf() {
      // Self reference to the class name
      // Rectangle name is only available in the class itself
      return Rectangle.toString()
    }
  };

  let rectangle1 = new MyRectangle(10, 20);
  // Rectangle is not defined in this scope
  // let rectangle2 = new Rectangle(10, 20); // Won't work
  console.log(`Class definition:\n${rectangle1.definitionOf()}`);
  console.log(`Rectangle area is: ${rectangle1.area()}`); // Rectangle area is: 200

  // Unnamed class expression
  let Circle = class {
    constructor(radius) {
      this.radius = radius;
    }
    area() {
      return Math.PI * this.radius * this.radius;
    }
  };

  let circle1 = new Circle(10);
  console.log(`Circle area is : ${circle1.area()}.`); // Circle area is : 314.1592653589793.

  // Like objects, classes can have getters and setters.
  class Person2 {
    constructor(firstName, lastName) {
      this.firstName = firstName;
      this.lastName = lastName;
    }

    get fullName() {
      return `${this.firstName} ${this.lastName}`;
    }

    set fullName(value) {
      let parts = value.split(' ');
      this.firstName = parts[0];
      this.lastName = parts[1];
    }
  }

  let person = new Person2('John', 'Doe');
  console.log(person.fullName); // John Doe
  person.fullName = 'Jane Doe';
  console.log(person.fullName); // Jane Doe

  // Like objects, you can have computed methods in classes.
  class Person3 {
    constructor(firstName, lastName) {
      this.firstName = firstName;
      this.lastName = lastName;
    }

    ['greet' + 'Person']() {
      console.log(`Hello, my name is ${this.firstName} ${this.lastName}.`);
    }
  }

  let person3 = new Person3('John', 'Doe');
  // Note the warning about the unresolved reference to greetPerson
  // in the editor. This is because the editor does not understand
  // that greetPerson is a computed method. The code will run without
  // any issues.
  // noinspection JSUnresolvedReference
  person3.greetPerson(); // Hello, my name is John Doe

  // Static Methods
  // Classes can have static methods. Static methods are methods that
  // are called on the class itself and not on instances of the class.
  // Static methods are defined using the 'static' keyword. Static
  // methods are useful for creating utility functions that are related
  // to the class but do not depend on the state of the class.
  class MathUtils {
    static add(a, b) {
      return a + b;
    }

    static subtract(a, b) {
      return a - b;
    }
  }
  console.log(`10 + 20 = ${MathUtils.add(10, 20)}`); // 30
  console.log(`10 - 20 = ${MathUtils.subtract(10, 20)}`); // -10

  // You can also define static methods on a class by assigning a function
  // to a property of the class. This is similar to defining properties
  // objects. The multiply method below is a static method of the MathUtils
  MathUtils.multiply = function(a, b) {
    return a * b;
  }

  console.log(`10 * 20 = ${MathUtils.multiply(10, 20)}`); // 200

  // You can also have static properties in a class. Static properties
  // are properties that are shared among all instances of the class.
  // E.g.:
  class Counter {
    static count = 0;

    constructor() {
      Counter.count++;
      this._id = Counter.count;
    }

    get id() {
      return this._id;
    }
  }

  let counter1 = new Counter();
  console.log(`counter1 ID: ${counter1.id}`); // 1
  let counter2 = new Counter();
  console.log(`counter2 ID: ${counter2.id}`); // 2
  let counter3 = new Counter();
  console.log(`counter3 ID: ${counter3.id}`); // 3
  console.log(`Counter count: ${Counter.count}`); // 3

  // Unlike C++ and Java, static properties and methods are inherited
  // by derived classes.
  class CountedEmployee extends Counter {
    constructor(firstName, lastName, age, email, job) {
      super();
      this.firstName = firstName;
      this.lastName = lastName;
      this.age = age;
      this.email = email;
      this.job = job;
    }
  }

  let countedEmployee1 = new CountedEmployee('John', 'Doe', 30, 'employee1@example.com', 'Software Engineer');
  console.log(`countedEmployee1 ID: ${countedEmployee1.id}`); // 4
  let countedEmployee2 = new CountedEmployee('Jane', 'Doe', 30, 'employee2@example.com', 'Marketing Manager');
  console.log(`countedEmployee2 ID: ${countedEmployee2.id}`); // 5
  let countedEmployee3 = new CountedEmployee('Sam', 'Doe', 30, 'employee3@example.com', 'Customer Service Representative');
  console.log(`countedEmployee3 ID: ${countedEmployee3.id}`); // 6
  console.log(`Employee counter: ${CountedEmployee.count}`); // 6

  // Private Properties and Methods
  // Javascript does not have built-in support for private properties
  // and methods. By convention properties and methods that are meant
  class Person4 {
    constructor(firstName, lastName) {
      this._firstName = firstName;
      this._lastName = lastName;
    }

    get firstName() {
      return this._firstName;
    }

    set firstName(value) {
      this._firstName = value;
    }

    get lastName() {
      return this._lastName;
    }

    set lastName(value) {
      this._lastName = value;
    }
  }

  let person4 = new Person4('John', 'Doe');
  console.log(person4.firstName); // John
  console.log(person4.lastName); // Doe

  // You can also simulate private properties and
  // methods using closures. A closure is a function that has access
  // to the outer function's scope. You can use closures to create
  // private properties and methods in a class. This technique does
  // not work for setter methods though. The earlier technique
  // is better for private properties that need to be modified.
  // E.g.:
  class Person5 {
    constructor(firstName, lastName) {
      let _firstName = firstName;
      let _lastName = lastName;

      this.getFirstName = function() {
        return _firstName;
      }

      this.getLastName = function() {
        return _lastName;
      }
    }
  }

  let person5 = new Person5('John', 'Doe');
  // _lastName and _firstName are only accessible via the closure.
  // noinspection JSUnresolvedReference
  console.log(person5._firstName); // undefined
  // noinspection JSUnresolvedReference
  console.log(person5._lastName); // undefined
  console.log(person5.getFirstName()); // John
  console.log(person5.getLastName()); // Doe

  // Recent versions of Javascript support private fields and methods
  // using the # symbol. Private fields and methods are only accessible
  // within the class that they are defined in. They are not accessible
  // outside the class. Use this as the preferred way to define private
  // fields and methods in a class.
  // E.g.:
  class Person6 {
    // Private fields
    #firstName;
    #lastName;

    constructor(firstName, lastName) {
      this.#firstName = firstName;
      this.#lastName = lastName;
    }

    get firstName() {
      return this.#firstName;
    }

    set firstName(value) {
      this.#firstName = value;
    }

    get lastName() {
      return this.#lastName;
    }

    set lastName(value) {
      this.#lastName = value;
    }

    greet() {
      console.log(`Hello, my name is ${this.#firstName} ${this.#lastName}.`)
    }
  }

  let person6 = new Person6('John', 'Doe');
  // #firstName and #lastName are only accessible within the class
  // they are defined in.
  // console.log(person6.#firstName); // SyntaxError: Private field '#firstName' must be declared in an enclosing class
  // console.log(person6.#lastName); // SyntaxError: Private field '#lastName' must be declared in an enclosing class
  console.log(person6.firstName); // John
  console.log(person6.lastName); // Doe

  // There is no support for protected fields and methods in Javascript.

  // Inheritance and the super keyword
  // You can call methods, the constructor and access properties
  // of the base class using the super keyword.

  class Employee6 extends Person6 {
    #job;

    constructor(firstName, lastName, job) {
      super(firstName, lastName);
      this.#job = job;
    }

    get job() {
      return this.#job;
    }

    set job(value) {
      this.#job = value;
    }

    greet() {
      // super
      super.greet();
      console.log(`I am a ${this.#job}.`);
    }
  }

  let employee6 = new Employee6('John', 'Doe', 'Software Engineer');
  employee6.greet(); // Hello, my name is John Doe. I am a Software Engineer.

  // You can also extend built-in classes like Array, Date, etc.
  // E.g.:
  class CustomArray extends Array {
    constructor(...elements) {
      super(...elements);
    }

    first() {
      return this[0];
    }

    last() {
      return this[this.length - 1];
    }
  }

  let customArray = new CustomArray(1, 2, 3, 4, 5);
  console.log(customArray.first()); // 1
  console.log(customArray.last()); // 5

  // However, unlike with regular classes you cannot extend static methods
  // of built-in classes. (TODO: CHECK IF THIS IS REALLY TRUE)

  // The instanceof operator works with classes as well. It returns true
  // if an object is an instance of a class and false otherwise.
  if (customArray instanceof CustomArray) {
    console.log('customArray is an instance of CustomArray.');
  } else {
    console.log('customArray is not an instance of CustomArray.');
  }
  if (customArray instanceof Array) {
    console.log('customArray is an instance of Array.');
  } else {
    console.log('customArray is not an instance of Array.');
  }
}
