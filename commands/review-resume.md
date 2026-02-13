# /review-resume

## 목적
팩트체크 통과한 이력서를 다관점에서 평가하고 개선 방향을 도출합니다.

## 서브에이전트 (병렬 3중 리뷰)
3개 서브에이전트를 **동시 실행**하여 다관점 리뷰를 수행합니다:

| 서브에이전트 | 관점 | 평가 내용 |
|-------------|------|----------|
| **career-resume-writer** | 문장 품질 | 가독성, 구조, STAR 프레임워크, Before/After |
| **career-fact-checker** | 검증 상태 | UNVERIFIED/CONFLICT 재확인, 수치 신뢰도 |
| **career-market-analyst** | JD 매칭 | JD 매칭률 분석 (JD 있을 때만 실행) |

## 입력
- outcome/2_verify/ 의 최신 파일
- src/jd/*.md (있으면 JD 기준 평가)
- config/scoring-rubric.md

## 실행 절차

### Step 1: 병렬 서브에이전트 호출
3개 서브에이전트를 **동시에** Task 도구로 호출합니다:

```
# 1) 문장 품질 리뷰
Task(subagent_type="career-resume-writer", prompt="""
리뷰 모드로 실행합니다.
대상 파일: {이력서 경로}
config/scoring-rubric.md 기준으로 평가:
- 첫인상 (10초 스캔), 임팩트, 기술 깊이, 가독성
- 항목별 A/B/C/D 등급 + Before/After 예시
""")

# 2) 검증 상태 재확인
Task(subagent_type="career-fact-checker", prompt="""
대상 파일: {이력서 경로}
scripts/check-evidence.sh 실행하여 검증 상태 재확인
UNVERIFIED/CONFLICT 항목 현황 보고
""")

# 3) JD 매칭 분석 (JD 있을 때만)
Task(subagent_type="career-market-analyst", prompt="""
대상 이력서: {이력서 경로}
타깃 JD: src/jd/*.md
JD 요구사항별 매칭 점수표 + 갭 분석
""")
```

### Step 2: 통합 리뷰 리포트 작성
메인 세션이 3개 결과를 통합하여 최종 리뷰 리포트를 생성합니다:
- 문장 품질 평가 (career-resume-writer 결과)
- 검증 상태 요약 (career-fact-checker 결과)
- JD 매칭 분석 (career-market-analyst 결과, 있을 때)
- 종합 등급 + 우선 개선 항목 Top 5

## 출력
- outcome/3_review/review_v{N}_{YYYYMMDD_HHmmss}.md

## 규칙
- 추상적 피드백 금지 ("더 구체적으로" 같은 피드백은 불가)
- 모든 피드백에 Before → After 예시 필수
- 평가는 보수적으로 (A 등급 남발 금지)

## 제안 트리거
- 특정 프로젝트의 기술 깊이가 부족하면:
  → "/mock-interview 로 해당 프로젝트를 심층 질문하면 숨겨진 임팩트를 발굴할 수 있습니다"
- 전체적으로 C 등급 이하면:
  → "user-profile.md 의 프로젝트 설명을 보강하는 것이 우선입니다"
