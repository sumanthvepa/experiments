//-*- coding: utf-8 -*-
/**
  protocols.swift: Explore protocols
*/
/* -------------------------------------------------------------------
 * protocols.swift: Explore protocols
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

func exploreProtocols() {
  // Protocols are a way of defining a blueprint of methods,
  // properties, and other requirements that suit a particular task
  // or piece of functionality. The protocol can then be adopted by a
  // class, structure, or enumeration to provide an actual
  // implementation of those requirements. Any type that satisfies
  // the requirements of a protocol is said to conform to that
  // protocol.
  // Protocols are similar to interfaces in other languages like Java.

  // A protocol can require any properties, methods, or initializers
  // that a conforming type must provide.
  protocol Vocal {
    // This is a read only property
    var maxVolume: Int { get }
    func speak()
  }

  protocol Ambulatory {
    // This is a read-only
    var numberOfLegs: Int { get }
    // This is a read-write property
    var maxSpeed: Double { get set }
    func walk()
  }

  class Person: Vocal, Ambulatory {
    // A read-only property can be implemented either
    // as a variable or a let constant
    let numberOfLegs: Int = 2
    
    // You can provide more functionality than the protocol
    // requires. But not less.  Here, maxVolume can be
    // adjusted, unlike in the protocol where it is
    // read only.
    var maxVolume: Int = 10
    
    var maxSpeed: Double = 5.0
    

    func speak() {
      print("Hello, World!")
    }

    func walk() {
      // Walking makes the person breathless
      maxVolume -= 2
      print("Walking...")
    }
  }

  let person = Person()
  person.speak()
  person.walk()
  print("Person's max volume is \(person.maxVolume)")
  print("Person's max speed is \(person.maxSpeed)")

  // You can use a protocol as a type
  let vocal: Vocal = person
  vocal.speak()

  // You can use a protocol as a type of a parameter
  func makeVocalSpeak(vocal: Vocal) {
    vocal.speak()
  }

  makeVocalSpeak(vocal: person)

  // You can use a protocol as a type of a return value
  func makeVocal() -> Vocal {
    return person
  }
  let vocalPerson: Vocal = makeVocal()
  vocalPerson.speak()

  // You can use a protocol as a type of a collection
  let vocals: [Vocal] = [person, vocalPerson]
  for vocal in vocals {
    vocal.speak()
  }

  // You can use a protocol as a type of a dictionary
  let vocalDictionary: [String: Vocal] = ["person": person, "vocalPerson": vocalPerson]
  for (key, vocal) in vocalDictionary {
    print("\(key) says:")
    vocal.speak()
  }

  // ... or in an array
  let vocalArray: [Vocal] = [person, vocalPerson]
  for vocal in vocalArray {
    vocal.speak()
  }

  // You can cast a protocol to a class by checking if the
  // the protocoal object is an instance of the class
  if let vp = vocal as? Person {
    print("Person has \(vp.numberOfLegs) legs")
  }
  // If all you want to do is check if the object is an instance
  // of a class, you can use the is keyword
  if vocal is Person {
    print("Vocal is a Person")
  }

  // You can constrain a generic function to only
  // accept types that confirm to a protocol
  func sayNTimes<T: Vocal>(speaker: T, times: Int) {
    for _ in 0..<times {
      vocal.speak()
    }
  }
  // Now only types that confirm to the protocol Vocal will
  // can be passed to sayNTimes.
  // This okay. Person conforms to protocol Vocal
  let person1: Person = Person()
  sayNTimes(speaker: person1, times: 3)
  
  struct QuietPerson {
    
    func speak() {
      print("Speak quietly, but carry a big stick")
    }
  }
  
  let qp = QuietPerson()
  qp.speak()
  
  // Won't work QuietPerson does not conform to
  // the Vocal protocal even though it has a
  // speak method.
  // sayNTimes(speaker: qp, times: 5)
  
  // You can also define a class whose generic parameter is
  // constrained by the protocol.
  class VocalSpeaker<T: Vocal> {
    var vocal: T
    init(vocal: T) {
      self.vocal = vocal
    }
    func speak() {
      vocal.speak()
    }
  }
  
  // Okay Person conforms to protocol Vocal
  let vp2 = VocalSpeaker<Person>(vocal: person)
  vp2.speak()
  // You can also let Swfit infer the generic parameter of VocalSpeaker
  let vp3 = VocalSpeaker(vocal: person)
  vp3.speak()
  
  // Not okay. QuietPerson does not conform to protocol Vocal
  // let vp4 = VocalSpeaker<QuietPerson>(vocal: qp)
}

// A particularly useful technique is to use an extension to conditionally
// conform to a protocol.
// Here Array is extended conditionally using where clause to specify
// that the extension is only to be used when Element conforms to the
// a
protocol TextRepresentable {
  var textualDescription: String { get }
}

extension Array: TextRepresentable where Element: TextRepresentable {
  var textualDescription: String {
    let itemsAsText = self.map { $0.textualDescription }
    return "[" + itemsAsText.joined(separator: ", ") + "]"
  }
}

func exploreConditionalProtocolConformance() {
  class Machine: TextRepresentable {
    var name: String
    init(name: String) {
      self.name = name
    }
    var textualDescription: String {
      return "Machine: \(name)"
    }
  }

  class Person: TextRepresentable {
    var name: String
    init(name: String) {
      self.name = name
    }
    var textualDescription: String {
      return "Person: \(name)"
    }
  }

  class Image {
    var name: String
    init(name: String) {
      self.name = name
    }
  }

  // Okay. Machine and Person conform to TextRepresentable
  // So you can call textualDescription on an Array of them
  // as an extension has been added to Array to conform to
  // TextRepresentable when Element conforms to TextRepresentable
  let machines = [Machine(name: "Mac"), Machine(name: "PC")]
  print(machines.textualDescription)

  // However, Image does not conform to TextRepresentable
  // so an array of Image will not have the textualDescription
  // property, as the extension is not applicable to it.
  let images: [Image] = [Image(name: "Image1"), Image(name: "Image2")]
  // This will not compile as Image does not conform to TextRepresentable
  // print(images.textualDescription)
  // You'll have to manually generate the text representation
  for image in images {
    print(image.name)
  }
}

func exploreAssociatedTypes() {
  // You cannot have a generic protocol. So for example
  // the following will not compile:
  /*
  protocol GenericProtocol<T> {
    var value: T { get }
  }
  */

  // However, you can use associated types to achieve the same
  // effect. Here is an example of a protocol with an associated
  // type
  protocol Container {
    associatedtype Item
    var items: [Item] { get set }
    mutating func append(item: Item)
  }

  // You can use the associated type in a class that conforms
  // to the protocol
  class Stack<T>: Container {
    typealias Item = T // This is not necessary, the Swift compiler
                       // will infer this,  but it is a good practice
    var items: [T] = []
    func append(item: T) {
      items.append(item)
    }
  }
  
  let strStack = Stack<String>()
  strStack.append(item: "a")
  strStack.append(item: "b")
  for n in 0..<strStack.items.count {
    print("strStack[\(n)] = \(strStack.items[n])")
  }

  // You can also have concrete types that conform to the protocol
  struct IntStack: Container {
    var items: [Int] = []
    mutating func append(item: Int) {
      items.append(item)
    }
  }
  
  var intStack = IntStack()
  intStack.append(item: 1)
  intStack.append(item: 2)
  for n in 0..<intStack.items.count {
    print("intStack[\(n)] = \(intStack.items[n])")
  }
}

func exploreOpaqueTypes() {
  protocol Shape {
    func draw() -> String
  }
  
  struct Triangle: Shape {
    private let drawing: String
    
    init(size: Int) {
      var lines: [String] = []
      for n in 1...size {
        let line = String(repeating: "*", count: n)
        lines.append(line)
      }
      self.drawing = lines.joined(separator: "\n")
    }
    
    func draw() -> String {
      return self.drawing
    }
  }
  
  struct Rectangle: Shape {
    private let drawing: String
    
    init(width: Int, height: Int) {
      var rectangle: String = ""
      for _ in 0..<height {
        for _ in 0..<width {
          rectangle.append("*")
        }
        rectangle.append("\n")
      }
      self.drawing = rectangle
    }
    
    func draw() -> String {
      return drawing
    }
  }
  
  struct FlippedShape<T: Shape>: Shape {
    private let drawing: String
    
    init(shape: Shape) {
      let lines = shape.draw().split(separator:"\n")
      self.drawing = lines.reversed().joined(separator: "\n")
    }
    
    func draw() -> String {
      return self.drawing
    }
  }
  
  struct JoinedShape<T: Shape, U: Shape>: Shape {
    private let drawing: String
    
    init(top: T, bottom: U) {
      self.drawing = top.draw() + "\n" + bottom.draw()
    }
    
    func draw() -> String {
      return drawing
    }
  }
  
  let triangle = Triangle(size: 5)
  let flippedTriangle = FlippedShape<Triangle>(shape: triangle)
  print(triangle.draw())
  print("\n")
  print(flippedTriangle.draw())
  let rectangle = Rectangle(width: 5, height: 4)
  print(rectangle.draw())
  
  // There are multiple ways to return a Shape type in Swit
  
  // This returns an object that conforms to the shape protocol
  func makeAShape(description: String) -> Shape {
    // This should return an object conforming to the
    // protocol. It can decide which subtype to return
    // dynamically at runtime.
    // Note that here depending on the description
    // string they actual type of shape can vary.
    // It can be a rectangle or a triangle.
    if description == "rectangle" {
      return Rectangle(width: 5, height: 10)
    }
    return Triangle(size: 5);
  }
  
  var aShape1 = makeAShape(description: "triangle")
  print("type(of: aShape1) = \(type(of: aShape1))")
  
  // You can call makeAShape with a different parameter
  // and get a different subtype
  aShape1 = makeAShape(description: "rectangle")
  print("type(of: aShape1) = \(type(of: aShape1))")
  let rectangle1 = aShape1 // We're storing this object for later.
  print("type(of: rectangle1) = \(type(of: rectangle1))")
  
  // Notice that the actual type of shape changed
  // between invocations.

  // Another way is for a function to return a
  // specific subtype of Shape.
  // For example makeTrapezoid could explicitly
  // specify that it returns a type JoindShape<Triangle, JoinedShape<Rectangle, FlippedShape<Triangle> > >
  func makeTrapezoid1(size: Int) -> JoinedShape<Triangle, JoinedShape<Rectangle, FlippedShape<Triangle> > > {
    let top = Triangle(size: size)
    let middle = Rectangle(width: size, height: 4)
    let bottom = FlippedShape<Triangle>(shape: top)
    let trapazoid = JoinedShape(top: top, bottom: JoinedShape(top: middle, bottom: bottom))
    return trapazoid
  }
  
  // Now the caller can call makeTrapezoid1 to get a trapezoid
  var aShape2 = makeTrapezoid1(size: 5)
  // The inferred type of trapezoid1 is this complex type.
  // JoinedShape<Triangle, JoinedShape<Rectangle, FlippedShape<Triangle> > >
  print("type(of: aShape2) = \(type(of: aShape2))")
  
  // You can call makeTrapezoid1 with different parameters
  aShape2 = makeTrapezoid1(size: 6)
  // But the actual concrete type of Shape2 is always the same.
  print("type(of: aShape2) = \(type(of: aShape2))")
  

  // However, the complex return type is really unnecessarily specific. All that the caller
  // needs to know is that the caller needs to know is that makeTrapezoid returns
  // a *specific* type of Shape. And exactly that type. The type will not vary
  // at runtime it is known precisely at compile time. It's just that the caller
  // need not know exectly what that type is. To allow this we use the some keyword:
  func makeTrapezoid2(size: Int) -> some Shape {
    let top = Triangle(size: size)
    let middle = Rectangle(width: size, height: 4)
    let bottom = FlippedShape<Triangle>(shape: top)
    let trapazoid = JoinedShape(top: top, bottom: JoinedShape(top: middle, bottom: bottom))
    return trapazoid
  }

  // For the function above the compiler knows exactly what the type is
  // but the details of the type are not revealed to the caller.
  // So you can do the following:
  var aShape3 = makeTrapezoid2(size: 5)
  print("type(of: aShape3) = \(type(of: aShape3))")
  
  // As with makeTrapezoid1 the actual type does not change
  // when calling makeTrapezoid2. It's just opaque.
  aShape3 = makeTrapezoid2(size: 5)
  print("type(of: aShape3) = \(type(of: aShape3))") // Still the same type
  
  // Notice that you can assign aShape2 to aShape1 but not the other way around:
  aShape1 = aShape2 // Okay. Assigning a Shape to a Shape
  
  // Will not compile // Cannot assign a Rectangle to JoinedShape<Triangle, JoinedShape<Rectangle, FlippedShape<Triangle> > >
  // aShape2 = rectangle1
  
  // You cannot assign aShape3 to aShape2 either.
  // This is becuase although their real type is the same, the
  // compiler hides the actual type from the caller. So the code
  // cannot assume anything about aShape3's actual type except
  // that it is aShape.
  // aShape2 = aShape3 // Will not compile
  
  // You can of course assing aShape3 to aShape1
  aShape1 = aShape3 // This is okay aShape3 is a Shape so the assignment is fine.
  
  // Now, if you call makeTrapezoid2 again with a different value
  // You will get the same type as was returned to aShape3
  let aShape4 = makeTrapezoid2(size: 7)
  // So you can assign aShape4 to aShape3
  aShape3 = aShape4  // Absolutely fine.
  // You don't know exactly what type aShape4 and aShap3 are but you
  // can be sure that they are the same type.
  
  
  // Now consider makeArrow, it also returns
  // some Shape. But this is a different shape
  // than that returned by makeTrapezoid
  func makeArrow(size: Int) -> some Shape {
    let top = Triangle(size: size)
    let bottom = FlippedShape<Triangle>(shape: top)
    let arrow = JoinedShape(top: top, bottom: bottom)
    return arrow
  }
  
  
  var aShape5 = makeArrow(size: 5)
  print("type(of: aShape5) = \(type(of: aShape5))")
  // The following two lines are to stop the
  // Swift compiler from complaining about aShape5
  // never being mutated. The attempt to mutate
  // further down is commented out. (As it
  // illustrates a concept.)
  aShape5 = makeArrow(size: 6)
  print("type(of: aShape5) = \(type(of: aShape5))")
  
  // Although aShape5 is some Shape, it is not the same
  // type as aShape3 and aShape4. You cannot assign it
  // to either
  // aShape3 = aShape5 // Nope. Not the same type.
  // This wont work either
  // aShape5 = aShape3
  // or this
  // aShape5 = aShape4

  // Now consider makeTrapezoid3 which returns same
  // real type as makeTrapezoid2. The rectangles
  // dimensions are different, but the type return type
  // is the same as makeTrapezoid2
  func makeTrapezoid3(size: Int) -> some Shape {
    let top = Triangle(size: size)
    let middle = Rectangle(width: size, height: size)
    let bottom = FlippedShape<Triangle>(shape: top)
    let trapazoid = JoinedShape(top: top, bottom: JoinedShape(top: middle, bottom: bottom))
    return trapazoid
  }
  
  var aShape6 = makeTrapezoid3(size: 7)
  print("type(of: aShape6) = \(type(of: aShape6))")
  // The following two lines are to stop the
  // Swift compiler from complaining about aShape6
  // never being mutated. The attempt to mutate
  // further down is commented out. (As it
  // illustrates a concept.)
  aShape6 = makeTrapezoid3(size: 6)
  print("type(of: aShape6) = \(type(of: aShape6))")

  // You still canot assign aShape6 to aShape3 and vice versa.
  // This is because, the compiler cannot assume in general that
  // a different function that returns some Type will return the
  // same exact type. Although the compiler could actually
  // figure it out in this case. But it would defeat the purpose of
  // making some Type an opaque type. The caller should not be able
  // to figure out that some Type returned by makeTrapezoid3 is the
  // same as that returned by makeTrapezoid2. That is an internal
  // implementation detail.
  // aShape6 = aShape3 // won't work
  // aShape3 = aShape6 // also won't work
}
  
func exploreBoxedTypes() {
  // Swift allows you to distinguish between two
  // types of collections of objects that implement
  // a given protocol.
  
  // For example. Consider the following 
  protocol Shape {
    func draw() -> String
  }

  class Triangle: Shape {
    func draw() -> String {
      return "*\n**\n***\n"
    }
  }

  class Rectangle: Shape {
    func draw() -> String {
      return "***\n***\n***\n"
    }
  }

  // Not consider a collection of shapes:
  // The shapes in this collection are are different
  // from each other. They are not the same subtype.
  let shapes1: [Shape] = [Triangle(), Rectangle()]
  for shape in shapes1 {
    print(shape.draw())
  }

  // This won't work becuase the actual subtypes are
  // different.
  // let shapes2: [some Shape] = [Triangle(), Rectangle()]
  // This will work though:
  let shapes2: [some Shape] = [Triangle(), Triangle()]
  for shape in shapes2 {
    print(shape.draw())
  }

  // Swift has deprecated the use of using Shape directly
  // as type of the collection. Instead you should use
  // any Shape. This is equivalent to the code for shape1.
  // This is equivalent to the code for shapes1.
  let shapes3: [any Shape] = [Triangle(), Rectangle()]
  for shape in shapes3 {
    print(shape.draw())
  }

  // You can refer to a boxed type directly. Although it
  // is more common in to use in the context of a collection.
  var shapeA: any Shape
  shapeA = Triangle()
  print("type(of: shapeA) = \(type(of: shapeA))")

  // Yopu just change the actual type of the Shape variable
  shapeA = Rectangle()
  print("type(of: shapeA) = \(type(of: shapeA))")

  // But if you want to make sure that the actual type
  // of the shapeA variable does not change, use the some
  // keyword and specify exact (although unknown to the
  // caller) type of the object by assigning a concrete
  // type to it.
  let shapeB: some Shape = Triangle()
  // Now shapeB must always be a Triangle. You cannot
  // change it to a Rectangle.
  // Won't work.
  // shapeB = Rectangle()
  print("type(of: shapeB) = \(type(of: shapeB))")
}
