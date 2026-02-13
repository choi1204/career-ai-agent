# /enrich-project

## 목적
인터뷰 기반으로 기존 프로젝트 파일의 기술적 깊이를 L4~L5 수준으로 보강합니다.
면접관이 "더 깊이 물어보고 싶다"고 느끼는 수준이 목표입니다.

## 사용법
```
/enrich-project {프로젝트 파일명 또는 번호}
```
예: `/enrich-project 04-guaranteed-banner` 또는 `/enrich-project 04`

## 실행
1. 대상 `src/projects/*.md` 읽고 현재 기술적 깊이 L1~L5 진단
2. `outcome/analysis/github_*.md` 로드 (있으면, /extract-github 결과)
3. AskUserQuestion으로 기술적 깊이 인터뷰 (5~8개 질문)
   - GitHub PR 데이터가 있으면 PR 기반 구체적 질문
   - 없으면 프로젝트 파일 기반 질문
4. career-resume-writer 서브에이전트로 프로젝트 파일 보강
5. Before/After 비교 제시

## 인터뷰 흐름
`config/technical-depth-checklist.md`의 L1~L5 기준에 따라:

1. **핵심 의사결정** (L2→L3): "처음부터 이 방식이었나? 다른 시도는?"
2. **시행착오** (L3→L4): "가장 어려웠던 기술적 문제와 해결 과정은?"
3. **제약 조건** (L4): "시간/리소스 제약으로 포기한 것은?"
4. **수치/측정** (Result 보강): "이 수치는 어떤 도구로 측정했나?"
5. **회고** (L5): "트래픽 10배면 어디가 먼저 문제될까?"

## 서브에이전트
**career-resume-writer** — 인터뷰 결과 기반 프로젝트 파일 보강 (기존 내용 삭제 금지, 추가/보강만)
