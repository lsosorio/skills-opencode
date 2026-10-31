#!/usr/bin/env bash
# Validate the skills repository: frontmatter, referenced files and known regressions.
set -euo pipefail
status=0
fail() { echo "FAIL: $1"; status=1; }

for skill_dir in skills/*/; do
  name=$(basename "$skill_dir")
  file="$skill_dir/SKILL.md"
  [ -f "$file" ] || { fail "$skill_dir has no SKILL.md"; continue; }
  [ "$(head -1 "$file")" = "---" ] || fail "$file: frontmatter must start with ---"
  grep -qx "name: $name" "$file" || fail "$file: name must be $name"
  description=$(grep -m1 '^description:' "$file" | cut -d' ' -f2-)
  [ -n "$description" ] || fail "$file: description missing"
  [ "${#description}" -le 1024 ] || fail "$file: description longer than 1024 characters"
  while read -r reference; do
    [ -f "$skill_dir/$reference" ] || fail "$file references missing $reference"
  done < <(grep -oE '(examples|references)/[A-Za-z0-9._/-]+\.md' "$file" | sort -u)
  if [ -f "commands/$name.md" ]; then
    grep -q '^description:' "commands/$name.md" || fail "commands/$name.md: description missing"
  else
    echo "WARN: $name has no slash command (optional)"
  fi
done

for command_file in commands/*.md; do
  [ -e "$command_file" ] || continue
  [ -d "skills/$(basename "$command_file" .md)" ] || fail "$command_file has no matching skill"
done

if grep -rn 'runs-on: ubuntu-latest' skills; then fail "ubuntu-latest found: pin ubuntu-24.04"; fi
if grep -rn 'cut -d\. -f1' skills; then fail "floating action tags found: use the exact tag"; fi
if [ -f README.es.md ]; then
  [ "$(grep -c '^## ' README.md)" = "$(grep -c '^## ' README.es.md)" ] || fail "README.md and README.es.md differ in section count"
else
  fail "README.es.md missing"
fi

if [ "$status" = 0 ]; then echo "OK: skills repository valid"; fi
exit "$status"
