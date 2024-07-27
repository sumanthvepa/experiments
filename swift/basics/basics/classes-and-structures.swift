//-*- coding: utf-8 -*-
/**
  classes.swift: Explore classes and structures
*/
/* -------------------------------------------------------------------
 * classes.swift: Explore classes
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License a
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
 *-----------------------------------------------------------------*/

func exploreClassesAndStructures() {
  // Class and structures in Swift are general-purpose,
  // flexible constructs that become the building blocks of your
  // program's code. You define properties and methods to add 
  // functionality to your classes and structures by using exactly
  // the same syntax as constants, variables, and functions.

  // The main difference between structures and classes is that
  // structures are value types and classes are reference types.
  // This means that structures are copied when they are passed
  // around in your code, and classes are passed by reference.

  // In this exploration, we focus on the common features of classes
  // and structures. We will explore features specific to structures
  // exploreStructuresSpecificFeatures().

  // Class and Structure Definition Syntax
  // You define a class or structure in Swift by writing the keyword
  // class or struct followed by the name of the class or structure.
  // The class's properties and methods are written within a pair of
  // braces:
  class Person {
    var name: String = ""
    var age: Int = 0

    func description() -> String {
      // Note that name and age variables refer to the properties
      // of the class. 
      // You can also refer to them using the self keyword.
      // E.g. self.name or self.age. But it is not necessary,
      // unless there is a name conflict.
      return "Name: \(name), Age: \(age)"
    }
  }

  struct Rectangle {
    var width: Int = 0
    var height: Int = 0

    func area() -> Int {
      return width * height
    }
  }

  // You can use the class or structure by creating an instance of it
  // using the initializer syntax. You can access the properties and
  // methods of the class or structure using the dot syntax.
  // Note in particular tha you can change the properties of a
  // let constant class instance. This is because the reference
  // is treated as a constant, not the instance itself.
  let person = Person()
  person.name = "Sanjay"
  person.age = 60
  print(person.description())

  // For struct though you cannot do that. It's a value type
  // and its values are immutable.
  // This won't work:
  /*
  let rectangle0 = Rectangle()
  rectangle0.width = 10
  rectangle0.height = 20
  */

  // Declaring the rectangle as a variable will work.
  var rectangle = Rectangle()
  rectangle.width = 10
  rectangle.height = 20
  print(rectangle.area())

  // If you want make the value of a property immutable in a class
  // you need to declare it as a constant (let).
  class Part {
    let id: Int
    var name: String

    // We'll discuss initializers later. But for now, this
    // initializes the properties of the class.
    init (id: Int, name: String) {
      self.id = id
      self.name = name
    }
  }

  // Now id is a constant and cannot be changed, regardless of
  // whether the Part instance is a constant or a variable.
  let part1 = Part(id: 1, name: "Engine")
  // This will not work
  // part1.id = 2
  // You can change the name property because it is a variable.
  part1.name = "Motor"
  print("Part 1: \(part1.id), \(part1.name)")

  // Even if the part instance is a variable, the id property
  // cannot be changed.
  var part2 = Part(id: 2, name: "Wheel")
  // This will not work
  // part2.id = 3
  // But the name can be changed as it is a variable.
  part2.name = "Tire"
  print("Part 2: \(part2.id), \(part2.name)")
  // Because part2 is a variable, it can be made to reference
  // a completely different instance
  let part3 = Part(id: 3, name: "Transmission")
  part2 = part3 // Now part2 and 3 reference the same instance

  // Changing part2 will change part3 as well.
  part2.name = "Continuous Variable Transmission"
  // Prints Part 3: 3, Continuous Variable Transmission
  print("Part 3: \(part3.id), \(part3.name)")

  // If you want to initialize the properties of a class or structure
  // at the point of creation, you can define an initializer.
  class Person2 {
    var name: String
    var age: Int

    init(name: String, age: Int) {
      // This is the initializer (also called the constructor in
      // other languages). It is called when an instance of the
      // class is created. You can use it to initialize the
      // properties of the class and do other setup.
      // The self keyword is used to refer to the instance being
      // created or operated upon. In this case, it is used to
      // distinguish between the instance's properties and the
      // parameters passed to the initializer.
      self.name = name
      self.age = age
    }

    func description() -> String {
      return "Name: \(name), Age: \(age)"
    }
  }
  let person2 = Person2(name: "Sanjay", age: 60)
  print(person2.description())

  // Works the same way for a struct. But structs don't need
  // initializers just to initialize their properties (unless some
  // complex computation is needed). This is because they have a
  // default memberwise initializer.
  struct Rectangle2 {
    var width: Int
    var height: Int

    func area() -> Int {
      return width * height
    }
  }
  // This is the default memberwise initializer. It initializes
  // the properties of the struct with the values passed to it.
  let rectangle2 = Rectangle2(width: 10, height: 20)
  print(rectangle2.area())

  // The properties of a class can be constants (let) or variables
  // (var). If you define a constant class, you must initialize it
  // in the initializer. You can also define a default value for
  // the property.
  class Person3 {
    let name: String
    var age: Int

    init(name: String, age: Int) {
      // You must initialize the constant property in the
      // initializer.
      self.name = name
      self.age = age
    }

    func description() -> String {
      return "Name: \(name), Age: \(age)"
    }
  }
  let person3a = Person3(name: "Alex", age: 20)
  // You can modify the age because both person3a and age are variables
  person3a.age = 30
  print(person3a.description())

  // Error: Cannot assign to name: 'name' is a 'let' constant
  // person3a.name = "Sam"

  let person3b = Person3(name: "Bob", age: 30)
  // Error: Cannot assign to property: 'person3b' is a 'let' constant
  person3b.age = 40
  print(person3b.description())

  // You can also define a default value for the property.
  // instead of doing it in the initializer.
  class Person4 {
    let name: String = "Sanjay"
    var age: Int = 60

    func description() -> String {
      return "Name: \(name), Age: \(age)"
    }
  }

  // The properties of a value type like struct are usually
  // immutable by methods within the struct. To enable modification
  // you have to mark the method as mutating
  // E.g.
  struct Point {
    var x: Int
    var y: Int
    
    // Needs to be marked mutating because it needs
    // to modify properties of the struct.
    // This won't work:
    // func moveBy(deltaX: Int, deltaY: Int) {
    //   x += deltaX
    //   y += deltaY
    // }
    // But this will: (Note the mutating keyword)
    mutating func moveBy(deltaX: Int, deltaY: Int) {
      x += deltaX
      y += deltaY
    }
    
    // No need to mark this mutating. It
    // does not change the properties of the struct.
    func distanceFromOrigin() -> Double {
      let dx = Double(x)
      let dy = Double(y)
      return (dx*dx + dy*dy).squareRoot()
    }
  }
  // Note tha assigning a new value to struct property
  // is okay as the x property itself is a variable.

  // I suspect, that the real purpose of the mutating
  // keyword is for Swift to optimize some operations
  // by using references for value types. If a mutating method
  // is called on a struct, then a copy needs to be made
  // to prevent other value types that are internally implemented
  // as references from being modified. (Copy-on-write) 
  // This is just a guess on my part.
  var point = Point(x: 10, y: 20)
  
  point.x = 30
  print("Point is \(point)") // Prints Point(x: 30, y: 20)

  // Classes in contrast to structs are reference types.
  // This means that when you pass a class instance to a function
  // or assign it to a variable, you are passing a reference to
  // the instance and not a copy of the instance. This means that
  // when you modify the instance, the changes are reflected in
  // all references to the instance.
  class Person5: Equatable {
    var name: String
    var age: Int

    init(name: String, age: Int) {
      self.name = name
      self.age = age
    }

    func description() -> String {
      return "Name: \(name), Age: \(age)"
    }

    // This function compares two person objects for
    // logical equivalence. To allow the use of person
    // objects in comparisons like if (personA == personB)
    // the class has to implement the Equatable protocol
    // as well as implement this static function.
    static func == (lhs: Person5, rhs: Person5) -> Bool {
      return lhs.name == rhs.name && lhs.age == rhs.age
    }
  }

  // Note that person6's name change even though it was person5's
  // name that was changed. That's because person5 and person6
  // are references to the same instance of the class.
  let person5 = Person5(name: "Sanjay", age: 60)
  let person6 = person5
  print("person5: \(person5.description())") // Prints Name: Sanjay, Age: 60
  print("person6: \(person6.description())") // Prints Name: Sanjay, Age: 60
  person6.name = "Samwise"
  print("person5: \(person5.description())") // Prints Name: Samwise, Age: 60
  print("person6: \(person6.description())") // Prints Name: Samwise, Age: 60

  // Comparison of class instances
  // You can compare the the identity of two class instances
  // using the identity operator ===.
  // The following comparison will evaluate to true because
  // person5 and person6 are references to the same instance.
  if person5 === person6 {
    print("person5 and person6 are the same instance")
  } else {
    print("person5 and person6 are different instances")
  }

  let person7 = Person5(name: "Samwise", age: 60)

  // The following comparison will evaluate to false because
  // person5 and person7 are references to different instances,
  // even though they have the same values.
  if person5 === person7 {
    print("person5 and person7 are the same instance")
  } else {
    print("person5 and person7 are different instances")
  }

  // You can also compare the values of two class instances
  // using the equality operator ==, provided it is defined
  // for the class.
  // The following comparison will evaluate to true because
  // person5 and person7 have the same values.
  if person5 == person7 {
    print("person5 and person7 have the same values")
  } else {
    print("person5 and person7 have different values")
  }

  // The properties we've seen so far are stored properties.
  // There are also computed properties. These are properties
  // that don't store a value but provide a getter and an
  // optional setter to get and set other properties or
  // perform some computation.
  // All computed properties must be declared as variable
  // since the values they return are not fixed.
  class Circle {
    var radius: Double = 0.0

    // This is a computed property. It does not store a value
    // but provides a getter and an optional setter to get and
    // set the circumference of the circle.
    var circumference: Double {
      get {
        return 2 * Double.pi * radius
      }
      set(newCircumference) {
        radius = newCircumference / (2 * Double.pi)
      }
    }

    // Note that this computed property's setter does not take a 
    // parameter. Instead, it uses the implicit newValue parameter
    // in the setter. This is a default name for the value being set.
    // It's a shorthand for a setter that takes a parameter.
    var diameter: Double {
      get {
        return radius * 2
      }
      set {
        radius = newValue / 2
      }
    }

    // This is a read-only computed property. It does not
    // store a value but provides a getter to get the area
    // of the circle.
    // Notice that the getter does not have a get keyword.
    // It is implicit. This is a shorthand for a read-only
    // computed property.
    var area: Double {
      return Double.pi * radius * radius
    }
  }

  // A lazy stored property is a property whose initial value
  // is not calculated until the first time it is used. You
  // indicate a lazy stored property by using the lazy keyword.
  // You must also mark the property as a variable (var) because
  // its value is not known until after initialization.
  
  // This example is taken from the Swift documentation.

  // This is a simulated data importer that reads data from
  // a file and imports it into the application.
  // It is supposed to be a heavy operation that is not
  // needed immediately.
  class DataImporter {
    var filename = "data.txt"
  }

  // This is a data manager that manages data imported by
  // the data importer.
  class DataManager {
    // By declaring the importer property as lazy, the importer
    // property is only created when it is first accessed.
    // Note that lazy properties are always variables. (i.e.
    // they are declared with the var keyword.)
    lazy var importer = DataImporter()
    var data = [String]()
  }
  let manager = DataManager()
  manager.data.append("Some data") // The importer property is not
                                   // created yet
  print(manager.importer.filename) // Prints data.txt. The importer
                                   // property is created here.

  // Properties can have observers that observe and respond to
  // changes in the property's value. You can add property observers
  // to stored properties and computed properties that have been
  // inherited. You can't add property observers to computed properties
  // defined in the same class (you don't need an observer) or lazy
  // stored properties because they are initialized only once.
  // The example below adds property observers to the radius
  // property of the Circle2 class.
  class Circle2 {
    // The radius property is a stored property. It is initialized
    // to zero and has property observers.
    var radius: Double = 0.0 {
      // The willSet observer is called just before the value
      // of the property is set. It is passed the new value
      // as a parameter.
      willSet(newRadius) {
        print("About to set radius to \(newRadius)")
      }
      // The didSet observer is called just after the value
      // of the property is set. It is passed the old value
      // as a parameter.
      didSet(oldRadius) {
        print("Just changed \(oldRadius) radius to \(radius)")
      }
    }

    // You cannot have a willSet/didSet observer on a computed property
    // unless it is inherited from a base class.
    var diameter: Double {
      get {
        return radius * 2
      }
      set {
        radius = newValue / 2
      }
      // Not legal
      /*
      willSet {
        print("About to set diameter to \(newValue)")
      }
      didSet(oldDiameter) {
        print("Just changed diameter from \(oldDiameter) to \(diameter)")
      }
      */
    }
  }

  let circle2 = Circle2()
  // The follwing will result in the following output:
  // About to set radius to 10.0
  // Just changed 0.0 radius to 10.0
  circle2.radius = 10.0

  // The following will result in the following output:
  // About to set diameter to 30.0
  // Just changed diameter from 20.0 to 30.0
  circle2.diameter = 30.0

  // You can also use type properties (also called static
  // properties). These are properties that
  // belong to the type itself and not to instances of the type.
  // You define type properties using the static keyword.
  // Type properties are useful for defining properties that are
  // shared by all instances of a class or structure.
  class SomeClass {
    static var someProperty = 0
  }
  SomeClass.someProperty = 10
  print(SomeClass.someProperty) // Prints 10

  // There is another type of property the is also shared by all
  // instances of a class or structure. It is called a class
  // property. Class properties are different from static properties
  // in the following ways. First, class properties cannot be stored
  // properties (lazy or otherwise). They must be computed properties.
  // Second, class properties can be overridden by subclasses.
  // You define class properties using the class keyword.
  class SomeClass2 {
    static var value = 10
    class var someProperty: Int {
      // Within a class property, you can refer to the class
      // itself using the self keyword. Strictly speaking
      // self is not necessary in this case. But it is used
      // to demonstrate the use of self in this context.
      return self.value + 1
    }
  }

  class SubClass2: SomeClass2 {
    static var subClassValue = 20
    override class var someProperty: Int {
      // Within a class property, you can refer to the class
      // itself using the self keyword. But it is optional
      // by default type variables can be accessed without
      // the self keyword.
      return subClassValue + 2
    }
  }

  print(SomeClass2.someProperty) // Prints 11
  print(SubClass2.someProperty) // Prints 22

  // A property wrapper is a generic structure that encapsulates
  // the logic for accessing a property. It is a way to add
  // custom behavior to a property without changing the property
  // itself. You define a property wrapper by creating a structure
  // that has a wrappedValue property and a projectedValue property.
  // The wrappedValue property is the actual value of the property
  // and the projectedValue property is the value that is projected
  // when you access the property.
  // The example below defines a property wrapper that adds
  // a prefix to a string.
  @propertyWrapper
  struct Prefix {
    // The wrappedValue property is the actual value of the
    // property. It is accessed using the dot syntax.
    var wrappedValue: String {
      get { return prefix + name }
      set { name = newValue }
    }

    // The projectedValue property is the value that is projected
    // when you access the property. It is accessed using the
    // dollar sign ($) followed by the property name.
    var projectedValue: String {
      get { return name }
    }

    // Need to define an initializer, because the default
    // initializer won't work when name is declared to be
    // private.
    init(prefix: String) {
      self.prefix = prefix
    }

  
    var prefix: String // This is the prefix
    private var name: String = "" // This is the persons name
  }

  // The example below uses the Prefix property wrapper to add
  // a prefix to a string.
  struct RespectfullyAddressedPerson {
    // Note that there is no storage associated
    // with the var name. The storage is provided
    // by the prefix class.
    // But code can treat the name variable like ordinary
    // string.
    @Prefix(prefix: "Mr. ")
    var name: String
    
    // We declare an initializer because the default
    // memberwise initializer does not work with property
    // wrappers.
    init(name: String = "") {
      self.name = name
    }
  }
  
  let person8 = RespectfullyAddressedPerson(name: "Del Piero")
  print(person8.name) // Prints Mr. Del Piero
  print(person8.$name) // Prints Del Piero (The projected value)
  
  // The projected value need not be reflection of the original value
  // it can be something completely different.

  // For example consider a property wrapper that stores values
  // into a database. The wrapped value is the value that is
  // stored in the database and the projected value is the
  // key that is used to store the value in the database.
  // The example below defines a property wrapper that stores
  // values in a database.
  @propertyWrapper
  struct Database {
    var wrappedValue: String {
      get { return database[key] ?? "" }
      set { database[key] = newValue }
    }

    var projectedValue: String {
      get { return key }
    }

    private var key: String
    private var database: [String: String] = [:]

    init(key: String) {
      self.key = key
    }
  }

  // The example below uses the Database property wrapper to store
  // values in a database.
  struct Person9 {
    @Database(key: "NAME")
    var name: String
  }
  // The name property is stored in the database using the key "NAME".
  var person9 = Person9()
  person9.name = "Del Vecchio"
  print(person9.name) // Prints Del Vecchio
  print(person9.$name) // Prints NAME

  // Combining property wrappers (i.e. composing them) is possible
  // but requires complex techniques that make such code hard
  // both create and understand. For now I will leave a link to
  // a blog post that explains how to do it.
  // https://noahgilmore.com/blog/nesting-property-wrappers/

  // Static functions are functions that belong to the type itself
  // and not to instances of the type. You define static functions
  // using the static keyword.
  class SomeClass3 {
    static var someProperty = 0
    static func someMethod() {
      SomeClass.someProperty += 1
      print("Some property: \(SomeClass.someProperty)")
    }
  }
  SomeClass3.someMethod() // Prints Some property: 1

  // Class functions are also functions that belong to the type
  // itself and not to instances of the type. You define class
  // functions using the class keyword. Unlike static functions,
  // class functions can be overridden by subclasses.
  // Note that for the purposes of this discussion, computed
  // properties are also functions.
  class SomeClass4 {
    class var someProperty: Int {
      return 0
    }
    class func someMethod() {
      print("Some property: \(someProperty)")
    }
  }

  SomeClass4.someMethod() // Prints Some property: 0

  class SubClass4: SomeClass4 {
    var value: Int = 1;
    override class var someProperty: Int {
      return 1
    }
  }
  SubClass4.someMethod() // Prints Some property: 1

  // You can define subscripts for classes, structures, and enumerations
  // to provide a shortcut for accessing the elements of a collection,
  // list, or sequence. You use the subscript keyword to define a
  // subscript. Subscripts are declared in the same way as computed
  // properties, but with the subscript keyword.
  // The exampe below defines a subscript for a DatabaseTable class
  // that allows you to access the rows of the table using the row
  // number.
  class DatabaseTable {
    var rows = ["Row 1", "Row 2", "Row 3"]

    subscript(index: Int) -> String {
      get {
        return rows[index]
      }
      set(newValue) {
        rows[index] = newValue
      }
    }
  }
  // You can access the rows of the table using the subscript.
  let table = DatabaseTable()
  print(table[0]) // Prints Row 1
  table[0] = "New Row 1"
  print(table[0]) // Prints New Row 1
  print(table[1]) // Prints Row 2

  // You can also define subscripts that take multiple parameters.
  // The example below defines a subscript for a Matrix class that
  // allows you to access the elements of the matrix using row and
  // column numbers.
  struct Matrix {
    var rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    subscript(row: Int, column: Int) -> Int {
      get {
        return rows[row][column]
      }
      set(newValue) {
        rows[row][column] = newValue
      }
    }
  } 
  // You can access the elements of the matrix using the subscript.
  var matrix = Matrix()
  print(matrix[0, 0]) // Prints 1
  matrix[0, 0] = 10
  print(matrix[0, 0]) // Prints 10
  print(matrix[1, 1]) // Prints 5

  // The subscripts described above are instance subscripts. You can
  // also define type subscripts that are called on the type itself
  // and not on instances of the type. You define type subscripts
  // using the static keyword.
  // The example below defines a type subscript for a Planets
  // enumeration.
  enum Planets: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune

    static subscript(index: Int) -> Planets {
      return Planets(rawValue: index)!
    }
  }

  // You can access the planets using the type subscript.
  let planet = Planets[3]
  print(planet) // Prints earth
  // You can interate over the planets using the raw values.
  for i in 1...8 {
    print(Planets[i])
  }

  // Classes can also have deinitializers. A deinitializer is called
  // immediately before a class instance is deallocated. You define
  // a deinitializer using the deinit keyword:
  class CustomFile {
    var filename: String

    init(filename: String) {
      // Simulate opening a file
      self.filename = filename
      print("Opening file \(filename)")
    }

    deinit {
      // Simulate closing a file
      print("Closing file \(filename)")
    }
  }

  // The deinitializer is called when the instance of the class is
  // deallocated. This happens when the instance goes out of scope
  // or when the reference to the instance is set to nil.
  var file: CustomFile? = CustomFile(filename: "data.txt")
  print("file?.filename = \(String(describing: file?.filename))")
  file = nil // Prints Closing file data.txt

  // It also works in situations where an exception is thrown
  class CustomError: Error {
    var message: String

    init(message: String) {
      self.message = message
    }
  }

  func funcThatThrows() throws {
    let file = CustomFile(filename: "file-in-func-that-throws.txt")
    if file.filename == "file-in-func-that-throws.txt" {
      throw CustomError(message: "An error occurred")
    }
    // The deinitializer is called on file when the exception is
    // thrown
  }

  do {
    try funcThatThrows()
  } catch {
    print("Caught error")
  }
}

func exploreInheritance() {
  // Inheritance is a way to define a new class based on an existing
  // class. The new class inherits the properties and methods of the
  // existing class. The existing class is called the superclass and
  // the new class is called the subclass.
  // E.g.:
  class Person {
    let name: String
    let age: Int

    // This is a normal initializer. It is refered to as a designated
    // initializer.
    init(name: String, age: Int) {
      self.name = name
      self.age = age
    }

    // You can have more than one initializer for a class
    // for example. This initializer will always create
    // a person named John Doe aged 28. These initializers
    // are called convenience initializers and are marked
    // with the keyword convenience. Convenience initializers
    // can call designated initializer or other convenience
    // initializers in the same class, but not initializers
    // in the superclass.
    convenience init() {
      self.init(name: "John Doe", age: 28)
    }

    func greet() -> String {
      return "Hi! I am \(name). I am \(age) years old"
    }
  }

  let bob = Person(name: "Bob", age: 45)
  print(bob.greet())

  // We can inherit from Person:
  class Employee: Person {
    let job: String

    // The initializer of this class does NOT need an override
    // modifier because it is actually a different fuction. The
    // signature is different; there is an additional job parameter.
    // It needs to delegate the initialization of the name and age to
    // the superclass's initializer. It cannot initialize superclass
    // properties directly.
    init(name: String, age: Int, job: String) {
      // self.name = name // Error. Cannot directly initialize a
                          // superlcass property.
      // self.age = age   // Error. Cannot directly initialize a
                          // superlcass property.

      // You cannot call super init, without initializing this class's
      // properties first.
      // super.init(name: name, age: age) // This will not work.
      self.job = job

      // Ok. And required. You must call the initializer here.
      // Unless a suitable empty designated initializer is available
      // in the superclass. Then it is called by default.
      super.init(name: name, age: age)
    }

    // You can also have a convenience initializer for
    // Employee. But a convenience initializer cannot
    // call a superclass initializer. These rules for initializers
    // ensure that it is not possible to use a property that has not
    // been initialized.
    convenience init() {
      // self.job = "Janitor"  // This is pointless, you need to
                               // delegate to the designated
                               // initializer anyway.
      // super.init()  // Error. Cannot delegate to superclass
                       // initializer
      // super.init(name: "John Doe", age: 28)  // Error. No joy.
                                                // Cannot delegate to 
                                                // a superlcass
                                                // initializer

      // Ok. And required. Delegating to a designated initializer
      // in the same class.
      self.init(name: "John Doe", age: 28, job: "Programmer")
    }

    // You can override methods with the override keyword.
    override func greet() -> String {
      // You can call the superclass's method using the super keyword.
      let prefix = super.greet()
      return prefix + " I'm a \(job)"
    }
  }

  let alice = Employee(name: "Alice", age: 25, job: "Programmer")
  print(alice.greet())

  // You cannot inherit from a struct.
  struct NotSubclassableShape {
    var name: String

    init(name: String) {
      self.name = name
    }

    func description() -> String {
      return "A \(name)"
    }
  }

  // Error: Inheritance from non-protocol, non-class type 'Shape
  /*
  struct Polygon: NotSubClassableShape {

  }
  */

  // A struct cannot inherit from a class either.
  // Stucts cannot particiapte in inheritance at all.
  class Shape {
    var name: String

    init(name: String) {
      self.name = name
    }

    func description() -> String {
      return "A \(name)"
    }
  }

  // Error: Inheritance from non-protocol, non-class type 'Shape2'
  /*
  struct Polygon: Shape2 {
  }
  */

  // You can override properties of a superclass. But the property must not
  // be immutable. So name can be changed only during initialization as
  // shown below: the prefix 'Dr.' is added to the person's name.
  class Doctor: Person {
    var specialization: String

    init(name: String, age: Int, specialization: String) {
      self.specialization = specialization
      super.init(name: "Dr. " + name, age: age)
    }

    override func greet() -> String {
      return super.greet() + ". I am a \(specialization)."
    }
  }

  // With this definition of a person, you can change
  // the name of the person after initialization.
  class Person2 {
    var name: String
    var age: Int

    init(name: String, age: Int) {
      self.name = name
      self.age = age
    }

    func greet() -> String {
      return "Hi! I am \(name). I am \(age) years old"
    }
  }

  let person2 = Person2(name: "Alice", age: 25)
  print(person2.greet())
  person2.name = "Alice Smith"
  print(person2.greet())

  // When you derive a class from Person2, the name property
  // can be overridden, because it is a variable.
  class Doctor2: Person2 {
    var specialization: String

    init(name: String, age: Int, specialization: String) {
      self.specialization = specialization
      super.init(name: name, age: age)
    }

    // Here the name property is being overridden. The name
    // is prefixed with 'Dr.'. When you override a property
    // you must override both the getter and the setter.
    override var name: String {
      get {
        return "Dr. " + super.name
      }
      set {
        super.name = newValue
      }
    }

    override func greet() -> String {
      return super.greet() + ". I am a \(specialization)."
    }
  }

  let drSmith = Doctor2(name: "Alice", age: 25, specialization: "Cardiologist")
  print(drSmith.greet())

  // You can use overrides to add property observers to properties
  // of a superclass. The example below adds property observers to
  // the specialization property of the Doctor2 class to keep track
  // of the doctor's job history.

  class DoctorWithJobHistory: Doctor2 {
    var jobHistory: [String] = []

    // Here the ovrride keyword is required, since the subclass
    // needs to initialize the jobHistory property with the
    // initial value of the specialization property.
    override init (name: String, age: Int, specialization: String) {
      super.init(name: name, age: age, specialization: specialization)
      jobHistory.append(specialization)
    }

    // We override the specialization property to add the
    // specialization to the jobHistory property when it is
    // changed.
    override var specialization: String {
      didSet {
        jobHistory.append(specialization)
      }
    }
  }

  let drJones = DoctorWithJobHistory(name: "Indiana Jones", age: 38, specialization: "Resident in Internal Medicine")
  print(drJones.greet())
  // Let's promote Dr. Jones
  drJones.specialization = "Attending Physician in Internal Medicine"
  // Prints ["Resident in Internal Medicine", "Attending Physician in Internal Medicine"]
  print(drJones.jobHistory)

  // You can use the final keyword to prevent a class from being
  // subclassed.
  final class FinalClass {
    var name: String

    init(name: String) {
      self.name = name
    }
  }

  // Error: Inheritance from a final class 'FinalClass'
  /*
  class SubClass: FinalClass {
  }
  */

  // You can declare individual methods or properties as final
  // to prevent them from being overridden in subclasses, rather
  // than the entire class.
  class BaseClass {
    final func finalMethod() {
      print("This method cannot be overridden")
    }

    func nonFinalMethod() {
      print("This method can be overridden")
    }
  }

  class SubClass: BaseClass {
    // Error: Cannot override final method
    /*
    override func finalMethod() {
      print("This method cannot be overridden")
    }
    */

    // This is okay
    override func nonFinalMethod() {
      print("This method has been overridden")
    }
  }

  let sub = SubClass()
  sub.finalMethod() // Prints This method cannot be overridden
  sub.nonFinalMethod() // Prints This method has been overridden

  // Unlike languages such as Java, Swift does not have the concept
  // of abstract classes. You cannot declare a class or a method as
  // abstract.
  // There are two ways to achieve the same effect in Swift. The first
  // is to use a protocol. You can define a protocol with the required
  // methods and properties and then have the classes that need to
  // implement the methods and properties conform to the protocol.
  // See protocols.swift for more information on protocols.
  // E.g.
  protocol Shape3 {
    var area: Double { get }
    var perimeter: Double { get }
  }

  class Circle: Shape3 {
    var radius: Double

    init(radius: Double) {
      self.radius = radius
    }

    var area: Double {
      return Double.pi * radius * radius
    }

    var perimeter: Double {
      return 2 * Double.pi * radius
    }
  }

  let circle = Circle(radius: 5)
  print("Area: \(circle.area), Perimeter: \(circle.perimeter)")

  // The second way to achieve the same effect is to use a class
  // with a method that throws an error. The method can be marked
  // as abstract by throwing an error. The subclass must override
  // the method and provide an implementation.
  // E.g.

  // This is just the error that is thrown when the abstract
  // method is called.
  class AbstractMethodError: Error {
    var message: String

    init(message: String) {
      self.message = message
    }
  }

  class AbstractClass {
    func aMethod() throws {
      throw AbstractMethodError(message: "This method is abstract")
    }
  }

  class ConcreteClass: AbstractClass {
    override func aMethod() {
      print("This is the concrete implementation")
    }
  }

  let concrete = ConcreteClass()
  concrete.aMethod() // Prints This is the concrete implementation

  // In general, it is better to use protocols to define abstract
  // classes in Swift.

  // A class can force a subclass to implement an initializer by
  // using the required keyword. The subclass must implement the
  // required initializer.
  class BaseClass2 {
    required init() {
      print("BaseClass2 initializer")
    }
  }

  class SubClass2: BaseClass2 {
    let member = 10
    // This won't work, because, even though it matches the signature
    // of the required initializer, it is not marked as required.
    /*
    init() {
      print("SubClass2 initializer")
    }
    */

    // This is fine. It is marked as required.
    required init() {
      print("SubClass2 initializer")
    }
  }

  // Now you can create an instance of the subclass.
  let sub2 = SubClass2()
  print(sub2.member)

  // You *have* to define the exact signatue of the required
  // initializer. Otherwise you get a compile time error.
  class SubClass3: BaseClass2 {
    let member: String

    // This is not the required initializer init()
    // This can be present but is not sufficient.
    init(member: String) {
      self.member = member
      print("SubClass3 initializer")
      super.init() // You can call this explicity if you wish.
    }

    // You must have this required initializer as well.
    required init() {
      member = "Default"
      print("SubClass3 initializer")
      // super.init() is called implicity.
    }
  }

  // Now you can create an instance of the subclass.
  let sub3 = SubClass3()
  print(sub3.member)

  // A class can have a failible initializer as well. This is
  // useful in situations where the initialization can fail.
  // E.g.:
  // For the class below, the initializer will fail if the filename
  // is empty.
  class Database {
    init?(filename: String) {
      if filename.isEmpty {
        return nil
      }
      print("Opening database \(filename)")
    }

    func store(data: String) {
      print("Storing \(data)")
    }
  }
  // In this situation, constructing a new Database will result
  // in an optional Database instance.
  let database:Database? = Database(filename: "data.db") // Prints Opening database data.db
  print("Type of database: \(type(of: database))") // Prints Type of database: Optional<Database>
  if let database: Database = database {
    print("Database opened successfully")
    database.store(data: "some stuff")
  } else {
    print("Failed to open database")
  }

  // You can also create failible initializer which returns an
  // implicitly unwrapped optional. This is useful when you are
  // sure that the initialization will not fail.
  // E.g.:
  class Database2 {
    init!(filename: String) {
      if filename.isEmpty {
        return nil
      }
      print("Opening database \(filename)")
    }

    func store(data: String) {
      print("Storing data: \(data)")
    }
  }

  // In this situation, constructing a new Database2 will result
  // in an implicitly unwrapped optional Database2 instance.
  // Prints Opening database data.db
  let database2:Database2! = Database2(filename: "data.db")
  // Prints Type of database2: Optional<Database2>
  print("Type of database2: \(type(of: database2))")
  // You can however directly use the instance without unwrapping it.
  database2.store(data: "Some data") // Note that you can call the
                                     // method directly without
                                     // unwrapping.

  // In general, it is better to use a failible initializer that
  // returns an optional rather than an implicitly unwrapped optional.
}

func exploreAdvancedClassConcepts() {
  // A class, struct or enum can be nested within another class, struct
  // or enum. This is useful when the nested type is only used by the
  // enclosing type. The nested type can access the properties and
  // methods of the enclosing type.
  // E.g.:
  class Car {
   // The Engine class is nested within the Car class. It is only
    // used by the Car class.
    class Engine {
      var horsepower: Int
      var displacement: Double

      init(horsepower: Int, displacement: Double) {
        self.horsepower = horsepower
        self.displacement = displacement
      }

      func description() -> String {
        return "\(horsepower) hp, \(displacement) L"
      }
    }

    let make: String
    let model: String
    let year: Int
    let engine: Engine


    init(make: String, model: String, year: Int, horsepower: Int, displacement: Double) {
      self.make = make
      self.model = model
      self.year = year
      self.engine = Engine(horsepower: horsepower, displacement: displacement)
    }

 

    func description() -> String {
      return "A \(year) \(make) \(model)"
    }
  }

  let car = Car(make: "Toyota", model: "Corolla", year: 2020, horsepower: 140, displacement: 1.8)
  print(car.description())
  print(car.engine.description())

  // You can reference the nested type using the dot syntax.
  let engine = Car.Engine(horsepower: 140, displacement: 1.8)
  print(engine.description())
}


// Extensions are a way to add new functionality to an existing class,
// struct, enum, or protocol. You don't have to have access to the
// source code of the class. You can add new properties, methods,
// subscripts, and initializers to an existing type using extensions.
// However, extensions must be declared at file scope. They cannot be
// used to extend a type within a function or method. Hence, this
// example is shown at file scope.
class FileScopePerson {
  var name: String
  var age: Int

  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }

  func greet() -> String {
    return "Hi! I am \(name). I am \(age) years old"
  }
}

// This extension adds a new method to the FileScopePerson class.
// It also modifies the greet method.
extension FileScopePerson {
  func shout() -> String {
    return "I'm \(name) damn it!. I'm bloody \(age) years old! Ain't I?"
  }

  // As the name extension implies. You can add new functionality.
  // but you cannot modify existing methods or override them.
  // For that use inheritance.
  // Won't work with or without the override keyword.
  /*
  override func greet() -> String {
    return "Grumble. I'm not feeling talkitive today"
  }
  */

  // Extensions can add new properties to a class. But they cannot
  // add stored properties to a class. They can only add computed
  // properties. Below is an example of a computed property.
  // Note that it is short-hand way to define just a getter.
  var description: String {
    return "Name: \(name), Age: \(age)"
  }

  // You can also add new initializers to a class using an extension.
  // This initializer is a convenience initializer. It initializes
  // the name and age properties to default values.
  convenience init() {
    self.init(name: "John Doe", age: 28)
  }

  // You can also add mutating methods to a class using an extension.
  // This method changes the name of the person to uppercase.
  // If extending a struct or enum use the mutating keyword to allow the
  // method to change the properties of the struct.
  func shoutName() {
    name = name.uppercased()
  }

  // You can also define subscripts in an extension.
  // This subscript returns the name of the person if the index is 0
  // and the age of the person if the index is 1.
  subscript(index: Int) -> String {
    if index == 0 {
      return name
    }
    if index == 1 {
      return String(age)
    }
    return ""
  }

  // Extensions can add pretty much anything to a class, except
  // for stored properties. You can add nested types, type properties,
  // type methods, type subscripts, static methods, and
  // static properties.
}

func exploreExtensions() {
  // Now we can use the shout method on the FileScopePerson class.
  let angryPerson = FileScopePerson(name: "Alice", age: 25)
  print (angryPerson.shout())
  print(angryPerson.shout())
  // And the computed description property.
  print(angryPerson.description)

  // And mutating method.
  angryPerson.shoutName()
  print(angryPerson.shout())

  // And the convenience initializer.
  let defaultPerson = FileScopePerson()
  print(defaultPerson.greet())
  print(defaultPerson.description)
  print(defaultPerson.shout())

  // And the subscript
  print(defaultPerson[0]) // Prints John Doe
  print(defaultPerson[1]) // Prints 28
}
