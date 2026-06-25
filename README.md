# productune-lite

> productune의 가벼운 형제. **PO가 자율적으로 판단해서 lifecycle을 진행하는** 1인 기획자용 dev-workflow 도구.

`productune-lite` 한 줄로 시작해서 **Define → Build → Ship** 3-stage를 PO + 3명의 worker 페르소나가 함께 돌립니다. 복잡한 ticket·tier memory·phase close gate 없이, PO의 판단이 그 자리를 대신합니다.

```
사용자 ─한 문장─▶ productune-lite (PO orchestrator, opus)
                     │
                     ├── pdtl-designer   → PRD / UX / Design / (회고)
                     ├── pdtl-developer  → 구현
                     └── pdtl-qa         → 검증
                                          │
                                          └─ worker는 session 시작에 doctrine 주입받음
                                             (common + 자기 habit). PO는 PO habit +
                                             bookshelf + 프로젝트 memory/state 주입.
```

## productune와 무엇이 다른가

`productune-lite`의 철학은 한 문장입니다: **"hook이 강제하던 기계장치 → PO의 자율 판단."**

| | productune (full) | productune-lite |
|---|---|---|
| 라이프사이클 | 5-phase, 경계마다 hook-enforced gate | **3 soft stage** (Define→Build→Ship), PO가 판단해서 진행 |
| 작업 단위 | ticket 파일 + frontmatter + worktree/branch + lint hook | **ticket 없음** — `current_task` + 한 줄 brief |
| Phase close gate | P3 4단계 gate를 hook이 phase write 차단하며 강제 | **gate 없음** — PO가 "충분한가" 판단 |
| 메모리 | 4-tier doctrine + 3-tier work memory + promotion gate + SoT/mirror 동기화 | **`docs/memory.md` 단일 파일** PO 큐레이팅 |
| 페르소나 doctrine | 전원 habit + bookshelf | **PO만 habit + bookshelf**, worker는 단일 habit |
| Hooks | ~18개 (3,157줄) — 결정론적 강제 | **1개** — session 시작 doctrine 주입뿐 |
| 마이그레이션 | config.json `schema_v` + migration 프레임워크 | **없음** — 설치 = doctrine 미러 + 심볼릭 링크 |
| 설치 | install.sh (skill 설치·GUI·hook 8종 merge 등) | install.sh (doctrine 미러 + agent 링크 + hook 1개 + PATH) |

namespace가 분리되어 (`pdtl-*` 에이전트 / `~/.productune-lite/` 미러 / `.productune-lite/` 프로젝트 상태) **기존 productune 설치와 충돌하지 않습니다.** 한 머신에 둘 다 둘 수 있습니다.

## 누구를 위한 도구인가

- 코드는 직접 짜지 않지만 무엇을 만들지 정의할 수 있는 1인 기획자 / PM
- 무거운 ceremony 없이 PO에게 위임하고 결과만 확인하고 싶은 사람
- 시니어 개발자/기획자에겐 full `productune`이 더 맞습니다 — lite는 의도적으로 덜어낸 버전입니다

## 3-stage lifecycle (PO 판단, gate 없음)

```
Define          Build                     Ship                       (idle)
  │               │                         │                           │
  ├ PO 인터뷰     ├ PO가 PRD를 다음 chunk로  ├ 배포(또는 N/A)            └ 출시 후
  ├ designer가    │  슬라이스 (ticket 없음)  ├ 라이브 검증 (prod 스모크)    다음 스코프
  │  PRD 작성     ├ designer 디자인          │   ↓ 버그?                    대기
  │  (clarity     ├ developer 구현           ├ 패치 루프 (dev→재배포→재검증) (work 자동
  │   loop math   ├ qa 검증 (dev↔QA 루프)    │   stage=ship 유지            생성 금지)
  │   없음)       │                          ├ 회고 → docs/memory.md       │
  └ PO가 "충분"   └ PO가 "core 동작" 판단    └ stage=idle                  └ 새 스코프 오면
     판단 → Build      → Ship                                                v<n+1> Define
```

`Define → Build → Ship`을 한 번 돈 게 한 **버전**(`v1`, `v2`, …). 출시 후 다음 스코프가 없으면 `stage=idle`로 쉬고, 스코프 없이 v2를 미리 열어 일거리를 만들지 않습니다 (lite 계약).

**Ship은 배포로 끝나지 않습니다.** 라이브 환경에서 실제 동작(env·health·핵심 경로)을 검증하고 — 로컬 green이 배포본 동작을 증명하지 않으므로 — 라이브 검증이 버그를 잡으면 **Build 재개가 아니라 Ship 내부 패치 루프**(patch→재배포→재검증, `stage=ship` 유지)로 처리합니다. fix가 진짜 새 스코프로 커지면 그때 다음 버전을 엽니다.

PO는 **load-bearing fork**(Build 진입·배포 전·되돌리기 힘든 작업·shipped 결정과 충돌)에서만 사용자에게 확인하고, 나머지(라우팅·다음 chunk·worker 호출·QA 루프·Ship 패치 루프)는 알아서 진행합니다.

## 메모리 — `docs/memory.md` 단일 파일

tier memory 전체를 한 파일이 대체합니다. PO가 큐레이팅하며 4개 섹션:

- **Decisions** — 확정된 제품/아키텍처 결정 (이후 충돌하는 요청은 PO가 flag + 확인)
- **Preferences** — 사용자 작업 선호 (톤·물어볼 것 vs 그냥 할 것)
- **Project facts** — 안정적 사실 (스택·배포 타겟·제약·외부 계정)
- **Learnings** — 라우팅/품질 교훈 (어떤 작업이 어떤 model tier가 필요한지 = 라우팅 bias)

promotion gate·tier·cross-project store 없음. 큰 결정만 사용자 확인 후 기록, 작은 라우팅 노트는 PO가 바로 append.

## 설치

```sh
# 의존성: jq, claude CLI (없으면 npm i -g @anthropic-ai/claude-code)
git clone <this-repo> productune-lite
bash productune-lite/scripts/install.sh
# → doctrine 미러(~/.productune-lite/) + agent 심볼릭 링크 + SessionStart hook 1개 + PATH
```

clone 위치는 자유 (심볼릭 링크 타겟이라 유지만 하면 됨). 단 `~/.productune-lite/`와 겹치지 않게.

## 사용

```sh
cd ~/my-product
productune-lite            # 첫 실행 시 프로젝트 init(.productune-lite/ + docs scaffold) 후 PO 실행
productune-lite install    # 설치 재실행 (doctrine 갱신)
productune-lite --help
```

첫 실행이 만드는 것:

```
.productune-lite/
├── config.json            # slug, created_at
└── po-state.json          # { schema_version, stage, version, current_task }
docs/
├── memory.md              # 단일 메모리 (PO 큐레이팅)
├── prd/PRD.md             # designer 작성
└── artifacts/             # 사용자 검토용 산출물 (mockup 등)
briefs/                    # current_task 진행 노트 (한 줄)
```

PO에게 한 문장으로 무엇을 만들지 말하면 됩니다. 예: `"비개발자가 AI로 앱을 만드는 노코드 툴"`.

## 페르소나 / 라우팅

| 페르소나 | 역할 | 기본 |
|---|---|---|
| **pdtl-po** | 오케스트레이터 (저자 X) | opus |
| **pdtl-designer** | PRD / UX / Design | opus (PRD·net-new) → sonnet (incremental) |
| **pdtl-developer** | 구현 | sonnet |
| **pdtl-qa** | 검증 | haiku (basic) → sonnet (grill/risk) |

PO가 복잡도·리스크·`docs/memory.md` 교훈으로 model×effort를 조정. 사용자 override: `/model <tier>`, `/effort <level>`.

## 구조

```
productune-lite/
├── agents/                          # ≤10줄 thin pointer (→ ~/.claude/agents/)
│   └── pdtl-{po,designer,developer,qa}.md
├── doctrine/
│   ├── common/habit.md              # worker 공통 (designer/dev/qa)
│   ├── po/
│   │   ├── habit.md                 # PO brain
│   │   └── bookshelf/               # lifecycle · delegation · routing · memory
│   ├── designer/habit.md
│   ├── developer/habit.md
│   └── qa/habit.md
├── scripts/
│   ├── install.sh · uninstall.sh · productune-lite
│   └── hooks/session-start-doctrine.sh   # 유일한 hook
└── README.md
```

## 검증 상태 — **v1.0**

**격리 VM smoke test 통과 (2026-06-25, v1.0).** 깨끗한 macOS VM(CUA/lume, claude만 설치)에서 전부 헤드리스로 `install.sh` → 프로젝트 init → 풀 dogfood(단일 HTML 디지털 시계)를 Define→Build→Ship→idle 자율 완주. 확인된 것:

- clean 머신에서 install(doctrine 미러·agent 링크·hook·PATH) → 4 페르소나 정상 동작(designer/developer/qa 실제 subagent 위임), PO(opus)는 직접 저작 없이 오케스트레이션만
- load-bearing fork(Build 진입 등)도 무인 모드에서 자율 통과 → 출시 후 `stage=idle`(lite 계약)
- 산출물: `clock.html` · PRD · `v1` 브랜치 커밋 · `docs/memory.md` 회고 큐레이팅 (8 FR PASS, 결함 0, dev↔QA 재시도 0)

그 smoke test가 잡아낸 결함 1건을 v1.0에 패치: **PRD 경로 일탈** — PO가 dispatch `[ctx]`에서 `prd_path`를 누락 → designer가 정규 `docs/prd/PRD.md` 대신 `docs/prd-v1-*.md`를 지어냄. 수정: designer habit이 `prd_path` 유무와 무관하게 **항상 `docs/prd/PRD.md`** 를 쓰도록, delegation이 ctx **shape**(특히 `prd_path`·`user_lang`)를 임의로 떨구지 않도록 명문화.

초기 dogfood 1회 완주 (2026-06-24) — 작은 제품(단일 HTML 카운트다운)으로 Define→Build→Ship 전체를 자율 진행. 확인된 것:

- doctrine 주입 → 4 페르소나 정상 동작, PO는 산출물 직접 저작 없이 전부 위임
- **세션 일회용 / po-state 재오리엔트** — 세션이 중간에 끊긴 뒤 새 PO가 `po-state.json` + `docs/memory.md`만으로 깔끔히 이어받아 마무리
- gate 없는 자율 stage 진행 + 단일 `docs/memory.md` 큐레이팅 (Decisions/Facts/Learnings)

그 과정에서 PO가 보고한 doctrine 모호점 4건을 반영: `idle` 휴지 stage 명문화 · po-state 정규 shape 문서화 · git 브랜치/커밋 타이밍 규칙 · brief vs memory 역할 분담.

## 제거

```sh
bash productune-lite/scripts/uninstall.sh   # agent·hook·PATH·~/.productune-lite 제거
# 프로젝트의 docs/ · .productune-lite/ 는 건드리지 않음 (작업물 보존)
```
