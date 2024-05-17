/**
 * @file LanguageTest.java: Unit tests for the Language class.
 * This is generated as part of gradle init. Since the basics
 * project is an essentially a tutorial exploration, there is no
 * need to write tests for it. However, this file will be used
 * to demonstrate how to write tests for Java classes using the
 * JUnit 5 framework.
 */
/* -------------------------------------------------------------------
 * LanguageTest.java: Unit tests for the Language class.
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

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class LanguageTest {
  @Test void topicsAreNotNull() {
    assertNotNull(
        Language.getTopics(),
        "getTopics should return a non-null list of topics");
  }
}
