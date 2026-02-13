# 시스템 진화 기록

## v1.0 — 초기 세팅
- 날짜: 2026-02-13
- 커맨드: draft-resume, verify-resume, review-resume, refine-resume,
          intake-project, mock-interview, analyze-jd, research-company,
          update-profile, create-command
- 검증: extract-metrics.sh, check-evidence.sh, validate-resume.sh
- 에이전트: Resume Writer, Fact Checker, Interview Coach, Market Analyst, Career Advisor

## v1.1 — 역량 평가 + 코딩테스트 + GitHub 워크플로우
- 날짜: 2026-02-13
- 추가 커맨드: assess-capability, coding-test, report-issue, fix-issue
- 추가 에이전트: Capability Assessor, Coding Coach
- 추가 설정: capability-dimensions.md, coding-test-categories.md
- 추가 템플릿: capability-assessment-template.md
- 변경: GitHub Issues 기반 개선 워크플로우 도입 (Issue → Branch → PR → Merge)

## v2.0 — 실제 서브에이전트 아키텍처
- 날짜: 2026-02-13
- 변경 유형: 아키텍처 대폭 개편

### 추가: 커스텀 에이전트 5개
- `.claude/agents/career-fact-checker.md` (sonnet, Write 권한 없음)
- `.claude/agents/career-resume-writer.md` (opus)
- `.claude/agents/career-interview-coach.md` (opus, 면접+코딩 통합)
- `.claude/agents/career-market-analyst.md` (sonnet, WebSearch/WebFetch)
- `.claude/agents/career-capability-assessor.md` (opus, 역량평가+어드바이저 통합)

### 수정: 기존 커맨드 6개 서브에이전트 연동
- `commands/verify-resume.md` → career-fact-checker 호출
- `commands/review-resume.md` → 병렬 3중 리뷰 (resume-writer + fact-checker + market-analyst)
- `commands/assess-capability.md` → haiku 데이터수집 → career-capability-assessor 분석
- `commands/research-company.md` → career-market-analyst (WebSearch)
- `commands/draft-resume.md` → career-resume-writer 호출
- `commands/mock-interview.md`, `commands/coding-test.md` → career-interview-coach 연동

### 추가: 새 커맨드 3개
- `commands/pipeline-resume.md` — 이력서 전체 파이프라인 자동화
- `commands/batch-analyze-jd.md` — 복수 JD 병렬 분석 + 비교 매트릭스
- `commands/multi-review.md` — 3관점 동시 리뷰 (HR + Tech Lead + Culture Fit)

### 추가: 검증 스크립트 2개
- `scripts/validate-evidence-refs.sh` — evidence 참조 파일 존재 검증
- `scripts/validate-coding-log.sh` — 코딩테스트 로그 형식 검증

### 수정: pre-commit hook 강화
- evidence 참조 검증 추가
- 코딩테스트 로그 형식 검증 추가
- outcome/4_final/ 디렉토리 지원 추가

## v2.1 — Claude Code Hooks + Git 워크플로우 강제화
- 날짜: 2026-02-13
- 변경 유형: 프롬프트 기반 → 코드 기반 강제화

### 추가: Claude Code Hooks 5개 (`.claude/hooks/`)
- `post-write-outcome.sh` — outcome/ 파일 Write 후 자동 검증 스크립트 실행
- `validate-outcome-filename.sh` — outcome/ 파일명 규칙 자동 검증
- `pre-git-commit.sh` — 커밋 메시지에 이슈 번호 (#N) 없으면 차단
- `pre-git-push.sh` — main 브랜치 직접 push 차단 (PR 필수)
- `pre-edit-profile.sh` — user-profile.md 수정 전 자동 백업

### 추가: `.claude/settings.json`
- PreToolUse / PostToolUse 이벤트에 hook 연결

### 수정: `/draft-resume`, `/refine-resume`
- 자동 팩트체크가 Hook으로 강제 (프롬프트 의존 제거)

### 수정: Git 워크플로우 강제화
- Issue → Branch → Commit(#N) → PR → Merge 흐름 코드로 강제

## v2.2 — 잔여 개선 + 제안 시스템 Hook 강제화
- 날짜: 2026-02-13
- 변경 유형: 완성도 향상 + 제안 시스템 코드 강제화

### 수정: `/analyze-jd` 서브에이전트 연동
- career-market-analyst 서브에이전트 호출로 변경 (WebSearch 활용 가능)

### 수정: 5개 커맨드 역할 참조 통일
- update-profile, create-command, intake-project, report-issue, fix-issue
- `에이전트 역할: config/agent-roles.md → Career Advisor` → `실행 주체: 메인 세션` 형식으로 통일

### 수정: PostToolUse Hook matcher 확장
- `Write` → `Write|Edit`로 확장 (Edit으로 outcome/ 수정 시에도 검증 적용)

### 추가: 제안 시스템 Hook
- `.claude/hooks/post-write-suggestion-check.sh` — outcome/ 산출물에 "제안" 섹션 포함 여부 체크
- 차단 아닌 리마인더 방식 (파이프라인 호환)
- 검사 대상: outcome/1_draft, 3_review, 4_refine, 4_final, analysis, assessment
- 검사 제외: outcome/2_verify (중간 산출물), learning (누적 데이터)

### 수정: README.md
- Claude Code Hooks 아키텍처 다이어그램 추가
- refine-resume 서브에이전트 정보 정정
- analyze-jd 서브에이전트 정보 추가
- "다른 프로젝트에 재사용 가능한 Hooks" 섹션 추가

### 수정: CLAUDE.md
- 원칙 2(능동적 제안)에 Hook 강제 설명 추가
- analyze-jd 서브에이전트 정보 정정

### 참고: 플러그인 분리 검토
- 제안 시스템을 별도 플러그인으로 분리하지 않기로 결정
- 이유: 제안 트리거의 95%가 도메인 특화, 범용 인프라 규모 부족
- session-wrap 플러그인(team-attention/plugins-for-claude-natives) 패턴 분석 완료

## v3.0 — GitHub 기반 기술적 깊이 추출 시스템
- 날짜: 2026-02-13
- 변경 유형: 새 기능 추가

### 배경
- 이력서 면접 피드백: "질문할게 없다", "기술적인 게 없다", "아하 모먼트가 없다"
- 핵심 원인: 코드가 아닌 기억에 의존한 이력서 → 기술적 디테일 누락
- 해결: GitHub 코드 히스토리에서 기술적 디테일을 추출하여 프로젝트 파일 보강

### 추가: 커스텀 에이전트 1개
- `.claude/agents/career-github-analyzer.md` (sonnet, Bash, Write 없음)
- `gh` CLI로 PR/커밋/리뷰 추출 → 기술적 패턴 분류 → 기존 프로젝트 매핑

### 추가: 커맨드 2개 (트리거 역할)
- `.claude/commands/extract-github.md` — GitHub PR/커밋 기술적 분석
- `.claude/commands/enrich-project.md` — 인터뷰 기반 프로젝트 기술적 깊이 보강

### 추가: 스크립트 1개
- `scripts/extract-github-prs.sh` — gh CLI PR 목록 추출 유틸리티

### 추가: 설정 1개
- `config/technical-depth-checklist.md` — L1~L5 기술적 깊이 체크리스트 + 아하 모먼트 패턴

### 수정: CLAUDE.md
- 서브에이전트 테이블에 career-github-analyzer 추가
- 데이터 보강 커맨드 섹션 추가
- commands/ 경로를 .claude/commands/로 정정

---
<!-- 이후 시스템 개선 시 아래에 기록 추가 -->
