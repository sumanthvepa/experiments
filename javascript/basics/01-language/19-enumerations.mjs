//-*- coding: utf-8 -*-
/**
 * @module 19-enumerations.mjs: Learn how to simulate enums
 * @author Sumanth Vepa <svepa@milestone42.com>
 * @licence GNU General Public License v3.0
 */
/* -------------------------------------------------------------------
 * 19-enumerations.mjs: Learn how to simulate enums
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

export function exploreEnumerations() {
  // Javascript does not have enumerations. But you
  // can simulate them with constant objects.
  // It's not really a good substitute for real enums.
  /**
   * @description An object representing an HttpError
   * @type {{"Internal Server Error": number, "Temporary Redirect": number, NotFound: number}}
   */
  const HttpErrors = {
    "NotFound": 404,
    "Temporary Redirect": 302,
    "Internal Server Error": 500
  };

  /**
   * @function returnAnError
   * @description returns an HttpError
   *
   * The return value is a number because the value of the key
   * HttpError.NotFound is a number: 404.
   *
   * @returns {number} An HttpError
   */
  function returnAnError() {
    return HttpErrors.NotFound;
  }

  const error = returnAnError();
  console.log(`The error is: ${error}`);

  // You can iterate over the keys of the HttpErrors object
  for (let httpError in HttpErrors) {
    console.log(`${httpError}`);
  }
}