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

// A note on comments
// The comments for programs in this series are intended to be read
// as teaching notes rather than as standard comments. They are
// are far more extensive than typical comments, as they are intended
// for educational purposes. Real code would be commented differently.
// Read the comments alongside the code to get the most out of them.


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
import http from 'node:http';

// The hostname is set to local host for safety. The servers in
// these lessons, although generally safe, are not explicitly designed
// for the open web.
const hostname = '127.0.0.1';

// Servers in this series use ports starting at 9000. The port number
// is related to the  lesson number. So if lesson number 23 has a
// server component, it will use port 9023. This makes it easy to
// figure out which port a given lesson's server is using.
const port = 9000;

// The createServer function is documented at:
// https://nodejs.org/docs/latest-v20.x/api/http.html#httpcreateserveroptions-requestlistener
// The request listener is a function that is called when the server receives
// a request via a 'request' event. The request listener is passed two
// arguments: a request object and a response object.
// The request object is an instance of the http.IncomingMessage class.
// The response object is an instance of the http.ServerResponse class.
const server = http.createServer((req, res) => {
  console.log('typeof req:', typeof req);
  console.log('detailed type of req:', Object.prototype.toString.call(req));
  console.log('class of req:', req.constructor.name);

  console.log('typeof res:', typeof res);
  console.log('detailed type of res:', Object.prototype.toString.call(res));
  console.log('class of res:', res.constructor.name);

  // To generate a response to the client, we use the response object's
  // setHeader and end methods. The setHeader method sets the value of a
  // response header. The end method sends the response headers and body
  // to the client. The end method takes an optional argument that is
  // used as the response body. If no argument is provided, the response
  // body is empty.
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

// The server listens on the specified port and hostname. When the server
// is ready to accept connections, the callback function is called.
// Internally, this callback is implemented as a listener on the
// 'listening' event that is emitted by the server when it starts
// listening. Complete documentation can be found here:
// https://nodejs.org/docs/latest-v20.x/api/http.html#class-httpserver
server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}`);
});
