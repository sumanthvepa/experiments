# Python Unit Tests

This repository contains multiple independent Python projects.

## Select the Project

Before running tests, identify the relevant Python project.

The project root is the nearest ancestor of the source or test file
that contains `pyproject.toml`. Some older projects have no
`pyproject.toml`. For those, the project root is the nearest ancestor
that contains the `tests/` directory. Run all commands from that
directory.

If a change affects multiple Python projects, run the relevant tests
in each project separately.

If a shared dataset or other shared resource changes, run the tests
for every Python project that consumes it.

## Environment

Make sure the relevant project's Python environment is active and
that the project is installed in that environment. Each project has its
own environment; its dependencies are listed in the project's
`packages.txt` and `local-packages.txt` files, where they exist.

If project imports or dependencies are unavailable, report that the
environment is not configured correctly. Do not install packages or
change import paths unless the user explicitly asks.

Do not set `PYTHONPATH=src` as a fallback.

## Run All Tests

From the relevant project root, run:

```bash
python -m unittest discover -s tests -p 'test_*.py' -v
```

## Run One Test Module

From the relevant project root, run:

```bash
python -m unittest discover -s tests \
  -p 'test_name.py' -v
```

## Namespace Layouts

Some projects have a source package that is a namespace package (it
has no `__init__.py`) and mirror that layout under `tests/`, for
example `tests/mws/test/`. Test discovery does not descend into
directories that lack an `__init__.py`, so the standard commands above
report `Ran 0 tests` for these projects.

Do not add an `__init__.py` to a namespace directory. Instead, run
discovery from the project root against the innermost test package
that has an `__init__.py`, and pass the project root as the top-level
directory:

```bash
python -m unittest discover -s tests/<namespace>/<package> -t . \
  -p 'test_*.py' -v
```

For example, in `python/starlette/02-middleware`:

```bash
python -m unittest discover -s tests/mws/test -t . \
  -p 'test_*.py' -v
```

Run this once for each test package. To run one test module, use its
dotted name:

```bash
python -m unittest -v tests.mws.test.test_application
```

If a run reports `Ran 0 tests`, check whether the tests live under a
namespace directory before concluding that no tests exist.

## Choose the Test Scope

When implementation code changes, first run its directly related test
module or modules. If those pass, run the complete test suite for that
Python project.

When test code changes, run the changed test module and then the
complete project test suite.

Documentation-only changes do not require unit tests unless they
change executable examples or generated artifacts.

## Test Framework

Use Python's built-in `unittest` framework and `unittest.TestCase`.

Do not use pytest unless the user explicitly asks for it.
