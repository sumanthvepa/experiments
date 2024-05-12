/* -------------------------------------------------------------------
 * 06-static-server.mjs: A configurable web server for static files.

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
 /**
  *  This is a simple web server that serves static files.
  * It uses the express framework to serve static files from a
  * document root directory. The document root directory is
  * specified on the command line with the -d option. The default
  * document root is ./public located in the same directory as the
  * where the server is run.
  * 
  * This is useful for many of the subsequent lessons that need
  * a static web server to serve HTML, CSS, and JavaScript files.
  */

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
      .option('-p, --port, <port>', 'Port number to listen on.', '9006')
      .option('-d, --document-root, <documentRoot>', 'Document root for static files.', 'public')
      .parse();

  const options = program.opts();
  return [options.host, options.port, options.documentRoot];
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
 *
 * @param documentRoot The document root for static files.
 */
function runServer(hostname, port, documentRoot) {
    const app = express();
    // Set the document root for static files.
    // Express will serve any URL beginning with / from
    // the document root directory.
    app.use(express.static(documentRoot));
    app.listen(port, hostname, () => {
        console.log(`Server running at http://${hostname}:${port}`);
    });
}

const [hostname, port, documentRoot] = processCommandLineArguments();
runServer(hostname, port, documentRoot);
