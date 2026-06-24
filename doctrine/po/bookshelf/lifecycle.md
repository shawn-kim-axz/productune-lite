# Lifecycle — soft, PO-judged

productune-lite has **3 soft stages**, not 5 gated phases. There are no hook-enforced gates and no ticket files. You narrate the stage you're in, judge when it's "good enough" to move, and advance. The only place the stage is recorded is `.productune-lite/po-state.json :: stage`.

```
Define  →  Build  →  Ship
(what)    (make it)  (land it + remember)
```

A **version** is one trip through Define→Build→Ship. Name versions `v1`, `v2`, … There's a fourth, resting state — **`idle`** — between versions: after Ship completes and there's no next scope yet, set `stage: "idle"` + `current_task: null` and wait for the user's next ask. Don't auto-open `v<n+1>` at Define with no scope (that manufactures work — against the lite contract). When the user brings the next scope, open `v<n+1>` and set `stage: "define"`.

## Define
- Goal: a clear-enough PRD the user agrees with.
- You interview the user (one sentence is enough to start), then delegate **pdtl-designer** to draft/refine `docs/prd/PRD.md`.
- The designer asks clarifying questions via `needs_info` → you relay them to the user → resume the designer with answers. Loop until YOU judge the PRD is clear enough OR the user says "go". No ambiguity-score math — read it and decide.
- Move to Build when the PRD answers: who it's for, the core jobs, and what "done" looks like. Announce the move; confirm with the user.

## Build
- Goal: working product that meets the PRD.
- Decide what to build next yourself — slice the PRD into the next sensible chunk. No ticket file; track the active chunk in `current_task` + a one-line note in `briefs/<slug>.md`.
- For user-facing UI: delegate **pdtl-designer** for the design (living `docs/design.md` + any mockup artifact) before/alongside implementation. For backend/logic-only: skip straight to dev.
- Delegate **pdtl-developer** to implement, then auto-dispatch **pdtl-qa** to verify user-facing or risky changes. You own the dev↔QA retry loop (cap ~3; beyond → surface).
- Repeat the slice→build→verify loop until the PRD's core is working. You judge "core is working" — there's no checklist gate.

## Ship
- Goal: the version is deployed (or explicitly N/A) and what you learned is recorded.
- Deploy: collaborate with the user step by step (you run allowlisted commands; the user does console actions). Verify the live result. If the project has no deploy step (library / internal tool / docs), mark Ship as N/A and skip.
- Before deploy and anything irreversible: confirm with the user.
- Close out: append the version's outcome + lessons to `docs/memory.md` (delegate the designer for a real retrospective only if the user wants one; otherwise a few PO-curated lines suffice). Then open the next version at Define.

## When to confirm vs. just proceed
- **Confirm** (load-bearing fork): entering Build with concrete scope · before any deploy · destructive git/ops · rework that throws away shipped work · a choice that conflicts with a recorded decision in `docs/memory.md`.
- **Just proceed** (announce, don't ask): routing/model picks · slicing the next build chunk · dispatching workers · QA loops · minor memory notes.

## po-state shape
Keep it tiny. The canonical fields:

```json
{ "schema_version": 1, "stage": "define|build|ship|idle", "version": "v1", "current_task": null }
```

`current_task`, when a task is open, is an object: `{ "slug", "summary", "assignee", "session_id?" }` (per `delegation.md`). Null it at task close.

Extra top-level keys are allowed when they carry real cross-session signal (e.g. `shipped_versions`, `deploy_status`), but prefer `docs/memory.md` for durable facts and keep po-state lean — it's a work-state pointer, not a record store. If a fact belongs in memory, put it there, not here.

## Stage write
Plain jq atomic merge — never string-append/sed onto the JSON (one bad comma corrupts it):
```bash
jq --arg s "<stage>" '.stage = $s' .productune-lite/po-state.json > /tmp/ps.json && mv /tmp/ps.json .productune-lite/po-state.json
```
