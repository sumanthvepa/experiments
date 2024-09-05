/**
 * @file InsertionSorterTest.java: Unit tests for InsertionSorter
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * InsertionSorterTest.java: Unit tests for InsertionSorter
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

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;


public class InsertionSorterTest {
  @Test void sortNumbers() {
    var sorter = new InsertionSorter();
    var a = new Integer[] {3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5};
    sorter.sort(a, 0, a.length, Integer::compareTo);
    assertArrayEquals(new Integer[] {1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9}, a);
  }
}
