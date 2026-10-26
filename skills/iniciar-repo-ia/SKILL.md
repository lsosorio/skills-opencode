---
name: iniciar-repo-ia
description: Inicializa un repositorio o workspace de Inteligencia Artificial y Modelos de Lenguaje en Python con uv para OpenCode y DeepSeek (iniciar repo, empezar proyecto IA, nuevo workspace uv). Configura git, remoto privado en GitHub, proyecto empaquetado con uv (sin pip ni Jupyter Notebooks), ruff, pytest, AGENTS.md con buenas prácticas de ingeniería de software, Engram, odd/tasks, GGA con DeepSeek y CI en GitHub Actions.
---

# iniciar-repo-ia

Deja un repositorio (o un workspace con varios) de Inteligencia Artificial en Python listo para trabajar con **OpenCode**, **DeepSeek**, **`uv`**, **Engram**, **GGA** y **ODD**. Corre en el directorio actual.

- **Idempotente:** si un paso ya está hecho, se salta. Nunca sobrescribe un archivo existente: lo muestra y pregunta si se completa o se deja.
- **Con confirmación:** crear el remoto en GitHub, el primer commit y el push se preguntan antes de ejecutar. Lo demás se hace sin preguntar.
- **Restricciones duras del entorno:**
  - Todo el manejo de Python, paquetes y ejecución se hace con **`uv`** (`uv init`, `uv add`, `uv sync`, `uv run`). **Prohibido usar `pip install`, `conda`, `poetry` o `requirements.txt`.**
  - **Prohibido usar Jupyter Notebooks (`.ipynb`)** o dependencias asociadas (`jupyter`, `ipykernel`, `notebook`). Todo el código vive en módulos de Python dentro de `src/` y pruebas en `tests/`.

## 1. Datos

Toma de la petición lo que venga y pregunta el resto en **un solo mensaje**:

- **Nombre** del proyecto. De él salen:
  - El *slug* (minúsculas y guiones, sin espacios: `Tarea Atención` → `tarea-atencion`), que usan Engram, la carpeta y el repo de GitHub.
  - El *paquete* Python (minúsculas y guiones bajos: `tarea_atencion`), que vive en `src/<paquete>/`.
- **Qué es**, en una o dos líneas.
- **Tipo:**
  - *Repo suelto* (por defecto).
  - *Repo dentro de un workspace:* la carpeta padre agrupa varios repos de un mismo proyecto. Se corre dentro del repo; si la raíz aún no tiene `AGENTS.md` ni `.engram/`, los crea este skill (pasos 4 y 5).
  - *Workspace con repos existentes:* se corre en la raíz.
- **Remoto:** ¿ya existe? Si no, se ofrece crearlo **privado** (`--private`) en el paso 10.

Si el nombre de la carpeta actual tiene espacios, avisa: los espacios en rutas obligan a entrecomillar en todos los scripts. Propón renombrarla al *slug* antes de seguir.

## 2. Inventario

Ejecuta esta verificación antes de crear o modificar archivos:

```bash
for t in git gh uv engram gga opencode docker secret-tool; do command -v "$t" >/dev/null && echo "ok  $t" || echo "falta $t"; done
gh auth status >/dev/null 2>&1 && echo "ok  gh autenticado" || echo "falta gh auth login"
ls -la
```

- **Sin `git` o sin `uv`, se detiene antes de tocar archivos** y entrega los comandos de instalación (abajo).
- **Sin `gh` o sin su sesión activa, y con remoto pedido, se detiene antes de crear archivos** y le da al usuario los pasos de abajo. Enterarse al final deja el push y el secreto del CI pendientes. Sin remoto pedido, sigue y lo anota como pendiente.
- Lo demás que falte se reporta al final; no detiene los demás pasos.
- Archivos que ya existan (`AGENTS.md`, `pyproject.toml`, `.gga`, `.engram/`, `.gitignore`, `.dockerignore`, `.github/workflows/`): no se tocan sin preguntar.
- **Workspace:** los repos son las carpetas donde vive el `pyproject.toml` o `.git`, no las de primer nivel. Localízalos con:

  ```bash
  find . -maxdepth 4 -type d -name .git -not -path '*/worktrees/*' -not -path '*/.venv/*'
  ```

  Los pasos 3 a 9 se hacen **en cada repo**. En la raíz del workspace solo van `AGENTS.md` general (paso 4) y Engram (paso 5).

### Instalar `uv` (si falta)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Instalar `gh` y abrir su sesión (si falta)

Método oficial (nunca con snap). En Debian y Ubuntu:

```bash
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
```

Después, iniciar sesión con permiso `workflow` (obligatorio porque el primer push incluye `.github/workflows/`):

```bash
gh auth login --hostname github.com --git-protocol https --web --scopes workflow
gh auth setup-git
gh auth status
```

## 3. Git y entorno Python con `uv`

### 3.1. Inicializar Git

```bash
git rev-parse --is-inside-work-tree 2>/dev/null || git init -b main
git status >/dev/null 2>&1 || git config --global --add safe.directory "$(pwd)"
```

### 3.2. Inicializar paquete Python con `uv`

Si no existe `pyproject.toml`, inicializa un proyecto empaquetado en `src/<paquete>/` e instala las herramientas de desarrollo (`ruff` y `pytest`):

```bash
uv init --package --name "<slug>" --vcs none
uv add --dev ruff pytest
```

Si `tests/` no existe, crea una prueba base para que `uv run pytest` verifique el paquete desde el primer commit:

```bash
mkdir -p tests
[ -f tests/__init__.py ] || touch tests/__init__.py
[ -f tests/test_smoke.py ] || printf 'def test_smoke() -> None:\n    assert True\n' > tests/test_smoke.py
```

Agrega al final de `pyproject.toml` la configuración de `ruff` y `pytest` si aún no está presente:

```toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "N", "SIM"]

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
```

Verifica que todo corra limpio con `uv`:

```bash
uv run ruff check .
uv run pytest
```

### 3.3. `.gitignore` y `.env.example`

Asegura que `.gitignore` cubra Python, `uv`, secretos, notebooks bloqueados y artefactos pesados de IA (pesos de modelos, cachés y datasets crudos):

```bash
agregar() { grep -qxF "$1" "$2" 2>/dev/null || echo "$1" >> "$2"; }
for l in \
  '# Python y uv' \
  '__pycache__/' \
  '*.py[cod]' \
  '*.so' \
  '.Python' \
  'build/' \
  'dist/' \
  '*.egg-info/' \
  '.venv/' \
  '.ruff_cache/' \
  '.pytest_cache/' \
  '.mypy_cache/' \
  '' \
  '# Secretos' \
  '.env' \
  '.env.*' \
  '!.env.example' \
  '' \
  '# Prohibido subir notebooks' \
  '*.ipynb' \
  '.ipynb_checkpoints/' \
  '' \
  '# Artefactos y pesos de IA/LLMs' \
  '*.gguf' \
  '*.safetensors' \
  '*.bin' \
  '*.pt' \
  '*.pth' \
  '*.onnx' \
  'wandb/' \
  'mlruns/' \
  '.hf_cache/' \
  'data/raw/*' \
  '!data/raw/.gitkeep' \
  'data/processed/*' \
  '!data/processed/.gitkeep'; do
  [ -n "$l" ] && agregar "$l" .gitignore || echo "" >> .gitignore
done
mkdir -p data/raw data/processed
[ -e data/raw/.gitkeep ] || touch data/raw/.gitkeep
[ -e data/processed/.gitkeep ] || touch data/processed/.gitkeep
```

Crea la plantilla `.env.example` sin valores reales:

```bash
[ -f .env.example ] || cat << 'EOF' > .env.example
# Variables de entorno. Copia este archivo a .env y completa los valores reales.
# NUNCA subas el archivo .env al repositorio.
DEEPSEEK_API_KEY=
HF_TOKEN=
EOF
```

Para excluir algo solo en este clon local sin tocar el `.gitignore` versionado:

```bash
excluir() { f="$(git rev-parse --git-dir)/info/exclude"; grep -qxF "$1" "$f" 2>/dev/null || echo "$1" >> "$f"; }
```

## 4. AGENTS.md (Contexto para OpenCode + Reglas para GGA)

OpenCode lee `AGENTS.md` como archivo principal de contexto y GGA revisa cada commit contra él. Mantenlo por debajo de 200 líneas, en viñetas y con las palabras clave de GGA en inglés tal cual: `REJECT if` (falla el commit), `REQUIRE` (falla si falta) y `PREFER` (sugiere, no falla).

```markdown
# <Nombre>

Estado: base activa
Curso: Técnicas Avanzadas de IA para Modelos de Lenguaje
Stack: Python (>=3.12) gestionado exclusivamente con `uv`.

## Qué es
<descripción del paso 1>

## Cómo se ejecuta
- Sincronizar entorno: `uv sync`
- Importar memoria del equipo (al clonar o tras `git pull`): `engram sync --import`
- Exportar memoria nueva al repo (antes de hacer commit/push): `engram sync && git add .engram/`
- Ejecutar módulo principal: `uv run <slug>` (o `uv run python -m <paquete>`)
- Linter y formato: `uv run ruff check .` y `uv run ruff format --check .`
- Pruebas: `uv run pytest`

## Estructura base
- `src/<paquete>/`: código fuente modular del proyecto.
- `tests/`: pruebas unitarias con `pytest`.
- `data/raw/` y `data/processed/`: datos de entrada y procesados (ignorados en git salvo `.gitkeep`).
- `odd/tasks/`: especificaciones de tareas y features (basadas en `odd/tasks/_plantilla.md`).
- `.engram/`: memoria compartida del proyecto (`config.json`, `manifest.json` y `chunks/`).
- `scripts/setup.sh`: script de onboarding para configurar entorno y hooks locales tras clonar.

## Flujo de trabajo en equipo y ODD
- **Onboarding al clonar por primera vez:** ejecutar `./scripts/setup.sh` (sincroniza `uv`, importa memoria de Engram e instala los hooks locales `gga` y `post-merge`).
- **Especificar antes de programar (ODD):** usar el skill `nueva-tarea-odd` (o crear primero `odd/tasks/<NN>-<slug>.md` siguiendo `odd/tasks/_plantilla.md`) y validarlo con el usuario antes de escribir código en `src/`.
- **Cierre de cada tarea:** usar el skill `cerrar-tarea-pr` (o correr `uv run ruff check .`, `uv run pytest`, registrar la evidencia en `odd/tasks/` y ejecutar `engram sync && git add .engram/` antes del commit).

## Decisiones
Cada decisión técnica o de diseño entra aquí con su fecha y su motivo.

## Reglas de código (GGA)

REJECT if:
- Archivos de Jupyter Notebook (`*.ipynb`) o dependencias de Jupyter (`jupyter`, `ipykernel`, `notebook`) en `pyproject.toml`
- Uso de `pip install`, `conda`, `poetry` o archivos `requirements.txt` → usar exclusivamente `uv add` y `uv run`
- Secretos, API keys (`DEEPSEEK_API_KEY`, `HF_TOKEN`), tokens o contraseñas en código o en archivos versionados
- Pesos de modelos (`*.bin`, `*.pt`, `*.safetensors`, `*.gguf`) o datasets pesados versionados en git
- Funciones o métodos sin anotaciones de tipos (*type hints*) en sus parámetros y valor de retorno
- Manejo de errores vacío (`except: pass`) o que descarta la excepción sin registrarla ni propagarla
- Nombres de modelos, hiperparámetros, rutas o URLs harcodeados dentro de funciones en lugar de constantes o configuración
- Código comentado dejado "por si acaso" o `print()` de depuración olvidados
- Imagen de contenedor con etiqueta `latest`, sin etiqueta, o que corre como `root`

REQUIRE:
- Tipado explícito en todas las firmas de funciones y métodos
- Lectura de variables de entorno y secretos desde configuración centralizada, nunca dispersa en la lógica

PREFER:
- Principio de responsabilidad única (SRP): cada módulo y función hace una sola cosa bien; funciones cortas con un solo nivel de abstracción
- Simplicidad (KISS y YAGNI): estructura modular limpia sin capas burocráticas (no forzar Clean Architecture completa si no aporta valor real); crear abstracciones o clases solo cuando exista un segundo uso o para aislar pruebas
- Inyección de dependencias por parámetro: recibir clientes externos (APIs, LLMs) o configuración como argumentos para probar con `pytest` sin llamadas reales a red
- Nombres descriptivos que digan qué hacen o qué contienen, sin abreviaturas crípticas (`tmp`, `aux`, `df`, `x1`)
```

En un **workspace**: crea un `AGENTS.md` en la raíz solo con el contexto común y una tabla de repos con su `Estado` (sin bloque de GGA), y un `AGENTS.md` completo por cada repo con la plantilla de arriba.

## 5. Engram (Memoria compartida en el proyecto)

```bash
engram init <slug>
```

- **Memoria compartida por Git (`.engram/`):** `.engram/config.json`, `.engram/manifest.json` y `.engram/chunks/*.jsonl.gz` **se versionan** dentro del repositorio. Así todo el equipo comparte y actualiza la base de datos de conocimiento del proyecto sin conflictos binarios de SQLite:
  - Antes de subir cambios: `engram sync` exporta las memorias nuevas a `.engram/chunks/` (revisar antes de hacer `git add .engram/` porque lo subido queda en el historial).
  - Al bajar cambios del equipo: `engram sync --import` incorpora los nuevos chunks de `.engram/chunks/` a la base local de cada integrante.
- **Automatización al hacer `git pull` (`post-merge` hook) y script de onboarding (`scripts/setup.sh`):** crea `scripts/setup.sh` versionado y ejecútalo para que tanto quien inicia el repo como cualquier compañero que lo clone después quede con `uv`, `engram`, `gga` y el hook `post-merge` configurados de una vez:

  ```bash
  mkdir -p scripts
  [ -f scripts/setup.sh ] || cat << 'EOF' > scripts/setup.sh
  #!/usr/bin/env bash
  set -euo pipefail
  uv sync
  command -v engram >/dev/null 2>&1 && engram sync --import || true
  command -v gga >/dev/null 2>&1 && gga install || true
  HOOK="$(git rev-parse --git-dir)/hooks/post-merge"
  [ -f "$HOOK" ] || printf '#!/usr/bin/env bash\n' > "$HOOK"
  grep -q 'engram sync --import' "$HOOK" 2>/dev/null || printf 'command -v engram >/dev/null 2>&1 && engram sync --import >/dev/null 2>&1 || true\n' >> "$HOOK"
  chmod +x "$HOOK"
  echo "Entorno y hooks configurados."
  EOF
  chmod +x scripts/setup.sh
  ./scripts/setup.sh
  ```

- **Workspace:** `engram init <slug>` en la raíz **y** en cada repo, con el **mismo** nombre. Pregunta cuál repo sincroniza `.engram/chunks/`. En los demás, agrega `.engram/chunks/` y `.engram/manifest.json` a su `.gitignore` para evitar copias desincronizadas.
- **Repo dentro de un workspace:** el nombre de Engram es el del workspace, no el del repo. Si la raíz ya tiene `.engram/config.json`, toma el nombre de ahí; si no, ejecuta `engram init <slug-workspace>` en la raíz primero y luego en el repo.

## 6. ODD (Especificaciones en `odd/tasks/`)

Crea el directorio `odd/tasks/` y la plantilla base `odd/tasks/_plantilla.md` para que todos los requerimientos del equipo sigan el mismo estándar:

```bash
mkdir -p odd/tasks
[ -f odd/tasks/_plantilla.md ] || cat << 'EOF' > odd/tasks/_plantilla.md
# <NN> - <Título de la funcionalidad o experimento>

Estado: propuesto | en progreso | completado
Rama: `feat/<slug>`

## 1. Objetivo
<Qué problema o requerimiento resuelve en 1 o 2 líneas.>

## 2. Especificación técnica (Entradas / Salidas)
- **Módulo(s):** `src/<paquete>/<modulo>.py`
- **Entradas:** <parámetros y tipos esperados>
- **Salidas:** <tipo de retorno o estructura de datos>
- **Dependencias / Configuración:** <modelos, hiperparámetros o clientes inyectados>

## 3. Criterios de aceptación
- [ ] <Comportamiento esperado en el caso normal>
- [ ] <Manejo de casos borde o entradas inválidas>
- [ ] Funciones tipadas (*type hints*) y probadas en `tests/test_<modulo>.py` sin llamadas reales a red

## 4. Tareas de implementación
- [ ] **T1:** <Definir modelos de datos y firmas en `src/`>
- [ ] **T2:** <Implementar lógica principal>
- [ ] **T3:** <Escribir pruebas unitarias en `tests/`>
- [ ] **T4:** <Verificar con `uv run ruff check .`, `uv run pytest` y exportar memoria con `engram sync`>

## 5. Evidencia de verificación
- `uv run ruff check .` -> <resultado>
- `uv run pytest` -> <resultado>
EOF
```

Los documentos de tareas (`odd/tasks/<NN>-<feature>.md`) se versionan junto con el código.

## 7. GGA (Gentleman Guardian Angel con OpenCode + DeepSeek)

Escribe `.gga` directo (sin `gga init`):

```ini
PROVIDER="opencode:deepseek/deepseek-chat"
RULES_FILE="AGENTS.md"
STRICT_MODE="true"
EXCLUDE_PATTERNS="uv.lock,*.lock,.engram/*,*.jsonl.gz,*.min.js,*.min.css,*.map,*.svg,*.png,*.jpg,*.jpeg,*.gif,*.ico,*.pdf,*.woff,*.woff2"
```

Luego instala el hook y verifica la configuración (si `gga` está instalado en el sistema):

```bash
gga install && gga config
```

`gga config` debe mostrar `PROVIDER: opencode:deepseek/deepseek-chat` y `RULES_FILE: AGENTS.md`. `.gga` se versiona.

## 8. .dockerignore

```text
.git
.github
.env
.env.*
!.env.example
.engram
.opencode
.claude
odd
.venv
__pycache__
.pytest_cache
.ruff_cache
.mypy_cache
tests
data/raw
*.gguf
*.safetensors
*.bin
*.pt
*.pth
*.onnx
```

## 9. CI en GitHub Actions

Obtén las versiones vigentes al crear los workflows (no las dejes flotantes):

```bash
OC_VER=$(npm view opencode-ai version 2>/dev/null || echo "latest")
GGA_TAG=$(git ls-remote --tags --refs --sort=-v:refname https://github.com/Gentleman-Programming/gentleman-guardian-angel.git 2>/dev/null | head -1 | sed 's#.*/##')
CHECKOUT=$(gh api repos/actions/checkout/releases/latest --jq .tag_name 2>/dev/null | cut -d. -f1)
SETUP_UV=$(gh api repos/astral-sh/setup-uv/releases/latest --jq .tag_name 2>/dev/null | cut -d. -f1)
echo "opencode=$OC_VER gga=${GGA_TAG:-main} checkout=${CHECKOUT:-v4} setup-uv=${SETUP_UV:-v5}"
```

### 9.1. Calidad y pruebas con `uv` (`.github/workflows/ci.yml`)

Reemplaza `<CHECKOUT>` (por ejemplo `v4`) y `<SETUP_UV>` (por ejemplo `v5`):

```yaml
name: CI (uv + ruff + pytest)

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  verificar:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@<CHECKOUT>
      - name: Instalar uv
        uses: astral-sh/setup-uv@<SETUP_UV>
        with:
          enable-cache: true
      - name: Sincronizar dependencias
        run: uv sync --locked --all-groups
      - name: Verificar que no existan notebooks ni requirements.txt
        run: |
          if find . -name "*.ipynb" -not -path "./.venv/*" | grep -q .; then
            echo "Error: No se permiten archivos Jupyter Notebook (.ipynb)"
            exit 1
          fi
          if [ -f requirements.txt ]; then
            echo "Error: Usa pyproject.toml y uv.lock en lugar de requirements.txt"
            exit 1
          fi
      - name: Linter (Ruff)
        run: uv run ruff check .
      - name: Formato (Ruff)
        run: uv run ruff format --check .
      - name: Pruebas (Pytest)
        run: uv run pytest
```

### 9.2. Revisión de GGA con DeepSeek en cada PR (`.github/workflows/gga-review.yml`)

Reemplaza `<CHECKOUT>`, `<OC_VER>` y `<GGA_TAG>`:

```yaml
name: Revisión GGA (DeepSeek)

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  contents: read

concurrency:
  group: gga-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  revisar:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    timeout-minutes: 15
    continue-on-error: true
    env:
      DEEPSEEK_API_KEY: ${{ secrets.DEEPSEEK_API_KEY }}
    steps:
      - uses: actions/checkout@<CHECKOUT>
        with:
          fetch-depth: 0
      - name: Instalar OpenCode y GGA
        run: |
          npm install -g opencode-ai@<OC_VER>
          git clone --depth 1 --branch <GGA_TAG> https://github.com/Gentleman-Programming/gentleman-guardian-angel.git "$RUNNER_TEMP/gga"
          chmod +x "$RUNNER_TEMP/gga/bin/gga"
          echo "$RUNNER_TEMP/gga/bin" >> "$GITHUB_PATH"
      - name: Revisar los cambios del PR
        run: gga run --pr-mode --diff-only
```

### 9.3. Secreto `DEEPSEEK_API_KEY` para el CI

El secreto `DEEPSEEK_API_KEY` se configura **después del push** (`gh secret set` requiere que exista el remoto). La clave nunca debe imprimirse en la conversación: vive en el llavero del sistema (`secret-tool`) y pasa por tubería directo a GitHub.

1. Revisa si ya existe en el llavero, sin imprimir el valor:

   ```bash
   secret-tool lookup service deepseek-ci >/dev/null 2>&1 && echo "api key en el llavero" || echo "sin api key en el llavero"
   ```

2. **Con clave en el llavero:** pregunta junto con el push (paso 10) y carga el secreto al repositorio:

   ```bash
   secret-tool lookup service deepseek-ci | gh secret set DEEPSEEK_API_KEY
   gh secret list
   ```

   `secret-tool lookup` solo se ejecuta con `|` hacia `gh secret set`, nunca solo.

3. **Sin clave en el llavero** (o sin `secret-tool`): entrega al usuario estos comandos para que los corra en una **terminal externa** (nunca dentro del chat del agente):

   ```bash
   sudo apt install libsecret-tools                                      # si falta secret-tool
   secret-tool store --label="DeepSeek CI Key" service deepseek-ci       # pega tu DEEPSEEK_API_KEY; no se muestra al escribir
   clear
   ```

   Si no hay llavero gráfico disponible, el usuario corre directamente en su terminal: `gh secret set DEEPSEEK_API_KEY` dentro del repo.

**Respaldo sin costo de API:** si prefieres usar GitHub Models en CI sin consumir saldo de DeepSeek, agrega `models: read` en `permissions` y en `env` define `GGA_PROVIDER: github:deepseek/DeepSeek-V3-0324` y `GH_TOKEN: ${{ github.token }}`.

## 10. Remoto privado y primer commit (con confirmación)

1. Formatea el código con `uv run ruff format .` y verifica `git status --short`.
2. Comprueba que `git status --short` **no** incluya `.env`, claves ni archivos fuera de lugar.
3. Pregunta confirmación antes del primer commit.
4. Haz el commit con Conventional Commits: `chore: iniciar repositorio con uv y reglas base`.
5. Si no hay remoto configurado, pide confirmación para crearlo **privado** y hacer el push:

   ```bash
   gh repo create <dueño>/<slug> --private --source . --remote origin --push
   ```

   *(El dueño por defecto es el usuario activo en `gh auth status`).*
6. Si ya existía el remoto, pregunta antes de correr `git push -u origin main`.
7. Tras el push, configura el secreto `DEEPSEEK_API_KEY` según el paso 9.3.

## 11. Verificación y cierre

Comprueba con comandos reales, no supongas:

- `uv run ruff check .` y `uv run pytest` → pasan sin errores.
- `gga config` (si `gga` está instalado) → `PROVIDER: opencode:deepseek/deepseek-chat`.
- `cat .engram/config.json` (si `engram` está instalado) → contiene el *slug* esperado.
- `[ -x "$(git rev-parse --git-dir)/hooks/post-merge" ]` → hook activo para importar memorias de `.engram/chunks/` automáticamente en cada `git pull`.
- `git status --short` → limpio y sin exponer `.env`.
- `odd/tasks/_plantilla.md` → existe.
- Si hubo push: `gh workflow list` muestra los workflows `CI (uv + ruff + pytest)` y `Revisión GGA (DeepSeek)`, y `gh secret list` muestra `DEEPSEEK_API_KEY` (si ya se cargó).

Cierra con una tabla concisa de lo creado, lo que falló y lo pendiente (herramientas faltantes o secreto de CI).
