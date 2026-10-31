# Example: close task 09 and open its pull request

Continues the `nueva-tarea-odd` example `windows-makefile-task.md`: branch `feat/09-windows-makefile` of the fictitious `acme-corpus-lab/corpus-acme` has the Makefile change, the README section and `odd/tasks/09-windows-makefile.md` with evidence, nothing committed yet. The reviewer is `acme-reviewer`. GGA prefixes its log lines with emoji markers; they are left out below.

## 1. Branch status and active task (step 1)

```text
$ git branch --show-current
feat/09-windows-makefile
$ git status --short
 M Makefile
 M README.md
?? odd/tasks/09-windows-makefile.md
```

## 2. Constraint audit and quality checks (step 2)

```text
$ find . -name "*.ipynb" -not -path "./.venv/*"
$ [ -f requirements.txt ] && echo "ERROR: requirements.txt exists" || echo "ok: no requirements.txt"
ok: no requirements.txt
$ git status --porcelain | grep -E '\.(env|gguf|safetensors|bin|pt|pth|onnx)$' || echo "ok: no secrets or model weights staged"
ok: no secrets or model weights staged
$ uv run ruff format .
17 files left unchanged
$ uv run ruff check .
All checks passed!
$ uv run pytest -v
...
tests/test_settings.py::test_env_file_is_optional PASSED                 [100%]

============================== 42 passed in 1.29s ==============================
```

## 3. ODD document and decisions (step 3)

`odd/tasks/09-windows-makefile.md` gets `Status: completed`, every criterion and task in `[x]`, and the outputs above in `## 5. Verification evidence`. The task fixed a rule for the whole project, so `AGENTS.md` gains one dated line under `## Architectural decisions`, with no figures:

```markdown
- 2026-10-29: On Windows the Makefile runs recipes with the Git for Windows bash and passes `--env-file` only when the file exists; WSL is not a supported shell.
```

## 4. Team memory (step 4)

The agent saved the summary with `mem_save` and exported it:

```text
$ engram sync
Exporting memories for project "corpus-acme"...
Created chunk 7c41e2a9: 3 obs, 1 sessions, 0 prompts
$ git status --short .engram/
 M .engram/manifest.json
?? .engram/chunks/7c41e2a9.jsonl.gz
```

## 5. GGA, commit, push and pull request (step 5)

5.0, before showing the plan:

```text
$ git add -A
$ gga run
  Gentleman Guardian Angel v2.10.1
  Provider-agnostic code review using AI

Provider: opencode:deepseek/deepseek-flash
Rules file: AGENTS.md
File patterns: *.py,*.go,*.ts,*.tsx,*.js,*.jsx,Makefile,*.md,*.toml,*.yml,*.yaml,*.sh,Dockerfile,.env.example
Cache: enabled

Files to review:
  - AGENTS.md
  - Makefile
  - README.md
  - odd/tasks/09-windows-makefile.md

Sending to opencode:deepseek/deepseek-flash for review (timeout: 300s)...

STATUS: PASSED
The Makefile keeps the POSIX branch unchanged and the task documents its evidence.

CODE REVIEW PASSED
```

5.1 and 5.2: the agent showed the status, the message `feat(make): support Windows with Git Bash and optional .env`, the pull request title and summary, and asked who reviews. The user answered `acme-reviewer` and confirmed.

5.3 and 5.4:

```text
$ git add -A && git status --short
M  .engram/manifest.json
A  .engram/chunks/7c41e2a9.jsonl.gz
M  AGENTS.md
M  Makefile
M  README.md
A  odd/tasks/09-windows-makefile.md
$ git commit -m "feat(make): support Windows with Git Bash and optional .env"
4 file(s) passed from cache
CODE REVIEW PASSED (cached)
[feat/09-windows-makefile 3c9d2e1] feat(make): support Windows with Git Bash and optional .env
 6 files changed, 94 insertions(+), 4 deletions(-)
$ BRANCH="$(git branch --show-current)"
$ BODY_FILE="$(mktemp)"
$ cat "odd/tasks/09-windows-makefile.md" .github/PULL_REQUEST_TEMPLATE.md > "$BODY_FILE"
$ git push -u origin "$BRANCH"
 * [new branch]      feat/09-windows-makefile -> feat/09-windows-makefile
$ gh pr create --title "feat(make): support Windows with Git Bash and optional .env" --body-file "$BODY_FILE" --reviewer "acme-reviewer"

Creating pull request for feat/09-windows-makefile into main in acme-corpus-lab/corpus-acme

https://github.com/acme-corpus-lab/corpus-acme/pull/9
```

5.5: the agent returned the URL and offered `gh run watch`.

## 6. After merge (step 6, with confirmation)

The reviewer approved with `revisar-pr`, CI and GGA were green, and the user confirmed the merge:

```text
$ gh pr merge "9" --squash --delete-branch
✓ Squashed and merged pull request acme-corpus-lab/corpus-acme#9 (feat(make): support Windows with Git Bash and optional .env)
✓ Deleted local branch feat/09-windows-makefile and switched to branch main
✓ Deleted remote branch feat/09-windows-makefile
$ git switch main && git pull --ff-only && git fetch --prune
Already on 'main'
Updating 5b8a0f4..e41c7d2
Fast-forward
$ git branch -d "feat/09-windows-makefile"
error: branch 'feat/09-windows-makefile' not found
```

The last error is expected: `--delete-branch` had already removed the local branch.

## 7. Final state

| Item | State |
|---|---|
| Task | `odd/tasks/09-windows-makefile.md`, `Status: completed`, evidence and Log |
| Pull request | #9 squashed into `main` after one approval |
| Branches | none left for task 09, local or remote |
| Memory | chunk `7c41e2a9` in `.engram/chunks/`; teammates import it on their next `git pull` |
