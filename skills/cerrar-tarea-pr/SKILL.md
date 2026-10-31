---
name: cerrar-tarea-pr
description: Closes an active ODD task, verifies code quality with uv (ruff and pytest), updates odd/tasks/, saves and syncs team memory in Engram, creates a GGA-validated commit, opens a GitHub Pull Request with a reviewer, and cleans up the branch after the merge (close task, finish feature, push changes, create PR, merge PR, cerrar tarea).
---

# cerrar-tarea-pr

Cleanly and reproducibly closes a feature branch before sharing it with the team: validates code with `uv`, audits against forbidden files, completes the specification in `odd/tasks/`, exports team memory to `.engram/chunks/`, and opens the Pull Request.

- **With confirmation:** creating the final commit, pushing the branch, and opening the Pull Request (`gh pr create`) are confirmed in a single step after all local checks pass. Merging and deleting the branch (step 6) need their own confirmation.

## 1. Branch status and active task

1. Identify the current branch, modified files, and active ODD document:

   ```bash
   git branch --show-current
   git status --short
   ls -1 odd/tasks/
   ```

2. **If currently on `main`:** warn the user and propose creating a `feat/<NN>-<slug>` branch before committing so the change goes through Pull Request and CI review.

## 2. Constraint audit and quality checks with `uv`

Run all checks in order. **If any check fails, stop and fix the issue before continuing.**

### 2.1. Forbidden notebooks, `requirements.txt`, secrets, and model weights

```bash
find . -name "*.ipynb" -not -path "./.venv/*"
[ -f requirements.txt ] && echo "ERROR: requirements.txt exists" || echo "ok: no requirements.txt"
git status --porcelain | grep -E '\.(env|gguf|safetensors|bin|pt|pth|onnx)$' || echo "ok: no secrets or model weights staged"
```

- If any `.ipynb` or `requirements.txt` file appears, remove it or migrate it to a Python module in `src/` / dependency in `pyproject.toml`.
- If `.env` or model weight files appear in `git status`, unstage them and add their pattern to `.gitignore`.

### 2.2. Formatting, linter (`ruff`), and unit tests (`pytest`)

```bash
uv run ruff format .
uv run ruff check .
uv run pytest -v
```

Both `ruff check` and `pytest` must exit with code `0`.

## 3. Complete the document in `odd/tasks/`

Update the `odd/tasks/<NN>-<slug>.md` file for the current branch:

1. Set the status header to `Status: completed` (or `Estado: completado`).
2. Confirm that all acceptance criteria (`## 3`) and implementation tasks (`## 4`) are checked (`- [x]`).
3. Update `## 5. Verification evidence` with the actual output summary from `uv run ruff check .` and `uv run pytest -v`, and verify that every item in the **Definition of Done (DoD)** of `CONSTITUTION.md` is satisfied.
4. If the task introduced a project-wide architectural or design decision, append a dated one-line entry under `## Architectural decisions` in `AGENTS.md` **only for rules and choices with their rationale; run figures (counts, sizes, durations) go to `CHANGELOG.md`**.

## 4. Shared team memory in Engram

So teammates receive the context of what was built when they run `git pull`:

1. Save a structured memory summary of the completed task in Engram (modules created/modified, technical decisions made, and usage):
   - Use the `mem_save` MCP tool if available; otherwise run via CLI:

     ```bash
     engram save "<NN> - <Task title>" "<Concise summary of implementation, key files, and design decisions>" --type architecture
     ```

2. Export the new memory chunks into the repository's `.engram/` folder:

   ```bash
   engram sync
   ```

3. Verify that `.engram/manifest.json` and `.engram/chunks/` appear in `git status --short`.

## 5. Commit, push, and Pull Request (with confirmation)

### 5.0. Run GGA before the commit

`gga run` reviews the staged files only, so stage the changes first:

```bash
git add -A
gga run
```

Fix every violation it reports, stage the fixes with `git add -A` and run it again until it prints `STATUS: PASSED`. Two cases are different:

- `STATUS: FAILED`: fix the violation. Never disable the hook and never use `git commit --no-verify` to skip a rejection.
- Ambiguous result (strict mode cannot find the `STATUS:` line because the model narrates before answering): set `STRICT_MODE="false"` in `.gga` only for this local review, read the whole review, apply its findings, restore `STRICT_MODE="true"` before committing and record the review in the ODD task evidence. `--no-verify` is allowed only with the team's explicit authorization, after that full review, and the task document must say so.

### 5.1. Show the release plan

Show the user:

- The output of `git status --short`.
- The proposed Conventional Commits message in English (e.g., `feat(<module>): implement <summary>`).
- The Pull Request title and summary.
- The reviewer: ask who reviews and take their GitHub login. If there is no reviewer, warn that the Pull Request will not meet "review required" in graded or evaluated flows.

### 5.2. Confirm

Ask for confirmation to execute the release steps.

### 5.3. Stage and commit

Upon confirmation, stage everything and review what will be committed:

```bash
git add -A
git status --short      # review: nothing unexpected (no .env, no data blobs)
```

If anything unexpected appears, unstage it with `git restore --staged <path>` and fix `.gitignore` before committing:

```bash
git commit -m "<type>(<scope>): <short description>"
```

*(When `git commit` runs, the local **GGA** pre-commit hook audits the diff with DeepSeek against `AGENTS.md`; files that already passed in 5.0 come from GGA's cache. If GGA rejects the commit, fix the reported violation and retry).*

### 5.4. Push and open the Pull Request

Push the branch and create the GitHub Pull Request with the ODD task document as the body and the reviewer from 5.1:

```bash
BRANCH="$(git branch --show-current)"
git push -u origin "$BRANCH"
gh pr create --title "<type>(<scope>): <short description>" --body-file "odd/tasks/<NN>-<slug>.md" --reviewer "<login>"
```

### 5.5. Report

Return the Pull Request URL to the user and offer to run `gh run watch` if they want to monitor the CI workflows live.

## 6. After merge (with confirmation)

The author merges once the reviewer approves and CI is green. Ask for confirmation, then:

```bash
gh pr merge "<n>" --squash --delete-branch      # or --merge, per repo convention
git switch main && git pull --ff-only && git fetch --prune
git branch -d "feat/<NN>-<slug>"
```

`--delete-branch` removes the remote branch and, when it can, the local one; the last line cleans up the local branch otherwise. After a squash merge Git does not see the branch as merged, so `git branch -d` refuses: use `git branch -D` only after `gh pr view "<n>" --json state` reports `MERGED`.
