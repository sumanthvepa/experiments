/* -------------------------------------------------------------------
 * 02-cli.mjs: Print command line arguments.
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
// Commander is a CLI library to process command line options.
// You can find its manual page here:
// https://www.npmjs.com/package/commander?activeTab=readme.
// To use this code you have to install commander first:
// $ npm install commander
import { Command } from 'commander';

const program = new Command();

// Each call to a method on program returns the program object itself.
// This allows for chaining method calls. The final parse() method
// uses process.argv implicitly.
program
    .version('1.0.0')
    .description('Print command line arguments.')
    .option('-p, --port, <port>', 'Port number to listen on.', '8080')
    .parse();

// The opts() method returns an object containing the options
// that were parsed from the command line. The args array
// contains the remaining command line arguments.
// Attributes of the options object are named after the long
// option names. The value of each attribute is the value
// of the option if it was specified on the command line.
// Otherwise, the value is the default value specified in
// the call to the option() method.
const options = program.opts();
const port = options.port;
const params = program.args;

// Note the use of .join(' ') to concatenate the elements of the
// array into a single string.
console.log(`Listening on port ${port}`);
console.log(`Remaining command line arguments: ${params.join(' ')}`);
