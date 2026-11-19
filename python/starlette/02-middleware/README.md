This is an exploration of Starlette's middleware capabilities.

## Starting the server

Run these commands from the project root (the directory that contains
`runws.sh`).

1. Create and activate a virtual environment, if you have not already:

   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. Install the project in editable mode, if you have not already:

   ```bash
   pip install -e .
   ```

3. Start the server:

   ```bash
   ./runws.sh
   ```

   The script runs uvicorn with auto-reload on port 5102:

   ```bash
   uvicorn mws.application:app --host=0.0.0.0 --port=5102 --reload
   ```

4. From another terminal, check that it responds:

   ```bash
   curl -i http://localhost:5102/
   ```

   You should get a `200 OK` response with the body
   `{"message":"hello"}`. The terminal running the server also prints
   two lines for each request from the `SimpleLogger` middleware, for
   example:

   ```
   Request: GET http://localhost:5102/
   Response status: 200
   ```

5. Press Ctrl+C in the server terminal to stop it.

### Running in a virtual machine

The script binds to `0.0.0.0`, so the server accepts connections on
every network interface. When it runs in a VM, you can reach it from
the host machine at `http://<vm-address>:5102/`, provided the VM's
network settings allow it (for example a bridged adapter or a
forwarded port).

The only sign in is a demo session cookie (see below), and its value is
hard coded in `src/mws/login.py`, so anyone who knows it can use it.
Only run the service on a network you trust. To accept connections from
the local machine only, change `--host=0.0.0.0` to `--host=127.0.0.1`
in `runws.sh`.

## Trying the / endpoint

The home page is open to everyone. It greets a signed in user by name
and everyone else with a plain `hello`. A user is signed in if the
request has the demo `session` cookie described in the next section
(the session `abc123` belongs to the user `alice`).

Start the server first (see above). The examples use port 5102. If you
run `curl` from another machine, replace `localhost` with the address
of the machine running the server.

The `-sS` option hides curl's progress output but still shows errors,
and `-i` shows the response status and headers.

1. Not signed in:

   ```bash
   curl -sS -i http://localhost:5102/
   ```

   You should get `200 OK` with the body `{"message":"hello"}`.

2. Signed in, with the demo session cookie:

   ```bash
   curl -sS -b 'session=abc123' http://localhost:5102/
   ```

   You should get `{"message":"hello alice"}`.
   (`-H 'Cookie: session=abc123'` does the same thing as `-b`.)

3. An unknown session is treated as not signed in:

   ```bash
   curl -sS -b 'session=nope' http://localhost:5102/
   ```

   You should get `{"message":"hello"}`.

## Trying the /account endpoint

The `/account` endpoint is only shown to signed in users. A user is
signed in if the request has a `session` cookie that matches an entry
in the `SESSIONS` table in `src/mws/login.py`. The table has one demo
entry: the session `abc123` belongs to the user `alice`.

Start the server first (see above). The examples use port 5102. If you
run `curl` from another machine, replace `localhost` with the address
of the machine running the server.

The `-sS` option hides curl's progress output but still shows errors,
and `-i` shows the response status and headers.

1. Signed in, with the demo session cookie:

   ```bash
   curl -sS -i -b 'session=abc123' http://localhost:5102/account
   ```

   You should get `200 OK` with the body `{"account":"alice"}`.
   (`-H 'Cookie: session=abc123'` does the same thing as `-b`.)

2. Not signed in, with no cookie or an unknown one:

   ```bash
   curl -sS -i http://localhost:5102/account
   ```

   You should get `303 See Other` and a `location` header that points
   back to the home page, with the original URL in the `next` query
   parameter, for example:

   ```
   location: http://localhost:5102/?next=http%3A%2F%2Flocalhost%3A5102%2Faccount
   ```

3. Follow the redirect with `-L`:

   ```bash
   curl -sS -L http://localhost:5102/account
   ```

   This ends at the home page and prints `{"message":"hello"}`.

4. Print only the status code:

   ```bash
   curl -sS -o /dev/null -w '%{http_code}\n' -b 'session=abc123' http://localhost:5102/account
   ```

   This prints `200`. Without `-b 'session=abc123'` it prints `303`.
