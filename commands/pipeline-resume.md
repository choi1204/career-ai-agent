# /pipeline-resume

## 목적
이력서 작성부터 검증, 리뷰, 수정까지 전체 파이프라인을 1커맨드로 자동화합니다.
기존 `/draft-resume → /verify-resume → /review-resume → /refine-resume` 4단계를 자동 실행합니다.

## 서브에이전트 파이프라인

```
career-resume-writer (초안)
  → career-fact-checker (검증)  [병렬: career-market-analyst (JD 매칭)]
  → 사용자 피드백 수신
  → career-resume-writer (수정본)
  → career-fact-checker (최종 검증)
```

## 입력
- src/user-profile.md (필수)
- src/projects/*.md (프로젝트 데이터)
- src/jd/*.md (타깃 JD, 있으면)

## 실행 절차

### Stage 1: 초안 생성
career-resume-writer 서브에이전트 호출:
```
Task(subagent_type="career-resume-writer", prompt="""
이력서 초안 3버전 생성 (Version A/B/C)
src/user-profile.md, src/projects/*.md, src/jd/*.md 참조
모든 수치에 evidence 태그 부착
outcome/1_draft/ 에 저장
""")
```

### Stage 2: 검증 + JD 매칭 (병렬)
2개 서브에이전트를 **동시 실행**:
```
# 팩트체크
Task(subagent_type="career-fact-checker", prompt="""
Stage 1 초안을 검증합니다.
scripts/extract-metrics.sh, scripts/check-evidence.sh 실행
5단계 태그 부착
""")

# JD 매칭 (JD 있을 때만)
Task(subagent_type="career-market-analyst", prompt="""
Stage 1 초안과 src/jd/*.md 매칭 분석
요구사항별 충족/미충족 분류
매칭률 산출
""")
```

### Stage 3: 사용자 피드백
- Stage 1~2 결과를 사용자에게 제시
- 버전 선택 (A/B/C)
- 추가 수정 요청 수집
- 선호도/톤 피드백

### Stage 4: 수정본 생성
career-resume-writer로 피드백 반영:
```
Task(subagent_type="career-resume-writer", prompt="""
선택된 버전: {사용자 선택}
사용자 피드백: {피드백 내용}
검증 결과: {CONFLICT/EXAGGERATED 수정사항}
JD 매칭 결과: {갭 보완 필요 항목}

피드백 반영하여 최종본 생성
UNVERIFIED 수치 → 정성적 표현으로 교체
outcome/4_final/ 에 저장
""")
```

### Stage 5: 최종 검증
career-fact-checker로 최종 검증:
```
Task(subagent_type="career-fact-checker", prompt="""
최종본 검증
scripts/validate-resume.sh 실행
UNVERIFIED/CONFLICT 잔존 여부 확인
""")
```

## 출력
- outcome/1_draft/draft_v{N}_{timestamp}.md (초안)
- outcome/2_verify/verify_v{N}_{timestamp}.md (검증 결과)
- outcome/3_review/review_v{N}_{timestamp}.md (리뷰 결과)
- outcome/4_final/resume_v{N}_{timestamp}.md (최종본)

## 규칙
- Stage 3에서 반드시 사용자 피드백을 기다림 (자동 스킵 불가)
- 최종본에 UNVERIFIED/CONFLICT 태그가 남아있으면 경고 표시
- 모든 Stage 결과를 개별 파일로 기록 (추적 가능)

## 제안 트리거
- 파이프라인 완료 후:
  → "최종본을 GitHub에 커밋할까요?"
- evidence/ 부족으로 검증률이 낮으면:
  → "src/evidence/에 증거 자료를 추가하면 다음 파이프라인 실행 시 검증률이 올라갑니다"
- 최종 검증 통과 시:
  → "/assess-capability 로 이력서 기반 종합 역량도 평가해보세요"
