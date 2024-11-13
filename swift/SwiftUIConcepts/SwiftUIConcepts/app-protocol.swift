// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * app-protocol.swift: Simulate a toy version of the SwiftUI App protocol
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

// This file demonstrates how SwiftUI might have implemeneted
// the App protocol.

// There are three concepts explored here:
// 1. How does a protocol like App provide an implementation of the main()
//    function. Short answer with an extension.
// 2. How it possible for the type of computed property like body to be
//    defined in a protocol such that the actual concrete type is
//    only specifed in the class that implements the protocol. Short
//    answer by declaring the property to be of an associatedtype in
//    the protocol.
// 3. Given that you've defined a computed property li


// MyScene is the toy version of the Scene protocol. It specifes a
// render function that confirming classes need to provide.
protocol MyScene {
  func render() -> String
}

// MyApp is a toy version of SwiftUI's App protocol. Like the real
// thing it defines a computed property called body. The body
// property is defined to be of type SceneType that is an
// asociatedtype that is defined to confirm to the protocol MyScene.
// The associated type is like a placeholder in Swift. The actual
// concrete type needs to be defined by the class that implements the
// MyApp protocol.
//
// Note that the use of the associatedtype is critical to the design
// of the SwiftUI App class. See MyAppWrong below for an example
// of design that defines body to be of type MyScene directly.
// and the problems it will face.
//
// Any class that confirms to the MyApp protocol must implement the
// body property to return a class that confirms to the MyScene
// protocol.
protocol MyApp {
  associatedtype SceneType: MyScene
  var body: SceneType { get }
}

// This extension defines an additional method run that is equivalent
// to an internal implementation of main within SwitUI for the app.
// This function implements run by calling the render method on the
// object returned by body. Hence any class implementing the MyApp
// protocol will automatically get a fully implemented run method.
extension MyApp {
  func run() {
    print(body.render())
  }
}

// HelloWorldScene is a concrete type the conforms to the Scene
// protocol.This corresponds the WindowGroup type that implements
// the Scene protocol in the real SwiftUI.
// Note the use of class instead of struct is not really all
// that important. It's there so that the property text can be
// modified by the function beCheerful, without the entire
// class needing to be modifiable. With a struct, the body
// property which is readonly, would not be modifiable.
class HelloWorldScene: MyScene {
  var text: String = "Hello, World!"
  
  func render() -> String {
    return self.text
  }
  
  func beCheerful() {
    self.text = "Hello, World! I'm feeling cheerful!"
  }
}


// There are two ways do define an app that confirms to the App protocol.
// The first way defined by HelloWorldApp1 class, defines body to be of
// concrete type HelloWorldScene. This works fine.
// It is particularly useful if you need to access methods specific to
// HelloWorldScene that are not available in MyScene, the beCheerful()
// method for example.
struct HelloWorldApp1: MyApp {
  // This typealias makes it explict that the concrete
  // type of the body property is HelloWorldScene.
  // The use of a typealias here is optional really.
  // It's meant for human readers. The compiler
  // does not need it.
  typealias SceneType = HelloWorldScene
  var body: HelloWorldScene { HelloWorldScene() }
}

func useHelloWorldApp1() {
  let app: HelloWorldApp1 = HelloWorldApp1()
  app.body.beCheerful() // This is why we need a class not a struct for this.
  app.run()  // Prints "Hello, World! I'm feeling cheerful"
}


// This version of a concrete app class, defines body as an opaque
// type that correspond to the MyScene protocol as some scene. Here,
// we've spcifed body to be a concrete type (some MyScene) by exactly
// what that type is, is not known to the user of the class
// HelloWorldApp2. So they cannot directly call beCheerful on the
// body property.
struct HelloWorldApp2: MyApp {
  var body: some MyScene { HelloWorldScene() }
}

func useHelloWorldApp2() {
  let app: HelloWorldApp2 = HelloWorldApp2()
  app.run()
  // let scene: HelloWorldScene = app.body // Will not compile. Error:
                                           // Cannot convert value of
                                           // type 'some MyScene' to
                                           // specified type
                                           // HelloWorldScene.
  // You have to cast the body property to a HelloWorldScene instance.
  if let scene = app.body as? HelloWorldScene {
    scene.beCheerful()
    print(scene.render())
  }
}


// Note that if you do not define the MyApp protocol, with
// placeholder associatedtype, then the type of body object
// is set to MyScene and can never be any concrete subtype.
protocol MyScene3 {
  func render() -> String
}

// Note the absence of an associated type.
protocol MyApp3 {
  var body: MyScene3 { get }
}

struct HelloWorldScene3: MyScene3 {
  func render() -> String {
    "Hello, World!"
  }
}

struct HelloWorldApp3: MyApp3 {
  // The following declaration will not work.
  // var body: some MyScene3 { HelloWorldScene3() } // Compiler error:
                                                    // Type 'HelloWorldApp3'
                                                    // does not confirm
                                                    // to protocol MyApp3
  
  // This works but there is a loss of type information.
  // You have to cast body to HelloWorldScene3 explicitly
  // to use it.
  var body: MyScene3 { HelloWorldScene3() }
}

/*
 This is the analysis from ChatGPT on why use var body: some MyScene3
 won't work.
 
 The issue with this code is that it does not fully conform to the
 MyApp protocol, specifically because of the type mismatch in the
 body property.

 In the MyApp protocol, the body property is defined to return
 a concrete type that conforms to MyScene:
 
 protocol MyApp {
   var body: MyScene { get }
 }

 This means that body should return a concrete type that directly
 conforms to the MyScene protocol. However, in the
 HelloWorldApp struct, you are using opaque return types
 (i.e., some MyScene) for the body property:
 
 struct HelloWorldApp: MyApp {
   var body: some MyScene { HelloWorldScene() }
 }

 By returning some MyScene, the body property in HelloWorldApp is
 actually an opaque type. This tells the compiler that body will
 return "some specific type that conforms to MyScene," but it doesn’t
 match the protocol’s requirement of returning a concrete MyScene type.
 
 Solution
 To fix this, you have two options:

 1. Change the MyApp protocol to use an opaque type (some MyScene)
    for body instead of requiring MyScene directly. However,
    protocols generally can't have opaque types in property
    requirements, so this may not be practical depending on your
    needs.
 2. Change the HelloWorldApp implementation to conform to the exact
    type required by MyApp.
 
 
 Note from svepa: This is infact what SwiftUI does.
 Solution 1: Change MyApp to use associatedtype (recommended)
 
 A common way to handle this in Swift is to use an associatedtype
 in the protocol instead of a concrete type. This allows the
 conforming type to specify the exact type returned by body.
 
 protocol MyApp {
   associatedtype SceneType: MyScene
   var body: SceneType { get }
 }

 struct HelloWorldApp: MyApp {
   var body: HelloWorldScene {
     HelloWorldScene()
   }
 }

 With this change:

 MyApp now has an associatedtype called SceneType, which must conform
 to MyScene. HelloWorldApp can then define its body property to return
 HelloWorldScene, which satisfies the protocol’s requirement.
 
 This approach is more flexible and avoids the problem of trying to
 use opaque types in protocols directly.
 
 
 Solution 2: Change body to return a concrete MyScene
 
 If you prefer not to use an associatedtype, you would need to return
 a concrete MyScene type directly (not with some):
 
 struct HelloWorldApp: MyApp {
   var body: MyScene { HelloWorldScene()() }
 }

 However, this approach might limit flexibility and result in
 type-erasure if you need different scenes for different apps, so
 the associatedtype approach is generally preferred in Swift.
*/


func toySwiftUIAppImplementation() {
  useHelloWorldApp1()
  useHelloWorldApp2()
}
