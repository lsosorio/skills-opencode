# Skills para OpenCode + DeepSeek (IA y Modelos de Lenguaje)

Colección de skills e instrucciones globales para **OpenCode** con **DeepSeek**, enfocados en proyectos de **Técnicas Avanzadas de IA para Modelos de Lenguaje** en Python usando exclusivamente **`uv`**.

## Estructura

- `AGENTS.md`: Instrucciones globales de idioma, criterio, eficiencia y escritura para `~/.config/opencode/AGENTS.md`.
- `skills/iniciar-repo-ia/SKILL.md`: Inicializador de repositorios y workspaces de IA en Python con `uv` (sin `pip` ni Jupyter Notebooks), configurado con `ruff`, `pytest`, `AGENTS.md`, Engram, `odd/tasks`, GGA (DeepSeek) y GitHub Actions CI.

## Instalación sin conflictos con Claude Code

Al usar `-a opencode`, el CLI de `skills.sh` instala los skills únicamente en `~/.config/opencode/skills/`, sin tocar `~/.claude/skills/`. Además, el nombre `iniciar-repo-ia` evita colisiones con otros skills globales de Claude Code.

### 1. Instalar el skill con `npx skills`

Globalmente para OpenCode:

```bash
npx skills add lsosorio/skills-opencode --skill iniciar-repo-ia -a opencode -g
```

Solo en el proyecto actual (`.opencode/skills/iniciar-repo-ia`):

```bash
npx skills add lsosorio/skills-opencode --skill iniciar-repo-ia -a opencode
```

Desde una copia local del repositorio:

```bash
npx skills add ./skills-opencode --skill iniciar-repo-ia -a opencode -g
```

### 2. Instalar las instrucciones globales (`AGENTS.md`)

```bash
mkdir -p ~/.config/opencode
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

## Uso en OpenCode

Dentro de la carpeta de un nuevo proyecto:

```bash
mkdir laboratorio-1 && cd laboratorio-1
opencode
```

En el chat de OpenCode solicita:

> Inicia el repo para el laboratorio 1 con `iniciar-repo-ia`.
