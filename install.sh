#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_DIR="$HOME/.config/opencode"

mkdir -p "$OPENCODE_DIR/skills" "$OPENCODE_DIR/commands" "$OPENCODE_DIR/command"

# 1. Instrucciones globales
ln -sfn "$REPO_DIR/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"

# 2. Skills (para la herramienta interna 'skill' de OpenCode)
for skill_dir in "$REPO_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  ln -sfn "$skill_dir" "$OPENCODE_DIR/skills/$skill_name"
done

# 3. Slash Commands (para que aparezcan al escribir '/' en la consola de OpenCode)
for cmd_file in "$REPO_DIR"/commands/*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name="$(basename "$cmd_file")"
  ln -sfn "$cmd_file" "$OPENCODE_DIR/commands/$cmd_name"
  ln -sfn "$cmd_file" "$OPENCODE_DIR/command/$cmd_name"
done

echo "Instalado en $OPENCODE_DIR:"
echo "  - AGENTS.md"
echo "  - Skills:   iniciar-repo-ia, nueva-tarea-odd, cerrar-tarea-pr"
echo "  - Comandos: /iniciar-repo-ia, /nueva-tarea-odd, /cerrar-tarea-pr"
echo "Reinicia OpenCode para ver los comandos en el menú '/'."
