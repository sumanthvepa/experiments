/**
 * InsertionSorter.java: An implementation of the Sorter interface
 * that sorts an array of elements using the insertion sort algorithm.
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * InsertionSorter.java: An implementation of the Sorter interface
 * that sorts an array of elements using the insertion sort algorithm.
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

import java.util.Comparator;

public class InsertionSorter implements Sorter {
  public <T> void sort(T[] a, int fromIndex, int toIndex, Comparator<? super T> c) {
    for (int i = fromIndex + 1; i < toIndex; ++i) {
      T key = a[i];
      int j = i - 1;
      while (j >= fromIndex && c.compare(key, a[j]) < 0) {
        a[j + 1] = a[j];
        j--;
      }
      a[j + 1] = key;
    }
  }
}
