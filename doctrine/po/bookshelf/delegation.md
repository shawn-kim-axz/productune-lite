# Delegation — dispatching workers

Never author worker output — dispatch it. Workers get their doctrine injected at session start; you pass only per-task context.

## Channel
- **Preferred: the `Agent` tool** — `Agent(subagent_type: "pdtl-<persona>", prompt: "<[ctx] line + task>")`. Result returns as tool output; the agent is continuable via `SendMessage(to: <agentId>)` with context intact (cheapest — use it for QA-retry / plan→impl follow-ups in the same task).
- **Fallback: shell** — `claude --add-dir ~/.productune-lite -p --agent pdtl-<persona> --permission-mode acceptEdits --model <tier> '<[ctx] + task>'`. Use only when the Agent tool is unavailable (headless/CI). Always FOREGROUND — never background a nested agent. Single-quote the prompt (backticks/`$()`/`<>` in a double-quoted string break the shell). Resume with `--resume "<session_id>"`.

## The `[ctx]` line
Pass one inline JSON line as the first thing in the prompt:
```
[ctx] {"slug":"<task-slug>","summary":"<one-line ask>","version":"v1","prd_path":"docs/prd/PRD.md","user_lang":"<BCP-47>","audience":"user|internal"}
```
- `user_lang` — resolve from the user's working language (what they're typing). Pass it every time so workers write user-facing prose in the right language.
- `prd_path` — always `docs/prd/PRD.md` (canonical, version-agnostic). Pass it on every Define/Build dispatch; never drop it or invent a per-version PRD filename.
- Keep the canonical keys above as the ctx **shape** — add task keys, don't silently replace or trim the shape. Dropping `prd_path`/`user_lang` makes workers improvise paths and languages (observed: designer invented `docs/prd-v1-*.md` when `prd_path` was omitted).
- Add task-specific keys as needed (`acceptance`, `design_path`, `target_files`) — keep it lean.
- Do NOT paste doctrine, habits, or standing rules into the prompt — they're already in the worker's context. Duplication wastes tokens and risks drift.

## Per-dispatch knobs
- **model + effort** → `bookshelf/routing.md` (always pass `--model` on the shell path; pass `model` to the Agent tool).
- **write grant** (shell path) → `--permission-mode acceptEdits` for authoring workers (designer/developer); QA needs none.
- **UI smoke** → give QA a browser tool (Playwright/Chromium MCP) when verifying rendered UI.

## What you write around a dispatch
- Open `current_task` in po-state before dispatch: `{slug, summary, assignee, stage}`. Optionally a one-line `briefs/<slug>.md` so progress survives a session swap.
- On a multi-turn task, record the worker's `session_id`/`agentId` so you can resume it.
- On task close, null `current_task`.
- That's it — no ticket frontmatter, no status enum, no worktree-per-task. (For risky parallel code work you MAY isolate a dev in a git worktree, but it's optional, not the default.)

## Plan-first (only when it earns it)
For genuinely complex / cross-cutting / risky work: dispatch the worker PLAN-ONLY first (open the prompt with `PLAN MODE — DO NOT WRITE CODE`, ask for goal/constraints/approach), sanity-check the plan (yourself, or a quick QA/designer cross-look), then resume the same session to implement. Skip this for ordinary changes — it's a tool, not a ritual.

## Dev↔QA loop
After an impl dispatch, auto-dispatch QA for user-facing or risky changes (no user confirm). On QA fail, resume the developer with the fail excerpt; retry ~3× then surface as blocked. Trivial non-shipping changes can skip QA — your judgment.

## Subagent return
Read `confidence` + `unresolved` + `needs_info`. Low confidence or non-empty unresolved → escalate (retry up a notch, or surface). `needs_info` → relay `next_question` to the user, then resume with the answer. Workers never call `AskUserQuestion` themselves — that channel is yours.
