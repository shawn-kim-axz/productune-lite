# productune-lite PRD

> 살아있는 단일 SoT. 매 버전 이 파일을 제자리에서 다듬는다(git 이 버전 히스토리). GUI 는 이 파일을 직접 렌더한다.
> 현재 작성 버전: **v1.1**

---

## 이 제품은 무엇인가

**productune-lite** — 코드를 모르는 기획자를 위한, PO 판단으로 굴러가는 가벼운 제품 워크플로우. v1.0 출시됨. 이 레포가 곧 제품이며, "제품 변경" = productune-lite 의 **doctrine 마크다운**(페르소나별 habit / bookshelf 규칙 파일) 편집이다.

**lite 계약 (절대 위반 금지):** ticket 파일 없음 · phase-close gate 없음 · enforcement hook 없음 · migration 프레임워크 없음. 이 모든 것을 대체하는 단 하나 = **PO 의 판단**. 라이프사이클은 3개의 soft stage + 휴지 상태: **Define → Build → Ship** (+ idle).

---

## 누구를 위한 것인가 (target user)

- **1차 사용자 = 기획자(비개발자).** WHAT 은 알지만 HOW(코드)는 모른다. PO(`pdtl-po`)와 대화만 하고, PO 가 designer / developer / qa 를 오케스트레이션한다.
- **간접 사용자 = 워커 페르소나들**(designer / developer / qa). doctrine 를 읽고 행동한다. v1.1 변경분의 실제 "독자"는 이들의 habit / bookshelf 파일이다.

---

## 핵심 잡(core jobs to be done)

1. 아이디어 한 줄에서 **명확한 PRD** 로 수렴한다 (Define).
2. PRD 를 **작동하는 제품**으로 만든다 — user-facing 이면 디자인부터 (Build).
3. **실제로 배포·검증**하고 배운 것을 기억한다 (Ship).

v1.0 이 이 뼈대를 이미 굴린다. v1.1 은 각 stage 의 **품질 규율**을 full productune 에서 4개 이식한다 — 단, 전부 hook/gate/ticket 이 아니라 **PO 판단 트리거 + doctrine 실천**으로.

---

## v1.1 범위 — 이식할 4개 역량

> 공통 원칙: 각 역량은 full 의 *가치*만 가져오고 *강제 기계장치*는 버린다. 산출물은 항상 "PO/워커가 이제 무엇을 다르게 하는가"로 정의한다. hook/gate/ticket 을 새로 만들지 않는다.
> (역량 3·4 = DS 준수 점검 + 보안 점검은 하나의 라이프사이클 순간 — **Build→Ship readiness pass** — 로 묶어 서술한다.)

### 1. Define — PRD clarity loop (점수 rubric 기반 명확성 루프)

**무엇을 이식하나.** full 의 구조화된 clarity-loop 규율(빠짐없는 커버리지 + 가장 안 명확한 지점부터 한 번에 하나씩 질문하는 수렴 루프)을, **명확성 점수와 함께 되살려 이식한다** — full 의 `A = 1 − Σ(clarityᵢ × weightᵢ)`, ready 기준 `A ≤ 0.05`, weight 표, 차원별 clarity 점수. 단 성격은 hook/gate 가 아니라 **판단 rubric** — "감 대신 점수로 더 잘 판단"하는 도구다. 그리고 full 의 5-iter 는 **hard cap 이 아니라 soft 가이드**로 가져온다(PO 가 아무 때나 finalize).

**lite 형태 (점수 rubric + 커버리지 체크리스트).**
- designer(`pdtl-designer`)는 PRD 를 쓸 때 아래 커버리지 차원을 훑고 **각 차원의 clarity(0–1)를 매겨 `A` 를 계산**한다. 커버리지 체크리스트와 점수를 **함께** 쓴다 (체크리스트 = 무엇을 볼지, 점수 = 얼마나 명확한지).

  | 차원 | weight |
  |:--|--:|
  | 문제 & 대상 사용자 | 0.18 |
  | 핵심 잡(JTBD) / 원하는 결과 | 0.14 |
  | 범위 경계 (in / out / later) | 0.13 |
  | 수용 조건("done") | 0.12 |
  | 위험 & 가정 | 0.10 |
  | 성공 신호 (north star + input) | 0.09 |
  | 솔루션 형태(가설) | 0.08 |
  | 외부 의존 / 통합 | 0.06 |
  | 브랜드 / UX 방향 | 0.05 |
  | 운영 / GTM / 런칭 | 0.05 |

  (weight 는 기본값 — 프로젝트 성격에 안 맞으면 designer 가 조정 가능.)
- `A ≤ 0.05` 면 designer 가 `state:"ready"` + `ambiguity_score` 를 리턴. 아니면 **가장 낮은 clarity × 높은 weight 차원**을 골라 `needs_info` + 단일 `next_question`(한 번에 하나, ≤200자). PO 가 사용자 언어로 릴레이 → 답 받아 designer resume.
- **5-iter 는 soft 가이드**(full 의 hard cap 아님) — 대략 이쯤이면 수렴됐거나 남은 건 열린 질문이라는 신호일 뿐, PO 는 **아무 때나 finalize** 로 마감할 수 있다. finalize 시 미해결분은 PRD `## 열린 질문`으로 내림.
- **수렴 판정 = PO 가 점수를 읽고 판단.** `A ≤ 0.05` 는 designer 의 ready 신호지 자동 전환이 아니다 — PO 가 점수를 참고해 Build 이동을 판단(사용자 확인)하고, 필요하면 점수와 무관하게 finalize override.

**PO/워커가 이제 다르게 하는 것.** designer 는 즉흥 인터뷰 대신 10개 차원에 clarity 점수를 매겨 가장 약한 곳부터 한 번에 하나씩 캔다. PO 는 "PRD 충분한가?"를 **감이 아니라 `A` 점수 + 차원별 clarity 로** 판단하고, 언제든 finalize override.

**no-hook/no-gate 준수.** lite 는 hook 이 없으니 점수는 **무엇도 강제하지 않는다** — `A ≤ 0.05` 도, 5-iter 도 자동 전환/차단을 안 한다. 점수는 designer 가 계산하고 PO 가 읽는 **판단 rubric**일 뿐, PO 가 finalize 로 언제든 override. auto-ticket 발행 없음. `needs_info` 는 v1.0 부터 있던 판단 릴레이 그대로.

---

### 2. Build (design step) — 디자인 시스템 → 하이파이 (순차, 사용자 승인 후)

**무엇을 이식하나.** full P2 체인의 S1(디자인 시스템 제안)+S5(하이파이 목업)의 *가치* — user-facing 작업에서 토큰 잡힌 DS 를 **먼저 사용자에게 보여 승인받고**, 그 위에 실제 렌더된 하이파이를 얹는다. full 의 5-스텝 gated 체인(S1→S5), 스텝별 hook gate, branch A/B/C 티켓 분류, design ticket 발행은 **버린다** — 순서와 3안 뽑는 *기준*만 가져오고 기계장치는 안 가져온다.

**lite 형태 (순차 + 사용자 방향 분기).**
- PO 가 user-facing UI 를 Build 할 때, developer 앞단에 designer 를 dispatch. 순서는 **반드시 순차**:
  - **① 디자인 시스템 목업(들)을 먼저 렌더해 사용자에게 보여준다.** `docs/artifacts/<slug>/design-system-*.html` 로 실제 렌더(토큰/타입/스페이싱/핵심 컴포넌트가 눈에 보이게 적용된 진짜 쇼케이스, 산문 아님).
  - **② 사용자 승인/선택.** 이게 lite 의 load-bearing fork 확인 지점 — 승인 전엔 하이파이로 안 간다.
  - **③ 승인된 방향으로 하이파이 목업** `docs/artifacts/<slug>.<ext>`(인터랙티브는 HTML 선호) + `docs/design.md` 에 확정 DS(토큰·핵심 컴포넌트·근거) 기록.
- **사용자 방향 분기 (① 단계에서):**
  - 사용자가 **원하는 디자인/방향이 있으면**("이 디자인으로 해줘" / 브랜드 가이드 제공) → **3안 생략**, 그 방향으로 **DS 목업 1개**만 세워 보여준다.
  - **딱히 없으면** → **DS 3안**을 렌더해 보여주고 사용자가 고른다.
- **3안 뽑는 기준 = productune S1 규율을 lite 로 반영** (`phase2-3-ticket-sequence.md` S1 요지):
  - **3-mix: A·B = Fit anchor · C = 웹서치 divergence.** A·B 는 `style-library/index.md`(인덱스만 참조, 라이브러리 통째 읽지 않음)에서 mood 에 맞는 Fit anchor 를 골라 **적응**(팔레트/타입/radius 재유도, 클론 아님). C 는 인덱스를 우회해 해당 표면/오디언스의 라이브 디자인 landscape 를 웹서치해 **진짜 새 방향**으로 발산(A·B 와 눈에 띄게 달라야 함).
  - **mood brief 먼저.** PRD 에서 표면 유형(대시보드/리딩/마케팅/툴) · 오디언스 온도 · mood 형용사 3–5 · 브랜드 제약을 도출한 뒤 anchor 를 고른다. 2개 미만이면 질문 하나로 채우고, 아니면 멈추지 않는다.
  - **famous-brand cap ≤1.** 3안 중 top-tier 디폴트(linear/stripe/vercel/claude/notion/airbnb 급)는 최대 1개.
  - **divergence rule.** 3안 중 **어느 둘이든 4개 mood label(`light|dark · minimal|rich · playful|serious · editorial|chrome`) 중 ≥2 가 다르다.** 폰트·컴포넌트 셰이프·레이아웃도 눈에 띄게 달라야("색만 다른 같은 안" 금지).
  - **렌더 요건.** 지정 폰트 실제 로드(bare `-apple-system` 금지), anti-default 패스, 게이트 전 render-verify. anti-default 크래프트 바: 진짜 시각 위계 · 일관 토큰 · 접근 대비 · generic AI-default 룩 금지.
- 브랜드 에셋(logo / favicon / og:image)은 확정 DS 에서 파생. Claude 는 이미지 생성 모델이 없으므로 → 필요 시 designer 가 `external_tool_recommendation`(ChatGPT/Gemini 프롬프트 + expected path, 항상 영어)으로 핸드오프하고 돌아온 PNG 를 다듬는다(직접 SVG 는 최후).
- **거부는 정규 판단 루프.** 사용자가 3안/1안을 거부하면 PO 가 짧은 interview 후 designer 재dispatch(거부된 방향은 다음 라운드에서 회피). gated 스텝 재진입이 아니다.

**PO/워커가 이제 다르게 하는 것.** v1.0 designer habit 은 "디자인 유지 + 목업"만 말한다. v1.1 은 user-facing 진입 시 **DS 를 먼저 보여 승인받고 그다음 하이파이**로 가는 순차 실천, 그리고 사용자 방향 유무에 따라 **1안/3안 분기**를 못 박는다. 3안을 뽑을 땐 designer 가 mood brief → Fit anchor(A·B) + 웹서치 divergence(C) + famous-cap + divergence rule 을 규율로 따른다.

**no-hook/no-gate 준수.** DS→하이파이 사이의 사용자 승인은 lite 의 **load-bearing fork 확인**(판단/컨펌)이지 hook 게이트가 아니다. S1–S5 스텝 게이트 없음, branch A/B/C 티켓 분류 없음, design ticket 발행 없음. productune 은 **3안 기준**만 참조 — 기계장치(게이트/티켓/branch 분류)는 가져오지 않는다. "언제 이 순차를 거나"는 PO 판단(minor tweak 이면 생략 가능).

---

### 3+4. Build → Ship 전환 — readiness pass (준수 점검 + 보안 점검)

역량 3(DS 준수 점검)과 역량 4(보안 점검)를 **하나의 라이프사이클 순간**으로 묶는다: **Build → Ship 전환 시 PO 가 표준으로 돌리는 readiness pass.** 두 점검을 이 한 지점에 붙여, 아무 때나 즉흥으로 떠올리는 대신 stage 경계에서 빠짐없이 돌게 한다.

**성격 — hook 게이트와 순수 즉흥판단 사이의 중간.** readiness pass 는 **아무것도 막지 않는다**(hook/gate 아님) — PO 가 어떤 점검을 N/A 로 판단하면 `docs/memory.md` 한 줄로 스킵 가능. 하지만 stage 경계에 **묶여 있어서** ad-hoc 판단보다 안 까먹는다. soft ritual 이지 no-waiver gate 가 아니다.

#### ① DS 준수 점검 (conformance check) — user-facing 이면

**무엇을 이식하나.** full P3 close-gate 의 디자인 컴플라이언스 + anti-default 미학 점검의 *가치* — 빌드가 DS 를 따랐는지, 하이파이와 맞는지 검증. full 의 mandatory·no-waiver hook gate 성격은 **버린다**.

- Ship 진입 시 user-facing 작업이면 PO 가 이 점검을 dispatch — **designer 또는 QA**(어디에 실을지는 PO 판단). 점검 항목:
  - **DS 일관성** — color/spacing/typography 토큰이 `docs/design.md` 와 일치. off-spec 없음.
  - **타이포** — 지정 폰트/스케일. 시스템 디폴트 아님.
  - **컬러** — 브랜드 팔레트. critical UI 에 off-palette / Tailwind 디폴트 없음.
  - **스페이싱** — DS 토큰. critical 레이아웃에 매직넘버 px 없음.
  - **에셋** — logo 존재+참조 · favicon · og:image · 메타태그(title/description/OG).
  - **하이파이 일치** — 빌드가 하이파이 목업과 맞는가. (하이파이 없으면 이 항목만 N/A, 나머지는 계속 검증.)
  - **anti-default 미학** — entry/critical 화면에 generic AI-slop 룩 아님. 차분한 면에 억지 시그니처도 감점.
- **문제 발견 시 = 정규 판단 루프.** PO 가 fix 슬라이스 → developer patch → 재점검. waiver 개념 대신 **PO 가 무엇을 봐줄지 판단**(예: 내부 도구는 미학 문턱 완화), 봐준 항목은 `docs/memory.md` 에 한 줄.

#### ② 보안 점검 (security check) — 표면 조건부 세트

**무엇을 이식하나.** full 의 6항목 보안 체크리스트의 *가치* — secrets · deps audit · data-exposure · dist-integrity 등. full 의 waivable close-gate 성격과 Electron 고정은 **버린다** — **lite 로 만드는 제품의 표면은 확정되지 않고 다양하다**(웹·데스크톱·CLI 등).

- Ship 진입 시(배포 직전) PO 가 이 점검을 QA(`pdtl-qa`) 에 dispatch. "6개 고정 리스트"가 아니라 **표면에 맞춰 PO 가 매번 적용/N/A 를 판단하는 세트** — 각 항목 "해당 표면일 때만":
  1. **secrets** *(대개 공통)* — 소스/빌드/dist 에 하드코딩 크리덴셜·키·토큰 없음. 민감값 런타임 주입.
  2. **deps** *(패키지 매니저 표면)* — `npm/pnpm audit` high/critical 미해결 없음(또는 triage+근거). 락파일 정합.
  3. **data-exposure** *(대개 공통)* — PII/민감 데이터 과수집·로그·전송 없음.
  4. **dist-integrity** *(배포 산출물 있는 표면)* — dist 가 정규 빌드에서 재현. 지원 시 서명/체크섬, 아니면 known-gap 기록.
  5. **entry-surface (CSP·헤더)** *(웹/브라우저 진입 표면)* — CSP 과도 개방(`unsafe-*` wildcard) 아님.
  6. **platform-hardening** *(데스크톱/Electron 등 네이티브 표면)* — `contextIsolation:true` · `nodeIntegration:false` · IPC 명시·검증 등.
- **표면 판단은 PO 가 매번.** 실제 표면 보고 적용/N/A 결정(예: 순수 CLI → entry-surface/platform-hardening N/A). 6개는 완결 리스트가 아니라 **출발 세트** — 표면이 새 위험(서버 인증/결제)을 부르면 PO 가 항목 추가 판단.
- **문제 발견 시 = Ship-내부 패치 루프**. fix 슬라이스 → developer patch → 재배포/재점검. `stage:"ship"` 유지, Build 로 안 돌아감. 실질 패치는 `docs/memory.md` 기록.
- env 한계 실패(제품 결함 아님)는 수동 fallback + 노트, `fail` 아님.

**PO/워커가 이제 다르게 하는 것.** v1.0 은 QA 가 기능만 보고 Ship 은 live 검증만 말한다. v1.1 은 **Build→Ship 전환에서 PO 가 readiness pass 를 표준으로 돌린다** — user-facing 이면 DS 준수 점검(designer/QA) + 표면 조건부 보안 점검(QA)을 한 지점에서 dispatch 하고, drift 는 patch 루프로, 보안 이슈는 Ship-내부 루프로 잡는다.

**no-hook/no-gate 준수.** readiness pass 는 stage 경계에 묶인 **soft ritual** — hook 검증 아님, "no open ✗ 없이는 close 금지" 강제 아님, waivable gate step 도 아님. "언제 도나 · 무엇이 N/A 인가 · 무엇을 봐주나"는 전부 PO 판단, N/A 는 memory 한 줄로 스킵. ticket 없이 dispatch + return envelope, 배포 결정은 PO+사용자 확인.

---

## non-goals (v1.1 이 하지 않는 것)

- ticket 파일 / phase-close gate / enforcement hook / migration 프레임워크 신설 — lite 계약 위반.
- 5-스텝 gated 디자인 체인(S1–S5), branch A/B/C 분류, design ticket 발행.
- no-waiver mandatory 게이트, tier-memory 기계장치. (readiness pass 는 **soft ritual** 이지 no-waiver gate/hook 이 아님 — PO 가 N/A 스킵 가능. 점수 rubric 도 **판단 도구**이지 자동 전환/차단 아님.)
- lite 를 heavy productune 으로 만들기. lite 는 lite 로 남는다.

> (참고: 이전 draft 는 "점수 수학 도입 거부"를 non-goal 로 뒀으나 v1.1 확정으로 **뒤집혀** 역량1 에 점수 rubric 을 도입한다. 강제 iter hard cap 은 여전히 도입 안 함 — 5-iter 는 soft 가이드.)

---

## v1.1 "done" 의 모습

이식 4개가 각각 **doctrine 마크다운 편집**으로 반영되고, 실행 시 아래가 관찰된다:

1. **Clarity loop (점수 rubric)** — `doctrine/designer/habit.md`(PRD 섹션)에 명확성 점수 `A = 1 − Σ(clarityᵢ × weightᵢ)` + weight 표 + 커버리지 차원이 **판단 rubric** 으로 들어감. designer 가 차원별 clarity 를 매겨 `A` 계산 + 가장 약한 곳부터 `needs_info` 단일 질문. PO 는 `A` 점수(ready 기준 `A ≤ 0.05`)를 읽어 수렴 판단하되 언제든 finalize override. 5-iter 는 soft 가이드지 hard cap 아님.
2. **디자인 시스템 → 하이파이 (순차)** — `doctrine/designer/habit.md` + `doctrine/po/bookshelf/lifecycle.md`(Build)에 "user-facing 진입 시 ① DS 목업 먼저 보여주고 → ② 사용자 승인 → ③ 하이파이" 순차 실천이 명문화. 사용자 방향 유무로 1안/3안 분기, 3안은 mood brief → Fit anchor(A·B) + 웹서치 divergence(C) + famous-cap ≤1 + divergence rule 규율로 뽑음. 실행 시 DS 목업 아티팩트 → (승인) → `docs/artifacts/<slug>` 하이파이 + `docs/design.md` 확정 DS 순으로 나옴.
3+4. **Ship 진입 readiness pass** — `doctrine/designer/habit.md` + `doctrine/qa/habit.md` + `doctrine/po/bookshelf/lifecycle.md`(Build→Ship 전환)에 **PO 가 표준으로 돌리는 readiness pass** 가 명문화: user-facing 이면 ① DS 준수 점검(designer 또는 QA, drift → patch 루프) + ② 표면 조건부 보안 점검(QA, 이슈 → Ship-내부 패치 루프). stage 경계에 묶인 **soft ritual** — PO 가 N/A 판단 시 memory 한 줄로 스킵, 아무것도 강제로 막지 않음이 doctrine 에서 확인됨.

그리고 **전 항목이 hook/gate/ticket 없이** 순수 PO 판단 + doctrine 실천으로 표현됐음이 각 doctrine 편집에서 확인된다(위 "no-hook/no-gate 준수" 문단이 수용 기준).

lite 의 3-stage 정체성(Define→Build→Ship + idle)과 "판단이 강제를 대체한다"는 계약이 v1.1 후에도 그대로 성립하면 done.

---

## 확정 사항 · 가정

- **확정: lite 로 만드는 제품의 표면은 다양하다**(웹·데스크톱·CLI 등 뭐든). → 역량4 보안 점검은 고정 6항목이 아니라 **표면 조건부 세트**로, PO 가 매번 적용/N/A 를 판단한다. (표면 관련 열린 질문 닫힘.)
- **확정: 역량3 준수 점검 주체** = PO 가 Build 시 designer 또는 QA 로 판단해 실음(고정 안 함).
- (가정) conformance/security 의 "무엇을 봐주나"(waiver 대체)는 PO 판단 + `docs/memory.md` 한 줄 기록으로 표현 — lite 에 waiver 필드/기계장치를 신설하지 않음.
- (가정) PRD 는 사용자가 직접 읽으므로 고정 템플릿 없이 한국어로, `versions/` 는 건드리지 않음(git 이 버전 히스토리).

## 열린 질문

- (현재 없음.)
