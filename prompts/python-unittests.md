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

If a run reports `Ran 0 tests`, the project may use a namespace
package layout (directories without `__init__.py`), which test
discovery cannot descend into. Such a project has its own
`prompts/python-unittests.md` with the commands to use. Follow that file
instead of the commands above.

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
