---
name: revisar-pr
description: Review a teammate's pull request against CONSTITUTION.md and AGENTS.md with ruff, pytest and GGA, and leave findings with file and line
---

# revisar-pr

Reviewer-side mirror of `cerrar-tarea-pr`: checks out a teammate's pull request without touching `main`, reads its ODD task and the project rules, runs the same checks as CI and GGA, walks the diff hunk by hunk, and delivers one GitHub review whose findings carry file, line, rule and severity.

- **Never your own pull request, never a merge:** this skill only reviews. The author merges with `cerrar-tarea-pr` §6.
- **With confirmation:** submitting the review (`gh pr review`) and opening follow-up issues are confirmed in a single step after the findings are shown.
- **Environment constraints:** the project ones apply while you run the checks: `uv` only (never `pip install`), no notebooks, and English in any code, comment or test you quote or suggest.

## 1. Inputs

Take the pull request number (or its branch) from the request and load its metadata and the current `gh` user:

```bash
gh pr view <n> --json title,body,headRefName,author,files
gh api user --jq .login
```

If `author.login` is the current user, stop: nobody reviews their own pull request. Ask who reviews it.

## 2. Checkout without touching `main`

```bash
git status --short          # must be clean: commit or stash your own work first
git fetch origin
gh pr checkout <n>
uv sync --locked
command -v engram >/dev/null 2>&1 && engram sync --import || true
```

If `uv sync --locked` fails, `uv.lock` does not match `pyproject.toml`: that is already a `blocker` (dependencies changed without `uv add` or `uv lock`).

## 3. Read before judging

1. The ODD task named in the pull request body (`odd/tasks/<NN>-<slug>.md`): objective, acceptance criteria, tasks, verification evidence and `## 6. Log`. If the body names no task, judge the change against its description and say so in the review.
2. `CONSTITUTION.md` and `AGENTS.md`: the `REJECT if`, `REQUIRE` and `PREFER` rules and the dated architectural decisions.
3. The scope of the change, against the base branch of the pull request (`main` unless `gh pr view` says otherwise):

   ```bash
   git diff origin/main...HEAD --stat
   git log --oneline origin/main..HEAD
   ```

## 4. Automated checks

Run them in order and keep each output for the review body:

```bash
uv run ruff format --check .
uv run ruff check .
uv run pytest
gga run --pr-mode --diff-only
```

Also run every `validate` command that `README.md` lists for the layers the diff touches. A failing check is a `blocker`. An ambiguous GGA result (no `STATUS:` line) is not a pass: read the whole review and turn each point into a finding; never edit `.gga` on the author's branch.

## 5. Manual checklist, hunk by hunk

Walk `git diff origin/main...HEAD` file by file:

- **GGA rules of `AGENTS.md`:** explicit type hints, no leftover `print()`, no hardcoded paths, URLs or model names inside functions, no swallowed errors (`except: pass`, or a catch that neither logs nor re-raises).
- **A test per bug fixed:** every `fix` commit adds a test that fails without the fix. Prove it by undoing the fix in the working tree only:

  ```bash
  git restore --source=origin/main -- <fixed file>
  uv run pytest <new test>                  # must fail
  git restore -- <fixed file>
  ```

- **Determinism, when the task claims it:** run the build twice and compare the hashes of every output file:

  ```bash
  CHECK_DIR="$(mktemp -d)"
  <build command> && find <output dir> -type f -exec sha256sum {} + | sort -k2 > "$CHECK_DIR/first.txt"
  <build command> && find <output dir> -type f -exec sha256sum {} + | sort -k2 > "$CHECK_DIR/second.txt"
  diff "$CHECK_DIR/first.txt" "$CHECK_DIR/second.txt" && echo "ok: deterministic"
  ```

- **Documentation updated:** `README.md` when behavior or commands change, a dated decision in `AGENTS.md` for each new rule (rules and rationale only), run figures in `CHANGELOG.md`.
- **Memory exported:** `.engram/` appears in `git diff --stat origin/main...HEAD` when the task produced decisions.
- **No data, weights or secrets in the diff:**

  ```bash
  git diff --name-only origin/main...HEAD | grep -E '^data/|\.env$|\.(ipynb|bin|pt|pth|safetensors|gguf|onnx)$' || echo "ok: no data, notebooks or weights"
  git diff origin/main...HEAD | grep -nE 'DEEPSEEK_API_KEY=[^ ]|HF_TOKEN=[^ ]|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}' || echo "ok: no secrets in the diff"
  ```

- **PEP 8:** the checklist in `references/pep8-checklist.md` for what `ruff` does not enforce (naming intent, comments that explain why, docstrings and test names in English, consistent returns).

## 6. Findings format

One line per finding, always pointing to a line of the diff and naming the rule it breaks:

```text
- <severity> · <path>:<line> · <rule> · <what fails and how to reproduce>
```

- `blocker`: breaks a `REJECT if` or `REQUIRE` rule, fails a check, misses an acceptance criterion, fixes a bug without a test, or adds data or secrets. Blocks the merge.
- `should`: breaks a `PREFER` rule or leaves a maintainability problem worth fixing in this pull request; it does not block on its own.
- `nit`: wording or style that `ruff` does not catch; optional.

The rule is a `REJECT if`, `REQUIRE` or `PREFER` line of `AGENTS.md`, a section of `CONSTITUTION.md`, an acceptance criterion of the task, or an item of the PEP 8 checklist. A preference without a written rule is not a finding.

Write the review body to a file outside the repository so it never lands in a commit:

```bash
REVIEW_FILE="$(mktemp)"
```

```markdown
## Review of #<n>: <title>

Checks: `ruff format --check` <pass|fail> · `ruff check` <pass|fail> · `pytest` <summary line> · `gga run --pr-mode --diff-only` <STATUS line>

### Blockers
- <findings, or "None">

### Should
- <findings, or "None">

### Nits
- <findings, or "None">
```

## 7. Deliver (with confirmation)

Show the findings and the body to the user, then submit one review:

```bash
gh pr review <n> --request-changes --body-file "$REVIEW_FILE"     # at least one blocker
gh pr review <n> --approve --body-file "$REVIEW_FILE"             # no blockers; should and nit items stay listed
```

Non-blocking items that stay open after the merge go to a follow-up ODD task (the author creates it with `nueva-tarea-odd`) or to an issue, never only to a chat:

```bash
gh issue create --title "Follow-up of #<n>: <summary>" --body "<finding lines and the pull request URL>"
```

## 8. Never merge

The merge belongs to the author, with explicit confirmation, in `cerrar-tarea-pr` §6. When the review is delivered, leave the author's branch and drop your local copy of it:

```bash
git switch main
git branch -D "<headRefName>"
```
