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

---
<!-- 이후 시스템 개선 시 아래에 기록 추가 -->
