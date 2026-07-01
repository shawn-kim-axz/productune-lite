#!/usr/bin/env bash
# productune-lite uninstaller — removes everything install.sh added. Idempotent.
# Does NOT touch any project's docs/ or .productune-lite/ (your work stays).

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_DIR="$REPO_DIR/scripts/hooks/"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
say() { printf '\033[36m[productune-lite]\033[0m %s\n' "$*"; }

# 1. agents
for p in pdtl-po pdtl-designer pdtl-developer pdtl-qa; do
  rm -f "$CLAUDE_DIR/agents/$p.md"
done
say "removed agent symlinks"

# 2. hook — strip by lite repo hooks DIR prefix, NEVER by basename. full
# productune ships a same-named session-start-doctrine.sh at a DIFFERENT path;
# a basename match here would clobber full's hook too (the historical bug).
if [ -f "$SETTINGS" ] && command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  jq --arg dir "$HOOK_DIR" '
    if (.hooks.SessionStart) then
      .hooks.SessionStart = [ .hooks.SessionStart[] | select(((.hooks[]?.command // "") | startswith($dir)) | not) ]
    else . end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  say "removed SessionStart hook"
fi

# 3. PATH symlinks
for cand in "$HOME/.local/bin" "/usr/local/bin" "$HOME/bin"; do
  [ -L "$cand/productune-lite" ] && rm -f "$cand/productune-lite"
done
say "removed entrypoint symlinks"

# 4. home mirror
rm -rf "$HOME/.productune-lite"
say "removed ~/.productune-lite (doctrine mirror + env)"

say "done. Project files (docs/, .productune-lite/ inside repos) were left untouched."
