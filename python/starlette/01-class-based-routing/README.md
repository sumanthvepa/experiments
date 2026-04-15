# Class Based Routing Demonstration

A hello world web service that uses class based routing and fully
implements a JSON web service including handling forbidden methods
and unknown URLs.

## Development

Install the project in editable mode from the project root:

```bash
pip install -e .
```

This makes the `cbrws` package importable from the active Python
environment while still using the source files in this working tree.

Start the web service with:

```bash
uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

This starts the Starlette app on `http://localhost:5101`. The host and
port are uvicorn options. Application behavior can be configured with
environment variables:

- `CBRWS_DEBUG`: defaults to `false`
- `CBRWS_LOG_LEVEL`: defaults to `INFO`
- `CBRWS_ACCESS_LOG`: defaults to `true`
- `CBRWS_ALLOWED_HOSTS`: defaults to `*`

To enable debug mode during local development, set `CBRWS_DEBUG` to
`true`:

```bash
CBRWS_DEBUG=true uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

If you want hot reload during development, add the `--reload` option.
This is not recommended for production use because it adds overhead
and can cause unexpected behavior if the app reloads while processing
a request. The command given below is should be ideal for local development:

```bash
CBRWS_DEBUG=true uvicorn cbrws.application:app --host 0.0.0.0 --port 5101 --reload
```

Run the unit tests with:

```bash
PYTHONPATH=tests python -m unittest discover -s tests/test_cbrws
```

The `PYTHONPATH=tests` setting lets the tests import shared test helpers
from the `tests` directory.

Useful URLs during development:

- `/`
- `/api`
- `/api/greeting`
- `/profiles/cbrws/v1`
- `/profiles/cbrws/v1/rels/greeting`

To change logging, set `CBRWS_LOG_LEVEL` to a standard Python logging
level such as `DEBUG`, `INFO`, `WARNING`, or `ERROR`. To disable
request access logs, set `CBRWS_ACCESS_LOG` to `false`:

```bash
CBRWS_LOG_LEVEL=DEBUG CBRWS_ACCESS_LOG=false \
  uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

To restrict accepted HTTP Host headers, set `CBRWS_ALLOWED_HOSTS` to a
comma-separated list of trusted host names:

```bash
CBRWS_ALLOWED_HOSTS=localhost,127.0.0.1,api.example.com \
  uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

Chrome blocks some ports, including port 6000, for HTTP requests. If
you choose one of those ports for local development, use a different
browser or launch Chrome with an explicit port allow list. On macOS:

```bash
open -na "Google Chrome" --args --explicitly-allowed-ports=6000 \
  --profile-directory="Default"
```

Chrome profile directory names include `Default` and the profile
directories under `~/Library/Application Support/Google/Chrome/`.

## Reverse Proxy Deployment

Generated response links use request information supplied by Starlette.
For an internal service that is called directly, no proxy-specific setup
is needed. Run uvicorn on the private interface that callers use, and
set `CBRWS_ALLOWED_HOSTS` to the host names those callers send.

For an Internet-facing service, terminate TLS at nginx and let nginx
forward the request to uvicorn over a private interface. In that setup,
nginx must pass the public `Host` value and the original request scheme
to uvicorn, and uvicorn must be configured to trust those proxy headers.
Without that contract, generated absolute URLs can use the internal
`http://127.0.0.1:5101` origin instead of the public HTTPS origin.

Run uvicorn directly for proxied deployments so proxy header handling is
explicit:

```bash
CBRWS_ALLOWED_HOSTS=api.example.com \
  uvicorn cbrws.application:app \
    --host 127.0.0.1 \
    --port 5101 \
    --proxy-headers \
    --forwarded-allow-ips 127.0.0.1
```

The `--proxy-headers` option lets uvicorn use trusted
`X-Forwarded-For` and `X-Forwarded-Proto` headers when building the ASGI
request scope. The `--forwarded-allow-ips` value must identify the proxy
that is allowed to set those headers. If nginx and uvicorn communicate
over a Unix domain socket, use the socket path instead. Use `*` only
when every path to uvicorn is controlled and untrusted clients cannot
connect directly.

A minimal nginx TLS-terminating proxy looks like this:

```nginx
server {
  listen 443 ssl;
  server_name api.example.com;

  ssl_certificate /path/to/fullchain.pem;
  ssl_certificate_key /path/to/privkey.pem;

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:5101;
  }
}
```

On Debian or Ubuntu, add the server block to a site file such as
`/etc/nginx/sites-available/cbrws` and enable it with a symbolic link:

```bash
sudo ln -s /etc/nginx/sites-available/cbrws /etc/nginx/sites-enabled/cbrws
```

On Fedora, RHEL, or CentOS, put the server block in a file such as
`/etc/nginx/conf.d/cbrws.conf`.

After changing nginx configuration, test the configuration before
reloading nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

If `nginx -t` reports an error, fix the configuration before reloading.
The reload command applies the new configuration without dropping
existing connections.

Do not expose the uvicorn port directly to the Internet in this
configuration. The proxy headers are trusted only because nginx is the
only client that can reach uvicorn. If the service is mounted below a URL
prefix, also configure uvicorn's `--root-path` so generated route URLs
include that prefix.

This project does not include a Dockerfile yet. The service is intended
to run in a container when deployed, but the container build needs to
follow project-specific conventions that will be added in a separate
task.

CORS handling is also planned as a future optional feature. Internal
web services do not need to enable it by default, but Internet-facing
web services that serve browser clients must treat explicit CORS
configuration as a required capability.

As an alternate workflow, you can run the app without installing it by
setting `PYTHONPATH=src`:

```bash
PYTHONPATH=src uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

For tests in the alternate workflow, include both `src` and `tests`:

```bash
PYTHONPATH=src:tests python -m unittest discover -s tests/test_cbrws
```
