/* -------------------------------------------------------------------
 * 03-server.mjs: A configurable web server that returns
 * "Hello, World!"
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
// See 00-server on importing modules.
import http from 'http';
import { Command } from 'commander';

function processCommandLineArguments() {
  const program = new Command();

  program
      .version('3.0.0')
      .description('A configurable web server that returns "Hello, World!"')
      .option('-p, --port, <port>', 'Port number to listen on.', '9003')
      .parse();

  const options = program.opts();
  return options.port;
}

function runServer(hostname, port) {
    const server = http.createServer((req, res) => {
        res.statusCode = 200;
        res.setHeader('Content-Type', 'text/plain');
        res.end('Hello, World!\n');
    });

    server.listen(port, hostname, () => {
        console.log(`Server running at http://${hostname}:${port}`);
    });
}

const hostname = '127.0.0.1'; // See 00-server for explanation.
const port = processCommandLineArguments();
runServer(hostname, port);
