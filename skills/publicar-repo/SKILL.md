---
name: publicar-repo
description: "Publish a repository safely: audit secrets and data across the whole history, check license and README, change visibility with confirmation, protect main and add reviewers with triage permission"
---

# publicar-repo

Publishes a repository without leaking what its history holds: audits secrets, data and model weights across every commit, checks the license and the README, changes the visibility, protects `main` and adds reviewers with `triage` permission.

- **Read-only until confirmed:** steps 1 to 5 change nothing. Each of steps 6 to 9 (visibility, collaborators, branch protection, pull request template) needs the user's confirmation.
- **Stop on any hit:** a secret, a tracked dataset or unclear rights over third-party content stop the skill until the owner decides.
- **History is never rewritten** without explicit confirmation, and a leaked secret is rotated before anything else.

## 1. Inputs

Extract what the request already gives and ask for the rest in a single message:

- `<owner>/<repo>`; by default the current one: `gh repo view --json nameWithOwner --jq .nameWithOwner`.
- Target visibility: `public` or `private`.
- The reviewers' GitHub logins and their permission, `triage` by default.
- The expected license, `MIT` by default.

## 2. Preconditions

```bash
git status --short                                  # must be clean
gh run list --branch main --limit 1                 # the last CI run on main must be green
test -f LICENSE && grep -n '^license = ' pyproject.toml
grep -cE 'badge\.svg|img\.shields\.io' README.md     # badges
grep -nE '^## (License|Credits)' README.md
```

If something is missing, stop and offer to complete it with the `LICENSE` step (§3.4) and the README template (§4.3) of `iniciar-repo-ia` before publishing.

## 3. Secrets audit over the whole history

```bash
git log -p --all | grep -nE 'DEEPSEEK_API_KEY=[^ ]|HF_TOKEN=[^ ]|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}' || echo "ok: no secrets in history"
command -v gitleaks >/dev/null && gitleaks detect --source . --log-opts="--all" || echo "gitleaks not installed: history scanned with grep only"
```

Any hit stops the skill: rotate the secret first; rewriting history with `git filter-repo` only with explicit confirmation. A line that only holds this pattern (a copy of this skill, for example) is a false positive. When `gitleaks` is installed and finds a leak it exits non-zero, so the fallback message prints as well: read the report above it.

## 4. Data and weights audit

```bash
git ls-files | grep -E '^data/|\.env$|\.(bin|pt|pth|safetensors|gguf|onnx)$' || echo "ok: no data or weights tracked"
git log --all --diff-filter=A --name-only --format= | sort -u | grep -E '^data/|\.env$|\.(bin|pt|pth|safetensors|gguf|onnx)$' || echo "ok: no data or weights in history"
git count-objects -vH
```

The second command lists files added in any commit, because a dataset deleted later still lives in the history. The `data/raw/.gitkeep` and `data/processed/.gitkeep` placeholders are expected hits; anything else under `data/` stops the skill. `size-pack` is the size the repository will publish.

## 5. Rights check

`README.md` must state the rights over any third-party content the project captures or uses (scraped pages, sample files, test fixtures) and that it is not redistributed. If the repository contains such content, stop until the owner confirms in writing (in the ODD task Log or in an issue) that it may be published.

## 6. Visibility (with confirmation)

Before confirming, tell the user the effects: the whole history becomes visible, forks become possible, Actions minutes on standard runners stop counting against the plan, and branch protection becomes available on free plans. Then:

```bash
gh repo edit <owner>/<repo> --visibility <public|private> --accept-visibility-change-consequences
gh repo view <owner>/<repo> --json visibility --jq .visibility
```

## 7. Collaborators (with confirmation)

One call per reviewer:

```bash
gh api -X PUT "repos/<owner>/<repo>/collaborators/<login>" -f permission=triage
gh api "repos/<owner>/<repo>/invitations" --jq '.[] | {login: .invitee.login, permission: .permissions}'
```

The invitation stays pending until the reviewer accepts it. `triage` is enough to be requested as reviewer and to submit reviews; never grant `push` or more just to review. GitHub counts toward a required approval only the reviews of people with write permission, so a `triage` approval shows on the pull request without satisfying step 8: the owner merges with the admin bypass that `enforce_admins: false` keeps, or grants `push` to the one reviewer whose approval must count.

## 8. Protect `main` (with confirmation)

`verify` is the job of `ci.yml` and `review` the job of `gga-review.yml` in repositories created with `iniciar-repo-ia`; use the job names of the repository:

```bash
gh api -X PUT "repos/<owner>/<repo>/branches/main/protection" --input - <<'EOF'
{
  "required_status_checks": { "strict": true, "contexts": ["verify", "review"] },
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 1, "dismiss_stale_reviews": true },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
gh api "repos/<owner>/<repo>/branches/main/protection" --jq '.required_status_checks.contexts, .required_pull_request_reviews.required_approving_review_count'
```

A required job blocks the merge whenever it fails, even with `continue-on-error: true` at job level, so with `review` required a missing `DEEPSEEK_API_KEY` or a provider outage blocks every merge. If the team keeps GGA advisory, remove `review` from `contexts`. On a private repository, branch protection needs a paid GitHub plan.

## 9. Pull request template (with confirmation)

If `.github/PULL_REQUEST_TEMPLATE.md` is missing, create it as in `iniciar-repo-ia` §3.7 on a branch and open a pull request for it (`ci: add pull request template`): with `main` protected, only admins can push to it directly.

## 10. Close

- Append a dated decision under `## Architectural decisions` in `AGENTS.md` (visibility, license, protection rules, with the rationale) and put the figures (repository size, number of collaborators) in `CHANGELOG.md`. `main` is protected now, so commit both on a branch and open a pull request with `cerrar-tarea-pr`.
- Print the final state:

  ```bash
  gh repo view <owner>/<repo> --json visibility,licenseInfo
  ```

## Example

See `examples/publish-corpus-acme.md` for a complete walkthrough.
