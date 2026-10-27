---
name: nueva-tarea-odd
description: Inicia, especifica e implementa un nuevo requerimiento o experimento de IA siguiendo ODD en odd/tasks/ para proyectos Python con uv en OpenCode y DeepSeek (nueva tarea, nuevo requerimiento, especificar feature, implementar tarea ODD). Sincroniza main y Engram, crea la rama feat/<NN>-<slug>, redacta la especificación en odd/tasks/<NN>-<slug>.md, pide confirmación antes de programar e implementa tarea por tarea con ruff y pytest.
---

# nueva-tarea-odd

Guía el ciclo completo de un requerimiento bajo **ODD (Organic-Driven Development)** en proyectos de Inteligencia Artificial con **`uv`**, **Engram** y **GGA**: primero especifica y valida el diseño en `odd/tasks/`, luego implementa de forma incremental en `src/` y `tests/`.

- **Regla de oro:** nunca escribas ni modifiques código en `src/` o `tests/` antes de que el documento `odd/tasks/<NN>-<slug>.md` esté creado y aprobado por el usuario.
- **Restricciones del entorno:** prohibido crear archivos `.ipynb`, usar `pip install` o dejar funciones sin *type hints*.

## 1. Contexto y sincronización inicial

1. Comprueba el estado actual del repositorio y sincroniza la memoria del equipo:

   ```bash
   git status --short
   command -v engram >/dev/null 2>&1 && engram sync --import || true
   ```

2. Si hay cambios sin guardar en otra rama, avisa antes de cambiar de rama.
3. Si estás en `main` (o el usuario pide empezar desde `main`), actualiza:

   ```bash
   git pull --ff-only || true
   ```

4. Consulta en Engram las decisiones previas del proyecto (`engram context` o la herramienta MCP de Engram si está activa) y lee `AGENTS.md` para conocer el nombre del paquete en `src/<paquete>/` y las reglas vigentes.

## 2. Numeración y creación de rama

1. Revisa los archivos existentes en `odd/tasks/` para calcular el siguiente número correlativo de dos dígitos (`01`, `02`, `03`, ...):

   ```bash
   ls -1 odd/tasks/ 2>/dev/null
   ```

2. A partir del requerimiento del usuario, define un *slug* corto en minúsculas con guiones (por ejemplo: `01-tokenizador-bpe` → rama `feat/01-tokenizador-bpe`).
3. Si aún estás en `main`, crea y cambia a la rama de trabajo:

   ```bash
   git switch -c "feat/<NN>-<slug>"
   ```

## 3. Redacción de la especificación (`odd/tasks/<NN>-<slug>.md`)

Si al pedido del usuario le falta algún dato crítico que obligaría a rehacer el diseño (como qué entrada recibe, qué salida devuelve o qué modelo/algoritmo usar), haz **una sola pregunta concreta** antes de redactar. Si puede inferirse razonablemente del contexto, asúmelo y decláralo.

Crea `odd/tasks/<NN>-<slug>.md` tomando como base `odd/tasks/_plantilla.md`:

```markdown
# <NN> - <Título claro del requerimiento>

Estado: propuesto
Rama: `feat/<NN>-<slug>`

## 1. Objetivo
<Descripción concisa en 1-2 líneas de qué resuelve este requerimiento.>

## 2. Especificación técnica (Entradas / Salidas)
- **Módulo(s):** `src/<paquete>/<modulo>.py`
- **Firmas propuestas (con type hints):**
  - `<funcion_o_clase>(...) -> <Retorno>`
- **Entradas:** <parámetros, tipos y restricciones>
- **Salidas:** <estructura o tipo devuelto>
- **Dependencias nuevas (`uv add`):** <ninguna, o lista exacta de paquetes>
- **Desacoplamiento para pruebas:** <cómo se inyecta el cliente LLM, modelo o configuración por parámetro para testear en `pytest` sin red>

## 3. Criterios de aceptación
- [ ] <Caso principal esperado con datos concretos>
- [ ] <Validación de entradas vacías, nulas o fuera de rango (excepción explícita)>
- [ ] <Manejo de errores externos (timeouts, respuestas malformadas del modelo) si aplica>
- [ ] Tipado estricto en todas las firmas y pruebas unitarias aisladas en `tests/test_<modulo>.py`

## 4. Tareas de implementación
- [ ] **T1:** <Definir modelos de datos / esquemas y firmas base en `src/<paquete>/<modulo>.py`>
- [ ] **T2:** <Implementar la lógica principal siguiendo SRP y KISS>
- [ ] **T3:** <Escribir pruebas unitarias en `tests/test_<modulo>.py` cubriendo casos normales y bordes>
- [ ] **T4:** <Ejecutar `uv run ruff check .` y `uv run pytest`, y registrar evidencia>

## 5. Evidencia de verificación
Pendiente de implementación.
```

## 4. Pausa obligatoria de aprobación

**Detente aquí.** Muestra al usuario un resumen breve de `odd/tasks/<NN>-<slug>.md` y pregunta si aprueba la especificación o quiere ajustar algún criterio antes de programar.

## 5. Implementación incremental (Tarea por tarea)

Una vez que el usuario apruebe:

1. Cambia `Estado: propuesto` a `Estado: en progreso` en `odd/tasks/<NN>-<slug>.md`.
2. Si hace falta instalar alguna dependencia aprobada en el punto 2 de la especificación, instálala exclusivamente con `uv`:

   ```bash
   uv add <paquete>
   ```

3. Ejecuta las tareas en orden (`T1` → `T2` → `T3` → `T4`):
   - Aplica buenas prácticas de ingeniería de software:
     - **SRP:** funciones cortas con una sola responsabilidad y un único nivel de abstracción.
     - **KISS / YAGNI:** sin capas ni interfaces innecesarias sino código modular directo y legible.
     - **Inyección por parámetro:** recibe clientes o configuración como argumentos para que `pytest` use *mocks/stubs* sin llamadas reales a APIs ni descargas de modelos pesados.
     - **Cero valores mágicos:** nombres de modelos, hiperparámetros o rutas van en constantes o configuración centralizada.
   - Al terminar cada tarea, márcala como `- [x]` en `odd/tasks/<NN>-<slug>.md`.
4. Corre la verificación en `T4`:

   ```bash
   uv run ruff format .
   uv run ruff check .
   uv run pytest -v
   ```

5. Si todo pasa sin errores, actualiza la sección `## 5. Evidencia de verificación` de `odd/tasks/<NN>-<slug>.md` con el resultado real de `ruff` y `pytest`, marca los criterios de aceptación cumplidos (`[x]`) e indica al usuario que puede revisar los cambios o ejecutar el skill `cerrar-tarea-pr` para sincronizar Engram y abrir el Pull Request.

