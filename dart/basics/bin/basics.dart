// -*- coding: utf-8 -*-
/// [basics.dart] An exploration of the Dart programming language.
/// This is the driver file for the various explorations of the
/// Dart programming language. Each exploration is implemented in
/// a separate file in the `lib` directory. The explorations are
/// imported into this driver file and executed in the `main` function.
/// The order in which the explorations are called is the order in
/// which one should read the explorations.
/* -------------------------------------------------------------------
 * basics.dart: An exploration of the Dart programming language.
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
library; // It seems that is is necessary here to prevent IntelliJ
         // from complaining about a dangling library doc comment.
         // from the triple-slash comment above.

import 'package:basics/comments.dart' as comments;

// The instructions for creating a dart project are an elaboration of the
// the instructions found on the Dart website at:
// https://dart.dev/get-dart
// Creating the basics project involves the following steps:
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
//    Run 'dart create -t console basics' in the dart projects directory.
// 2. Run the application to see if it works.
// 3. Open the folder in IntelliJ IDEA
// 4. Set the DART SDK in IntelliJ IDEA. To do this go to
//    Settings -> Languages & Frameworks -> Dart. Then click enable
//    Dart Support for the project. Then set the path to the Dart SDK.
//    Which will be located in the `bin/cache/dart-sdk` directory of
//    the Flutter SDK. On my machine the Flutter SDK is installed at:
//    $HOME/Documents/Projects/third-party/flutter/latest

void main(List<String> arguments) {
  comments.explore();
}
