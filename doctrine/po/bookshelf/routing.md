# Routing — model + effort

Pick a model and effort per dispatch. Start from the persona floor, adjust by signals, bias by `docs/memory.md` learnings. Effort follows the model. Always pass the model explicitly (agents carry no default).

## Per-persona floor (the sensible default)

| Persona | Floor | Why |
|:--|:--|:--|
| Designer — new PRD / net-new design | opus / high | the hardest authoring; clarity matters most |
| Designer — incremental PRD / single screen / design notes | opus / medium → sonnet / medium | spec work, less open-ended |
| Developer | sonnet / medium | code authoring baseline |
| QA — basic smoke | haiku / low | pass/fail + run a command |
| QA — adversarial / risky verify | sonnet / medium | surface-level passes aren't enough |

## Adjust
- **Step up** (model and/or effort): risk area (auth / payments / PII / migration / public API) · cross-cutting or many files · keywords like architecture / refactor / system-wide / i18n · the same worker failed this kind of task before (per memory) · the user already reworked it once.
- **Step down**: trivial single-file change, typo, a settled-plan execution with no open questions.
- When in doubt on something net-new or ambiguous, author at opus; faithful execution of a settled plan can sit at the floor.

## Effort follows the model
- haiku → low · sonnet → medium · opus → high.
- A step-up bumps effort one tier alongside the model (opus/high → opus/xhigh).
- `xhigh`/`max` are opus-only and reserved for the genuinely hardest single calls (net-new PRD, system architecture). Don't reach them via routine step-ups.

## Memory bias
Before routing, recall relevant lines from `docs/memory.md` → Learnings. If a kind of task has burned you at the floor before, start a notch higher. After a task that deviated from your estimate (needed escalation, got reworked), jot a one-line learning back to memory so the next pick is smarter. This is the lite replacement for the calibration log — same idea, one file, no separate ledger.

## User overrides (honor immediately)
- `/model <haiku|sonnet|opus>` — force the next dispatch's model.
- `/effort <low|medium|high|xhigh>` — force the next dispatch's effort.

## Trace
Announce each dispatch in one line (user lang): which worker, rough effort, why. Map effort words for the user: low="quick" · medium="balanced" · high="careful" · xhigh="very careful" · max="exhaustive".
