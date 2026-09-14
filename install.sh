#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/powerup.power"
shell_config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/shell.json"
timestamp="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$plugin_dir"
if [[ -e "$plugin_dir/Panel.qml" ]]; then
  backup_dir="${plugin_dir}.backup.${timestamp}"
  cp -a "$plugin_dir" "$backup_dir"
  printf 'Backup created at %s\n' "$backup_dir"
fi

cp "$project_dir/plugin/Panel.qml" "$plugin_dir/Panel.qml"
cp "$project_dir/plugin/Model.js" "$plugin_dir/Model.js"
cp "$project_dir/plugin/manifest.json" "$plugin_dir/manifest.json"

if [[ -f "$shell_config" ]]; then
  python3 - "$shell_config" <<'PY'
import json
import os
import sys
import tempfile

path = sys.argv[1]
with open(path, encoding="utf-8") as stream:
    config = json.load(stream)

layout = config.setdefault("bar", {}).setdefault("layout", {})
for section in ("left", "center", "right"):
    layout[section] = [
        entry for entry in layout.get(section, [])
        if not (isinstance(entry, dict) and entry.get("id") == "elizeu.power")
    ]
right = layout["right"]
if not any(isinstance(entry, dict) and entry.get("id") == "powerup.power" for entry in right):
    right.append({"id": "powerup.power"})

directory = os.path.dirname(path)
fd, temporary = tempfile.mkstemp(prefix=".shell.json.", dir=directory, text=True)
try:
    with os.fdopen(fd, "w", encoding="utf-8") as stream:
        json.dump(config, stream, indent=2, ensure_ascii=False)
        stream.write("\n")
    os.replace(temporary, path)
except Exception:
    os.unlink(temporary)
    raise
PY
fi

if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

printf 'Installed powerup.power to %s\n' "$plugin_dir"
