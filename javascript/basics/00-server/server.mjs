/* -------------------------------------------------------------------
 * 00-server.mjs: A simple web server that returns 
 * "Hello, World!" in plain text.
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

// Import the http module.
//  Note that we are importing the http module using the ES6 import
//  syntax. We do this because the import syntax is part of the
//  ECMAScript 6 (ES6) standard.  Node.js code typically uses the
//  CommonJS module system, which uses the require function to import
//  code. We prefer the import syntax because it is more modern and
//  standard.
//  To use the import syntax, we need to use the .mjs file extension.
//  Alternately, we could specify "type": "module" in the package.json
//  file, but we prefer to use the .mjs file extension.
import http from 'http';

// The hostname is set to local host for safety. The servers in
// these lessons, although generally safe, are not explicitly designed
// for the open web.
const hostname = '127.0.0.1';

// Servers in this series use  ports starting at 9000. The port number
// is related to the  lesson number. So if lesson number 23 has a
// server component, it will use port 9023. This makes it easy to
// figure out which port a given lesson's server is using.
const port = 9000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}`);
});
