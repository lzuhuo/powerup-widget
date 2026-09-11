#!/usr/bin/env bash
set -euo pipefail

plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/powerup.power"
shell_config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/shell.json"

if [[ -d "$plugin_dir" ]]; then
  rm -rf "$plugin_dir"
fi

if [[ -f "$shell_config" ]]; then
  python3 - "$shell_config" <<'PY'
import json
import os
import sys
import tempfile

path = sys.argv[1]
with open(path, encoding="utf-8") as stream:
    config = json.load(stream)

layout = config.get("bar", {}).get("layout", {})
for section in ("left", "center", "right"):
    entries = layout.get(section, [])
    layout[section] = [
        entry for entry in entries
        if not (isinstance(entry, dict) and entry.get("id") == "powerup.power")
    ]

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

printf 'Removed powerup.power\n'
