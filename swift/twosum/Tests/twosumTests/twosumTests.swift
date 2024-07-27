// -*- coding: utf-8 -*-
/* -------------------------------------------------------------------
 * twosumTests.swift: Unit tests for twosum
 *
 * Copyright (C) 2024 Sumanth Vepa.
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License a
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
 *-----------------------------------------------------------------*/

import XCTest
@testable import twosum

final class TwosumTests: XCTestCase {
  func testTwoSumRegularSolution() throws {
    // The sum can be found in the list and the indexes
    // are not exteremal values.
    let result = try twoSum(numbers: [3, 5, 7, 2], sum: 12)
    XCTAssertEqual(result.first, 1)
    XCTAssertEqual(result.second, 2)
  }
  
  func testTwoSumExtremeIndex1() throws {
    let result = try twoSum(numbers: [3, 5, 7, 2], sum: 8)
    XCTAssertEqual(result.first, 0)
    XCTAssertEqual(result.second, 1)
  }

  func testTwoSumExtremeIndex2() throws {
    let result = try twoSum(numbers: [3, 2, 7, 4], sum: 6)
    XCTAssertEqual(result.first, 1)
    XCTAssertEqual(result.second, 3)
  }
  
  func testTwoSumExtremeIndex3() throws {
    let result = try twoSum(numbers: [3, 2, 7, 4], sum: 7)
    XCTAssertEqual(result.first, 0)
    XCTAssertEqual(result.second, 3)
  }
  
  func testTwoSumNegativeVales() throws {
    let result = try twoSum(numbers: [2, -3, 7, 3, 6], sum: 0)
    XCTAssertEqual(result.first, 1)
    XCTAssertEqual(result.second, 3)
  }
  
  func testTwoSumNoSolution() {
    do {
      let _ = try twoSum(numbers: [3, 2, 7, 4], sum: 12)
      // Should have thrown an exception
      XCTFail("Expected exception TwoSumError.NoSolution")
    } catch TwoSumError.NoSolution {
      // Expected. Do nothing.
    } catch {
      // Unexpected exception
      XCTFail("Expected exception TwoSumError.NoSolution, caught \(error) instead")
    }
  }
}

