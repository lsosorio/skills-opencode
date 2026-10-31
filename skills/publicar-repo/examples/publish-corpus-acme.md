# Example: publish `corpus-acme`

The fictitious `acme-corpus-lab/corpus-acme` stayed private while the team checked what the corpus may show. Now the course needs it public, with two reviewers and a protected `main`. Every name, login and URL here is fictitious.

## 1. Inputs (step 1)

```text
Repository ........ acme-corpus-lab/corpus-acme
Visibility ........ public
Reviewers ......... acme-reviewer (triage), acme-teacher (triage)
License ........... MIT
```

## 2. Preconditions (step 2)

```text
$ git status --short
$ gh run list --branch main --limit 1
STATUS  TITLE                                                        WORKFLOW                 BRANCH  EVENT  ELAPSED
✓       feat(make): support Windows with Git Bash and optional .env  CI (uv + ruff + pytest)  main    push   41s
$ test -f LICENSE && grep -n '^license = ' pyproject.toml
6:license = "MIT"
$ grep -cE 'badge\.svg|img\.shields\.io' README.md
5
$ grep -nE '^## (License|Credits)' README.md
88:## License
92:## Credits
```

## 3. Secrets audit (step 3)

```text
$ git log -p --all | grep -nE 'DEEPSEEK_API_KEY=[^ ]|HF_TOKEN=[^ ]|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}' || echo "ok: no secrets in history"
ok: no secrets in history
$ command -v gitleaks >/dev/null && gitleaks detect --source . --log-opts="--all" || echo "gitleaks not installed: history scanned with grep only"
10:42AM INF 57 commits scanned.
10:42AM INF scan completed in 312ms
10:42AM INF no leaks found
```

## 4. Data and weights audit (step 4)

```text
$ git ls-files | grep -E '^data/|\.env$|\.(bin|pt|pth|safetensors|gguf|onnx)$' || echo "ok: no data or weights tracked"
data/processed/.gitkeep
data/raw/.gitkeep
$ git log --all --diff-filter=A --name-only --format= | sort -u | grep -E '^data/|\.env$|\.(bin|pt|pth|safetensors|gguf|onnx)$' || echo "ok: no data or weights in history"
data/processed/.gitkeep
data/raw/.gitkeep
$ git count-objects -vH | grep size-pack
size-pack: 1.18 MiB
```

Only the two expected placeholders appear, in the tree and in the history.

## 5. Rights check (step 5)

The License section of `README.md` says the pages of `acme.example` belong to their owner and that the corpus is neither versioned nor redistributed. `tests/fixtures/` holds three trimmed pages of that site, so the agent stopped. The owner confirmed in issue #13 that the trimmed fixtures may be published as test copies, with the rights note of the README, and the skill went on.

## 6. Visibility (step 6, with confirmation)

The agent listed the effects (whole history visible, forks possible, Actions minutes no longer counted, branch protection available) and the user confirmed:

```text
$ gh repo edit acme-corpus-lab/corpus-acme --visibility public --accept-visibility-change-consequences
✓ Edited repository acme-corpus-lab/corpus-acme
$ gh repo view acme-corpus-lab/corpus-acme --json visibility --jq .visibility
PUBLIC
```

## 7. Collaborators (step 7, with confirmation)

```text
$ gh api -X PUT "repos/acme-corpus-lab/corpus-acme/collaborators/acme-reviewer" -f permission=triage
$ gh api -X PUT "repos/acme-corpus-lab/corpus-acme/collaborators/acme-teacher" -f permission=triage
$ gh api "repos/acme-corpus-lab/corpus-acme/invitations" --jq '.[] | {login: .invitee.login, permission: .permissions}'
{"login":"acme-reviewer","permission":"triage"}
{"login":"acme-teacher","permission":"triage"}
```

Each `PUT` returned the invitation as JSON. The agent warned that a `triage` approval shows on the pull request but does not count toward the required approval, so the owner merges with the admin bypass that `enforce_admins: false` keeps.

## 8. Protect `main` (step 8, with confirmation)

The repository came from `iniciar-repo-ia`, so its jobs are `verify` and `review`. The team wants GGA as a gate and the `DEEPSEEK_API_KEY` secret is set, so both checks stay required:

```text
$ gh api -X PUT "repos/acme-corpus-lab/corpus-acme/branches/main/protection" --input - <<'EOF'
{
  "required_status_checks": { "strict": true, "contexts": ["verify", "review"] },
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 1, "dismiss_stale_reviews": true },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
$ gh api "repos/acme-corpus-lab/corpus-acme/branches/main/protection" --jq '.required_status_checks.contexts, .required_pull_request_reviews.required_approving_review_count'
[
  "verify",
  "review"
]
1
```

## 9. Pull request template (step 9)

`.github/PULL_REQUEST_TEMPLATE.md` already existed (created by `iniciar-repo-ia` §3.7), so nothing changed.

## 10. Close (step 10)

On branch `docs/record-publication`, through a pull request because `main` is protected now, `AGENTS.md` gained the decision and `CHANGELOG.md` the figures:

```markdown
- 2026-10-30: The repository is public under MIT; `main` requires one approval and the `verify` and `review` checks, and reviewers get `triage`. The captured corpus stays out of Git.
```

```markdown
- Published on 2026-10-30: pack of 1.18 MiB, 2 reviewers with `triage`.
```

```text
$ gh repo view acme-corpus-lab/corpus-acme --json visibility,licenseInfo
{
  "licenseInfo": {
    "key": "mit",
    "name": "MIT License",
    "nickname": ""
  },
  "visibility": "PUBLIC"
}
```

## Final state

| Item | State |
|---|---|
| Visibility | public, MIT License detected by GitHub |
| Audits | no secrets or data in the history; fixtures published with the owner's written consent |
| Reviewers | `acme-reviewer` and `acme-teacher`, `triage`, invitations pending acceptance |
| `main` | one approval, `verify` and `review` required, no force pushes or deletions |
