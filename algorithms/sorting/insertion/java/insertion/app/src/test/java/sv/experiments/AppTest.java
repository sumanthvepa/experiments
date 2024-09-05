/**
 * @file AppTest.java: Unit test for App.java.
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * AppTest.java: Unit test for App.java.
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
package sv.experiments;

import java.io.IOException;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertArrayEquals;

class AppTest {
  @Test void loadDataset() throws IOException, NumberFormatException {
    var expected = new Integer[] {822, 934, 192, 843, 309, 592, 391, 309, 201, 974, 587, 394, 573, 934, 292, 583, 483};
    var actual = App.loadDataset("src/test/resources/numbers.txt");
    assertArrayEquals(expected, actual);
  }
}
