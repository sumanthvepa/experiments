/* -------------------------------------------------------------------
 * json-server.mjs: A configurable express server that returns a JSON
 * greeting
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

import express from 'express';
import { Command } from 'commander';

// Note the comments are JSDoc comments.
// See https://jsdoc.app/about-getting-started
/**
 * Process command line arguments.
 * @returns {*[hostname, port]}: The hostname and port number to listen on.
 */
function processCommandLineArguments() {
  const program = new Command();

  program
      .version('4.0.0')
      .description('A configurable express server that returns "Hello, World!"')
      .option('-h, --host, <host', 'Hostname to listen on.', '127.0.0.1')
      .option('-p, --port, <port>', 'Port number to listen on.', '9005')
      .parse();

  const options = program.opts();
  return [options.host, options.port];
}

/**
 * runServer: Start the web server.
 *
 * Returns "Hello, World!" to any HTTP GET request for the root URL.
 * 
 * This function uses the express framework to create a web server.
 * For this simple example, there is no real benefit to using express.
 * It is introduced here to demonstrate its use. It will become more
 * useful as the server becomes more complex.
 *
 * @param hostname The host interface to listen on. Use 0.0.0.0 to 
 *                  listen on all interfaces.
 * @param port The port number to listen on.
 */
function runServer(hostname, port) {
    const app = express();

    // For this application, the message is too short to
    // benefit from pretty printing. But should you neet to do so
    // you set an option on the app object. (This should
    // be done before the first call to app.get.)
    // app.set('json spaces', 2);

    app.get('/', (req, res) => {
	const message = {'greeting': 'Hello, World!'};
        // Express adds the method json which in addition to
        // serializing the object to a JSON string, sets the
        // Content-Type header to application/json.
        res.json(message);
        // You can also use JSON.stringify serialize the object
        // and then use res.send. You  will havr to manually set
        // the application type to application/json using
        // res.setHeader.
        // res.setHeader('Content-Type', 'application/json');
        // res.send(JSON.stringify(message));
    });
    app.listen(port, hostname, () => {
        console.log(`Server running at http://${hostname}:${port}`);
    });
}

const [hostname, port] = processCommandLineArguments();
runServer(hostname, port);
