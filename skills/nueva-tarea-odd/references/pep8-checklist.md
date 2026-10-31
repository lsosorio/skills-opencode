# PEP 8 checklist

Source: https://peps.python.org/pep-0008/ (and PEP 257 for docstrings). `ruff` enforces the rule families in brackets; the rest is reviewed by hand.

## Naming [N]
- Packages: short, lowercase, no underscores. Modules: short, `snake_case`.
- Classes and exceptions: `CapWords`; exceptions end in `Error`.
- Functions, methods, variables, arguments: `snake_case`. Constants: `UPPER_CASE` at module level.
- Internal names: one leading underscore (`_cache`); name mangling (`__attr`) only to avoid clashes in subclasses.
- Never single-letter `l`, `O` or `I`. Descriptive names: no `tmp`, `aux`, `df`, `x1` (project rule).

## Layout [E, W]
- 4 spaces per indentation level; no tabs. Line length 100 (team decision; PEP 8 says 79).
- Two blank lines around top-level `def` and `class`; one between methods. No trailing whitespace; file ends with one newline.
- Imports at the top, one per line, grouped standard library / third party / local, absolute imports [I]. No wildcard imports.
- Line breaks before binary operators; continuation lines aligned or hanging with 4 extra spaces (`ruff format` decides).

## Whitespace [E2]
- No spaces inside brackets or before a comma, colon or semicolon; one space around assignment and comparison operators.
- No spaces around `=` in keyword arguments and defaults, except with an annotation: `def f(x: int = 1)`.

## Statements and comparisons [E7, SIM, B]
- `is None` / `is not None`, never `== None`. `isinstance(obj, int)`, never `type(obj) is int` for compatibility.
- Truth of sequences: `if not seq`, never `len(seq) == 0`. Never compare booleans with `==`.
- One statement per line; no compound `if x: y()`.
- All `return` statements of a function return an expression or none of them does.
- Resources with `with`; string methods instead of `string` module; `''.startswith()` instead of slicing.

## Exceptions [E722, B]
- Never bare `except:`; catch the narrowest class you can handle, `except Exception` at most.
- Re-raise with context: `raise NewError("...") from exc`. Keep the `try` body minimal.
- Exceptions are classes; `raise ValueError("message")`, never a string.

## Docstrings [D, PEP 257]
- Triple double quotes; first line imperative and on one line (`"""Return the parsed manifest."""`).
- Multi-line: summary, blank line, details; closing quotes on their own line.
- In English, like identifiers, comments and test names (project rule).

## Type hints [ANN, PEP 484]
- Every parameter and return annotated, including `-> None`. Avoid `Any` when a concrete type exists.
- Modern syntax: `list[str]`, `X | None` [UP].

## Comments
- Complete sentences, in English, that explain why, not what. Block comments above the code, inline comments two spaces after it and rarely.
- No commented-out code and no `print()` left behind (GGA rule).
