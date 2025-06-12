/**
 * @file Constants.kt: Explore constants in Kotlin.
 */
/* -------------------------------------------------------------------
 * Constants.kt: Explore constants in Kotlin.
 *
 * Copyright (C) 2024-25 Sumanth Vepa.
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

// Identifiers in Kotlin.
// Kotlin supports Unicode characters in identifiers. See the use
// of the reduced Planck's constant symbol (ℏ) below.

// There are two types of constants in Kotlin  compile time constants
// and runtime constants.

// A compile time constant is one whose value
// is fully determined at compile time. This is indicated with
// 'const val'.

// For example reduced plank constant's value fully known at compile
// time, so we can declare it as a const val.

// Note that we are suppressing the warnings from IntelliJ IDEA for
// non-ASCII characters  and the use of 'non-letter' characters in
// top-level property names.

@Suppress("NonAsciiCharacters", "ObjectPropertyName")
const val ℏ = 1.0545718e-34 // Reduced Planck's constant in J.s

// Of course, you can also use a more traditional identifier
const val REDUCED_PLANCK_CONSTANT = 1.0545718e-34

/**
 * Explore constants in Kotlin
 */
fun exploreConstants() {
  println("exploring constants...")

  // Print a const val value.
  println("Reduced Planck's constant (ℏ) = $ℏ")
  println("REDUCED_PLANK_CONSTANT = $REDUCED_PLANCK_CONSTANT")

  // A dummy function that does not actually get user input. Used to
  // demonstrate the concept of a runtime constant.
  fun dummyReadLine(): String {
    return "dummy input"
  }

  // A runtime constant is indicated with just val. It
  // indicates a value that can be assigned to just once.
  // In this sense it is very similar to Java's final
  // keyword.
  // val input = readLine() ?: "default value" // This line would read user input
                                               // from the console, but we are
                                               // simulating it with a dummy
                                               // function to avoid blocking
                                               // the program.
  val input = dummyReadLine()
  println("The value is $input")

  // You cannot change the value of input once it is initialized.
  // input = "new value" // Error: Val cannot be reassigned.

  println("...finished exploring constants")
}
