# Career AI Agent

멀티 에이전트 기반 커리어 관리 시스템입니다.
이력서 생성, 팩트체크, 기술 면접 시뮬레이션, 채용 시장 분석을 하나의 시스템으로 관리합니다.

## 왜 만들었나?

LLM으로 이력서를 쓰면 문장은 그럴듯하지만 수치를 지어내고, 맥락은 빠지고, 톤은 중구난방입니다.
이 프로젝트는 **멀티 에이전트 + 코드 기반 팩트체크**로 이 문제를 해결합니다.

## 아키텍처

```
사용자
  │
  ▼
CLAUDE.md (부트스트랩)
  │
  ├─ 메인 세션 (Career Advisor — 오케스트레이터)
  │   │
  │   ├─ .claude/agents/ (5개 커스텀 서브에이전트)
  │   │   ├─ career-resume-writer   [opus]    이력서 작성
  │   │   ├─ career-fact-checker    [sonnet]  팩트체크 (Write 없음)
  │   │   ├─ career-interview-coach [opus]    면접+코딩 코치
  │   │   ├─ career-market-analyst  [sonnet]  시장분석 (WebSearch)
  │   │   └─ career-capability-assessor [opus] 역량평가
  │   │
  │   ├─ 단일 에이전트 커맨드
  │   │   ├─ /draft-resume      → career-resume-writer
  │   │   ├─ /verify-resume     → career-fact-checker
  │   │   ├─ /research-company  → career-market-analyst (WebSearch)
  │   │   └─ /mock-interview    → career-interview-coach
  │   │
  │   ├─ 병렬 에이전트 커맨드
  │   │   ├─ /review-resume     → 3중 병렬 (writer+checker+analyst)
  │   │   ├─ /multi-review      → 3관점 (HR+TechLead+CultureFit)
  │   │   ├─ /batch-analyze-jd  → N개 JD 동시 분석
  │   │   └─ /assess-capability → haiku(수집) → opus(분석)
  │   │
  │   └─ 파이프라인 커맨드
  │       └─ /pipeline-resume   → 초안→검증→리뷰→수정 자동화
  │
  ├─ Claude Code Hooks (.claude/hooks/) — 코드 레벨 강제화
  │   ├─ post-write-outcome.sh          outcome/ 작성 후 자동 검증
  │   ├─ validate-outcome-filename.sh   파일명 규칙 자동 검증
  │   ├─ post-write-suggestion-check.sh 제안 섹션 포함 여부 리마인더
  │   ├─ pre-git-commit.sh             이슈 번호(#N) 필수 강제
  │   ├─ pre-git-push.sh              main 직접 push 차단
  │   └─ pre-edit-profile.sh           프로필 수정 전 자동 백업
  │
  └─ 검증 스크립트 (scripts/)
      ├─ extract-metrics.sh             수치 자동 추출
      ├─ check-evidence.sh              증거 대조
      ├─ validate-resume.sh             최종 검증
      ├─ validate-evidence-refs.sh      evidence 참조 검증
      ├─ validate-coding-log.sh         코딩테스트 로그 검증
      └─ git pre-commit hook            커밋 시 자동 게이트
```

## 핵심 차별점

### 1. 실제 멀티 에이전트 구조
`.claude/agents/`에 5개 커스텀 에이전트가 독립된 모델/도구/권한을 가집니다.
opus(글쓰기/코칭) / sonnet(검증/분석) / haiku(데이터 수집)으로 모델 티어링.
career-fact-checker는 Write 권한 없음 (소스 오염 방지 샌드박스).

### 2. 코드 기반 팩트체크
프롬프트가 아닌 스크립트로 수치를 추출하고 증거와 대조합니다.
git pre-commit hook으로 검증 안 된 이력서는 커밋을 차단합니다.

### 3. 능동적 자기 발전
시스템이 스스로 개선점을 찾아 제안합니다.
반복 작업은 `/create-command`로 새 커맨드로 내재화됩니다.

### 4. 범용 프레임워크
개인정보가 구조에 포함되지 않습니다.
`src/user-profile.md`에 본인 데이터를 넣으면 누구나 사용할 수 있습니다.

## 시작하기

### 1. 클론 & 초기 설정
```bash
git clone https://github.com/choi1204/career-ai-agent.git
cd career-ai-agent
chmod +x scripts/*.sh
./scripts/setup-hooks.sh
```

### 2. 프로필 작성
`src/user-profile.md`를 본인 경력으로 채우세요.

### 3. 프로젝트 등록
```
claude
> /intake-project
```

### 4. 이력서 생성
```
> /draft-resume
> /verify-resume
> /review-resume
> /refine-resume
```

### 5. 면접 & 코딩테스트 준비
```
> /mock-interview
> /coding-test
```

### 6. 종합 역량 평가
```
> /assess-capability
```

## 커맨드 목록

### 이력서 파이프라인
| 커맨드 | 설명 | 서브에이전트 |
|--------|------|------------|
| `/draft-resume` | 이력서 초안 3버전 생성 | career-resume-writer |
| `/verify-resume` | 팩트체크 (환각 제거) | career-fact-checker |
| `/review-resume` | 다관점 리뷰 (병렬 3중) | writer+checker+analyst |
| `/refine-resume` | 최종본 생성 | career-resume-writer → fact-checker |
| `/pipeline-resume` | 전체 파이프라인 자동화 | 전체 에이전트 |
| `/multi-review` | HR+TechLead+CultureFit 동시 리뷰 | 3에이전트 병렬 |

### 면접 & 코딩테스트
| 커맨드 | 설명 | 서브에이전트 |
|--------|------|------------|
| `/mock-interview` | 기술 면접 시뮬레이션 (L1~L5) | career-interview-coach |
| `/coding-test` | 코딩테스트 연습/모의시험/취약분석 | career-interview-coach |

### 역량 평가 & 분석
| 커맨드 | 설명 | 서브에이전트 |
|--------|------|------------|
| `/assess-capability` | 종합 역량 평가 (강점/약점 + 로드맵) | haiku → capability-assessor |
| `/analyze-jd` | 채용공고 분석 + 매칭률 | career-market-analyst |
| `/batch-analyze-jd` | 복수 JD 병렬 분석 + 비교 매트릭스 | market-analyst x N |
| `/research-company` | 기업 리서치 (실시간 웹검색) | career-market-analyst |

### 데이터 관리
| 커맨드 | 설명 |
|--------|------|
| `/intake-project` | 새 프로젝트 체계적 등록 |
| `/update-profile` | 프로필 개선 |

### 시스템 관리
| 커맨드 | 설명 |
|--------|------|
| `/report-issue` | 문제/개선 아이디어를 GitHub Issue로 등록 |
| `/fix-issue` | Issue 기반 브랜치 → 수정 → PR 자동화 |
| `/create-command` | 새 커맨드 생성 (메타) |

## 팩트체크 파이프라인

```
이력서 수치 → extract-metrics.sh (자동 추출)
                    ↓
             check-evidence.sh (증거 대조)
                    ↓
              검증 태그 부착
         ✅ VERIFIED / 📝 SELF_REPORTED
         ⚠️ UNVERIFIED / ❌ CONFLICT / 🔍 EXAGGERATED
                    ↓
             validate-resume.sh (최종 검증)
                    ↓
              git pre-commit hook (자동 게이트)
```

## 면접 깊이 모델

| 레벨 | 유형 | 예시 | 평가 |
|------|------|------|------|
| L1 | What | "무엇을 했나요?" | 기초 |
| L2 | Why | "왜 그 기술을 선택했나요?" | 양호 |
| L3 | Alternative | "다른 방법은?" | 우수 |
| L4 | Tradeoff | "트레이드오프는?" | 탁월 |
| L5 | Retrospective | "다시 한다면?" | 시니어급 |

## 종합 역량 평가

`/assess-capability`는 축적된 모든 데이터를 분석하여 7개 차원으로 평가합니다:

| 차원 | 데이터 소스 |
|------|-----------|
| 기술 역량 | 프로젝트 기술 스택 + 면접 L레벨 |
| 문제 해결 | 프로젝트 도전/해결 + 면접 L3~L5 + 코딩테스트 |
| 시스템 설계 | 아키텍처 경험 + 트레이드오프 이해도 |
| 커뮤니케이션 | 이력서 가독성 + 면접 구조화 |
| 임팩트/성과 | 정량적 성과 + 비즈니스 기여도 |
| 성장 가능성 | 회고 품질 + 학습 패턴 |
| 시장 적합성 | JD 매칭률 + 기술 트렌드 |

결과물: 강점/약점 분석 + 즉시/단기/중기/장기 개선 로드맵

## 코딩테스트 준비

`/coding-test`는 4가지 모드를 지원합니다:

| 모드 | 설명 |
|------|------|
| practice | 유형/난이도별 연습 (힌트 단계 제공) |
| exam | 실전 모의시험 (3~4문제, 120분) |
| review | 기존 풀이 리뷰 + 최적화 |
| analyze | 풀이 이력 기반 취약 유형 분석 |

## Claude Code Hooks

프롬프트가 아닌 코드 레벨에서 규칙을 강제합니다 (`.claude/settings.json` + `.claude/hooks/`).

| Hook | 이벤트 | 동작 | 방식 |
|------|--------|------|------|
| `post-write-outcome.sh` | PostToolUse (Write\|Edit) | outcome/ 파일 작성 후 검증 스크립트 자동 실행 | 리마인더 |
| `validate-outcome-filename.sh` | PostToolUse (Write\|Edit) | 파일명 규칙 `{type}_v{N}_{YYYYMMDD_HHmmss}.md` 검증 | 리마인더 |
| `post-write-suggestion-check.sh` | PostToolUse (Write\|Edit) | outcome/ 산출물에 "제안" 섹션 포함 여부 체크 | 리마인더 |
| `pre-git-commit.sh` | PreToolUse (Bash) | 커밋 메시지에 이슈 번호 `#N` 필수 | 차단 |
| `pre-git-push.sh` | PreToolUse (Bash) | main/master 직접 push 차단 | 차단 |
| `pre-edit-profile.sh` | PreToolUse (Write\|Edit) | user-profile.md 수정 전 자동 백업 | 투명 |

### 다른 프로젝트에 재사용 가능한 Hooks

아래 Hooks는 career-ai-agent에 종속되지 않아 다른 Claude Code 프로젝트에서도 복사하여 사용할 수 있습니다:

- **`pre-git-commit.sh`** — 커밋 메시지에 이슈 번호 강제 (Issue → Branch → PR 워크플로우)
- **`pre-git-push.sh`** — main 브랜치 직접 push 차단
- **`validate-outcome-filename.sh`** — 파일명 규칙 검증 (정규식만 변경하면 됨)

## GitHub Issues 기반 개선 워크플로우

```
문제 발견 → /report-issue → GitHub Issue 생성
                                    ↓
              /fix-issue {번호} → 브랜치 생성 → 수정 → PR
                                    ↓
                              리뷰 → 머지 → evolution-log 기록
```

## 라이선스
MIT
