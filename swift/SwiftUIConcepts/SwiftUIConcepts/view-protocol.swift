// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * view-protocol.swift: Simulate a toy version of SwiftUI's View protocol.
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

// This is a toy implementation of SwiftUI's View protocol
// and some its important subclasses and supporting classes.

// This toy implementation illustrates the following techniques
// that SwiftUI uses to implelement Views.

// 1. It demonstrates the Use of Never to stop the infinite composition
// of Views problem.
// The infinite composition problem can be seen in the definition of the
// protocol. The body property is of type MyView. This means every instance
// that implements the MyView protocol has to have a valid body instance
// that also implements MyView. This leads to an infinite sequence of
// MyView's. Or alternatively a loop pointing back to an existing MyView.

// One way in which this problem can be resolved is to define the associated
// type Body to be of type Never for a 'leaf' View. Never is Swift enumeration
// that has no values and cannot be constructed.

// Now when a view is rendered, the rendering code checks to see if
// the type of Body is Never, and if so it never uses the body property.


// But there are some problems with this strategy that need to be solved.
// First Never does not implement MyView. So defining typealias Body = Never
// wont' work normally. The way SwiftUI overcomes this problem is by defining
// an extension to Never that implements the MyView protocol. The implementation
// the MyView protocol in the extension is a dummy. the body property raises
// a fatalError if actually called. But the body propery of the Never extension
// will never be called as discussed above.


// This definition of MyView matches the definition of View from the
// SwiftUI framework.
// Note that there is no mechanism shown here to render a view. But SwiftUI
// must surely have such a mechanism. In this toy implementation, a render
// method is indeed defined. But it is defined within an extension. It is
// this render method, and the methods that override it in subclasses, that
// implement the check to see if Body is of type never. See
// view-protocol-implementation.swift for details.
protocol MyView {
  associatedtype Body: MyView
  var body: Self.Body { get }
}

// This extension defines Never as implementing the MyView protocol.\
// The implementation of the protocol is in the view-protocol-implementation.swift
// file.
extension Never: MyView {
}


// This is a toy analogue of SwiftUI's Text struct.
// This is an example of a leaf view. Note the definition of the Body
// type to be Never. Also the initializer takes a string as message to be
// displayed by the view.
struct MyText: MyView {
  typealias Body = Never
  let message: String
  init(message: String) {
    self.message = message
  }
}

// This is a toy analogue of SwiftUI's VStack struct.
// This is also, somewhat surprisingly a leaf view. It too defines
// the Body type to be Never. The reason why this is a leaf view
// is that it actually has multiple children, the array of views
// called items. But the body property can return only one View.
// So the MyVStack struct defines Body to be of never, and provides
// a special render method in the implementation that lays out the
// child views and calls their respective render methods. This render
// method is not part of the structure's user visible API though.
// You can see its implementation in
// view-protocol-implementation.swift.
struct MyVStack: MyView {
  let items: [any MyView]
  typealias Body = Never
}

// This is a toy analogue of the user-defined 'ContentView' in a SwiftUI
// HelloWorld application.
// The body consists is a MyVStack type returned as an opaque,
// some MyView type.
// This toy implementation differs from the way it is implemented
// in actual SwiftUI app, in that it does not use a ViewBuilder.
// For this version of the toy app, I'm skipping those complications.
// Instead, the body property actually creates a MyVStack object
// explicitly.
struct MyHelloWorldView: MyView {
  var body: some MyView {
    let item1 = MyText(message: "Hello,")
    let item2 = MyText(message: "World!")
    return MyVStack(items: [item1, item2])
  }
}

