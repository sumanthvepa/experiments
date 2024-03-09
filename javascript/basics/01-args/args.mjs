/* -------------------------------------------------------------------
 * 01-args.mjs: Print command line arguments.
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

// Note that it does not matter how the program was invoked
// on the command line. i.e. either as
// $ node args.mjs 
// or
// $ ./args.mjs
// The argv array will always have as its first element
// the path to the node executable.
// The second element of the array will always be the
// path to this script.
// The third element onwards will contain any command
// line arguments passed to the script.
for(let n = 0; n < process.argv.length; ++n) {
  console.log(process.argv[n]);
}
