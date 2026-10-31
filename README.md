# OpenCode + DeepSeek Skills (Python & AI with `uv`)

Collection of skills and global instructions for **OpenCode** powered by **DeepSeek**, tailored for **Python and Artificial Intelligence** projects using **`uv`**, pragmatic software engineering best practices, **ODD (`odd/tasks`)**, **Engram**, and **GGA**.

## Repository structure

- `AGENTS.md`: Global instructions covering language, judgment, efficiency, writing style, and Python/AI workflow for `~/.config/opencode/AGENTS.md`.
- `skills/iniciar-repo-ia/SKILL.md`: Bootstraps public or private repositories and workspaces in Python with `uv` (no `pip`, no Jupyter Notebooks), with an MIT license and a README template, preconfigured with `ruff`, `pytest`, `CONSTITUTION.md`, `AGENTS.md`, shared team memory via Engram, `odd/tasks/_template.md`, GGA (DeepSeek), and GitHub Actions CI.
- `skills/nueva-tarea-odd/SKILL.md`: Specifies a new requirement under ODD in `odd/tasks/<NN>-<slug>.md`, creates its `feat/<NN>-<slug>` branch, requests confirmation before coding, and implements task by task with `ruff` and `pytest`.
- `skills/cerrar-tarea-pr/SKILL.md`: Audits code quality (`ruff` + `pytest` + zero `.ipynb`/secrets), completes the document in `odd/tasks/`, exports team memory with `engram sync`, creates a GGA-validated commit, opens a GitHub Pull Request with a reviewer, and cleans up the branch after the merge.
- `commands/`: one OpenCode slash command per skill, so each skill also appears in the `/` menu.

## Installation

Tested with: OpenCode 2.1.2 (workshop runs) and 2.2.5 (skills and commands load), GGA 2.10.1, Engram 3.5.4, uv 0.13.1.

### 1. Install the skills with `npx skills`

```bash
npx skills add lsosorio/skills-opencode -a opencode -g
```

Or install a single skill:

```bash
npx skills add lsosorio/skills-opencode --skill iniciar-repo-ia -a opencode -g
npx skills add lsosorio/skills-opencode --skill nueva-tarea-odd -a opencode -g
npx skills add lsosorio/skills-opencode --skill cerrar-tarea-pr -a opencode -g
```

`npx skills` keeps its copy in `~/.agents/skills/` (registered in `~/.agents/.skill-lock.json`), not in `~/.config/opencode/skills/`, and links that copy into the directory of each agent selected with `-a` that needs one (Claude Code: `~/.claude/skills/<name>`). OpenCode reads `~/.agents/skills/` directly. Check with `ls -l ~/.agents/skills/`.

### 2. Or link a local clone

A clone keeps a single copy that `git pull` updates. From the root of the clone:

```bash
mkdir -p ~/.config/opencode/skills
for skill in skills/*/; do
  name=$(basename "$skill")
  ln -sfn "$PWD/skills/$name" ~/.config/opencode/skills/"$name"
done
ls -l ~/.config/opencode/skills/
```

Use one method per skill: remove an `npx` copy with `npx skills remove -g <name>` before linking the clone. With two copies under the same name OpenCode loads only one, and it may not be the clone.

### 3. Install global instructions (`AGENTS.md`)

```bash
mkdir -p ~/.config/opencode
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

With a clone, `ln -sfn "$PWD/AGENTS.md" ~/.config/opencode/AGENTS.md` keeps it in sync.

### Windows

OpenCode reads its configuration from `~/.config/opencode`, which on Windows is `C:\Users\<user>\.config\opencode`. Run the commands of this README from Git Bash. `npx skills add ... -a opencode -g` works the same way; for a manual install copy the folders instead of linking them, because `ln -s` in Git Bash copies by default and `New-Item -ItemType SymbolicLink` needs Developer Mode or an elevated shell:

```bash
mkdir -p ~/.config/opencode/skills ~/.config/opencode/command
cp -r skills/* ~/.config/opencode/skills/
cp commands/*.md ~/.config/opencode/command/
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

Repeat the copy after every `git pull` of this repository.

## Slash commands

Each file in `commands/` is a slash command that loads its skill. OpenCode reads global commands from `~/.config/opencode/command/` (it also accepts `commands/`; keep a single directory so every command loads once). From the root of this repository:

```bash
mkdir -p ~/.config/opencode/command
cp commands/*.md ~/.config/opencode/command/
```

With a local clone, link them instead so `git pull` updates them:

```bash
for command in commands/*.md; do
  ln -sfn "$PWD/$command" ~/.config/opencode/command/"$(basename "$command")"
done
```

| Command | What it does |
|---|---|
| `/iniciar-repo-ia` | Bootstraps the repository in the current directory |
| `/nueva-tarea-odd <requirement>` | Specifies the requirement under ODD and waits for approval before coding |
| `/cerrar-tarea-pr` | Verifies the branch, completes the ODD task and opens the pull request |

Restart `opencode` after adding or changing a command.

## Usage workflow in OpenCode

After installing, restart `opencode` and invoke the desired skill in chat:

1. **Create or bootstrap a project (`iniciar-repo-ia`):**
   > *"Use `iniciar-repo-ia` to initialize the repository."*
   *(Teammates cloning an existing repository only need to run `./scripts/setup.sh`).*

2. **Specify and implement a requirement (`nueva-tarea-odd`):**
   > *"Use `nueva-tarea-odd` to implement the semantic similarity module."*

3. **Close the task and open a Pull Request (`cerrar-tarea-pr`):**
   > *"Use `cerrar-tarea-pr` to validate changes, sync Engram, and open the PR."*
