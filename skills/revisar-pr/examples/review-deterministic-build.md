# Example: review a pull request that promises a deterministic build

Pull request #12 of the fictitious `acme-corpus-lab/corpus-acme`, opened by `acme-maintainer`, closes task `11-deterministic-catalog`. Its criterion 2 says: "two runs of `uv run acme build` produce byte-identical files in `data/gold/`". The reviewer is `acme-reviewer`. GGA prefixes its log lines with emoji markers; they are left out below.

## 1. Inputs (step 1)

```text
$ gh pr view 12 --json title,body,headRefName,author,files --jq '{title, branch: .headRefName, author: .author.login, files: [.files[].path]}'
{"author":"acme-maintainer","branch":"feat/11-deterministic-catalog","files":["CHANGELOG.md","odd/tasks/11-deterministic-catalog.md","src/corpus_acme/catalog.py","tests/test_catalog.py"],"title":"feat(gold): build the corpus catalog deterministically"}
$ gh api user --jq .login
acme-reviewer
```

The author is not the current user, so the review goes on.

## 2. Checkout without touching `main` (step 2)

```text
$ git status --short
$ git fetch origin
$ gh pr checkout 12
Switched to a new branch 'feat/11-deterministic-catalog'
$ uv sync --locked
Resolved 31 packages in 3ms
Audited 29 packages in 0.09ms
$ engram sync --import
Imported 1 new chunk(s) from .engram/
```

## 3. Read before judging (step 3)

The agent read the task (objective, the four criteria and the Log), `CONSTITUTION.md` and `AGENTS.md`, then the scope:

```text
$ git diff origin/main...HEAD --stat
 CHANGELOG.md                          |  2 +
 odd/tasks/11-deterministic-catalog.md | 58 ++++++++++++++++
 src/corpus_acme/catalog.py            | 41 ++++++++---
 tests/test_catalog.py                 | 36 ++++++++++
 4 files changed, 131 insertions(+), 6 deletions(-)
```

## 4. Automated checks (step 4)

```text
$ uv run ruff format --check .
19 files already formatted
$ uv run ruff check .
All checks passed!
$ uv run pytest
47 passed in 1.42s
$ gga run --pr-mode --diff-only
Mode: PR (diff-only review)
Files to review:
  - CHANGELOG.md
  - odd/tasks/11-deterministic-catalog.md
  - src/corpus_acme/catalog.py
  - tests/test_catalog.py

STATUS: PASSED

CODE REVIEW PASSED
$ uv run acme validate
ok: 312 documents, 0 errors
```

Every check is green. The determinism claim still needs the manual step.

## 5. Manual checklist (step 5)

Two builds on the same checkout matched, because the directory order did not change between them. The agent rebuilt from a copy of `data/silver/` written in reverse order, which changes the order the filesystem returns:

```text
$ CHECK_DIR="$(mktemp -d)"
$ uv run acme build && find data/gold -type f -exec sha256sum {} + | sort -k2 > "$CHECK_DIR/first.txt"
$ mkdir "$CHECK_DIR/silver" && for f in $(ls -r data/silver/*.json); do cp "$f" "$CHECK_DIR/silver/"; done
$ uv run acme build --silver-dir "$CHECK_DIR/silver" && find data/gold -type f -exec sha256sum {} + | sort -k2 > "$CHECK_DIR/second.txt"
$ diff "$CHECK_DIR/first.txt" "$CHECK_DIR/second.txt" && echo "ok: deterministic"
2c2
< aae53ec280b1dc28370da73f4b3d2ad396bfa84d8be10dc26a4c77c1a0439c99  data/gold/catalog.sha256
---
> 4a409b01301383d75c49a3cbb058b3aa765e7a594eba8450607cf2c24e099014  data/gold/catalog.sha256
```

The cause is in the hunk that builds the hash:

```diff
+    digest = hashlib.sha256()
+    for document_path in silver_dir.glob("*.json"):
+        digest.update(document_path.read_bytes())
```

`Path.glob` yields files in directory order, so the digest depends on how `data/silver/` was written. The rest of the checklist passed: type hints present, no `print()`, paths in `layout.py`, the figure (312 documents) in `CHANGELOG.md` and not in `AGENTS.md`, no data or secrets in the diff. One comment in the new test says what the code does instead of why.

## 6. Findings and review body (step 6)

The agent wrote the body to `REVIEW_FILE="$(mktemp)"`, outside the repository:

```markdown
## Review of #12: feat(gold): build the corpus catalog deterministically

Checks: `ruff format --check` pass · `ruff check` pass · `pytest` 47 passed in 1.42s · `gga run --pr-mode --diff-only` STATUS: PASSED

### Blockers
- blocker · src/corpus_acme/catalog.py:27 · Task 11, criterion 2 (byte-identical outputs) · `silver_dir.glob("*.json")` follows directory order, so `data/gold/catalog.sha256` changes when `data/silver/` is copied or restored in another order. Reproduce: build from a copy written with `ls -r` and compare the hashes. Fix: iterate over `sorted(silver_dir.glob("*.json"))` and add a test that builds from two directories filled in opposite orders.

### Should
- None

### Nits
- nit · tests/test_catalog.py:31 · PEP 8 checklist, Comments · `# loop over the files` repeats the code; explain why the order matters or remove it.
```

## 7. Deliver (step 7, with confirmation)

The user confirmed the request for changes:

```text
$ gh pr review 12 --request-changes --body-file "$REVIEW_FILE"
✓ Requested changes to pull request acme-corpus-lab/corpus-acme#12
```

The author pushed `sorted(...)`, the two-directory test and the comment fix. On the second round the reverse-order rebuild printed `ok: deterministic`, and the agent approved:

```text
$ gh pr review 12 --approve --body-file "$REVIEW_FILE"
✓ Approved pull request acme-corpus-lab/corpus-acme#12
```

## 8. Never merge (step 8)

```text
$ git switch main
$ git branch -D "feat/11-deterministic-catalog"
Deleted branch feat/11-deterministic-catalog (was 9a1c4e7).
```

The merge stays with `acme-maintainer`, who runs `cerrar-tarea-pr` §6 with confirmation.
