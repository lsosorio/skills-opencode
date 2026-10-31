# Example: task 09, Windows portability of the Makefile

`corpus-acme` (Python 3.12, `uv`) has a Makefile written before the team had a Windows member. Its `fetch` target runs `uv run --env-file .env acme fetch`, and its first line is `SHELL := /usr/bin/env bash`. Every name here is fictitious.

## 1. Request and synchronization (step 1)

The request, which becomes `L1` word for word:

> On Windows `make help` fails with "/usr/bin/env: No such file or directory" and `make fetch` breaks when there is no .env. Make the Makefile work on Windows without changing Linux or CI.

```text
$ git status --short
$ engram sync --import
No new chunks to import.
$ git pull --ff-only
Already up to date.
```

The agent read `CONSTITUTION.md`, `AGENTS.md` and the Engram context: the package is `src/corpus_acme/`, and GNU make on Windows is native, so it cannot resolve `/usr/bin/env`.

## 2. Numbering and branch (step 2)

```text
$ ls -1 odd/tasks/
01-corpus-scope.md
...
08-license-and-readme.md
_template.md
$ git switch -c "feat/09-windows-makefile"
Switched to a new branch 'feat/09-windows-makefile'
```

## 3. Specification draft (step 3)

No critical detail was missing, so the agent asked nothing and recorded its assumption as `A1`. File `odd/tasks/09-windows-makefile.md`:

```markdown
# 09 - Windows portability of the Makefile

Status: proposed
Branch: `feat/09-windows-makefile`

## 1. Objective
Make `make` and the onboarding work on Windows without changing the POSIX flow of Linux, macOS and CI.

## 2. Technical specification (Inputs / Outputs)
- **Module(s):** `Makefile`, `README.md` (Install section)
- **Inputs:** `OS`, which GNU make sets to `Windows_NT` on Windows; whether `$(ENV_FILE)` exists
- **Outputs:** `SHELL` pointing to Git Bash on Windows and to `/usr/bin/env bash` elsewhere; `ENV_ARG` holding `--env-file` only when the file exists
- **New dependencies (`uv add`):** none
- **Test decoupling:** no Python changes; verified with `make -n`, which prints recipes without running them

## 3. Acceptance criteria
- [ ] `make help` exits 0 on Windows with Git for Windows installed
- [ ] Without Git Bash, `make` stops with an actionable message instead of a cryptic error
- [ ] On Linux and in CI, `SHELL` stays `/usr/bin/env bash`
- [ ] `make fetch` works without `.env`, because `uv run --env-file` fails when the file is missing
- [ ] `README.md` explains the Windows onboarding with the Git for Windows bash

## 4. Implementation tasks
- [ ] **T1:** Select `SHELL` from `$(OS)` and search Git Bash in the usual install paths
- [ ] **T2:** Add `ENV_ARG` so `--env-file` is omitted when `.env` does not exist
- [ ] **T3:** Document the Windows onboarding in `README.md`
- [ ] **T4:** Verify with `make help`, `make -n fetch`, `uv run ruff check .` and `uv run pytest`

## 5. Verification evidence
Pending implementation.

## 6. Log

- L1 (request): On Windows `make help` fails with "/usr/bin/env: No such file or directory" and `make fetch` breaks when there is no .env. Make the Makefile work on Windows without changing Linux or CI.
- A1 (assumption): Windows users have Git for Windows installed; WSL is not a supported shell for this repository.
```

## 4. Approval gate (step 4)

The agent stopped and wrote:

```text
Task 09 is drafted in odd/tasks/09-windows-makefile.md: SHELL by OS with a Git Bash
search, --env-file only when .env exists, and a Windows section in the README.
Assumption A1: Git for Windows is installed; WSL is out of scope.
No Python code changes and no new dependencies. Approve, or tell me what to adjust.
```

The user answered "Approved". The agent appended `- 2026-10-29: approved without changes.` to the Log and set `Status: in-progress`.

## 5. Implementation (step 5)

T1 and T2 changed the top of the Makefile:

```makefile
ifeq ($(OS),Windows_NT)
GIT_BASH ?= $(firstword $(wildcard C:/Progra~1/Git/bin/bash.exe) $(wildcard C:/Progra~2/Git/bin/bash.exe))
ifeq ($(GIT_BASH),)
$(error Git Bash not found. Install Git for Windows or pass GIT_BASH=<path to bash.exe>)
endif
SHELL := $(GIT_BASH)
else
SHELL := /usr/bin/env bash
endif
ENV_FILE ?= .env
ENV_ARG := $(if $(wildcard $(ENV_FILE)),--env-file "$(ENV_FILE)",)
```

T4 evidence, copied into `## 5. Verification evidence`:

```text
$ make help
  help           Show this help
  fetch          Capture the public pages into data/raw/
  lint           Run ruff check
  test           Run pytest
$ make -n fetch ENV_FILE=.env.missing
uv run acme fetch
$ uv run ruff check .
All checks passed!
$ uv run pytest
42 passed in 1.31s
```

Files changed on the branch:

```text
odd/tasks/09-windows-makefile.md   new
Makefile                           modified
README.md                          modified
```

## 6. Final state

All criteria and tasks are `[x]`, `## 5. Verification evidence` holds the real outputs, and the closing message repeats assumption A1. The branch is ready for `cerrar-tarea-pr`, which sets `Status: completed`, syncs Engram and opens the pull request (see its example `close-task-09.md`).
