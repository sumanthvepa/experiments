/* -------------------------------------------------------------------
 * ContentView.swift: Entry point to the HelloWorld iOS application
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

// HelloWorldView represents the content that is rendered
// by the application. The generated code calls this ContenView
// for that reason. I've renamed that class to HelloWorldView
// to better reflect its function.

// The HelloWorldView implements the View protocol, which
// is documented here:
// https://developer.apple.com/documentation/swiftui/view

// The thing to note about a View is that, it is itself composed of a
// property called body, that is defined to be a placeholder that itself
// has to implement the View protocol. This is similar to how the
// App protocols body property works. See HelloWorldApp for an
// explanation of how that works.

// There is however one significant difference between App's body and
// View's body. An App's body property is required to implement the
// Scene protocol. However, the View's body property is required to
// implement the View protocol itself. This creates a potentially
// infinite composition of View objects. The way SwiftUI deals with this
// infinite recursion problem is to have 'leaf' views that define
// the placeholder body property to be of type Never. This is
// explored in more detail in  see view-protocol.swift in the project
// swift/SwiftUIConcepts in the experiments repository.
//
// Also see this forum discussion on why Some SwiftUI views have
// body = Swift.Never
// https://forums.swift.org/t/why-some-swiftui-views-have-body-swift-never/27372
// The Swift.Never type is documented at:
// https://developer.apple.com/documentation/swift/never.
// The Never type is explored in more detail in the file never-enum.swift
// in the project swift/basics in the experiments repository.
struct HelloWorldView: View {
  var body: some View {
    VStack {
      // Note how two 'views' are instantiated.
      // The thing I'm not clear about here is how two such
      // instances are combined by VStack. I believe this
      // something to do with @ViewBuilder attribute. I'll
      // have to explore that in detail later.
      // TODO: Explore @ViewBuilder and the problem of how this code block is used to construct a a VStack view.
      // See this blog post on ViewBuilders:
      // https://www.avanderlee.com/swiftui/viewbuilder/
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
  }
}

#Preview {
  HelloWorldView()
}
