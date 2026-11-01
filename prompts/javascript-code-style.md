# Javascript Coding Style Guidelines

When creating Javascript code follow these style guidelines:

## Line Length

Keep lines to between 70 and 80 characters long. DO NOT
let lines be longer than 80 characters, unless it is unavoidable.

## Indentation

ALWAYS use 2 spaces for indents.


## String Quotes

ALWAYS use single quoted strings wherever possible.


## Use JSDoc Extensively
ALWAYS annotate all modules, files, classes, methods, functions and variables,
with JSDoc comments. Provide types for the parameters of every function
and for its return value.

## Comply with the AirBnB Javascript style otherwise
Always write code that complies with
[AirBnB Javascript guidelines](https://github.com/airbnb/javascript)
except where it conflicts with the rules above.


## License Headers

Follow the path-based licensing rules in
`prompts/license-headers.md`.

## Run eslint

Always run eslint after generating code and report the warnings to
the user. Run it from the directory of the Javascript project that
contains the file (the one with the `eslint.config.mjs`), using that
project's configuration. If the project has no eslint configuration,
tell the user instead of creating one. Follow the user's instructions
on how to fix the warnings.
