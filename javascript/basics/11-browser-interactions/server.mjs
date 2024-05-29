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
  *  This is a simple web server that serves a single static
  *  file: index.html. The index.html file references
  *  Javascript code in interactions.js
  *  The index.html file is served from the document root. The
  *  document root directory is specified on the command line with
  *  the -d option. The default document root is ./static located
  *  in the same directory as the where the server is run.
  *
  *  The code here is almost identical to the code in
  *  09-static-server. Take a look at that project for more
  *  details on how this code works.
  *
  *  Differences from that code are explained in the comments.
  */

import express from 'express';
import { Command } from 'commander';

/**
 * Process command line arguments.
 * @returns {*[hostname, poer, documentRoot]}: The hostname, port
 *   number to listen on and the document root for static files.
 */
function processCommandLineArguments() {
  const program = new Command();

  program
      .version('4.0.0')
      .description('A web server that serves a single static file to explore in-browser interactions with alert, prompt and confirm')
      .option('-h, --host, <host', 'Hostname to listen on.', '127.0.0.1')
      .option('-p, --port, <port>', 'Port number to listen on.', '9008')
      .option('-d, --document-root, <documentRoot>', 'Document root for static files.', 'static')
      .parse();

  const options = program.opts();
  return [options.host, options.port, options.documentRoot];
}

/**
 * runServer: Start the web server.
 *
 * Returns index.htm for any request for the root URL / and 404
 * otherwise.
 *
 * @param hostname The host interface to listen on. Use 0.0.0.0 to 
 *                  listen on all interfaces.
 * @param port The port number to listen on.
 *
 * @param documentRoot The document root for static files.
 */
function runServer(hostname, port, documentRoot) {
    const app = express();
    app.use(express.static(documentRoot));
    app.listen(port, hostname, () => {
      // noinspection HttpUrlsUsage
      console.log(`Server running at http://${hostname}:${port}`);
    });
}

const [hostname, port, documentRoot] = processCommandLineArguments();
runServer(hostname, port, documentRoot);
