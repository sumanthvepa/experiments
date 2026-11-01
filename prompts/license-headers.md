# Source-Code License Headers

Before creating or modifying a source file, determine whether it is
first-party code, or vendored, generated, copied or third-party code.

## First-Party Code

All first-party source code in this repository is licensed under the
GNU General Public License, version 3 or any later version.

For new first-party source files, use the header from:

`prompts/copyleft-template.txt`

This applies to implementation code, tests, and type stubs, including
`.py`, `.pyi`, `.js`, `.mjs`, `.html`, `.css`, `.jinja2` and shell
(`.sh`) files. Replace the placeholders and render every line as a
comment using the source language's syntax.

When modifying an existing first-party source file that has no license
header, add the GPL header.

Do not add a proprietary header to any file in this repository.
Proprietary experiments belong in a different repository.

## Existing and Third-Party Code

Preserve existing copyright and license notices.

Do not replace or remove an existing license header unless
explicitly requested by the user. Several existing files (for example,
the Javascript files under `javascript/basics/`) carry a differently
formatted header that already states the GPL license. Leave these as
they are.

Do not apply first-party headers to vendored, generated, copied, or
third-party code. Preserve its original licensing.

If a file's ownership, origin, or applicable license is unclear, stop
and ask the user before adding or changing its license header.

## Non-Source Files

Do not add source-code license headers to datasets, Markdown documents,
configuration files, generated artifacts, or media unless a separate
instruction requires one.
