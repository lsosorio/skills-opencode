---
name: nueva-tarea-odd
description: Starts, specifies, and implements a new Python/AI requirement or experiment following ODD in odd/tasks/ with uv in OpenCode and DeepSeek (new task, specify feature, implement ODD task, nueva tarea). Syncs main and Engram, creates the feat/<NN>-<slug> branch, drafts odd/tasks/<NN>-<slug>.md, requests approval before coding, and implements task by task with ruff and pytest.
---

# nueva-tarea-odd

Guides the full lifecycle of a requirement under **ODD (Organic-Driven Development)** in Python and Artificial Intelligence projects using **`uv`**, **Engram**, and **GGA**: first specify and validate the design in `odd/tasks/`, then implement incrementally in `src/` and `tests/`.

- **Golden rule:** never write or modify code in `src/` or `tests/` before `odd/tasks/<NN>-<slug>.md` is created and approved by the user.
- **Environment constraints:** never create `.ipynb` files, never use `pip install`, always include explicit type hints, and write all code identifiers, docstrings, comments, and tests in **English**.

## 1. Initial context and synchronization

1. Check the working tree status and import shared team memory:

   ```bash
   git status --short
   command -v engram >/dev/null 2>&1 && engram sync --import || true
   ```

2. If there are uncommitted changes on another branch, warn the user before switching branches.
3. If on `main` (or if the user asks to start from `main`), fast-forward pull:

   ```bash
   git pull --ff-only || true
   ```

4. Query Engram for prior project decisions (`engram context` or the Engram MCP tool if active) and read `CONSTITUTION.md` and `AGENTS.md` to identify the package path `src/<package>/`, architectural boundaries, and active project rules.

## 2. Task numbering and branch creation

1. List existing files in `odd/tasks/` to determine the next two-digit sequence number (`01`, `02`, `03`, ...):

   ```bash
   ls -1 odd/tasks/ 2>/dev/null
   ```

2. From the user's requirement, derive a short lowercase hyphenated *slug* (e.g., `01-bpe-tokenizer` → branch `feat/01-bpe-tokenizer`).
3. If currently on `main`, create and switch to the feature branch:

   ```bash
   git switch -c "feat/<NN>-<slug>"
   ```

## 3. Specification draft (`odd/tasks/<NN>-<slug>.md`)

If the user's request is missing a critical detail that would force a redesign (such as expected inputs, expected outputs, or target algorithm/model), ask **one concise question** before drafting. Otherwise, make a reasonable assumption and state it explicitly.

Create `odd/tasks/<NN>-<slug>.md` based on `odd/tasks/_template.md` (or `odd/tasks/_plantilla.md` if present):

```markdown
# <NN> - <Clear requirement title>

Status: proposed
Branch: `feat/<NN>-<slug>`

## 1. Objective
<Concise 1-2 line description of what this requirement solves.>

## 2. Technical specification (Inputs / Outputs)
- **Module(s):** `src/<package>/<module>.py`
- **Proposed signatures (with type hints):**
  - `<function_or_class>(...) -> <ReturnType>`
- **Inputs:** <parameters, types, and validation rules>
- **Outputs:** <returned data structure or type>
- **New dependencies (`uv add`):** <none, or exact package list>
- **Test decoupling:** <how the LLM client, model, or configuration is injected via parameters to test in `pytest` offline>

## 3. Acceptance criteria
- [ ] <Expected happy-path behavior with concrete data>
- [ ] <Validation of empty, null, or out-of-range inputs (explicit exception)>
- [ ] <Handling of external failures (timeouts, malformed model outputs) if applicable>
- [ ] Strict type hints on all signatures and isolated unit tests in `tests/test_<module>.py`

## 4. Implementation tasks
- [ ] **T1:** <Define data models / schemas and base signatures in `src/<package>/<module>.py`>
- [ ] **T2:** <Implement core logic following SRP and KISS>
- [ ] **T3:** <Write unit tests in `tests/test_<module>.py` covering normal and edge cases>
- [ ] **T4:** <Run `uv run ruff check .` and `uv run pytest`, and record verification evidence>

## 5. Verification evidence
Pending implementation.
```

## 4. Mandatory approval gate

**Stop here.** Present a brief summary of `odd/tasks/<NN>-<slug>.md` to the user and ask for approval or adjustments before writing any code.

## 5. Incremental implementation (Task by task)

Once the user approves:

1. Update `Status: proposed` to `Status: in-progress` in `odd/tasks/<NN>-<slug>.md`.
2. If new dependencies were approved in section 2 of the spec, install them exclusively with `uv`:

   ```bash
   uv add <package>
   ```

3. Execute the tasks sequentially (`T1` → `T2` → `T3` → `T4`):
   - Follow pragmatic software engineering practices:
     - **English-only code:** all module names, classes, functions, variables, type annotations, docstrings, and test names must be in English.
     - **SRP:** short functions with a single responsibility and a single level of abstraction.
     - **KISS / YAGNI:** modular, direct code without unnecessary layers or interfaces.
     - **Parameter injection:** accept external clients or settings as arguments so `pytest` tests use mocks/stubs without live API calls or heavy model downloads.
     - **Zero magic values:** keep model names, hyperparameters, and file paths in constants or centralized configuration.
   - Mark each completed task as `- [x]` in `odd/tasks/<NN>-<slug>.md`.
4. Run verification in `T4`:

   ```bash
   uv run ruff format .
   uv run ruff check .
   uv run pytest -v
   ```

5. Once all checks pass, update `## 5. Verification evidence` in `odd/tasks/<NN>-<slug>.md` with the actual `ruff` and `pytest` output, mark satisfied acceptance criteria (`[x]`), and let the user know they can inspect the changes or run `cerrar-tarea-pr` to sync Engram and open the Pull Request.
