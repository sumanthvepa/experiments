/**
 * @file App.java: A program that sorts an array of integers using
 * the insertion sort algorithm.
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * App.java: A program that sorts an array of integers using
 * the insertion sort algorithm.
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

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import org.jetbrains.annotations.NotNull;

public class App {
  static Integer[] loadDataset(@NotNull String filename) throws IOException, NumberFormatException {
    ArrayList<Integer> numbers = new ArrayList<>();
    try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
      String line;
      while ((line = br.readLine()) != null) {
        for (String part : line.split("\\s+")) {
          numbers.add(Integer.parseInt(part));
        }
      }
    }
    return numbers.toArray(new Integer[0]);
  }

  public static void main(String[] args) {
    var sorter = new InsertionSorter();
    for (var filename : args) {
      try {
        var numbers = loadDataset(filename);
        sorter.sort(numbers, 0, numbers.length, Integer::compareTo);
        for (var number : numbers) System.out.println(number);
      } catch (IOException | NumberFormatException ex) {
        System.err.println("Error reading file " + filename + ": " + ex.getMessage());
      }
    }
  }
}
