// -*- coding: utf-8 -*-
/// [greeting_test.dart] The canonical 'Hello, World!' program.
/* -------------------------------------------------------------------
 * greeting_test.dart: Unit tests for the greeting library.
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
library;

/// Import [greeting.dart] library.
import 'package:hello/greeting.dart' as greeting;

/// Import the [test] library.
import 'package:test/test.dart';

/// The [main] function. Executes unit tests.
void main() {
  test('calculate', () {
    expect(greeting.hello(), 'Hello, World');
  });
}
