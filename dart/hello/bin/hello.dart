// -*- coding: utf-8 -*-
/// [hello.dart] The canonical 'Hello, World!' program.
/* -------------------------------------------------------------------
 * hello.dart: The canonical 'Hello, World!' program.
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
library; // Not sure what this does.

/// Import the [greeting.dart] library.
import 'package:hello/greeting.dart' as greeting;

// The instructions for creating the hello project are an elaboration of the
// the instructions found on the Dart website at:
// https://dart.dev/get-dart
// Creating the hello project involves the following steps:
// 1. Install prerequisites
//    1.1. Install the Xcode development environment
//        1.1.1. Install Xcode (use the app store if possible)
//        1.1.2. Install Xcode command line tools (run `xcode-select --install`)
//        1.1.3. Accept the Xcode license agreement (run `sudo xcodebuild -license`)
//        1.1.4. Install Rosetta2 (run `softwareupdate --install-rosetta --agree-to-license`)
//        1.1.5. Install CocoaPods (run `sudo gem install cocoapods`)
//               See: https://cocoapods.org/
//    1.2. Install Android Studio
//        1.2.1. Download and install Android Studio (
//        1.2.2. Install the Flutter and Dart plugins
//        1.2.3. Install Android SDK command line tools
//               Open Android Studio go to 'More Actions' -> 'SDK Manager'
//               Make sure the left pane is set to 'Languages and Frameworks' -> Android SDK
//               Then select the 'SDK Tools' tab, and check the 'Android SDK Command-line Tools'
//               Click 'Apply' to install the tools.
//    1.3. Install IntelliJ IDEA and the Flutter plugin
//        1.3.1. Download and install IntelliJ IDEA
//        1.3.2. Install the Dart plugin
//        1.3.2. Install the Flutter plugin
//
//    1.4. Install Flutter and Dart SDKs
//        1.4.1. Download the Flutter SDK from the Flutter website
//               Goto: https://docs.flutter.dev/get-started/install
//               Click on the 'macOS' tab, then choose desktop
//               Goto https://docs.flutter.dev/get-started/install/macos/desktop?tab=download
//               Click on the 'Download Flutter SDK' link for macOS (arm64)
//               This will download the file `flutter_macos_2.8.0-stable.zip`
//        1.4.2. Extract the Flutter SDK
//               Flutter must be installed in a user writable directory.
//               On my Mac I use $HOME/Documents/Projects/third-party/flutter
//               Unzip the downloaded file to the desired location.
//        1.4.3. Add the Flutter & Dart SDK to your PATH
//               Add the bin directory to the path.
//        1.4.4. Make a note of the Dart SDK location.
//               The Dart SDK is included with the Flutter SDK. It is located in
//               the `bin/cache/dart-sdk` directory.
//        1.4.5. Run `flutter doctor` to check the Flutter installation.
//               This will check the Flutter installation and report any issues.
//               It will also report the location of the Dart SDK.
//        1.4.6. Accept any Android Licenses you might have missed.
//               This is done by running `flutter doctor --android-licenses`

// Create a console dart application
// 1. Create a new console application
//    Run 'dart create -t console hello'
// 2. Run the application to see if it works.
// 3. Open the folder in IntelliJ IDEA
// 4. Set the DART SDK in IntelliJ IDEA.

// I've modified hello to have doc comments and for it to behave
// similarly to the hello project in Java and Kotlin.

/// Calls the [hello] function from the [greeting.dart] library,
/// and prints the result.
void main(List<String> arguments) {
  print(greeting.hello());
}
