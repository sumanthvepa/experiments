/**
 * @file AppTest.java: Unit tests for App.java
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * AppTest.java: Unit tests for App.java
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
package sv.experiments.twosum;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import org.apache.commons.lang3.tuple.Pair;
import org.apache.commons.lang3.tuple.ImmutablePair;

class AppTest {
  @Test void twoSum() {
    int[] numbers = {3, 4, 7, 9};
    int sum = 11;
    Pair<Integer, Integer> expected
      = new ImmutablePair<Integer, Integer>(1, 2);
    Pair<Integer, Integer> actual = App.twoSum(numbers, sum);
    assertEquals(actual, expected);
  }
}
