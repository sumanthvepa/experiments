/**
 * @file App.java: Solution to the leetcode twosum problem
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * App.java: Solution to the leetcode twosum problem
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

import org.jetbrains.annotations.NotNull;

import org.apache.commons.lang3.tuple.Pair;
import org.apache.commons.lang3.tuple.ImmutablePair;

public class App {
  static Pair<Integer, Integer> twoSum(int @NotNull [] numbers, int sum) {
    for (int i = 0; i < numbers.length; i++) {
      for (int j = i + 1; j < numbers.length; j++) {
        if (numbers[i] + numbers[j] == sum) return ImmutablePair.of(i, j);
      }
    }
    throw new IllegalArgumentException("No solution");
  }

  public static void main(String[] args) {
    try {
      int[] nums = {3, 4, 2, 5};
      int sum = 6;
      var indices = twoSum(nums, sum);
      System.out.println(indices.getLeft());
      System.out.println(indices.getRight());
    } catch (IllegalArgumentException e) {
      System.out.println(e.getMessage());
    }
  }
}
