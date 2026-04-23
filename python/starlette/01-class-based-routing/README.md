# Class Based Routing Demonstration

A hello world web service that uses class based routing and fully
implements a JSON web service including handling forbidden methods
and unknown URLs.

## Development

### Create the virtual environment and install dependencies
Create a Python virtual environment and install dependencies from the project root:
```bash
python -m venv venv
source venv/bin/activate
```

You can either install exact dependencies from requirements.txt:

Install the latest version of the packages from packages.txt
```bash
packages3.sh
````
This should be done if you have just checked out a new branch and want
to create a venv with the latest versions of the dependencies.

Sometimes this is not desirable, for example if you want to create
a project the dependencies in requirements.txt. In that case, install
from requirements.txt:

```bash
pip install -r requirements.txt
```

### Install the project in editable mode
Install the project in editable mode from the project root:

```bash
pip install -e .
```
After editable install, the cbrws package is importable from the
active Python environment while still using the source files in
this working tree. The test modules still import helpers from
tests, so set PYTHONPATH=tests when running tests.

Now you can start doing development work. (See the section
on testing and running the web service below for how to run the app
and tests)

### pyproject.toml vs requirements.txt vs packages.txt
For milestone42 projects, packages.txt is the source of truth for top
level dependencies. The way we work at Milestone42 is that there is an
expectation that the project will work with the latest versions of the
its dependencies, so packages.txt does not specify versions. The
project should be tested with the latest versions of dependencies
before merging to main.

Requirements.txt is a generated file that pins the exact versions of
dependencies that are known to work together. When you are ready to
deploy the project to production, regenerate requirements.txt
in the development environment first:

Pyproject.toml is used to specify the project metadata and dependencies
in a standardized way. It is used by pip to install the project and
its dependencies. Currently you are required to manually keep
pyproject.toml in sync with packages.txt, but in the future we may
add a script to automate this.
  
```bash
rm -r venv
python -m venv venv
source venv/bin/activate
packages3.sh
pip install -e .
```

### Deploying to production

#### Building a wheel for production deployment
Assuming you have a clean venv and everything work in the development
environment. Check out a clean version of the project in production
location (on a different machine or location) and do the following:

```bash
python -m venv venv
source venv/bin/activate
python -m pip install  build
python -m build
```

The `build` step creates a wheel file in the `dist` directory that can
be copied into a production environment and installed into a
production virtual environment with

#### Installing the wheel in production
Copy the wheel file from the `dist` directory in the build environment
to the production environment (the container) and then run:
```bash
pip install dist/cbrws-0.1.0-py3-none-any.whl
```

Now follow the instructions in the next section to run the web service
in production.

# Running the web service
Start the web service with:

```bash
uvicorn cbrws.application:app --log-config config/log-config.dev.json --host 0.0.0.0 --port 5101
```

This starts the Starlette app on `http://localhost:5101`. The host and
port are uvicorn options. The --log-config option give uvicorn the path
to the development logging configuration. Application behavior can be
configured with environment variables:

- `CBRWS_DEBUG`: defaults to `false`
- `CBRWS_ALLOWED_HOSTS`: defaults to `localhost,127.0.0.1`

To enable debug mode during local development, set `CBRWS_DEBUG` to
`true`:

```bash
CBRWS_DEBUG=true uvicorn cbrws.application:app --log-config config/log-config.dev.json --host 0.0.0.0 --port 5101
````

If you want hot reload during development, add the `--reload` option.
This is not recommended for production use because it adds overhead
and can cause unexpected behavior if the app reloads while processing
a request. The command given below should be ideal for local development:

```bash
CBRWS_DEBUG=true \
  uvicorn cbrws.application:app \
  --log-config config/log-config.dev.json \
  --host 0.0.0.0 \
  --port 5101 \
  --reload
```

As a convenience for development, the command has been placed
in the `run-dev.sh` script. You can run that script instead of typing the full command:

```bash
./run-dev.sh
````

By convention the stdout and sterr output of the scrpt are tee'd
to 'ws.log' in the project root, so you can see the logs in real time and
also have them saved to a file for later review. Run the
script in the project root as follows:

```bash
./run-dev.sh 2>&1 | tee ./ws.log
```

In production CBRWS_DEBUG should be `false` and `--reload` should not be used.
CBRWS_ALLOWED_HOSTS should be set to a comma-separated list of trusted host
ips or hostnames that clients will use to connect to the service. The
application will not start with `CBRWS_ALLOWED_HOSTS=*` unless
`CBRWS_DEBUG=true`.

```bash
CBRWS_DEBUG=false \
  CBRWS_ALLOWED_HOSTS="localhost, crystal.milestone42.com, darkness2.milestone42.com, dustbin2.milestone42.com, pitts.milestone42.com" \
  uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

### Testing
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

The app emits logs through Python loggers. Application request access
logging is always enabled and cannot be turned off through application
configuration. Use uvicorn logging options to control log levels,
formatting, and destinations.

Uvicorn's built-in `--log-level` option only affects uvicorn's own
loggers, not the application's loggers. To see application logs
use the ``--log-config`` option to give uvicorn a logging
configuration that includes the application's loggers. The included
development logging configuration sends application logs to
standard error and uvicorn's HTTP access logs to standard output,
so you can easily separate them.
```bash
uvicorn cbrws.application:app \
  --host 0.0.0.0 \
  --port 5101 \
  --log-config config/log-config.dev.json
```

The `config/log-config.dev.json` file is a Python `logging.config`
dictionary in JSON form. It has these top-level entries:

- `version`: selects the logging configuration schema version. Python
  currently requires this to be `1`.
- `disable_existing_loggers`: keeps loggers that were created before
  the config file is loaded instead of disabling them.
- `formatters`: defines how log records are converted to text.
- `handlers`: defines where formatted log records are written.
- `loggers`: maps logger names to handlers, log levels, and propagation
  behavior.

The `formatters` section defines three output formats:

- `default`: uses `uvicorn.logging.DefaultFormatter` for general
  uvicorn messages. The `fmt` value prints uvicorn's level prefix and
  the message, and `use_colors` lets uvicorn decide whether colors are
  appropriate for the current terminal.
- `access`: uses `uvicorn.logging.AccessFormatter` for uvicorn's own
  HTTP access logs. Its format includes the client address, request
  line, and status code.
- `cbrws`: uses the standard logging formatter for application logs.
  It prints the timestamp, level, logger name, and message with the
  configured date format.

The `handlers` section sends each formatted record to a stream:

- `default`: writes general uvicorn messages to standard error with
  the `default` formatter.
- `access`: writes uvicorn access messages to standard output with the
  `access` formatter.
- `cbrws`: writes cbrws application messages to standard error with the
  `cbrws` formatter.

The `loggers` section connects named loggers to those handlers:

- `uvicorn`: sends general uvicorn logs to the `default` handler at
  `INFO` level and stops them from propagating to ancestor loggers.
- `uvicorn.error`: sets the error logger level to `INFO`. It does not
  define its own handler, so it inherits uvicorn's logger behavior.
- `uvicorn.access`: sends uvicorn's HTTP access logs to the `access`
  handler at `INFO` level and stops propagation.
- `cbrws`: sends all cbrws application logs, including the app's
  always-on request access logs, to the `cbrws` handler at `DEBUG`
  level and stops propagation.

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

Generated response links use Starlette route paths with a public origin
resolved through `CBRWS_ALLOWED_HOSTS`. For an internal service that is
called directly, no proxy-specific setup is needed. Run uvicorn on the
private interface that callers use, and set `CBRWS_ALLOWED_HOSTS` to the
host names those callers send.

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
