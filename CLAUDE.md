# Career AI Agent

멀티 에이전트 기반 커리어 관리 시스템입니다.

## 프로젝트 구조
- `src/` — 사용자의 경력 데이터 (Source of Truth)
- `commands/` — 실행 가능한 커맨드 (플러그인)
- `outcome/` — 작업 산출물 (버전 누적)
- `config/` — 에이전트 역할, 검증 규칙, 평가 기준
- `scripts/` — 코드 기반 검증 훅
- `templates/` — 각종 템플릿

## 시작하기
1. `src/user-profile.md`를 읽어 사용자 컨텍스트를 파악하세요.
2. 사용 가능한 커맨드는 `commands/` 폴더를 확인하세요.
3. 커맨드 실행 시 해당 .md 파일의 지침을 따르세요.

## 핵심 원칙

### 원칙 1: 근거 기반 기록 (Traceable by Default)
- 이력서에 수치를 기재할 때 → 반드시 출처 경로를 함께 기록
  - 출처 있음: `[evidence: {파일경로}]`
  - 출처 없음: `[UNVERIFIED: 출처 필요]`
- 기술적 주장 → 관련 PR/커밋/문서 링크
- outcome/ 의 모든 파일에 "참조한 소스 파일 목록" 섹션 포함

### 원칙 2: 능동적 제안 (Proactive Suggestion)
- 커맨드 실행 중 개선 기회를 발견하면 작업 결과 하단에 "제안사항" 섹션 추가
- 반복 패턴 발견 시 → 커맨드화 제안
- 새로운 요구가 반복될 가능성이 있으면 → 스킬 내재화 제안
- **Hook 강제**: outcome/ 산출물 Write/Edit 시 `post-write-suggestion-check.sh`가 "제안" 섹션 포함 여부를 자동 체크하여 리마인더 제공

### 원칙 3: 코드 기반 검증 (Programmatic Verification)
- **Claude Code Hooks** (`.claude/settings.json`)로 프롬프트가 아닌 코드 레벨 강제:
  - `outcome/` 파일 Write 후 → 검증 스크립트 **자동 실행** (AI 의지와 무관)
  - `outcome/` 파일명 규칙 → Write 후 **자동 검증**
  - `src/user-profile.md` 수정 전 → **자동 백업** 생성
  - `git commit` → 이슈 번호 (#N) 없으면 **차단**
  - `git push origin main` → **차단** (PR 통해서만 반영)
- scripts/ 의 훅으로 수치 추출 → 증거 대조 → 자동 플래그
- git pre-commit hook으로 검증 안 된 이력서 커밋 차단

### 원칙 4: 자기 발전 시스템 (Self-Evolving)
- config/evolution-log.md에 시스템 개선 이력 기록
- 커맨드 지침 부족 발견 시 → 업데이트 제안
- user-profile.md 지속 개선 제안

## 산출물 파일명 규칙
- `{type}_v{N}_{YYYYMMDD_HHmmss}.md`
- 기존 파일 덮어쓰기 금지, 항상 새 버전 생성

## 서브에이전트
`.claude/agents/`에 5개 커스텀 에이전트가 있습니다. Task 도구의 `subagent_type`으로 호출합니다.

| 에이전트 | 모델 | 역할 | 특수 권한 |
|---------|------|------|----------|
| career-resume-writer | opus | 이력서 작성 (STAR) | Write |
| career-fact-checker | sonnet | 수치/주장 검증 | Bash (Write 없음) |
| career-interview-coach | opus | 면접+코딩테스트 | Write |
| career-market-analyst | sonnet | 시장 분석/기업 리서치 | WebSearch, WebFetch |
| career-capability-assessor | opus | 7차원 역량 평가 | Write |

## 커맨드 목록

### 이력서 파이프라인
| 커맨드 | 설명 | 서브에이전트 |
|--------|------|------------|
| `/draft-resume` | 초안 생성 + **자동 팩트체크** | resume-writer → fact-checker |
| `/verify-resume` | 팩트체크 재실행 (수동) | career-fact-checker |
| `/review-resume` | 다관점 리뷰 (병렬 3중) | resume-writer + fact-checker + market-analyst |
| `/refine-resume` | 최종본 생성 + **자동 검증** | resume-writer → fact-checker |
| `/pipeline-resume` | 초안→검증→리뷰→수정 자동화 | 전체 파이프라인 |
| `/multi-review` | HR+Tech Lead+Culture Fit 동시 리뷰 | 3에이전트 병렬 |

### 면접 & 코딩테스트
| 커맨드 | 설명 | 서브에이전트 |
|--------|------|------------|
| `/mock-interview` | 기술 면접 시뮬레이션 (L1~L5) | career-interview-coach |
| `/coding-test` | 코딩테스트 연습/모의시험/취약분석 | career-interview-coach |

### 역량 평가 & 분석
| 커맨드 | 설명 | 서브에이전트 |
|--------|------|------------|
| `/assess-capability` | 종합 역량 평가 (강점/약점 + 로드맵) | haiku(수집) → capability-assessor |
| `/analyze-jd` | 채용공고 분석 + 매칭률 | career-market-analyst |
| `/batch-analyze-jd` | 복수 JD 병렬 분석 + 비교 매트릭스 | career-market-analyst × N |
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

## 개선 워크플로우
모든 시스템 개선은 아래 흐름을 따릅니다:
1. 문제/아이디어 발견 → `/report-issue` → GitHub Issue 생성
2. 수정 착수 → `/fix-issue {번호}` → 브랜치 생성
3. 수정 완료 → PR 생성 → 리뷰 → main에 머지
4. config/evolution-log.md에 기록
