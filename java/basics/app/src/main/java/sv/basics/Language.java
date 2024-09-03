/**
 * @file Language.java: A series of notes on the Java programming
 * language, written as a collection of Java packages and files.
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * Language.java: A series of notes on the Java programming language,
 * written as a collection of Java packages and files.
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
package sv.basics;

import java.util.List;

/**
 * The Language class is the driver class for the exploration
 * of the Java programming language.
 */
public class Language {

  public static List<String> getTopics() {
    return List.of(
        "Comments",
        "Variables and Constants",
        "Primitive Data Types",
        "Arrays",
        "Operators",
        "Expressions, Statements and Blocks",
        "Control Flow Statements",
        "Classes and Objects",
        "Null References",
        "Enumerations",
        "Records",
        "Annotations",
        "Interfaces and Inheritance",
        "Numbers",
        "Strings",
        "Exceptions",
        "Generics",
        "Packages",
        "Modules",
        "Basic I/O",
        "Collections",
        "Concurrency",
        "Java Functional Programming"
    );
  }

  /**
   * The main method is the entry point of the application.
   *
   * @param args the command-line arguments. These
   *             are currently ignored.
   */
  public static void main(String[] args) {
    // This tutorial exploration follows the structure of the
    // Java Tutorial at https://docs.oracle.com/javase/tutorial/,
    // With updates on features in Java releases from Java 9 through 22.
    // The features of each release are described at:
    // https://docs.oracle.com/en/java/javase/22/language/java-language-changes.html

    // The tutorial is structured as a series of classes, with each
    // class exploring a different aspect of the Java programming
    // language. This driver class calls the explore method of each
    // class in turn in the order in which the topics should be
    // explored.
    // This code is intended to be read rather than executed. Although,
    // if you do execute it, it will work.

    // Note 0: Overview of Java Platform

    // Note 1: Creating Java Projects with Gradle
    // INSTALLING JAVA AND GRADLE
    // You first need to install Java and Gradle.
    // Instructions for installing Java on AlmaLinux are as follows:
    // sudo dnf install java-21-openjdk-devel
    // alternatives --set 'java' java-21-openjdk.aarch64 // For ARM 64-bit Linux
    // alternatives --set 'java' java-21-openjdk.x86_64 // For x86 64-bit Linux
    // Set JAVA_HOME to the Java installation directory in your .bash_profile
    // export JAVA_HOME=/usr/lib/jvm/java

    // Instructions for installing Java on macOS are as follows:
    // sudo port install openjdk21
    // Set JAVA_HOME to the Java installation directory in your .zprofile
    // export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21-macports.jdk/Contents/Home

    // Instructions for installing Gradle on AlmaLinux are as follows:
    // Download the latest gradle installation from https://gradle.org/
    // Extract the downloaded file to /opt/gradle/N.N.N (where
    // N.N.N is the version number.)
    // Create a symbolic link to the extracted directory as follows:
    // ln -s /opt/gradle/N.N.N /opt/gradle/latest
    // Finally, add the Gradle bin directory to the PATH environment
    // variable as follows:
    // export GRADLE_HOME=/opt/gradle/latest
    // export PATH=$PATH:/opt/gradle/latest/bin

    // Instructions for installing Gradle on macOS are as follows:
    // sudo port install gradle
    // Add GRADLE_HOME to your .zprofile
    // export GRADLE_HOME=/opt/local/share/java/gradle

    // The recommended way to create Java projects is with Gradle.
    // In particular, my preferred way of using Gradle is to use the
    // Kotlin DSL. It seems like the Gradle project is moving towards
    // the Kotlin DSL as the default way of creating projects.


    // SETTING UP A NEW JAVA PROJECT WITH GRADLE
    // Create the directory in which the project will be created.
    // E.g. mkdir -p ~/projects/myproject
    // Change to the project directory.
    // E.g. cd ~/projects/myproject
    // Run the gradle init command.
    // E.g. gradle init
    // Select the application type: Java application
    // Select application structure: Single application project
    // Select the build script DSL: Kotlin
    // Select the test framework: JUnit Jupiter

    // You may have to rename the package name in the build.gradle.kts
    // and change the directory structure and package directive in the
    // java file to match the package name.

    // Finally build and run the project:
    // gradle build
    // gradle run

    // IMPORT THE PROJECT INTO INTELLIJ IDEA
    // Open IntelliJ IDEA and select File -> New -> Project from Existing Sources
    // Select the build.gradle.kts file in the project directory

    // PASSING COMMAND-LINE ARGUMENTS when using Gradle
    // To pass command-line arguments to the main method when using Gradle,
    // you can use the --args option as follows:
    // gradle run --args="arg1 arg2 arg3"
    //
    // From within IntelliJ IDEA, Edit Configurations,
    // append --args="arg1 arg2 arg3" to the run task.


    // Note 2: Program entry point main. Discuss the new 'classless'
    // main feature.

    // Note 3: Comments and documentation comments in particular.
    Comments.explore();

    // Note 4: Variables and  constants
    Variables.explore();

    // Note 5: Primitive Data Types
    PrimitiveDataTypes.explore();

    // Note 6: Arrays
    Arrays.explore();

    // Note 7: Operators
    Operators.explore();

    // Note 8: Expression, Statements and Blocks
    ExpressionsStatementsBlocks.explore();

    // Note 9: Control Flow Statements
    ControlFlowStatements.explore();

    // Note 10: Classes and Objects
    ClassesAndObjects.explore();

    // Note 11: Null References
    NullReferences.explore();

    // Note 12: Enumerations
    Enumerations.explore();

    // Note 13: Records
    Records.explore();

    // Note 14: Annotations
    Annotations.exploreUse();

    // Note 15: Interfaces and Inheritance
    InterfacesAndInheritance.explore();

    // Note 16: Numbers
    Numbers.explore();

    // Note 17: Strings
    Strings.explore();

    // Note 18: Exceptions
    Exceptions.explore();

    // Note 19: Generics
    Generics.explore();

    // Note 20: Packages
    Packages.explore();

    // Note 21: Modules
    Modules.explore();

    // Note 22: Basic I/O
    BasicIO.explore();

    // Note 23: Collections
    Collections.explore();

    // Note 24: Concurrency
    Concurrency.explore();

    // Note 25: Java Functional Programming
    FunctionalProgramming.explore();

    // Note 26: Explore Creating Annotations
    Annotations.exploreCreation();
  }
}
