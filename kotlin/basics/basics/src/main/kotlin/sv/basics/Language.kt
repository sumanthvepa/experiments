
/**
 * @file Language.kt: A series of notes on the Kotlin programming
 * language, written as a collection of Kotlin packages and files.
 */
/* -------------------------------------------------------------------
 * language.kt: A series of notes on the Kotlin programming
 * language, written as a collection of Kotlin packages and files.
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
package sv.basics
/*
   Setting up a Kotlin project using Gradle.

   Step 1: Create the project's root directory.

   Step 2: Run gradle init. (This assumes that gradle has already
   been installed on your system.)
   Choose the following options:
    - Type of project: application
    - Implementation language: Kotlin
    - Java version: 21
    - Project name: basics
    - Select application structure: Single application project
    - DSL: Kotlin
    Build, test and run the initial project to make sure that it
    works. Do it this way:
    ./gradlew clean
    ./gradlew build
    ./gradlew test
    ./gradlew run


    Step 3: Change the default package name from org.example to
    sv.basics.
        Step 3a: Rename the directory src/main/kotlin/org/example to
        src/main/kotlin/sv/basics.
        Step 3b: Change the package name in the file App.kt from
        package org.example to package sv.basics.
        Step 3c: Rename the directory src/test/kotlin/org/example to
        src/test/kotlin/sv/basics.
        Step 3d: Change the package name in the file AppTest.kt from
        package org.example to package sv.basics.
        Step 3e: Change the main class of the project in the file
        build.gradle.kts from org.example.App to sv.basics.App.
    Clean, build, test and run the project to make sure that it works.
    See Step 2 for instructions on how to do this.

    Step 4: Change the name of the class App to Language.
        Step 4a: Rename the file App.kt to Language.kt.
        Step 4b: Change the name of the class in the file Language.kt
        from App to Language.
        Step 4c: Change references to App in the file Language.kt to
        Language.
        Step 4d: Rename the file AppTest.kt to LanguageTest.kt.
        Step 4e: Change the name of the class in the file LanguageTest.kt
        from AppTest to LanguageTest.
        Step 4f: Change references to App in the file LanguageTest.kt to
        Language.
        Step 4g: Change the name of the main class of the project in the
        file build.gradle.kts from sv.basics.AppKt to sv.basics.LanguageKt
    Clean, build, test and run the project to make sure that it works.
    See Step 2 for instructions on how to do this.

    Step 5: Change the app directory to basics.
        Step 5a: Rename the directory app to basics in the project
         root directory.
        Step 5b: Change rootProject.name = "app" to
        rootProject.name = "basics" in file settings.gradle.kts.
    Clean, build, test and run the project to make sure that it works.
    See Step 2 for instructions on how to do this.
 */

class Language {
    val hello: String
        get() {
            return "Hello World!"
        }
}

fun main() {
    println(Language().hello)
    exploreConstants()
}
