# Skills para OpenCode + DeepSeek (IA y Modelos de Lenguaje)

Colección de skills e instrucciones globales para **OpenCode** con **DeepSeek**, enfocados en proyectos de **Técnicas Avanzadas de IA para Modelos de Lenguaje** en Python usando exclusivamente **`uv`**.

## Estructura

- `AGENTS.md`: Instrucciones globales de idioma, criterio, eficiencia y escritura para `~/.config/opencode/AGENTS.md`.
- `skills/iniciar-repo-ia/SKILL.md`: Inicializador de repositorios privados y workspaces de IA en Python con `uv` (sin `pip` ni Jupyter Notebooks), configurado con `ruff`, `pytest`, `AGENTS.md`, Engram compartido en equipo, `odd/tasks/_plantilla.md`, GGA (DeepSeek) y GitHub Actions CI.
- `skills/nueva-tarea-odd/SKILL.md`: Especifica un nuevo requerimiento bajo ODD en `odd/tasks/<NN>-<slug>.md`, crea su rama `feat/<NN>-<slug>`, pide confirmación antes de programar e implementa tarea por tarea con `ruff` y `pytest`.
- `skills/cerrar-tarea-pr/SKILL.md`: Audita calidad (`ruff` + `pytest` + cero `.ipynb`/secretos), cierra el documento en `odd/tasks/`, exporta la memoria del equipo con `engram sync`, hace el commit validado por GGA y abre el Pull Request en GitHub.

## Instalación sin conflictos con Claude Code

Al usar `-a opencode`, el CLI de `skills.sh` instala los skills únicamente en `~/.config/opencode/skills/`, sin tocar `~/.claude/skills/`.

### 1. Instalar todos los skills con `npx skills`

Globalmente para OpenCode:

```bash
npx skills add lsosorio/skills-opencode -a opencode -g
```

O instalar uno específico:

```bash
npx skills add lsosorio/skills-opencode --skill iniciar-repo-ia -a opencode -g
npx skills add lsosorio/skills-opencode --skill nueva-tarea-odd -a opencode -g
npx skills add lsosorio/skills-opencode --skill cerrar-tarea-pr -a opencode -g
```

Desde una copia local del repositorio:

```bash
npx skills add ./skills-opencode -a opencode -g
```

### 2. Instalar las instrucciones globales (`AGENTS.md`)

```bash
mkdir -p ~/.config/opencode
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

## Flujo de uso en OpenCode

1. **Crear o configurar el proyecto (`iniciar-repo-ia`):**
   > *"Inicia el repo para el taller 1 con `iniciar-repo-ia`."*
   *(Si eres un compañero que acaba de clonar el repositorio, corre `./scripts/setup.sh`).*

2. **Empezar un punto o requerimiento (`nueva-tarea-odd`):**
   > *"Usa `nueva-tarea-odd` para implementar el comparador de embeddings coseno."*

3. **Entregar la tarea al equipo (`cerrar-tarea-pr`):**
   > *"Usa `cerrar-tarea-pr` para cerrar la tarea y abrir el PR."*
