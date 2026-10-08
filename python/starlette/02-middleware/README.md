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

The service has no authentication. Only run it on a network you trust.
To accept connections from the local machine only, change
`--host=0.0.0.0` to `--host=127.0.0.1` in `runws.sh`.
