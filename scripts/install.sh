#!/usr/bin/env bash
# productune-lite installer — deliberately minimal.
#
# Does four things, all idempotent:
#   1. Mirror doctrine     repo/doctrine/  ->  ~/.productune-lite/doctrine/
#   2. Symlink agents       repo/agents/pdtl-*.md  ->  ~/.claude/agents/
#   3. Merge ONE hook       session-start-doctrine.sh into ~/.claude/settings.json
#   4. Register PATH        symlink the `productune-lite` entrypoint into a bin dir
#
# No GUI, no migration framework, no Tier-2 personal scaffold, no skill installer.
# Namespaced `pdtl-*` + `~/.productune-lite/` so it never collides with full productune.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_ROOT="$HOME/.productune-lite"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_SRC="$REPO_DIR/scripts/hooks/session-start-doctrine.sh"

say() { printf '\033[36m[productune-lite]\033[0m %s\n' "$*"; }

command -v jq >/dev/null 2>&1 || { echo "[!] jq is required (brew install jq)"; exit 1; }
command -v claude >/dev/null 2>&1 || say "note: 'claude' CLI not found — install with: npm i -g @anthropic-ai/claude-code"

# 1. Mirror doctrine (one-way: repo is SoT). rsync if present, else cp.
say "mirroring doctrine -> $HOME_ROOT/doctrine"
mkdir -p "$HOME_ROOT/doctrine"
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$REPO_DIR/doctrine/" "$HOME_ROOT/doctrine/"
else
  rm -rf "$HOME_ROOT/doctrine"; mkdir -p "$HOME_ROOT/doctrine"
  cp -R "$REPO_DIR/doctrine/." "$HOME_ROOT/doctrine/"
fi

# 2. Symlink agents (edit-in-place — repo file is the live source).
say "linking agents -> $CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/agents"
for f in "$REPO_DIR"/agents/pdtl-*.md; do
  ln -sf "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

# 3. Merge the SessionStart hook into ~/.claude/settings.json (idempotent).
say "registering SessionStart hook"
mkdir -p "$CLAUDE_DIR"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
chmod +x "$HOOK_SRC"
tmp="$(mktemp)"
jq --arg cmd "$HOOK_SRC" '
  .hooks //= {} |
  .hooks.SessionStart //= [] |
  # drop any prior productune-lite entry, then add ours once
  .hooks.SessionStart = ([ .hooks.SessionStart[] | select((.hooks[]?.command // "") | test("session-start-doctrine.sh$") | not) ]) |
  .hooks.SessionStart += [ { "matcher": "startup|resume|clear|compact", "hooks": [ { "type": "command", "command": $cmd } ] } ]
' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"

# 4. PATH — symlink the entrypoint into the first writable bin on PATH (fallback ~/.local/bin).
ENTRY="$REPO_DIR/scripts/productune-lite"
chmod +x "$ENTRY"
BIN=""
for cand in "$HOME/.local/bin" "/usr/local/bin" "$HOME/bin"; do
  case ":$PATH:" in *":$cand:"*) [ -d "$cand" ] && [ -w "$cand" ] && { BIN="$cand"; break; };; esac
done
[ -z "$BIN" ] && { BIN="$HOME/.local/bin"; mkdir -p "$BIN"; }
ln -sf "$ENTRY" "$BIN/productune-lite"
say "entrypoint -> $BIN/productune-lite"
case ":$PATH:" in *":$BIN:"*) ;; *) say "add to PATH: export PATH=\"$BIN:\$PATH\"";; esac

# Record repo path for the entrypoint.
mkdir -p "$HOME_ROOT"
printf 'PDTL_REPO=%s\n' "$REPO_DIR" > "$HOME_ROOT/productune-lite.env"

say "done. cd into a project and run: productune-lite"
