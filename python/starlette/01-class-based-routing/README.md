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
python -m cbrws.application
```

This starts the Starlette app on `http://localhost:5101`. The host,
port, and debug mode can be configured with environment variables:

- `CBRWS_HOST`: defaults to `0.0.0.0`
- `CBRWS_PORT`: defaults to `5101`
- `CBRWS_DEBUG`: defaults to `false`
- `CBRWS_LOG_LEVEL`: defaults to `INFO`
- `CBRWS_ACCESS_LOG`: defaults to `true`
- `CBRWS_ALLOWED_HOSTS`: defaults to `*`

To enable debug mode during local development, set `CBRWS_DEBUG` to
`true`:

```bash
CBRWS_DEBUG=true python -m cbrws.application
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

You can also start the app directly with uvicorn:

```bash
uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

To enable debug mode when starting the app with uvicorn, set the same
environment variable:

```bash
CBRWS_DEBUG=true uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```

When starting the app with uvicorn directly, the host and port are
configured by uvicorn's `--host` and `--port` options.

To change logging, set `CBRWS_LOG_LEVEL` to a standard Python logging
level such as `DEBUG`, `INFO`, `WARNING`, or `ERROR`. To disable
request access logs, set `CBRWS_ACCESS_LOG` to `false`:

```bash
CBRWS_LOG_LEVEL=DEBUG CBRWS_ACCESS_LOG=false python -m cbrws.application
```

To restrict accepted HTTP Host headers, set `CBRWS_ALLOWED_HOSTS` to a
comma-separated list of trusted host names:

```bash
CBRWS_ALLOWED_HOSTS=localhost,127.0.0.1,api.example.com \
  python -m cbrws.application
```

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
PYTHONPATH=src python -m cbrws.application
```

For tests in the alternate workflow, include both `src` and `tests`:

```bash
PYTHONPATH=src:tests python -m unittest discover -s tests/test_cbrws
```
