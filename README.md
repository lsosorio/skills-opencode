# Skills para OpenCode + DeepSeek (IA y Modelos de Lenguaje)

Colección de skills e instrucciones globales para **OpenCode** con **DeepSeek**, enfocados en proyectos de **Técnicas Avanzadas de IA para Modelos de Lenguaje** en Python usando exclusivamente **`uv`**.

## Estructura

- `AGENTS.md`: Instrucciones globales de idioma, criterio, eficiencia y escritura para `~/.config/opencode/AGENTS.md`.
- `skills/*/SKILL.md`: Definición completa de cada skill (`iniciar-repo-ia`, `nueva-tarea-odd`, `cerrar-tarea-pr`).
- `commands/*.md`: Atajos de barra (`/iniciar-repo-ia`, `/nueva-tarea-odd`, `/cerrar-tarea-pr`) para que aparezcan en el menú autocompletable `/` de la consola de OpenCode.
- `install.sh`: Instalador directo que enlaza `AGENTS.md`, `skills/` y `commands/` en `~/.config/opencode/`.

## Instalación sin conflictos con Claude Code

En OpenCode los **skills** (`~/.config/opencode/skills/`) se invocan por lenguaje natural, mientras que los **comandos con `/`** del menú interactivo se leen desde `~/.config/opencode/commands/`.

### Opción A: Instalar todo (Skills + Slash Commands `/` + `AGENTS.md`)

Desde una copia local del repositorio:

```bash
chmod +x ./skills-opencode/install.sh
./skills-opencode/install.sh
```

### Opción B: Instalar solo los skills con `npx skills`

```bash
npx skills add lsosorio/skills-opencode -a opencode -g
```

## Flujo de uso en OpenCode

1. **Crear o configurar el proyecto (`iniciar-repo-ia`):**
   > *"Inicia el repo para el taller 1 con `iniciar-repo-ia`."*
   *(Si eres un compañero que acaba de clonar el repositorio, corre `./scripts/setup.sh`).*

2. **Empezar un punto o requerimiento (`nueva-tarea-odd`):**
   > *"Usa `nueva-tarea-odd` para implementar el comparador de embeddings coseno."*

3. **Entregar la tarea al equipo (`cerrar-tarea-pr`):**
   > *"Usa `cerrar-tarea-pr` para cerrar la tarea y abrir el PR."*
