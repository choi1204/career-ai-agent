# /refine-resume

## 목적
리뷰 결과를 반영하여 최종 이력서를 생성합니다.

## 서브에이전트
**career-resume-writer** (`.claude/agents/career-resume-writer.md`) — 최종본 작성
**career-fact-checker** (`.claude/agents/career-fact-checker.md`) — 자동 최종 검증

## 입력
- outcome/3_review/ 의 최신 파일
- outcome/1_draft/ 의 모든 버전 (장점 결합용)
- src/jd/*.md

## 실행 절차

### Step 1: career-resume-writer로 최종본 생성
```
Task(subagent_type="career-resume-writer", prompt="""
최종 이력서를 생성합니다.

1. outcome/3_review/ 최신 리뷰 결과 읽기
2. outcome/1_draft/ 의 모든 버전에서 가장 효과적인 표현 선별
3. 리뷰 개선 사항 반영
4. UNVERIFIED 수치 → 정성적 표현으로 대체
5. outcome/4_refine/final_v{N}_{timestamp}.md에 저장
""")
```

### Step 2: 자동 최종 검증 (career-fact-checker)
최종본 생성이 완료되면 **자동으로** 검증을 수행합니다.
사용자가 별도로 `/verify-resume`를 실행할 필요 없습니다.

```
Task(subagent_type="career-fact-checker", prompt="""
대상 파일: {Step 1에서 생성된 최종본 경로}

1. scripts/validate-resume.sh 실행 → UNVERIFIED/CONFLICT/EXAGGERATED 잔존 확인
2. scripts/validate-evidence-refs.sh 실행 → evidence 참조 파일 존재 확인
3. scripts/check-evidence.sh 실행 → 수치 최종 대조
4. 검증 결과 반환
""")
```

### Step 3: 검증 결과 통합
- 최종본 하단에 "검증 상태 요약" 섹션 자동 첨부
- UNVERIFIED/CONFLICT 잔존 시 사용자에게 경고
- 모든 검증 통과 시 "커밋 가능" 상태 표시

## 출력
- outcome/4_refine/final_v{N}_{YYYYMMDD_HHmmss}.md
  - 최종 이력서 본문
  - "검증 상태 요약" 섹션 (자동 첨부)
  - "남은 검증 필요 항목" 섹션 (있는 경우)
  - "user-profile.md 업데이트 제안" 섹션

## 규칙
- UNVERIFIED 수치는 최종본에서 수치 형태로 사용 불가
  → "거래액 54.3% 증가" → "거래액 대폭 증가 [수치 확인 필요]"
- VERIFIED + SELF_REPORTED 수치만 이력서에 그대로 사용
- 최종본 하단에 "이 이력서의 검증 상태" 요약 포함

## 제안 트리거
- 최종본 완성 후:
  → "/update-profile 로 이번 작업에서 발견된 인사이트를 프로필에 반영하세요"
- JD별 커스텀이 필요하면:
  → "다른 포지션용 이력서가 필요하면 src/jd/에 JD를 추가하고 /draft-resume를 다시 실행하세요"
