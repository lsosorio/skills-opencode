# Example: bootstrap `corpus-acme`

A team starts `corpus-acme`, a Python 3.12 pipeline that turns the public pages of a fictitious company (`https://www.acme.example/`) into a Markdown corpus for a RAG assignment. The assignment is graded, so the repository must be public with an MIT license. Every name, login and URL here is fictitious.

## 1. Inputs (step 1)

The request was "Use `iniciar-repo-ia` to start corpus-acme". The skill asked for the missing items in one message and got:

```text
Project name ............ Corpus Acme
What it is .............. Web scraping pipeline that turns the public pages of acme.example
                          into a Markdown corpus with front matter for a RAG assignment.
Type .................... standalone repo
Remote .................. does not exist: create it
Visibility .............. public (graded deliverable, MIT license)
```

Derived values: slug `corpus-acme`, package `corpus_acme`, owner `acme-corpus-lab` (the account in `gh auth status`).

## 2. Environment inventory (step 2)

```text
ok  git
ok  gh
ok  uv
ok  engram
ok  gga
ok  opencode
missing docker
ok  secret-tool
ok  gh authenticated
```

`docker` is missing; it does not block any step and goes to the final summary.

## 3. Commands in order

```bash
git init -b main
uv init --package --name "corpus-acme" --vcs none
uv add --dev ruff pytest
mkdir -p tests && touch tests/__init__.py
printf 'def test_smoke() -> None:\n    assert True\n' > tests/test_smoke.py
# 3.2 to 3.7: ruff and pytest settings, .gitignore, data/, .env.example, .gitattributes,
# LICENSE (gh api licenses/mit), CHANGELOG.md, Makefile, PULL_REQUEST_TEMPLATE.md
# 4: CONSTITUTION.md, AGENTS.md and README.md from the templates
engram init corpus-acme
./scripts/setup.sh
# 6 and 7: odd/tasks/_template.md and .gga, then the hook
gga install && gga config
# 9: resolve versions, then write ci.yml and gga-review.yml with them
uv run ruff format . && uv run ruff check . && uv run pytest
```

Version resolution printed `opencode=1.19.5 gga=v2.10.1 checkout=v7.0.1 setup-uv=v10.3.3`, so the workflows use `actions/checkout@v7.0.1`, `astral-sh/setup-uv@v10.3.3`, `opencode-ai@1.19.5`, GGA `v2.10.1` and `runs-on: ubuntu-24.04`.

## 4. Files created

```text
corpus-acme/
├── .engram/config.json
├── .env.example
├── .gga
├── .gitattributes
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/{ci.yml,gga-review.yml}
├── .gitignore  .dockerignore  .python-version
├── AGENTS.md  CONSTITUTION.md  README.md  CHANGELOG.md  LICENSE  Makefile
├── data/{raw,processed}/.gitkeep
├── odd/tasks/_template.md
├── pyproject.toml  uv.lock
├── scripts/setup.sh
├── src/corpus_acme/__init__.py
└── tests/{__init__.py,test_smoke.py}
```

## 5. Local verification (step 11)

```text
$ uv run ruff check .
All checks passed!
$ uv run ruff format --check .
4 files already formatted
$ uv run pytest
============================= test session starts ==============================
platform linux -- Python 3.12.14, pytest-9.2.0, pluggy-1.7.0
rootdir: /home/dev/corpus-acme
configfile: pyproject.toml
testpaths: tests
collected 1 item

tests/test_smoke.py .                                                    [100%]

============================== 1 passed in 0.01s ===============================
$ gga config
Values:
  PROVIDER:          opencode:deepseek/deepseek-flash
  FILE_PATTERNS:     *.py,*.go,*.ts,*.tsx,*.js,*.jsx,Makefile,*.md,*.toml,*.yml,*.yaml,*.sh,Dockerfile,.env.example
  RULES_FILE:        AGENTS.md
  STRICT_MODE:       true
$ cat .engram/config.json
{
  "project_name": "corpus-acme"
}
```

## 6. Initial commit and public push (step 10, with confirmation)

After the user confirmed the commit, the GGA hook reviewed the staged files and printed `STATUS: PASSED`. Because the visibility is public, the audit ran before the push:

```text
$ git ls-files | grep -E '(^|/)\.env$|\.(pem|key|p12)$' || echo "ok: no .env or keys tracked"
ok: no .env or keys tracked
$ git ls-files | grep -E '\.(ipynb|bin|pt|pth|safetensors|gguf|onnx)$' || echo "ok: no notebooks or weights tracked"
ok: no notebooks or weights tracked
$ git log -p --all | grep -nE 'DEEPSEEK_API_KEY=[^ ]|HF_TOKEN=[^ ]|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}' || echo "ok: no secrets in history"
ok: no secrets in history
$ gh repo create acme-corpus-lab/corpus-acme --public --source . --remote origin --push
✓ Created repository acme-corpus-lab/corpus-acme on GitHub
  https://github.com/acme-corpus-lab/corpus-acme
✓ Added remote https://github.com/acme-corpus-lab/corpus-acme.git
✓ Pushed commits to https://github.com/acme-corpus-lab/corpus-acme.git
$ secret-tool lookup service deepseek-ci | gh secret set DEEPSEEK_API_KEY
✓ Set Actions secret DEEPSEEK_API_KEY for acme-corpus-lab/corpus-acme
```

## 7. First push with CI green

```text
$ gh run list --limit 1
STATUS  TITLE                                                   WORKFLOW                 BRANCH  EVENT  ELAPSED
✓       chore: bootstrap repository with uv and baseline rules  CI (uv + ruff + pytest)  main    push   38s
$ gh repo view acme-corpus-lab/corpus-acme --json visibility,licenseInfo --jq '{visibility, license: .licenseInfo.name}'
{"license":"MIT License","visibility":"PUBLIC"}
```

The GGA workflow only runs on pull requests, so the first push shows the CI workflow alone.

## 8. Final state

| Item | State |
|---|---|
| Repository | `acme-corpus-lab/corpus-acme`, public, MIT, `main` pushed |
| CI | green on the first push with exact action tags and `ubuntu-24.04` |
| GGA | pre-commit hook installed; the PR workflow waits for the first pull request |
| Engram | project `corpus-acme`; the `post-merge` hook imports `.engram/chunks/` on every pull |
| Pending | `docker` not installed, needed only when the project adds a container |

Next step: the first requirement with `nueva-tarea-odd`.
