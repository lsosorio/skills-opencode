# Skills para OpenCode + DeepSeek (Python e IA con `uv`)

Colección de skills e instrucciones globales para **OpenCode** con **DeepSeek**, orientados al desarrollo de proyectos de **Python e Inteligencia Artificial** usando exclusivamente **`uv`**, buenas prácticas de ingeniería de software, **ODD (`odd/tasks`)**, **Engram** y **GGA**.

## Estructura

- `AGENTS.md`: Instrucciones globales de idioma, criterio, eficiencia, escritura y flujo de trabajo para `~/.config/opencode/AGENTS.md`.
- `skills/iniciar-repo-ia/SKILL.md`: Inicializa repositorios privados y workspaces en Python con `uv` (sin `pip` ni Jupyter Notebooks), configurado con `ruff`, `pytest`, `AGENTS.md`, Engram compartido en equipo, `odd/tasks/_plantilla.md`, GGA (DeepSeek) y GitHub Actions CI.
- `skills/nueva-tarea-odd/SKILL.md`: Especifica un nuevo requerimiento bajo ODD en `odd/tasks/<NN>-<slug>.md`, crea su rama `feat/<NN>-<slug>`, pide confirmación antes de programar e implementa tarea por tarea con `ruff` y `pytest`.
- `skills/cerrar-tarea-pr/SKILL.md`: Audita calidad (`ruff` + `pytest` + cero `.ipynb`/secretos), cierra el documento en `odd/tasks/`, exporta la memoria del equipo con `engram sync`, hace el commit validado por GGA y abre el Pull Request en GitHub.

## Instalación

Al usar `-a opencode`, el CLI de `skills.sh` instala los skills únicamente en `~/.config/opencode/skills/`, sin tocar `~/.claude/skills/`.

### 1. Instalar todos los skills con `npx skills`

```bash
npx skills add lsosorio/skills-opencode -a opencode -g
```

O instalar uno específico:

```bash
npx skills add lsosorio/skills-opencode --skill iniciar-repo-ia -a opencode -g
npx skills add lsosorio/skills-opencode --skill nueva-tarea-odd -a opencode -g
npx skills add lsosorio/skills-opencode --skill cerrar-tarea-pr -a opencode -g
```

### 2. Instalar las instrucciones globales (`AGENTS.md`)

```bash
mkdir -p ~/.config/opencode
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

## Flujo de uso en OpenCode

Después de instalar, reinicia `opencode` y solicita el skill correspondiente en el chat:

1. **Crear o configurar el proyecto (`iniciar-repo-ia`):**
   > *"Usa `iniciar-repo-ia` para iniciar el repositorio del proyecto."*
   *(Si eres un integrante del equipo que acaba de clonar el repositorio, corre `./scripts/setup.sh`).*

2. **Especificar e implementar un requerimiento (`nueva-tarea-odd`):**
   > *"Usa `nueva-tarea-odd` para implementar el módulo de procesamiento y evaluación."*

3. **Cerrar la tarea y abrir el Pull Request (`cerrar-tarea-pr`):**
   > *"Usa `cerrar-tarea-pr` para validar cambios, sincronizar Engram y abrir el PR."*
