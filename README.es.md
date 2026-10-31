[English](README.md) · [Español](README.es.md)

# Skills de OpenCode + DeepSeek (Python e IA con `uv`)

Mantén `README.es.md` sincronizado: todo cambio en `README.md` actualiza esta versión en español en el mismo commit.

Colección de skills e instrucciones globales para **OpenCode** con **DeepSeek**, pensada para proyectos de **Python e Inteligencia Artificial** con **`uv`**, buenas prácticas pragmáticas de ingeniería de software, **ODD (`odd/tasks`)**, **Engram** y **GGA**.

## Estructura del repositorio

- `AGENTS.md`: instrucciones globales de idioma, criterio, eficiencia, estilo de redacción y flujo de trabajo Python/IA para `~/.config/opencode/AGENTS.md`.
- `skills/iniciar-repo-ia/SKILL.md`: arranca repositorios y workspaces públicos o privados en Python con `uv` (sin `pip` ni Jupyter Notebooks), con licencia MIT y plantilla de README, y los deja configurados con `ruff`, `pytest`, `CONSTITUTION.md`, `AGENTS.md`, memoria de equipo compartida con Engram, `odd/tasks/_template.md`, GGA (DeepSeek) y CI en GitHub Actions.
- `skills/nueva-tarea-odd/SKILL.md`: especifica un requisito nuevo bajo ODD en `odd/tasks/<NN>-<slug>.md`, crea su rama `feat/<NN>-<slug>`, pide confirmación antes de programar e implementa tarea por tarea con `ruff` y `pytest`.
- `skills/cerrar-tarea-pr/SKILL.md`: audita la calidad del código (`ruff` + `pytest` + cero `.ipynb` y secretos), completa el documento en `odd/tasks/`, exporta la memoria del equipo con `engram sync`, crea un commit validado por GGA, abre un Pull Request en GitHub con revisor y limpia la rama después del merge.
- `skills/revisar-pr/SKILL.md`: revisa el pull request de un compañero contra `CONSTITUTION.md` y `AGENTS.md` con `ruff`, `pytest` y GGA, y envía una sola revisión en GitHub cuyos hallazgos indican archivo, línea, regla y severidad. Nunca hace merge.
- `commands/`: un comando `/` de OpenCode por skill, para que cada skill aparezca también en el menú `/`.
- `scripts/validate_skills.sh` y `.github/workflows/validate.yml`: verificaciones del repositorio, descritas en [Validación](#validación).

## Instalación

Probado con: OpenCode 2.1.2 (corridas del taller) y 2.2.5 (carga de skills y comandos), GGA 2.10.1, Engram 3.5.4, uv 0.13.1.

### 1. Instala las skills con `npx skills`

```bash
npx skills add lsosorio/skills-opencode -a opencode -g
```

O instala una sola skill:

```bash
npx skills add lsosorio/skills-opencode --skill iniciar-repo-ia -a opencode -g
npx skills add lsosorio/skills-opencode --skill nueva-tarea-odd -a opencode -g
npx skills add lsosorio/skills-opencode --skill cerrar-tarea-pr -a opencode -g
npx skills add lsosorio/skills-opencode --skill revisar-pr -a opencode -g
```

`npx skills` guarda su copia en `~/.agents/skills/` (registrada en `~/.agents/.skill-lock.json`), no en `~/.config/opencode/skills/`, y enlaza esa copia en el directorio de cada agente elegido con `-a` que lo necesite (Claude Code: `~/.claude/skills/<name>`). OpenCode lee `~/.agents/skills/` directamente. Compruébalo con `ls -l ~/.agents/skills/`.

### 2. O enlaza un clon local

Un clon mantiene una sola copia que `git pull` actualiza. Desde la raíz del clon:

```bash
mkdir -p ~/.config/opencode/skills
for skill in skills/*/; do
  name=$(basename "$skill")
  ln -sfn "$PWD/skills/$name" ~/.config/opencode/skills/"$name"
done
ls -l ~/.config/opencode/skills/
```

Usa un solo método por skill: borra la copia de `npx` con `npx skills remove -g <name>` antes de enlazar el clon. Con dos copias del mismo nombre OpenCode carga solo una, y puede no ser la del clon.

### 3. Instala las instrucciones globales (`AGENTS.md`)

```bash
mkdir -p ~/.config/opencode
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

Con un clon, `ln -sfn "$PWD/AGENTS.md" ~/.config/opencode/AGENTS.md` lo mantiene sincronizado.

### Windows

OpenCode lee su configuración de `~/.config/opencode`, que en Windows es `C:\Users\<user>\.config\opencode`. Ejecuta los comandos de este README desde Git Bash. `npx skills add ... -a opencode -g` funciona igual; para una instalación manual copia las carpetas en lugar de enlazarlas, porque `ln -s` en Git Bash copia por defecto y `New-Item -ItemType SymbolicLink` necesita el modo de desarrollador o una terminal con permisos de administrador:

```bash
mkdir -p ~/.config/opencode/skills ~/.config/opencode/command
cp -r skills/* ~/.config/opencode/skills/
cp commands/*.md ~/.config/opencode/command/
cp AGENTS.md ~/.config/opencode/AGENTS.md
```

Repite la copia después de cada `git pull` de este repositorio.

## Comandos `/`

Cada archivo de `commands/` es un comando `/` (slash command) que carga su skill. OpenCode lee los comandos globales de `~/.config/opencode/command/` (también acepta `commands/`; deja un solo directorio para que cada comando cargue una sola vez). Desde la raíz de este repositorio:

```bash
mkdir -p ~/.config/opencode/command
cp commands/*.md ~/.config/opencode/command/
```

Con un clon local, enlázalos en vez de copiarlos para que `git pull` los actualice:

```bash
for command in commands/*.md; do
  ln -sfn "$PWD/$command" ~/.config/opencode/command/"$(basename "$command")"
done
```

| Comando | Qué hace |
|---|---|
| `/iniciar-repo-ia` | Arranca el repositorio en el directorio actual |
| `/nueva-tarea-odd <requisito>` | Especifica el requisito bajo ODD y espera aprobación antes de programar |
| `/cerrar-tarea-pr` | Verifica la rama, completa la tarea ODD y abre el pull request |
| `/revisar-pr <número>` | Revisa el pull request de un compañero y envía los hallazgos |

Reinicia `opencode` después de agregar o cambiar un comando.

## Claude Code

Claude Code lee las skills de `~/.claude/skills/<name>/SKILL.md`, el mismo formato, así que un solo clon sirve a las dos herramientas y las dos copias nunca se separan. Desde la raíz del clon:

```bash
mkdir -p ~/.claude/skills
for skill in skills/*/; do
  name=$(basename "$skill")
  ln -sfn "$PWD/skills/$name" ~/.claude/skills/"$name"
done
ls -l ~/.claude/skills/
```

En Windows, copia las carpetas en lugar de enlazarlas (`cp -r skills/* ~/.claude/skills/`) y repite la copia después de cada `git pull`, igual que en las instrucciones de OpenCode.

- Las instrucciones globales de `AGENTS.md` se instalan para OpenCode (`~/.config/opencode/AGENTS.md`). Claude Code no lee ese archivo; sus instrucciones globales viven en `~/.claude/CLAUDE.md`.
- La skill `iniciar-repo` del plugin `lmbros` de Claude Code se solapa con `iniciar-repo-ia`. Deja solo una de las dos para que no diverjan; enlazar estas skills no borra ni cambia el plugin.

## Flujo de uso en OpenCode

Después de instalar, reinicia `opencode` e invoca en el chat la skill que necesites:

1. **Crear o arrancar un proyecto (`iniciar-repo-ia`):**
   > *"Usa `iniciar-repo-ia` para inicializar el repositorio."*
   *(Quien clona un repositorio existente solo necesita ejecutar `./scripts/setup.sh`).*

2. **Especificar e implementar un requisito (`nueva-tarea-odd`):**
   > *"Usa `nueva-tarea-odd` para implementar el módulo de similitud semántica."*

3. **Cerrar la tarea y abrir un Pull Request (`cerrar-tarea-pr`):**
   > *"Usa `cerrar-tarea-pr` para validar los cambios, sincronizar Engram y abrir el PR."*

4. **Revisar el Pull Request de un compañero (`revisar-pr`):**
   > *"Usa `revisar-pr` en el pull request 12."*

## Validación

[![validate](https://github.com/lsosorio/skills-opencode/actions/workflows/validate.yml/badge.svg)](https://github.com/lsosorio/skills-opencode/actions/workflows/validate.yml)

`scripts/validate_skills.sh` revisa el frontmatter de cada skill (nombre igual a su carpeta, descripción de 1024 caracteres como máximo), que exista cada archivo de `examples/` y `references/` que menciona un `SKILL.md`, que cada comando `/` tenga su skill, las regresiones conocidas (`ubuntu-latest` y tags flotantes de las actions) y que los dos README tengan las mismas secciones. El workflow `validate` lo corre en cada push a `main` y en cada pull request. Córrelo antes de cada commit:

```bash
bash scripts/validate_skills.sh    # OK: skills repository valid
```
