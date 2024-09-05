/**
 * Sorter.java: An interface that defines a method to sort an array of
 * elements using a comparator.
 */
/* -*- coding: utf-8 -*- */
/* -------------------------------------------------------------------
 * Sorter.java: An interface that defines a method to sort an array of
 * elements using a comparator.
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

public interface Sorter {
  public <T> void sort(
      T[] a, int fromIndex, int toIndex, Comparator<? super T> c);
}
