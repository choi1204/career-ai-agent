# /verify-resume

## 목적
이력서 초안의 모든 주장/수치를 원본 데이터와 대조하여 환각을 제거합니다.

## 서브에이전트
**career-fact-checker** (`.claude/agents/career-fact-checker.md`)
- 모델: sonnet (체계적 비교, 빠른 처리)
- 도구: Read, Grep, Glob, Bash (Write 권한 없음 — 소스 수정 불가)

## 입력
- outcome/1_draft/ 의 최신 파일 (또는 사용자 지정)
- src/user-profile.md
- src/projects/*.md
- src/evidence/

## 실행 절차

### Step 1: career-fact-checker 서브에이전트 호출
Task 도구로 `career-fact-checker` 서브에이전트를 실행합니다:
```
Task(subagent_type="career-fact-checker", prompt="""
대상 파일: {대상 이력서 경로}

1. scripts/extract-metrics.sh 실행하여 수치/주장 추출
2. scripts/check-evidence.sh 실행하여 프로그래매틱 대조
3. 추출된 각 항목을 소스와 대조하여 5단계 태그 부착:
   - src/evidence/ 파일과 대조 → ✅ VERIFIED
   - src/projects/*.md 에만 있음 → 📝 SELF_REPORTED
   - 어디에도 없음 → ⚠️ UNVERIFIED
   - 소스와 수치 불일치 → ❌ CONFLICT
   - 소스 대비 20% 이상 차이 → 🔍 EXAGGERATED
4. 검증 결과를 마크다운으로 반환
""")
```

### Step 2: 메인 세션이 결과 기록
- 서브에이전트 반환 결과를 `outcome/2_verify/`에 기록
- 수정 제안 (CONFLICT/EXAGGERATED 항목) 정리
- 출처 요청 목록 (UNVERIFIED 항목) 정리

## 출력
- outcome/2_verify/verify_v{N}_{YYYYMMDD_HHmmss}.md
  - 원문 + 각 문장별 검증 태그
  - 수정 제안 (CONFLICT/EXAGGERATED 항목)
  - 출처 요청 목록 (UNVERIFIED 항목)
  - 자동 검증 결과 (스크립트 실행 로그)

## 규칙
- CONFLICT 항목은 원본 수치와 초안 수치를 나란히 표시
- UNVERIFIED 항목은 삭제하지 않고 태그만 부착 + 사용자에게 출처 요청
- 사용자에게 "이 수치의 출처를 제공해주세요" 형태로 구체적 질문

## 제안 트리거
- UNVERIFIED 비율이 30% 이상이면:
  → "증거 자료가 부족합니다. src/evidence/ 가이드를 참고해서 추가해주세요"
- 특정 프로젝트의 수치가 전부 UNVERIFIED이면:
  → "/intake-project 로 해당 프로젝트를 다시 정리하면 검증률이 올라갑니다"
