#!/usr/bin/env bash
# productune-lite — Claude Code SessionStart hook (matcher: startup|resume|clear|compact)
#
# Injects doctrine into the session context so personas behave without relying on
# the model to "remember" to cat files (which silently degrades after compaction).
# This is the ONLY hook productune-lite ships — there are no enforcement / gate /
# migration / shape-guard hooks. Lite favors PO judgment over deterministic machinery.
#
# Injection (layer order, later wins):
#   pdtl-po        -> PO habit + bookshelf index  (PO does NOT read the worker common)
#                     + the PROJECT's docs/memory.md + .productune-lite/po-state.json slice
#   pdtl-<worker>  -> common habit + that worker's habit
#
# Bookshelf detail files load on demand via Bash `cat` with $HOME-expanded ABSOLUTE
# paths (the Read tool does NOT expand `~`; never guess `/root`).
#
# Output goes through hookSpecificOutput.additionalContext (not bare stdout) to avoid
# interleaving with other plugins' hook output. jq is a hard dependency.

set +e

EVENT_JSON="$(cat 2>/dev/null || true)"
AGENT_TYPE=""; EVENT_CWD=""
if [ -n "$EVENT_JSON" ] && command -v jq >/dev/null 2>&1; then
  AGENT_TYPE="$(printf '%s' "$EVENT_JSON" | jq -r '.agent_type // ""' 2>/dev/null)"
  EVENT_CWD="$(printf '%s' "$EVENT_JSON" | jq -r '.cwd // ""' 2>/dev/null)"
fi

ROOT="$HOME/.productune-lite/doctrine"
COMMON="$ROOT/common/habit.md"

emit_ctx() {
  printf '%s' "$1" | jq -Rs '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:.}}'
  exit 0
}

# Walk up from cwd to find the project root (.productune-lite/ marker).
find_proj() {
  local d="$1"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -f "$d/.productune-lite/po-state.json" ] || [ -f "$d/.productune-lite/config.json" ]; then
      printf '%s' "$d"; return 0
    fi
    d="$(dirname "$d")"
  done
  return 0
}

# Map agent_type -> persona.
PERSONA=""
case "$AGENT_TYPE" in
  pdtl-po)        PERSONA="po" ;;
  pdtl-designer)  PERSONA="designer" ;;
  pdtl-developer) PERSONA="developer" ;;
  pdtl-qa)        PERSONA="qa" ;;
esac

if [ -n "$PERSONA" ]; then
  PERSONA_HABIT="$ROOT/$PERSONA/habit.md"

  # PO is orchestrator-only and does NOT read the worker common habit.
  NEED_COMMON=1
  [ "$PERSONA" = "po" ] && NEED_COMMON=0

  # fail-loud: required doctrine absent OR truncated (empty) on this machine.
  # `! -s` catches a 0-byte mirror (e.g. interrupted rsync/cp) that `! -f` misses.
  MISSING=""
  [ "$NEED_COMMON" = "1" ] && [ ! -s "$COMMON" ] && MISSING="$MISSING $COMMON"
  [ ! -s "$PERSONA_HABIT" ] && MISSING="$MISSING $PERSONA_HABIT"
  if [ -n "$MISSING" ]; then
    printf '[!] productune-lite doctrine MISSING for %s:%s\n' "$AGENT_TYPE" "$MISSING" >&2
    emit_ctx "[productune-lite doctrine — MISSING]
Required doctrine file(s) are not present on this machine:$MISSING
STOP. Run productune-lite's install.sh to restore doctrine. Do not act without doctrine."
  fi

  COMMON_BLOCK=""
  if [ "$NEED_COMMON" = "1" ]; then
    COMMON_BLOCK="----- BEGIN common habit ($COMMON) -----
$(cat "$COMMON")
----- END common habit -----

"
  fi

  # PO-only: inject the project's live memory + state slice so the PO re-orients
  # every turn without a separate read step.
  PROJECT_BLOCK=""
  if [ "$PERSONA" = "po" ]; then
    PROJ="$(find_proj "$EVENT_CWD")"
    if [ -n "$PROJ" ]; then
      if [ -f "$PROJ/docs/memory.md" ]; then
        PROJECT_BLOCK="$PROJECT_BLOCK

----- BEGIN project memory ($PROJ/docs/memory.md) -----
$(cat "$PROJ/docs/memory.md")
----- END project memory -----"
      fi
      if [ -f "$PROJ/.productune-lite/po-state.json" ]; then
        PROJECT_BLOCK="$PROJECT_BLOCK

----- BEGIN po-state ($PROJ/.productune-lite/po-state.json) -----
$(cat "$PROJ/.productune-lite/po-state.json")
----- END po-state -----"
      fi
    fi
  fi

  emit_ctx "[productune-lite doctrine — $AGENT_TYPE session start]
Your doctrine is injected below. Bookshelf detail files referenced inside load on demand via Bash \`cat\` under $HOME/.productune-lite/ (the Read tool does NOT expand \`~\`; never guess \`/root\`).

$COMMON_BLOCK----- BEGIN $PERSONA habit ($PERSONA_HABIT) -----
$(cat "$PERSONA_HABIT")
----- END $PERSONA habit -----$PROJECT_BLOCK

Act per the doctrine above. Do NOT acknowledge or narrate this injection (no 'doctrine loaded / 로드됨 / 진행하겠다'-type preamble in ANY register) — your first user-facing line must be product substance (greeting / read-back / answer) in the user-facing register."
fi

# No agent_type (plain `claude` resume, clear/compact). Only inject if inside a
# productune-lite project; otherwise stay silent (this machine may also run other tools).
PROJ="$(find_proj "$EVENT_CWD")"
[ -z "$PROJ" ] && exit 0
[ ! -s "$COMMON" ] && exit 0

emit_ctx "[productune-lite — session start, persona unspecified]
You are in a productune-lite project ($PROJ). If you are acting as the PO, load the PO doctrine:
Bash \`cat \"$HOME/.productune-lite/doctrine/po/habit.md\"\` (and bookshelf/ on demand). A worker persona loads common + its own habit. The Read tool does NOT expand \`~\` — use the \$HOME-expanded path above."
