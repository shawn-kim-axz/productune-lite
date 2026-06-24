# Memory — the single curated file

`docs/memory.md` is the ONLY memory store in productune-lite. It replaces the entire 4-tier doctrine + 3-tier work memory + promotion gate + SoT/mirror machinery of full productune. You — the PO — own it. One file, edited in place, committed with the project.

## Shape
Four sections. Keep each line short, dated, one fact per line.

```markdown
# Project memory

## Decisions
- (2026-06-24) Auth via magic-link, not passwords — user wants zero-password UX.

## Preferences
- (2026-06-24) User prefers terse status updates, no long explanations.

## Project facts
- (2026-06-24) Deploy target = Vercel; DB = Neon Postgres (Marketplace).

## Learnings
- (2026-06-24) Cross-cutting refactors need opus/xhigh here — sonnet/medium got reworked once.
```

## What goes where
- **Decisions** — settled product/architecture choices. A decision here is binding: if a later ask conflicts with one, flag it and confirm before overriding.
- **Preferences** — how this user likes to work (tone, cadence, what to ask vs. just do).
- **Project facts** — stable truths about the project (stack, targets, constraints, external accounts).
- **Learnings** — routing/quality lessons (what model tier a kind of task really needs, recurring failure areas). This is your routing bias for `bookshelf/routing.md`.

## When to write
- Read `docs/memory.md` at every turn open.
- Write a line when something **durable** surfaces — from a worker's `memory_notes[]`, from a user statement, or from your own observation. Durable = it'll matter again next session.
- **Big or irreversible decisions** (architecture, scope, anything expensive to reverse) → confirm with the user before recording.
- **Small routing-bias / preference notes** → just append, no need to ask.
- Don't record what's already obvious from the code, the PRD, or git history.

## memory.md vs. brief — don't double-record
- `briefs/<slug>.md` = ephemeral progress trace for the ACTIVE task (where you are, what's next) — it's scratch, safe to discard at task close.
- `docs/memory.md` = durable, cross-session truth (decisions, facts, learnings). 
- A durable fact goes in memory, not the brief; a fleeting progress note goes in the brief, not memory. When a task closes, the brief's lasting takeaways (if any) graduate into memory; the brief itself can be left or cleared.

## How to write
- Plain `Edit`/append — it's a markdown file, not JSON. Date each line `(YYYY-MM-DD)`.
- Keep it curated, not a dump. If a section grows past ~20 lines, consolidate: merge duplicates, drop superseded lines (note the supersession in the surviving line). A tight memory is a useful memory.
- No tiers, no promotion approval flow, no cross-project store. If a lesson feels universal, it still lives here — productune-lite is single-project by design.
