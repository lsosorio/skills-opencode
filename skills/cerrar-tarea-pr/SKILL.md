---
name: cerrar-tarea-pr
description: Cierra una tarea ODD en curso, verifica calidad con uv (ruff y pytest), actualiza odd/tasks/, guarda y sincroniza la memoria del equipo en Engram, hace el commit validado por GGA y abre el Pull Request en GitHub (cerrar tarea, terminar feature, subir cambios, crear PR).
---

# cerrar-tarea-pr

Cierra de forma limpia y reproducible una tarea desarrollada en una rama antes de compartirla con el resto del equipo: valida el código con `uv`, audita que no se suban archivos prohibidos, completa el documento en `odd/tasks/`, exporta la memoria del equipo a `.engram/chunks/` y crea el Pull Request.

- **Con confirmación:** hacer el commit final, el `git push` y crear el Pull Request (`gh pr create`) se preguntan en un solo paso después de pasar todas las verificaciones locales.

## 1. Estado de la rama y tarea activa

1. Identifica la rama actual, los archivos modificados y el documento ODD activo:

   ```bash
   git branch --show-current
   git status --short
   ls -1 odd/tasks/
   ```

2. **Si estás directamente en `main`:** avisa al usuario y propón crear una rama `feat/<NN>-<slug>` antes de hacer commit para que el cambio pase por Pull Request y revisión de CI.

## 2. Auditoría de restricciones y calidad con `uv`

Ejecuta todas las comprobaciones en orden. **Si cualquiera falla, detente y corrige el problema antes de continuar.**

### 2.1. Prohibición de Notebooks, `requirements.txt`, secretos y pesos

```bash
find . -name "*.ipynb" -not -path "./.venv/*"
[ -f requirements.txt ] && echo "ERROR: existe requirements.txt" || echo "ok: sin requirements.txt"
git status --porcelain | grep -E '\.(env|gguf|safetensors|bin|pt|pth|onnx)$' || echo "ok: sin secretos ni pesos"
```

- Si aparece algún `.ipynb` o `requirements.txt`, elimínalo o conviértelo a módulo en `src/` / dependencia en `pyproject.toml`.
- Si aparece `.env` o pesos de modelos en el estado de git, sácalos del stage y agrégalos a `.gitignore`.

### 2.2. Formato, Linter (`ruff`) y Pruebas (`pytest`)

```bash
uv run ruff format .
uv run ruff check .
uv run pytest -v
```

Ambos comandos (`ruff check` y `pytest`) deben terminar con código de salida `0`.

## 3. Cierre del documento en `odd/tasks/`

Revisa el archivo `odd/tasks/<NN>-<slug>.md` correspondiente a esta rama:

1. Cambia el encabezado a `Estado: completado`.
2. Verifica que todos los criterios de aceptación (`## 3`) y tareas (`## 4`) estén marcados con `- [x]`.
3. Actualiza `## 5. Evidencia de verificación` con el resumen real de `uv run ruff check .` y `uv run pytest -v`.
4. Si en la tarea se tomó una decisión de arquitectura o diseño relevante para todo el proyecto, agrégala en una línea con fecha en la sección `## Decisiones` de `AGENTS.md`.

## 4. Memoria compartida en Engram

Para que el resto del equipo reciba el contexto de lo construido cuando haga `git pull`:

1. Guarda en Engram una memoria resumida de la tarea completada (qué módulo se creó/modificó, decisiones técnicas tomadas y cómo se usa):
   - Si tienes la herramienta MCP `mem_save` activa, úsala; si no, ejecuta por CLI:

     ```bash
     engram save "<NN> - <Título de la tarea>" "<Resumen conciso de qué se implementó, archivos clave y decisiones tomadas>" --type architecture
     ```

2. Exporta los nuevos chunks a la carpeta `.engram/` del repositorio:

   ```bash
   engram sync
   ```

3. Comprueba que `.engram/manifest.json` y `.engram/chunks/` reflejen la exportación en `git status --short`.

## 5. Commit, Push y Pull Request (con confirmación)

1. Muestra al usuario:
   - La salida de `git status --short`.
   - El mensaje de commit propuesto en formato Conventional Commits (por ejemplo: `feat(<modulo>): implementar <resumen>`).
   - El título y resumen del Pull Request.
2. Pide confirmación para ejecutar el cierre.
3. Al confirmar:

   ```bash
   git add .
   git commit -m "<tipo>(<alcance>): <descripción corta>"
   ```

   *(Al correr `git commit`, el hook pre-commit de **GGA** revisará el diff con DeepSeek contra `AGENTS.md`. Si GGA rechaza el commit, corrige el hallazgo reportado y vuelve a intentar).*

4. Sube la rama y abre el Pull Request en GitHub usando el contenido del documento ODD como cuerpo:

   ```bash
   RAMA="$(git branch --show-current)"
   git push -u origin "$RAMA"
   gh pr create --title "<tipo>(<alcance>): <descripción corta>" --body-file "odd/tasks/<NN>-<slug>.md"
   ```

5. Entrega al usuario el enlace del Pull Request creado y, si desea ver el resultado de los workflows en vivo, ofrece correr `gh run watch`.

