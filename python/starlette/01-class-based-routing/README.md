# Class Based Routing Demonstration

A hello world web service that uses class based routing and fully
implements a JSON web service including handling forbidden methods
and unknown URLs.

## Development

Start the web service from the project root with:

```bash
PYTHONPATH=src python -m cbrws.application
```

This starts the Starlette app on `http://localhost:5101`.

Useful URLs during development:

- `/`
- `/api`
- `/api/greeting`
- `/profiles/cbrws/v1`
- `/profiles/cbrws/v1/rels/greeting`

You can also start the app directly with uvicorn:

```bash
PYTHONPATH=src uvicorn cbrws.application:app --host 0.0.0.0 --port 5101
```
