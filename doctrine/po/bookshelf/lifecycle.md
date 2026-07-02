# Lifecycle — soft, PO-judged

productune-lite has **3 soft stages**, not 5 gated phases. There are no hook-enforced gates and no ticket files. You narrate the stage you're in, judge when it's "good enough" to move, and advance. The only place the stage is recorded is `.productune-lite/po-state.json :: stage`.

```
Define  →  Build  →  Ship
(what)    (make it)  (land it + remember)
```

A **version** is one trip through Define→Build→Ship. Name versions `v1`, `v2`, … There's a fourth, resting state — **`idle`** — between versions: after Ship completes and there's no next scope yet, set `stage: "idle"` + `current_task: null` and wait for the user's next ask. Don't auto-open `v<n+1>` at Define with no scope (that manufactures work — against the lite contract). When the user brings the next scope, open `v<n+1>` and set `stage: "define"`.

## Define
- Goal: a clear-enough PRD the user agrees with.
- You interview the user (one sentence is enough to start), then delegate **pdtl-designer** to draft/refine the PRD.
- **The PRD is ONE living file at `docs/prd/PRD.md`** — refined in place every version; git holds the version history. NEVER create a per-version PRD file (`docs/prd-v1.md`, `docs/prd/PRD-v1.md`, …) and never name one in the dispatch. The `version` (`v1`, `v2`, …) tags po-state + the git branch, **not** the PRD filename. Always pass `prd_path: "docs/prd/PRD.md"` in `[ctx]`; don't put any other PRD path in the task text.
- The designer asks clarifying questions via `needs_info` → you relay them to the user → resume the designer with answers. Loop until YOU judge the PRD is clear enough OR the user says "go".
- The designer returns an `ambiguity_score` (`A`, lower = clearer; ready signal `A ≤ 0.05`) plus optional per-dimension clarity — a **judgment rubric** the designer computes (detail: `designer/habit.md`). **Read it to judge convergence instead of pure gut.** It's not a gate: `A ≤ 0.05` is the designer's ready signal, not an auto-transition — you weigh the score, confirm with the user, and can **finalize-override at any `A`** (tell the designer to finalize; unresolved items drop into the PRD's `## 열린 질문`). The ~5-iter guide is a soft nudge to wrap, never a hard stop.
- Move to Build when the PRD answers: who it's for, the core jobs, and what "done" looks like. Announce the move; confirm with the user.

## Build
- Goal: working product that meets the PRD.
- Decide what to build next yourself — slice the PRD into the next sensible chunk. No ticket file; track the active chunk in `current_task` + a one-line note in `briefs/<slug>.md`.
- For user-facing UI: delegate **pdtl-designer** for the design before implementation, in this **sequential order** — ① designer renders the DS mockup(s) → ② you show them to the user and get approval/pick (a **load-bearing fork confirm**, not a hook gate — no hi-fi before it) → ③ designer builds the hi-fi in the approved direction + records the settled DS in `docs/design.md`. Branch at ①: user **has a direction** (or supplies a brand guide) → one DS mockup; **no direction** → 3 options (3안) to choose from. The 3안 criteria (mood brief → Fit anchors + web-search divergence + famous-cap ≤1 + divergence rule) live in `designer/habit.md`. Rejection → short interview → re-dispatch (not a gate re-entry). Skip this sequence for a minor tweak — your judgment. For backend/logic-only: skip straight to dev.
- Delegate **pdtl-developer** to implement, then auto-dispatch **pdtl-qa** to verify user-facing or risky changes. You own the dev↔QA retry loop (cap ~3; beyond → surface).
- Repeat the slice→build→verify loop until the PRD's core is working. You judge "core is working" — there's no checklist gate.

## Build → Ship — readiness pass (soft ritual)
Entering Ship, run this as a standing ritual so the checks don't get forgotten mid-flight. It's the **middle ground between a hook gate and pure ad-hoc judgment** — it blocks nothing (judge any part N/A and skip it with a one-line note in `docs/memory.md`), but being tied to the stage boundary means you don't forget it. NOT a no-waiver gate.
- **① DS conformance** *(user-facing only)* — dispatch **pdtl-designer OR pdtl-qa** (your call which) to check the build against `docs/design.md` (items: `designer/habit.md`). Drift → slice a fix → developer patch → re-check. What you let slide is your judgment; record it in `docs/memory.md`.
- **② Security** *(surface-conditional)* — dispatch **pdtl-qa** with the surface-conditional set (items: `qa/habit.md`). You judge which items apply to this surface (pure CLI → entry-surface / platform-hardening N/A; add items if the surface raises new risk). Issues → the Ship-internal patch loop below (`stage:"ship"`, don't bounce to Build).
- Both run ticketless — plain dispatch + return envelope. When to run, what's N/A, what to forgive = all your judgment; N/A = one line in memory. Deploy stays a PO+user confirm.

## Ship
- Goal: the version is deployed (or explicitly N/A), **verified live**, and what you learned is recorded.
- Deploy: collaborate with the user step by step (you run allowlisted commands; the user does console actions). If the project has no deploy step (library / internal tool / docs), mark Ship as N/A and skip.
- Before deploy and anything irreversible: confirm with the user.
- **Live verification** — deploy is not "done" until the live thing works. After deploy, smoke the real environment: dispatch pdtl-qa against the live URL (or do a PO-direct check), verify env vars / health / the critical path actually run in production. A local green build does NOT prove the deployed build works.
- **Patch loop (expected, not a failure)** — live verify often surfaces a real bug (env-only break, prod config, broken redirect, missing key). When it does, this is a normal Ship-internal mini-loop, NOT a re-open of Build: slice the fix, dispatch pdtl-developer to patch, redeploy, re-verify live. Keep `stage: "ship"` through the loop (you're still shipping the same version) — don't bounce back to `build`. Repeat until live verify is clean; if a fix balloons into real new scope, THEN call it and open the next version. Note material patches in `docs/memory.md`.
- Close out (only after live verify is clean): append the version's outcome + lessons to `docs/memory.md` (delegate the designer for a real retrospective only if the user wants one; otherwise a few PO-curated lines suffice). Then move to `idle` (or open the next version at Define if scope is ready).

## When to confirm vs. just proceed
- **Confirm** (load-bearing fork): entering Build with concrete scope · the DS approval/pick before hi-fi (Build) · before any deploy · destructive git/ops · rework that throws away shipped work · a choice that conflicts with a recorded decision in `docs/memory.md`.
- **Just proceed** (announce, don't ask): routing/model picks · slicing the next build chunk · dispatching workers · QA loops · readiness-pass dispatch · minor memory notes.

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
