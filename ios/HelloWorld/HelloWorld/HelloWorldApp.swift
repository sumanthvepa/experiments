// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * HelloWorldApp.swift: Entry point to the HelloWorld iOS application
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
import SwiftUI

/**
 HelloWorldApp implements the App protocol. The App protocol is
 documented in the SwiftUI reference at:
 https://developer.apple.com/documentation/swiftui/app
 
 It is marked @main to indicate to the SwiftUI framework that it is
 the entry point to the application.
 
 The @main attribute is documented in the Swift Language reference:
 https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes#main

 Technically @main indicates that the struct implements  a function
 with the signature static func main(). However, p00HerlloApp does
 not directly, implement main. That is provided by the SwiftUI
 framework, most likely, via an extension to the App protocol.
 
 To see how this might actually be implemented, see
 app-protocol.swift in the project SwiftUIConcepts in the experiments
 repository.
*/
@main
struct HelloWorldApp: App {
  // The body property is a computed property required by the App
  // protocol. It is defined in the protocol to return a placeholder
  // type (an associatedtype) called Body which must conform to the
  // Scene protocol. The body property is documented in the SwiftUI
  // reference at: https://developer.apple.com/documentation/swiftui/app
  
  // The concrete type of the property is determined
  // by the code below, to be of an opaque type some Scene.

  // To understand how App protocol and the body property
  // implementation works, see the file app-protocol.swift in the
  // SwiftUIConcepts project in the experiments repository.
  var body: some Scene {
    WindowGroup { HelloWorldView() }
  }
  
  // The code above is equivalent to the following. (You can check
  // by commenting out the code above, uncommenting the code below.
  // You will get the same exact behavior.)
  // Note the following:
  //  1. The actual type of the computed property body is
  //     WindowGroup<ContentView>. Since this information is not
  //     needed in the app, it is hidden by specifying the type of
  //     the property to be some Scene, an opaque type in the code
  //     above, but is made explicit in the code below.
  //  2. The get method is implicit in the code above, but the code
  //     below, makes it explicit with a get keyword.
  //  3. The return is also implicit in the code, above. In the code
  //     below the return is explicit. The getter returns group, an
  //     instance of WindowGroup<ContentView> which impements the Scene
  //     protocol.
  //  4. The code above uses a trailing closure: { ContentView() }.
  //     But the code below first defines an explicit function
  //     called viewCreator which, when called, returns an instance of
  //     ContentView. Then it creates an object called group
  //     which is an instance of a WindowGroup initialized with the
  //     viewCreator function. The group object is returned as the
  //     property value.
  /*
   var body: WindowGroup<ContentView> {
      get {
        func viewCreator() -> ContentView {
          return ContentView()
        }
        let group: WindowGroup<ContentView> = WindowGroup(makeContent: viewCreator)
        return group
      }
   }
   */
}
