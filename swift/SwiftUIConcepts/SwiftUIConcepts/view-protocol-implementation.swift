// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * view-protocol-implementation.swift: Simulate a toy version of SwiftUI's View protocol.
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

// This file contains definitions that are not part of the public
// API of the toy analogue of SwiftUI. It is intended to represent
// my best guess of how SwiftUI internals might actually work.

// As described in view-protocol.swift, this extension impelents
// the MyView protocol for the Never type. the Body type is defined
// to be never and the body property will raise a fatal exception
// if called. It is never intended to be called.
extension Never {
  typealias Body = Never
  var body: Self.Body { fatalError("Never does not have a body") }
}

// Once again this is the private implementation of the body
// body property for MyVStack. As discussed in view-protocol.swift,
// the body property is of type Never, and the implementation of
// the body property raises a fatal error. It should never be
// called in the normal course of events.
extension MyVStack {
  var body: Self.Body {
    fatalError("VStack does not have a body")
  }
}


// The Renderable protocol defines a method called render that
// is intended to be implemented by every class/struct that
// implements this protocol.

// Note that this is NOT a part of SwiftUI's API. This is
// is an implementation detail, although a critical one, of this
// toy analogue of SwiftUI. It's my best guess at how SwiftUI
// might be rendering views under the covers. This why its
// in the private implementation file
// view-protocol-implementation.swift

// See the classes below for actual implementations of the render method.
protocol Renderable {
  func render()
}

// This extension implements a render method on the MyView protocol.
// This implementation, checks if the body property is of type Never,
// if not, it casts the property to a renderable and class the render
// method on it. Every instance of MyView will get this render method
// by default. Unless it overrides it by implementing the Renderable
// protocol. For the toy SwiftUI structs, they do override the
// implementation. But 'user defined' views like MyHelloWorldView
// do not. Those views, get this implementation by default.
extension MyView {
  func render() {
    let type = Body.self
    if type != Never.self {
      if let renderable = self.body as? Renderable {
        renderable.render()
      }
    }
  }
}


// This extension implements the body property for a MyText
// view. As with all 'leaf' views, the Body is defined as never
// in the view-protocol.swift file, and the body property
// is implemented here to throw a fatal error. It should never
// be called in the normal course of events.
extension MyText {
  var body : Self.Body {
    fatalError("MyText does not have a body")
  }
}

// This the toy implementation of the UI rendering logic for
// a text view. It simply prints the text message. In the
// real SwiftUI there will be some graphic code that renders
// the text.
// The rendering logic is implemented by having MyText
// implement the Renderable interface.
extension MyText: Renderable {
  func render() {
    print(self.message)
  }
}

// This is the toy implementation of the UI rendering logic
// for a VStack view. It implements the Renderable interface.

// Within its render method it iterates over the child views,
// casts them as Renderable instances (becuase the public API
// defines them as MyView instances. And then calls the render
// method on the child views.

// In the real UI code, there would be a bunch of graphics
// calls, here we just separate the two renderable items by
// an extra new line.
extension MyVStack: Renderable {
  func render() {
    for item in self.items {
      if let renderable = item as? Renderable {
        renderable.render()
      }
      print("\n")
    }
  }
}


/*

// There is one problem with this code. That is the fact
// that MyHelloWorldView is supposed to be a user defined
// view. So it is not possible in the real SwiftUI implementation
// for there to be an implementation of this within the framework.
// The actual render function with the tests for Never or something
// like it must be present, but not in this extension type structure.
// For now I'm leaving it here, since, I don't have an idea of how
// SwiftUI must implement this.
extension MyHelloWorldView: Renderable {
  func render() {
    let type = Body.self
    if type != Never.self {
      if let renderable = self.body as? Renderable {
        renderable.render()
      }
    }
  }
}
*/

// This function represents the framework logic that renders
// views. In SwiftUI application, as with all frameworks,
// control is inverted. The main function actually exists
// within the framework and not within user defined code.

// This toy function simulates that inversion of control
// it calls the MyHelloWorldView's render function.
func renderMyHelloWorldView() {
  let view = MyHelloWorldView()
  view.render()
}
