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
  let person = Person()
  person.name = "Sanjay"
  person.age = 60
  print(person.description())

  var rectangle = Rectangle()
  rectangle.width = 10
  rectangle.height = 20
  print(rectangle.area())

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
  // complex computation). This is because they have a default
  // memberwise initializer.
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
  // inherited. You can't add property observers to lazy stored
  // properties because they are initialized only once.
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
      //didSet(oldRadius) {
      //  print("Just changed \(oldRadius) radius to \(radius)")
      //}
    }

    // You cannot have a willSet observer on a computed property
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
}
