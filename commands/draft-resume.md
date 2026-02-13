# /draft-resume

## 목적
사용자의 경력 데이터와 타깃 JD 기반으로 이력서 초안 3가지 버전을 생성합니다.

## 서브에이전트
**career-resume-writer** (`.claude/agents/career-resume-writer.md`)
- 모델: opus (뉘앙스 있는 글쓰기, 톤 컨트롤)
- 도구: Read, Grep, Glob, Write

## 입력
- src/user-profile.md (필수)
- src/projects/*.md (있으면 참조)
- src/jd/*.md (있으면 타깃 맞춤, 없으면 범용)

## 실행 절차

### Step 1: career-resume-writer 서브에이전트 호출
```
Task(subagent_type="career-resume-writer", prompt="""
이력서 초안 3버전을 생성합니다.

1. src/user-profile.md 읽기
2. src/projects/*.md 전체 읽기
3. src/jd/*.md 타깃 JD 분석 (있으면)
4. config/scoring-rubric.md 자가 점검 기준 참조
5. 3가지 버전 생성:
   - Version A: 비즈니스 임팩트/성과 중심
   - Version B: 기술적 깊이/아키텍처 중심
   - Version C: A+B 균형형
6. 각 수치마다 출처 태그 부착
7. outcome/1_draft/draft_v{N}_{timestamp}.md에 저장
""")
```

### Step 2: 메인 세션이 검증 훅 실행
- `scripts/extract-metrics.sh` 실행하여 수치 목록 추출
- 수치 목록을 출력 파일 하단 "추출된 수치 목록" 섹션에 첨부

## 출력
- outcome/1_draft/draft_v{N}_{YYYYMMDD_HHmmss}.md
- 3개 버전을 하나의 파일에 구분하여 저장

## 규칙
- src/user-profile.md에 없는 경력/프로젝트를 생성하지 않음
- src/evidence/에서 확인 가능한 수치만 `[evidence: ...]` 태그
- 확인 불가 수치는 `[UNVERIFIED: 출처 필요]` 태그
- JD가 있으면 JD 요구사항과 매칭되는 경험을 우선 배치

## 제안 트리거
- user-profile.md에 프로젝트 설명이 부족하면:
  → "/intake-project 로 프로젝트 상세를 먼저 등록하면 이력서 품질이 올라갑니다"
- evidence/ 가 비어있으면:
  → "성과 수치의 출처(대시보드 캡처, 보고서 등)를 evidence/에 추가하면 팩트체크 통과율이 올라갑니다"
- JD가 없으면:
  → "src/jd/에 타깃 채용공고를 추가하면 맞춤형 이력서를 만들 수 있습니다"
